// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/service_provider_personnalization_page.dart';
import 'package:trade_hart/views/authentication_pages/shop_personalisation_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class StripeCreationPage extends StatefulWidget {
  final int businessType;
  const StripeCreationPage({super.key, required this.businessType});

  @override
  State<StripeCreationPage> createState() => _StripeCreationPageState();
}

class _StripeCreationPageState extends State<StripeCreationPage> {
  String stripeAccountId = "";
  bool chargesEnabled = false;
  bool paymentEnabled = false;
  bool creationIntent = false;
  var user = FirebaseAuth.instance.currentUser;

  Future<String> createStripeAccount() async {
    String? idToken = await user?.getIdToken();
    final response = await http.post(
      Uri.parse(
          'https://us-central1-tradehart-f5f44.cloudfunctions.net/createStripe'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final accountId = jsonResponse['accountId'];
      final verificationUrl = jsonResponse['verificationUrl'];
      await launchUrl(Uri.parse(verificationUrl));
      print(accountId);
      return accountId;
    } else {
      throw Exception('Failed to create Stripe account');
    }
  }

  Future<Map<String, dynamic>> retrieveStripeAccount(String accountId) async {
    String? idToken = await user?.getIdToken();
    final response = await http.post(
      Uri.parse(
          'https://us-central1-tradehart-f5f44.cloudfunctions.net/stripeVerif'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'accountId': accountId}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to retrieve Stripe account: ${response.body}');
    }
  }

  void checkAccountVerification(String accountId) async {
    try {
      final accountDetails = await retrieveStripeAccount(accountId);
      final chargesEnabled = accountDetails['chargesEnabled'];
      final paymentEnabled = accountDetails['paymentEnabled'];

      final String accountStatus = chargesEnabled && paymentEnabled
          ? 'Compte vérifié et opérationnel'
          : 'Compte non vérifié ou non opérationnel';

      print('Statut du compte: $accountStatus');

      if (stripeAccountId.isNotEmpty && paymentEnabled && chargesEnabled) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({"stripe account id": stripeAccountId});
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (context) {
          if (widget.businessType == 0) {
            return ShopPersonnalisationPage();
          }
          return ServiceProviderPersonalizationPage();
        }), (Route<dynamic> route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Veuillez finaliser votre compte Stripe.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ));
        creationIntent = false;
      }
    } catch (e) {
      print('Erreur lors de la vérification du compte: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(children: [
        Image.asset(
          "images/finance.png",
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        SizedBox(
          height: manageHeight(context, 15),
        ),
        AppBarTitleText(title: "Gérer vos paiement en toute", size: 15.5),
        AppBarTitleText(title: "sécurité avec Stripe.", size: 15.5),
        SizedBox(
          height: manageHeight(context, 60),
        ),
        TextButton(
            onPressed: () {
              if (!creationIntent) {
                setState(() async {
                  stripeAccountId = await createStripeAccount();
                });
              }
              setState(() {
                creationIntent = true;
              });
            },
            child: Text("Créer un compte Stripe")),
        SizedBox(
          height: manageHeight(context, 100),
        ),
        GestureDetector(
          onTap: () {
            checkAccountVerification(stripeAccountId);
          },
          child: Container(
            width: manageWidth(context, 200),
            height: manageHeight(context, 50),
            decoration: BoxDecoration(
              color: AppColors.mainColor,
              borderRadius: BorderRadius.circular(manageWidth(context, 25)),
            ),
            child: Center(
              child: Text(
                "Suivant",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: manageWidth(context, 16),
                ),
              ),
            ),
          ),
        )
      ])),
    );
  }
}
