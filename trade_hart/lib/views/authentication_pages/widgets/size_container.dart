import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class ArticleSizeContainer extends StatelessWidget {
  final Color color;
  final String size;
  const ArticleSizeContainer(
      {super.key,
      required this.size,
      this.color = const Color.fromARGB(255, 104, 104, 104)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: manageHeight(context, 10),
          bottom: manageHeight(context, 10),
          left: manageWidth(context, 17)),
      height: manageHeight(context, 40),
      width: manageWidth(context, 60),
      decoration: BoxDecoration(
          border: Border.all(
            color: color, // Couleur des bordures vertes
            width: 1.0, // Épaisseur des bordures
          ),
          borderRadius: BorderRadius.circular(manageWidth(context, 20))),
      child: Center(
          child: Text(
        size,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: manageWidth(context, 16.5),
          color: color,
        ),
      )),
    );
  }
}
