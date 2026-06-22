/// MOQ / SKU / Bulk pricing + quantity-stepper helper.
///
/// Mirrors the logic documented in `PRODUCT_PRICING_API.md` (generated from the
/// web app). The authoritative per-unit rate and line total still come from the
/// backend `POST products/variant/price` endpoint (`unit_price` + `price`),
/// because `sku_rate` / `min_qty` are not exposed to the client. What this
/// helper owns is the purely client-side behaviour that the server cannot do:
///
///   * the quantity-stepper ladder (§5), and
///   * resolving the active tier label (§4 Step C) when the raw tier fields are
///     available (future-proof; falls back gracefully when they are null).
///
/// Effective ladder: `sku_qty -> min_moq -> min_moq*2 -> ...`, with `min_qty`
/// being the bulk threshold somewhere on that ladder.
class MoqPricing {
  /// Smallest sellable unit (floor). Usually 1. Never larger than [minMoq].
  static int effectiveSkuQty(dynamic skuQty, int minMoq) {
    final int q = _toInt(skuQty, fallback: 1);
    final int floor = q > 0 ? q : 1;
    // The SKU floor cannot be above the MOQ step, otherwise the ladder breaks.
    return floor > minMoq && minMoq > 0 ? minMoq : floor;
  }

  /// Normal Minimum Order Quantity / step size. Defaults to 1 when unset.
  static int effectiveMinMoq(dynamic minMoq) {
    final int m = _toInt(minMoq, fallback: 1);
    return m > 0 ? m : 1;
  }

  /// §5 — initial value of the quantity selector is the MOQ.
  static int initialQuantity(dynamic minMoq) => effectiveMinMoq(minMoq);

  /// §5 Plus button.
  ///  - if `current < min_moq` (sitting at the SKU floor) -> jump to `min_moq`
  ///  - else -> `current + min_moq`
  ///  - if `stockManaged`, cap at the available stock ([maxLimit]).
  static int increment(
    int current, {
    required dynamic minMoq,
    bool stockManaged = false,
    int? maxLimit,
  }) {
    final int step = effectiveMinMoq(minMoq);
    int next = current < step ? step : current + step;
    if (stockManaged && maxLimit != null && maxLimit > 0 && next > maxLimit) {
      next = maxLimit;
    }
    return next;
  }

  /// §5 Minus button.
  ///  - if `current > min_moq` -> `current - min_moq`
  ///  - if `current == min_moq` and `sku_qty < min_moq` -> drop to `sku_qty`
  ///  - never below the SKU floor.
  static int decrement(
    int current, {
    required dynamic minMoq,
    dynamic skuQty,
  }) {
    final int step = effectiveMinMoq(minMoq);
    final int floor = effectiveSkuQty(skuQty, step);
    int next;
    if (current > step) {
      next = current - step;
    } else if (current == step && floor < step) {
      next = floor;
    } else {
      next = floor;
    }
    return next < floor ? floor : next;
  }

  /// §5 — Minus is disabled when `current <= sku_qty`.
  static bool canDecrement(int current, {required dynamic minMoq, dynamic skuQty}) {
    final int floor = effectiveSkuQty(skuQty, effectiveMinMoq(minMoq));
    return current > floor;
  }

  /// §5 — Plus is disabled once stock-managed quantity reaches the cap.
  static bool canIncrement(
    int current, {
    bool stockManaged = false,
    int? maxLimit,
  }) {
    if (stockManaged && maxLimit != null && maxLimit > 0) {
      return current < maxLimit;
    }
    return true;
  }

  /// Clamp a manually typed quantity into the valid `[skuQty, maxLimit]` range.
  static int clampManual(
    int typed, {
    required dynamic minMoq,
    dynamic skuQty,
    bool stockManaged = false,
    int? maxLimit,
  }) {
    final int floor = effectiveSkuQty(skuQty, effectiveMinMoq(minMoq));
    int q = typed < floor ? floor : typed;
    if (stockManaged && maxLimit != null && maxLimit > 0 && q > maxLimit) {
      q = maxLimit;
    }
    return q;
  }

  /// §4 Step C — active tier for the given quantity, when the raw tier fields
  /// are known. Returns `"sku"`, `"bulk"` or `"moq"`. Used only for an optional
  /// label; the displayed rate itself comes from the server.
  static String activeTier(
    int quantity, {
    required dynamic minMoq,
    dynamic skuQty,
    dynamic skuRate,
    dynamic minQty,
    dynamic minQtyPriceValue,
  }) {
    final int moq = effectiveMinMoq(minMoq);
    final double skuRateVal = _toDouble(skuRate);
    final int minQtyThreshold = _toInt(minQty, fallback: 0);
    final double bulkPrice = _toDouble(minQtyPriceValue);

    final bool skuTierActive = quantity < moq && skuRateVal > 0;
    final bool bulkTierActive =
        minQtyThreshold > 0 && quantity >= minQtyThreshold && bulkPrice != 0;

    if (skuTierActive) return "sku";
    if (bulkTierActive) return "bulk";
    return "moq";
  }

  static int _toInt(dynamic v, {int fallback = 0}) {
    if (v == null) return fallback;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString().trim()) ?? fallback;
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    // Strip anything that is not part of a number (currency symbols, commas).
    final cleaned = v.toString().replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}
