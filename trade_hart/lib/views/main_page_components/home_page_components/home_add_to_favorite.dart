import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';

class HomeAddToFavorite extends StatefulWidget {
  final Color color;
  const HomeAddToFavorite({super.key, required this.color});

  @override
  State<HomeAddToFavorite> createState() => _HomeAddToFavoriteState();
}

class _HomeAddToFavoriteState extends State<HomeAddToFavorite> {
  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(
            left: manageWidth(context, 130), top: manageWidth(context, 132)),
        height: manageWidth(context, 30),
        width: manageWidth(context, 30),
        decoration: BoxDecoration(
            color: widget.color, //Color.fromARGB(164, 253, 120, 162),
            borderRadius: BorderRadius.circular(10)),
        child: const Center(
          child: Icon(
            CupertinoIcons.heart,
            color: Colors.white,
          ),
        ));
  }
}
