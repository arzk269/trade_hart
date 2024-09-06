import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class PriceView extends StatelessWidget {
  final double price;
  const PriceView({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: manageWidth(context, 8),
          right: manageWidth(context, 8),
          bottom: manageHeight(context, 4)),
      child: Text('\$$price',
          style: GoogleFonts.workSans(
            fontSize: manageWidth(context, 16),
          )),
    );
  }
}
