import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';

class AddToCartButton extends StatelessWidget {
  const AddToCartButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            left: manageWidth(context, 130), top: manageHeight(context, 132)),
        height: manageWidth(context, 30),
        width: manageWidth(context, 30),
        decoration: BoxDecoration(
            color: AppColors.mainColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(manageWidth(context, 10))),
        child: const Icon(
          Icons.add_shopping_cart_rounded,
          color: Colors.white,
        ));
  }
}
