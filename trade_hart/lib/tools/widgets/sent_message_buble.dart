import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';

class SentMessageBuble extends StatelessWidget {
  final String message;
  const SentMessageBuble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width *
            0.8, // Limite la largeur du conteneur à 80% de la largeur de l'écran
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(manageWidth(context, 20)),
        color: Colors.blueAccent,
      ),
      margin: EdgeInsets.symmetric(
          vertical: manageHeight(context, 10),
          horizontal: manageWidth(context, 10)),
      padding: EdgeInsets.all(manageWidth(context, 10)),
      child: Text(
        message,
        style: GoogleFonts.poppins(color: Colors.white),
      ),
    );
  }
}
