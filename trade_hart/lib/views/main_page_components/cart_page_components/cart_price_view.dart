import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class CartPriceView extends StatelessWidget {
  final double price;
  const CartPriceView({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Text('\$$price',
        style: GoogleFonts.workSans(
          fontSize: manageWidth(context, 16),
        ));
  }
}
