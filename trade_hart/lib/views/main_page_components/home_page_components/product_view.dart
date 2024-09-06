// import 'package:flutter/material.dart';
// import 'package:trade_hart/model/identifyed_product.dart';
// import 'package:trade_hart/views/main_page_components/home_page_components/home_add_to_favorite.dart';
// import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/product_container_view.dart';
// import 'package:trade_hart/views/main_page_components/pages/product_details_page.dart';

// class ProductView extends StatefulWidget {
//   //final Seller seller;
//   //final Product product;
//   final IdentifyedProduct identifyedProduct;

//   const ProductView({
//     super.key,
//     required this.identifyedProduct,
//   });
//   @override
//   State<ProductView> createState() => _ProductViewState();
// }

// class _ProductViewState extends State<ProductView> {
//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         GestureDetector(
//             onTap: () {
//               Navigator.push(context, MaterialPageRoute(
//                 builder: (context) {
//                   return ProductDetailsPage(
//                       detailedProduct: widget.identifyedProduct);
//                 },
//               ));
//             },
//             child: ProductContainer(
//                 product: widget.identifyedProduct.product,
//                 seller: widget.identifyedProduct.seller)),
//       //  const HomeAddToFavorite()
//       ],
//     );
//   }
// }
