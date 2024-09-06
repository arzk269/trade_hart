import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';

class CartProductImageView extends StatelessWidget {
  final String imagePath;
  const CartProductImageView({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: manageWidth(context, 90),
      width: manageWidth(context, 90),
      child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => SizedBox(
                height: manageHeight(context, 150),
                width: manageWidth(context, 165),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle,
                      size: manageWidth(context, 20),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                )),
          )),
    );
  }
}
