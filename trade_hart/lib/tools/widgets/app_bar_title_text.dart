import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppBarTitleText extends StatelessWidget {
  final double size;
  final String title;
  const AppBarTitleText({super.key, required this.title, required this.size});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: size,
      ),
    );
  }
}
