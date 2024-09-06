// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:url_launcher/url_launcher.dart';

class SuportServicePage extends StatefulWidget {
  const SuportServicePage({super.key});

  @override
  State<SuportServicePage> createState() => _SuportServicePageState();
}

class _SuportServicePageState extends State<SuportServicePage> {
  final String email = "contact.tradehart@gmail.com";
  final String phoneNumber = "+33751258837";

  Future<void> launchEmail() async {
    final Uri params = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Contact&body=Bonjour', // add subject and body here
    );
    final url = params.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch $url');
    }
  }

  Future<void> launchPhone() async {
    final Uri params = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    final url = params.toString();
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      print('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 5),
                ),
                MainBackButton()
              ],
            ),
            Image.asset(
              "images/suport_service.jpg",
              width: double.infinity,
              height: manageHeight(context, 390),
              fit: BoxFit.cover,
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                AppBarTitleText(
                  title: "Nous équipes sont toujours disponibles",
                  size: 15,
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                AppBarTitleText(
                  title: "pour vous assister et pour répondre",
                  size: 15,
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                AppBarTitleText(
                  title: "à toutes vos questions.",
                  size: 15,
                ),
              ],
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                AppBarTitleText(
                  title: "Contacts : ",
                  size: 15,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.mail,
                    size: manageWidth(context, 15),
                    color: Colors.deepPurple,
                  ),
                  TextButton(
                    onPressed: launchEmail,
                    child: Text('suport@tradehart.com',
                        style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.phone,
                    size: manageWidth(context, 15),
                    color: Colors.deepPurple,
                  ),
                  TextButton(
                    onPressed: launchPhone,
                    child: Text('07 51 25 88 37', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
