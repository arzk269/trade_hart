import 'package:flutter/material.dart';
import 'package:trade_hart/model/product.dart';
import 'package:trade_hart/model/seller.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/product_container_view.dart';

class WishListProductView extends StatefulWidget {
  final Seller seller;
  final Product product;
  const WishListProductView(
      {super.key, required this.product, required this.seller});

  @override
  State<WishListProductView> createState() => _WishListProductViewState();
}

class _WishListProductViewState extends State<WishListProductView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ProductContainer(product: widget.product, seller: widget.seller),
        Container(
            margin: EdgeInsets.only(
                left: manageWidth(context, 130),
                top: manageHeight(context, 132)),
            height: manageWidth(context, 30),
            width: manageWidth(context, 30),
            decoration: BoxDecoration(
                color: AppColors.mainColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(manageWidth(context, 10))),
            child: const Icon(
              Icons.add_shopping_cart_rounded,
              color: Colors.white,
            ))
      ],
    );
  }
}
