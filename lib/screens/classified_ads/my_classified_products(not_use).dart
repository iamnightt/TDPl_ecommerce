import 'package:active_ecommerce_cms_demo_app/helpers/shimmer_helper.dart';
import 'package:active_ecommerce_cms_demo_app/my_theme.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_model.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_product_details.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_product_edit.dart';
import 'package:active_ecommerce_cms_demo_app/screens/classified_ads/classified_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// class MyClassifiedProducts extends StatefulWidget {
//   const MyClassifiedProducts({Key? key}) : super(key: key);

//   @override
//   State<MyClassifiedProducts> createState() => _MyClassifiedProductsState();
// }

// class _MyClassifiedProductsState extends State<MyClassifiedProducts> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<MyClassifiedProvider>(context, listen: false).fetchProducts();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productProvider = Provider.of<MyClassifiedProvider>(context);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           "My Products",
//           style: TextStyle(
//             color: Color(0xff3E4447),
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         backgroundColor: MyTheme.mainColor,
//         scrolledUnderElevation: 0.0,
//       ),
//       backgroundColor: MyTheme.mainColor,
//       body: Stack(
//         children: [
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'All Products',
//                   style: TextStyle(
//                     color: Color(0xffE62E04),
//                     fontFamily: 'Public Sans',
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 12),
//                 Expanded(
//                   child: productProvider.loading &&
//                           productProvider.products.isEmpty
//                       ? Center(
//                           child: ShimmerHelper().buildListShimmer(
//                               item_count: 20, item_height: 80.0))
//                       : productProvider.errorMessage.isNotEmpty
//                           ? Center(child: Text(productProvider.errorMessage))
//                           : ListView.builder(
//                               itemBuilder: (context, index) {
//                                 final product = productProvider.products[index];
//                                 return myProductCard(product);
//                               },
//                               itemCount: productProvider.products.length,
//                             ),
//                 ),
//               ],
//             ),
//           ),
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: _buildPaginationControls(productProvider),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPaginationControls(MyClassifiedProvider provider) {
//     int currentPage = provider.currentPage;
//     int lastPage = provider.lastPage;

//     return Container(
//       color: MyTheme.mainColor
//           .withOpacity(0.7), // Ensures the background is transparent
//       padding: EdgeInsets.symmetric(vertical: 8), // Padding to prevent overlap
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           IconButton(
//             icon: Icon(Icons.arrow_back_ios_outlined),
//             onPressed: currentPage > 1 ? provider.loadPreviousPage : null,
//           ),
//           SizedBox(width: 8),
//           for (int i = 1; i <= lastPage; i++)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: GestureDetector(
//                 onTap: () => provider.fetchProducts(page: i),
//                 child: Container(
//                   padding: EdgeInsets.symmetric(vertical: 6, horizontal: 11),
//                   decoration: BoxDecoration(
//                     color: i == currentPage ? Colors.red : Colors.white,
//                     borderRadius: BorderRadius.circular(4),
//                     border: Border.all(color: Colors.grey),
//                   ),
//                   child: Text(
//                     i.toString(),
//                     style: TextStyle(
//                       color: i == currentPage ? Colors.white : Colors.black,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           SizedBox(width: 8),
//           IconButton(
//             icon: Icon(Icons.arrow_forward_ios_rounded),
//             onPressed: currentPage < lastPage ? provider.loadNextPage : null,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget myProductCard(ClassifiedProductModel product) {
//     final conditionColor = (product.condition?.toLowerCase() == 'used')
//         ? Color(0xffE62E04)
//         : Color(0xffFFA800);

//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ClassifiedAdsDetails(slug: product.slug ?? ''),
//           ),
//         );
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Stack(
//           children: [
//             Container(
//               height: 80,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(6),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.08),
//                     spreadRadius: 0.5,
//                     blurRadius: 20,
//                     offset: Offset(0, 10),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(
//                     width: 80,
//                     decoration: BoxDecoration(
//                       image: DecorationImage(
//                         image: NetworkImage(product.thumbnailImage ?? ''),
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Center(
//                       child: Text(
//                         product.name ?? '',
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: Color(0xff3E4447),
//                           fontSize: 13,
//                           fontWeight: FontWeight.normal,
//                         ),
//                       ),
//                     ),
//                   ),
//                   PopupMenuButton<String>(
//                     icon: Icon(
//                       Icons.more_vert,
//                       color: Color(0xff6B7377),
//                       size: 18,
//                     ),
//                     onSelected: (value) {
//                       switch (value) {
//                         case 'Edit':
//                           // Implement your Edit functionality here
//                           break;
//                         case 'Delete':
//                           // Implement your Delete functionality here
//                           break;
//                         case 'Status':
//                           // Implement your Status functionality here
//                           break;
//                       }
//                     },
//                     itemBuilder: (BuildContext context) => [
//                       PopupMenuItem(
//                         value: 'Edit',
//                         child: Text('Edit'),
//                         onTap: () {
//                           Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) =>
//                                       ClassifiedProductEdit()));
//                         },
//                       ),
//                       PopupMenuItem(
//                         value: 'Delete',
//                         child: Text('Delete'),
//                         onTap: () {
//                           print('delet');
//                         },
//                       ),
//                       PopupMenuItem(
//                         value: 'Status',
//                         child: Text('Status'),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             Positioned(
//               top: 0,
//               left: 0,
//               child: Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: conditionColor,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(6),
//                     bottomRight: Radius.circular(6),
//                   ),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.08),
//                       spreadRadius: 0.5,
//                       blurRadius: 1,
//                       offset: Offset(-1, 1),
//                     ),
//                   ],
//                 ),
//                 child: Text(
//                   product.condition ?? 'No condition specified',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 10,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class MyClassifiedProducts extends StatefulWidget {
  const MyClassifiedProducts({Key? key}) : super(key: key);

  @override
  State<MyClassifiedProducts> createState() => _MyClassifiedProductsState();
}

class _MyClassifiedProductsState extends State<MyClassifiedProducts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MyClassifiedProvider>(context, listen: false).fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<MyClassifiedProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Products",
          style: TextStyle(
            color: Color(0xff3E4447),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: MyTheme.mainColor,
        scrolledUnderElevation: 0.0,
      ),
      backgroundColor: MyTheme.mainColor,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Row(children: [
                  Expanded(
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          color: Color(0xffE62E04),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              spreadRadius: 0.5,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            )
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Remaining Uploads',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '800',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 75,
                      decoration: BoxDecoration(
                          color: Color(0xffFEF0D7),
                          borderRadius: BorderRadius.circular(6),
                          border:
                              Border.all(color: Color(0xffFFA800), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              spreadRadius: 0.5,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            )
                          ]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Add New Products',
                            style: TextStyle(
                                color: Color(0xffE5411C),
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Icon(
                            Icons.add,
                            color: Color(0xffE5411C),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 16),
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xffFBEAE6),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Color(0xffE62E04), width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/package.png',
                          height: 20,
                        ),
                        Text(
                          'Current Package',
                          style: TextStyle(
                              color: Color(0xff6B7377),
                              fontSize: 12,
                              fontWeight: FontWeight.normal),
                        ),
                        Text(
                          'Platinum',
                          style: TextStyle(
                              color: Color(0xffE5411C),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Upgrade Package',
                          style: TextStyle(
                              color: Color(0xffE5411C),
                              fontSize: 12,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold),
                        ),
                        Icon(Icons.arrow_forward_rounded,
                            color: Color(0xffE5411C), size: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 140, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'All Products',
                  style: TextStyle(
                    color: Color(0xffE62E04),
                    fontFamily: 'Public Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: productProvider.loading &&
                          productProvider.products.isEmpty
                      ? Center(
                          child: ShimmerHelper().buildListShimmer(
                              item_count: 20, item_height: 80.0))
                      : productProvider.errorMessage.isNotEmpty
                          ? Center(child: Text(productProvider.errorMessage))
                          : ListView.builder(
                              itemBuilder: (context, index) {
                                final product = productProvider.products[index];
                                return myProductCard(product);
                              },
                              itemCount: productProvider.products.length,
                            ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildPaginationControls(productProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls(MyClassifiedProvider provider) {
    int currentPage = provider.currentPage;
    int lastPage = provider.lastPage;

    return Container(
      color: MyTheme.mainColor.withOpacity(0.7),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: currentPage > 1 ? provider.loadPreviousPage : null,
          ),
          SizedBox(width: 8),
          for (int i = 1; i <= lastPage; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: GestureDetector(
                onTap: () => provider.fetchProducts(page: i),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 11),
                  decoration: BoxDecoration(
                    color: i == currentPage ? Colors.red : Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    i.toString(),
                    style: TextStyle(
                      color: i == currentPage ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios_rounded),
            onPressed: currentPage < lastPage ? provider.loadNextPage : null,
          ),
        ],
      ),
    );
  }

  Widget myProductCard(ClassifiedProductModel product) {
    final conditionColor = (product.condition?.toLowerCase() == 'used')
        ? Color(0xffE62E04)
        : Color(0xffFFA800);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ClassifiedAdsDetails(slug: product.slug ?? ''),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Stack(
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    spreadRadius: 0.5,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(product.thumbnailImage ?? ''),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Center(
                      child: Text(
                        product.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xff3E4447),
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.white,
                    icon: Icon(
                      Icons.more_vert,
                      color: Color(0xff6B7377),
                      size: 18,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'Edit':
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassifiedProductEdit(
                                productId: product.id,
                              ),
                            ),
                          );
                          break;
                        case 'Delete':
                          _deleteDialog(context, product);
                          break;
                        case 'Status':
                          _statusDialog(context, product);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        height: 25, // Set your preferred height here
                        value: 'Edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        height: 25, // Set your preferred height here
                        value: 'Delete',
                        child: Text('Delete'),
                      ),
                      PopupMenuItem(
                        height: 25, // Set your preferred height here
                        value: 'Status',
                        child: Text('Status'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: conditionColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      spreadRadius: 0.5,
                      blurRadius: 1,
                      offset: Offset(-1, 1),
                    ),
                  ],
                ),
                child: Text(
                  product.condition ?? 'No condition specified',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _deleteDialog(BuildContext context, ClassifiedProductModel product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text("Delete Product"),
        content: Text("Are you sure you want to delete this product?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              Provider.of<MyClassifiedProvider>(context, listen: false)
                  .deleteProduct(product.id);

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void _statusDialog(BuildContext context, ClassifiedProductModel product) {
  bool isPublished = product.status;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Published"),
                Switch(
                  value: isPublished,
                  onChanged: (newStatus) {
                    setState(() {
                      isPublished = newStatus;
                    });

                    Provider.of<MyClassifiedProvider>(context, listen: false)
                        .changeProductStatus(product.id, newStatus);
                  },
                  activeColor: Colors.green,
                ),
              ],
            );
          },
        ),
      );
    },
  );
}
