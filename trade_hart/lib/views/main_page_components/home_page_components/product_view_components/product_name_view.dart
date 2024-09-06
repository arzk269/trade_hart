import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class ProductNameView extends StatelessWidget {
  final String name;
  final double? size;
  const ProductNameView({super.key, required this.name, this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: manageWidth(context, 115)),
      margin: EdgeInsets.only(
          left: manageWidth(context, 8),
          right: manageWidth(context, 8),
          bottom: manageHeight(context, 4)),
      child: Text(
        name,
        style: GoogleFonts.workSans(
            fontSize: size ?? manageWidth(context, 14),
            fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
