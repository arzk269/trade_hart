import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';

class SelectionButton extends StatelessWidget {
  final String selection;
  final VoidCallback changeSelection;
  final Color buttonColor;
  final Color textColor;
  const SelectionButton(
      {super.key,
      required this.selection,
      required this.changeSelection,
      required this.buttonColor,
      required this.textColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: changeSelection,
      child: Container(
        margin: selection == "e-shop"
            ? EdgeInsets.only(left: manageWidth(context, 15))
            : EdgeInsets.only(right: manageWidth(context, 15)),
        width: manageWidth(context, 120),
        height: manageHeight(context, 40),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.0),
            color: buttonColor,
            border: Border.all(
                color: AppColors.mainColor,
                width: 1,
                style: BorderStyle.solid)),
        child: Center(
          child: Text(
            selection,
            style: GoogleFonts.workSans(
                color: textColor, fontSize: manageWidth(context, 16)),
          ),
        ),
      ),
    );
  }
}
