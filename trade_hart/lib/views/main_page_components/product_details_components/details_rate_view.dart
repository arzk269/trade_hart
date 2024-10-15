import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class DetailsRateStars extends StatelessWidget {
  final int rate;
  final int nbRates;
  const DetailsRateStars({super.key, required this.rate, required this.nbRates});

  @override
  Widget build(BuildContext context) {
    switch (rate) {
      case 0:
        return Row(
          children: [
            Icon(Icons.star,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            SizedBox(
              width: manageWidth(context, 2.5),
            ),
            Text("$nbRates avis",
                style: GoogleFonts.workSans(
                  color: const Color.fromARGB(255, 102, 102, 102),
                  fontSize: manageWidth(context, 11),
                )),
          ],
        );

      case 1:
        return Row(
          children: [
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            SizedBox(
              width: manageWidth(context, 2.5),
            ),
            Text("$nbRates avis",
                style: GoogleFonts.workSans(
                  color: const Color.fromARGB(255, 102, 102, 102),
                  fontSize: manageWidth(context, 11),
                )),
          ],
        );

      case 2:
        return Row(
          children: [
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            SizedBox(
              width: manageWidth(context, 2.5),
            ),
            Text("$nbRates avis",
                style: GoogleFonts.workSans(
                  color: const Color.fromARGB(255, 102, 102, 102),
                  fontSize: manageWidth(context, 11),
                )),
          ],
        );

      case 3:
        return Row(
          children: [
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            SizedBox(
              width: manageWidth(context, 2.5),
            ),
            Text("$nbRates avis",
                style: GoogleFonts.workSans(
                  color: const Color.fromARGB(255, 102, 102, 102),
                  fontSize: manageWidth(context, 12.5),
                )),
          ],
        );

      case 4:
        return Row(
          children: [
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star_border,
                color: Colors.grey, size: manageWidth(context, 18)),
            SizedBox(
              width: manageWidth(context, 2.5),
            ),
            Text("$nbRates avis",
                style: GoogleFonts.workSans(
                  color: const Color.fromARGB(255, 102, 102, 102),
                  fontSize: manageWidth(context, 11),
                )),
          ],
        );

      case 5:
        return Row(
          children: [
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            Icon(Icons.star,
                color: Colors.amber, size: manageWidth(context, 18)),
            SizedBox(
              width: manageWidth(context, 2.5),
            ),
            Text("$nbRates avis",
                style: GoogleFonts.workSans(
                  color: const Color.fromARGB(255, 102, 102, 102),
                  fontSize: manageWidth(context, 11),
                )),
          ],
        );
    }

    return Row(
      children: [
        Icon(Icons.star, color: Colors.grey, size: manageWidth(context, 18)),
        Icon(Icons.star, color: Colors.grey, size: manageWidth(context, 18)),
        Icon(Icons.star, color: Colors.grey, size: manageWidth(context, 18)),
        Icon(Icons.star, color: Colors.grey, size: manageWidth(context, 18)),
        Icon(Icons.star_border,
            color: Colors.grey, size: manageWidth(context, 18)),
        SizedBox(
          width: manageWidth(context, 2.5),
        ),
        Text("$nbRates avis",
            style: GoogleFonts.workSans(
              color: const Color.fromARGB(255, 102, 102, 102),
              fontSize: manageWidth(context, 11),
            )),
      ],
    );
  }
}
