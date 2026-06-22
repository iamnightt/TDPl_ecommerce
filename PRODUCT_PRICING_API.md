# Product API — Fields & MOQ-Based Rate Calculation

> Reference doc for the Flutter app team.
> Describes (1) what the Product Detail API returns, (2) the live "price by quantity" API,
> and (3) exactly how the per-unit rate and total are calculated from MOQ / SKU / bulk fields.
>
> Source of truth in code:
> - Detail response: `app/Http/Resources/V2/ProductDetailCollection.php`
> - Price-by-qty (API): `app/Http/Controllers/Api/V2/ProductController.php@getPrice`
> - Price-by-qty (Web, authoritative tier logic): `app/Http/Controllers/HomeController.php@variant_price`
> - Pricing helpers: `app/Http/Helpers.php`

---

## 1. Endpoints

| Purpose | Method & Path | Controller |
|---|---|---|
| Product detail (single product) | `GET api/v2/products/{slug}` (detail collection) | `ProductDetailCollection` |
| **Live price for a chosen quantity/variant** | `POST api/v2/products/variant/price` | `ProductController@getPrice` |
| (Web equivalent — newer 3-tier logic) | `POST /product/variant-price` | `HomeController@variant_price` |

> ⚠️ **Critical:** the mobile API (`getPrice`) currently uses an **older 2-tier** formula
> (base vs bulk). The website uses a **newer 3-tier** formula (SKU / MOQ / Bulk) that also
> uses `sku_qty` and `sku_rate`. See **§5** before implementing. Decide with the backend
> owner which one the app must match. This doc documents both.

---

## 2. Product Detail API — returned fields

From `ProductDetailCollection::toArray()`. Envelope:

```json
{
  "success": true,
  "status": 200,
  "data": [ { ...product... } ]
}
```

### Product object fields

| Field | Type | Meaning |
|---|---|---|
| `id` | int | Product id |
| `name` | string | Translated product name |
| `added_by` | string | `"admin"` (in-house) or `"seller"` |
| `seller_id` | int | Owner user id |
| `shop_id` / `shop_slug` / `shop_name` / `shop_logo` | mixed | Shop info (0/empty when in-house) |
| `photos` | array | `[{ "variant": "", "path": "<url>" }]` — general + per-variant images |
| `thumbnail_image` | string(url) | Thumbnail |
| `tags` | string[] | Tags |
| `price_high_low` | string | Display string, e.g. `"From $10 to $25"` or single price |
| `choice_options` | array | `[{ "name": <attribute_id>, "title": "<attr name>", "options": [..] }]` |
| `colors` | array | Color hex codes (e.g. `"#ff0000"`) |
| `has_discount` | bool | `true` when base price ≠ discounted price |
| `discount` | string | e.g. `"-15%"` |
| `stroked_price` | string | Original (pre-discount) base price, formatted |
| `main_price` | string | **Discounted MOQ unit price**, formatted (see §4) |
| `min_qty_price` | string | **Bulk unit price** (per-unit at/above `min_qty`), formatted |
| `calculable_price` | float | Raw numeric discounted base price (for math, 2dp) |
| `currency_symbol` | string | Currency symbol |
| `current_stock` | int | Qty of first stock row |
| `unit` | string | Unit label (pcs, kg, …) |
| `rating` / `rating_count` | float/int | Rating |
| `earn_point` | float | Club points earned |
| `description` | string | HTML description |
| `downloads` | string\|null | PDF url |
| `video_link` | string | Video url |
| `brand` | object | `{ id, slug, name, logo }` |
| `link` | string | Web product url |
| `wholesale` | array | Wholesale tiers (only if `wholesale` addon active) — see §6 |
| `est_shipping_time` | int | Estimated shipping days |
| `stock_manage` | int(0/1) | Whether stock is tracked/limited |
| `min_moq` | int | **Minimum order quantity** (default qty + MOQ step) |

