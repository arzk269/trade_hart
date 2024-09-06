import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class CartSellerNameView extends StatelessWidget {
  final String name;
  const CartSellerNameView({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.bag,
          color: const Color.fromARGB(255, 255, 141, 152),
          size: manageWidth(context, 14),
        ),
        SizedBox(width: manageWidth(context, 2)),
        Text(name,
            style: GoogleFonts.workSans(
              color: const Color.fromARGB(255, 102, 102, 102),
              fontSize: manageWidth(context, 12.184),
            )),
      ],
    );
  }
}
