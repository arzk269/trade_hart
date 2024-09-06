import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';

class ProductImageView extends StatelessWidget {
  final double? size;
  final String imagePath;

  const ProductImageView({super.key, required this.imagePath, this.size});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(11),
        topRight: Radius.circular(11),
      ),
      child: Image.network(
        imagePath,
        fit: BoxFit.cover,
        height: manageHeight(context, 150),
        width: manageWidth(context, 165),
        errorBuilder: (context, error, stackTrace) {
          return SizedBox(
              height: manageHeight(context, 150),
              width: manageWidth(context, 165),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_triangle,
                    size: manageWidth(context, 30),
                  ),
                  SizedBox(
                    height: manageHeight(context, 3),
                  ),
                  const Text(
                    "Erreur lors du chargement",
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ));
        },
      ),
    );
  }
}