> ⚠️ The detail response does **NOT** include `sku_qty`, `sku_rate`, or `min_qty` directly.
> The Flutter UI needs these for the quantity stepper and tier math. Either:
> - rely entirely on the price endpoint (§3) to return the correct rate per quantity, **or**
> - request the backend to add `sku_qty`, `sku_rate`, `min_qty` to the detail response.

---

## 3. Price-by-Quantity API — `POST products/variant/price`

Call this **every time** the user changes quantity, color, or any choice option.

### Request body

| Param | Required | Notes |
|---|---|---|
| `slug` | yes | Product slug |
| `quantity` | yes | Chosen quantity (default 1) |
| `color` | optional | Color **hex without `#`** (API resolves to color name) |
| `variants` | optional | Comma-separated attribute values (e.g. `"Red,XL"`) |

### Response (`getPrice`)

```json
{
  "result": true,
  "data": {
    "price":        "<total = unit_price * quantity, formatted>",
    "unit_price":   "<per-unit rate for the active tier, formatted>",
    "stock":        <int qty>,
    "stock_txt":    "<int or 'In Stock'/'Out Of Stock'>",
    "digital":      0,
    "variant":      "<variant key>",
    "variation":    "<variant key>",
    "max_limit":    <int qty>,
    "in_stock":     0,
    "image":        "<variant image url or ''>",
    "stock_manage": 0,
    "min_moq":      <int>
  }
}
```

### How `getPrice` computes the rate (current API — **2-tier**)

```
1. base = product_stock.price        // for the matched variant row
2. if wholesale_product:
       base = wholesalePrices.where(max_qty >= quantity).first().price
3. apply discount to base   (percent or amount, only within discount date window)
4. apply taxes to base      (percent and/or amount, summed)

5. unit_price = (quantity >= min_qty  AND  min_qty_price != 0)
                  ? min_qty_price        // BULK tier
                  : base                 // base/MOQ tier
6. price (total) = unit_price * quantity
```

There is **no SKU tier** here. `sku_rate` / `sku_qty` are ignored by the current API.

---

## 4. How rates are calculated — the MOQ tier model (Web / authoritative)

The website (`HomeController@variant_price`) uses **three quantity tiers**. This is the
intended/full behaviour to replicate.

### Fields involved

| Field (on `products`) | Role |
|---|---|
| `sku_qty` | Smallest sellable unit (floor; usually 1) |
| `sku_rate` | Per-unit price when `quantity < min_moq` (loose/single price) |
| `min_moq` | Normal Minimum Order Quantity (default qty, and step size) |
| `unit_price` | Per-unit price at the normal MOQ tier (non-variant products) |
| `min_qty` | Quantity threshold where **bulk** pricing starts |
| `min_qty_price` | Per-unit **bulk** price at/above `min_qty` |
| `variant_product` | If true, base price = matched `product_stock.price` instead of `unit_price` |
| `wholesale_product` | If true, base price overridden by wholesale tier (§6) |

### Step A — resolve the base MOQ price

```
base = variant_product ? product_stock.price : unit_price
if wholesale_product:
    base = wholesalePrices.where(max_qty >= quantity).first().price
```

### Step B — apply discount + tax to `base`

Discount applies only if `discount_start_date` is null OR now is within
[`discount_start_date`, `discount_end_date`]:

```
if discount_type == 'percent':  base -= base * discount / 100
if discount_type == 'amount' :  base -= discount

tax = sum over product.taxes of:
        percent -> base * tax / 100
        amount  -> tax
base += tax
min_qty_price += tax        // bulk price gets tax added (NOT discount)
```

> Note the asymmetry (must be matched exactly):
> - `base` (MOQ tier) → discount **and** tax applied.
> - `min_qty_price` (bulk tier) → **tax only**, no discount.
> - `sku_rate` (SKU tier) → **neither** discount nor tax applied.

### Step C — pick the active tier by quantity

```
sku_tier_active  = (quantity <  min_moq)  AND (sku_rate > 0)
bulk_tier_active = (quantity >= min_qty)  AND (min_qty_price != 0)

if sku_tier_active:        unit_rate = sku_rate          ; tier = "sku"
elif bulk_tier_active:     unit_rate = min_qty_price     ; tier = "bulk"
else:                      unit_rate = base              ; tier = "moq"
```

