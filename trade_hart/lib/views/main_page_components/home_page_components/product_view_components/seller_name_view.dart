import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class SellerNameView extends StatelessWidget {
  final String name;
  final double? iconSize;
  final double? fontSize;
  final double? marginLeft;
  const SellerNameView(
      {super.key,
      required this.name,
      this.iconSize,
      this.fontSize,
      this.marginLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: manageWidth(context, 150),
      margin: EdgeInsets.only(
        left: marginLeft ?? manageWidth(context, 8),
        right: manageWidth(context, 8),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.bag,
            color: const Color.fromARGB(255, 255, 141, 152),
            size: iconSize ?? manageWidth(context, 14),
          ),
          SizedBox(width: manageWidth(context, 2)),
          Text(
            name,
            style: GoogleFonts.workSans(
              color: const Color.fromARGB(255, 102, 102, 102),
              fontSize: fontSize ?? manageWidth(context, 12.184),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
