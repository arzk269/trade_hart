import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';

class SquareAuthProvider extends StatelessWidget {
  final String imagePath;
  const SquareAuthProvider({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(manageWidth(context, 9)),
      width: manageWidth(context, 65),
      height: manageWidth(context, 65),
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 243, 236, 236),
          borderRadius: BorderRadius.circular(manageWidth(context, 16))),
      child: Image.asset(
        imagePath,
        height: manageHeight(context, 35),
      ),
    );
  }
}
