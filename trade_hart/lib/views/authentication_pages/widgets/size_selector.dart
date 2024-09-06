import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class SizeSelector extends StatefulWidget {
  final Color color;
  final int sizeCategory;
  const SizeSelector(
      {super.key, required this.sizeCategory, required this.color});

  @override
  State<SizeSelector> createState() => _SizeSelectorState();
}

class _SizeSelectorState extends State<SizeSelector> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(
            top: manageHeight(context, 10),
            bottom: manageHeight(context, 10),
            left: manageWidth(context, 15)),
        height: manageHeight(context, 40),
        width: manageWidth(context, 130),
        decoration: BoxDecoration(
            border: Border.all(
              color: widget.color, // Couleur des bordures vertes
              width: 1.0, // Épaisseur des bordures
            ),
            borderRadius: BorderRadius.circular(20)),
        child: Center(
            child: Text(
          widget.sizeCategory == 0
              ? 'Vetements'
              : widget.sizeCategory == 1
                  ? 'Chaussures'
                  : 'Autre',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: 16.5,
            color: widget.color,
          ),
        )),
      ),
    );
  }
}
