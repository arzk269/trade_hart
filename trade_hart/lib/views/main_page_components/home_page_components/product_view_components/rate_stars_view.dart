// ignore_for_file: prefer__ructors_in_immutables
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class RateStars extends StatelessWidget {
  final bool withText;
  final double? starsSize;
  final int rate;
  final int nbRates;
  const RateStars(
      {super.key,
      required this.rate,
      required this.nbRates,
      this.starsSize,
      this.withText = true});

  @override
  Widget build(BuildContext context) {
    switch (rate) {
      case 0:
        return Container(
          margin: EdgeInsets.only(
              left: manageWidth(context, 6.5),
              right: manageWidth(context, 8),
              bottom: manageHeight(context, 4)),
          child: Row(
            children: [
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
              SizedBox(
                child: withText
                    ? Text("$nbRates avis",
                        style: GoogleFonts.workSans(
                          color: const Color.fromARGB(255, 102, 102, 102),
                          fontSize: manageWidth(context, 11),
                        ))
                    : null,
              ),
            ],
          ),
        );

      case 1:
        return Container(
          margin: EdgeInsets.only(
              left: manageWidth(context, 6.5),
              right: manageWidth(context, 8),
              bottom: manageHeight(context, 4)),
          child: Row(
            children: [
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
              SizedBox(
                child: withText
                    ? Text("$nbRates avis",
                        style: GoogleFonts.workSans(
                          color: const Color.fromARGB(255, 102, 102, 102),
                          fontSize: manageWidth(context, 11),
                        ))
                    : null,
              ),
            ],
          ),
        );

      case 2:
        return Container(
          margin: EdgeInsets.only(
              left: manageWidth(context, 6.5),
              right: manageWidth(context, 8),
              bottom: 4),
          child: Row(
            children: [
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
              SizedBox(
                child: withText
                    ? Text("$nbRates avis",
                        style: GoogleFonts.workSans(
                          color: const Color.fromARGB(255, 102, 102, 102),
                          fontSize: manageWidth(context, 11),
                        ))
                    : null,
              ),
            ],
          ),
        );

      case 3:
        return Container(
          margin: EdgeInsets.only(
              left: manageWidth(context, 6.5),
              right: manageWidth(context, 8),
              bottom: 4),
          child: Row(
            children: [
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
              SizedBox(
                child: withText
                    ? Text("$nbRates avis",
                        style: GoogleFonts.workSans(
                          color: const Color.fromARGB(255, 102, 102, 102),
                          fontSize: manageWidth(context, 11),
                        ))
                    : null,
              ),
            ],
          ),
        );

      case 4:
        return Container(
          margin: EdgeInsets.only(
              left: manageWidth(context, 6.5),
              right: manageWidth(context, 8),
              bottom: 4),
          child: Row(
            children: [
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.grey,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
              SizedBox(
                child: withText
                    ? Text("$nbRates avis",
                        style: GoogleFonts.workSans(
                          color: const Color.fromARGB(255, 102, 102, 102),
                          fontSize: manageWidth(context, 11),
                        ))
                    : null,
              ),
            ],
          ),
        );

      case 5:
        return Container(
          margin: EdgeInsets.only(
              left: manageWidth(context, 6.5),
              right: manageWidth(context, 8),
              bottom: 4),
          child: Row(
            children: [
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              Icon(Icons.star,
                  color: Colors.amber,
                  size: starsSize != null
                      ? manageWidth(context, starsSize!)
                      : manageWidth(context, 18)),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
              SizedBox(
                child: withText
                    ? Text("$nbRates avis",
                        style: GoogleFonts.workSans(
                          color: const Color.fromARGB(255, 102, 102, 102),
                          fontSize: manageWidth(context, 11),
                        ))
                    : null,
              ),
            ],
          ),
        );
    }

    return Container(
      margin: EdgeInsets.only(
          left: manageWidth(context, 6.5),
          right: manageWidth(context, 8),
          bottom: 4),
      child: Row(
        children: [
          Icon(Icons.star,
              color: Colors.grey,
              size: starsSize != null
                  ? manageWidth(context, starsSize!)
                  : manageWidth(context, 18)),
          Icon(Icons.star,
              color: Colors.grey,
              size: starsSize != null
                  ? manageWidth(context, starsSize!)
                  : manageWidth(context, 18)),
          Icon(Icons.star,
              color: Colors.grey,
              size: starsSize != null
                  ? manageWidth(context, starsSize!)
                  : manageWidth(context, 18)),
          Icon(Icons.star,
              color: Colors.grey,
              size: starsSize != null
                  ? manageWidth(context, starsSize!)
                  : manageWidth(context, 18)),
          Icon(Icons.star,
              color: Colors.grey,
              size: starsSize != null
                  ? manageWidth(context, starsSize!)
                  : manageWidth(context, 18)),
          SizedBox(
            width: manageWidth(context, 2.5),
          ),
          SizedBox(
            child: withText
                ? Text("$nbRates avis",
                    style: GoogleFonts.workSans(
                      color: const Color.fromARGB(255, 102, 102, 102),
                      fontSize: manageWidth(context, 11),
                    ))
                : null,
          ),
        ],
      ),
    );
  }
}