### Step D — total

```
total = unit_rate * quantity
```

### Web response (`variant_price`)

```json
{
  "price":              "<total, formatted>",
  "unit_rate":          "<per-unit for active tier, formatted>",
  "active_tier":        "sku | moq | bulk",
  "quantity":           "<stock qty or 'In Stock'/'Out Of Stock'>",
  "max_limit":          <stock qty>,
  "in_stock":           0,
  "min_qty_price":      "<formatted, tax-added>",
  "min_qty_price_true": false,   // == bulk_tier_active
  "sku_tier_active":    false,
  "sku_rate":           "<formatted>",
  "stock_manage":       0,
  "digital":            0,
  "variation":          "<variant key>"
}
```

### Worked example

Product: `sku_qty=1`, `sku_rate=120`, `min_moq=10`, `unit_price=100`,
`min_qty=50`, `min_qty_price=85`. (no discount/tax for simplicity)

| Quantity | Tier | Unit rate | Total |
|---|---|---|---|
| 1–9 | SKU | 120 | qty × 120 |
| 10–49 | MOQ | 100 | qty × 100 |
| 50+ | BULK | 85 | qty × 85 |

Cheaper per-unit the more you buy; SKU (buying below MOQ) is the most expensive per unit.

---

## 5. Quantity stepper rules (client-side) — replicate in Flutter

The qty selector does **not** increment by 1. Using `sku_qty` and `min_moq`:

- **Initial value:** `min_moq`.
- **Minus:**
  - if `current > min_moq` → `current - min_moq`
  - if `current == min_moq` and `sku_qty < min_moq` → drop to `sku_qty`
  - disabled when `current <= sku_qty`
- **Plus:**
  - if `current < min_moq` (sitting at SKU floor) → jump to `min_moq`
  - else → `current + min_moq`
  - if `stock_manage == 1`, cap at available stock (`max_limit`)

Effective ladder: `sku_qty → min_moq → min_moq*2 → …`, with `min_qty` being the
bulk threshold somewhere on that ladder. Call the price endpoint after every change.

---

## 6. Wholesale products

If `wholesale_product == 1`, the base per-unit price comes from a wholesale tier table
**before** discount/tax. Each tier: `{ min_qty, max_qty, price }`. The chosen tier is the
first whose `max_qty >= quantity`. Detail API returns these under `wholesale` (when the
`wholesale` addon is active).

```
wholesale: [
  { "min_qty": 1,  "max_qty": 9,  "price": "..." },
  { "min_qty": 10, "max_qty": 49, "price": "..." },
  ...
]
```

---

## 7. Stock / availability flags

- `max_limit` / `stock` / `current_stock` → available quantity for the variant.
- `in_stock` (0/1) → whether it can be added to cart.
- `stock_manage` (0/1) → whether stock is limited (caps the Plus button & max).
- `stock_txt` → `"In Stock"` / `"Out Of Stock"` when `stock_visibility_state == 'text'`.
- When `in_stock == 0 && digital == 0 && stock_manage == 1` → show "Out of Stock",
  hide Add-to-cart / Buy-now.

---

## 8. Summary checklist for Flutter

1. Load product via detail API → read `min_moq`, `main_price`, `min_qty_price`,
   `current_stock`, `stock_manage`, `colors`, `choice_options`, `wholesale`.
2. Get `sku_qty` / `sku_rate` / `min_qty` (request backend to expose them, or rely on the
   price endpoint's `unit_rate`/`active_tier`).
3. Render qty stepper using the ladder in §5.
4. On every qty/color/option change → `POST products/variant/price`.
5. Show `unit_rate` (per-unit for the active tier) and `price` (line total); update stock UI.
6. ⚠️ Confirm whether to mirror **3-tier (web)** or **2-tier (current API)** pricing — they
   differ when `sku_rate`/`sku_qty` are set.
