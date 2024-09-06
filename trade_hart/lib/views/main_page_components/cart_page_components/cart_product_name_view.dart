import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class CartProductNameView extends StatelessWidget {
  final String name;
  const CartProductNameView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: manageWidth(context, 160),
      child: Text(name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.workSans(
              fontSize: manageWidth(context, 14), fontWeight: FontWeight.w500)),
    );
  }
}
