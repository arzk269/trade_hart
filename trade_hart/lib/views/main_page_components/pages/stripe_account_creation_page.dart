// // ignore_for_file: avoid_print
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:trade_hart/constants.dart';
// import 'package:url_launcher/url_launcher.dart';

// class StripeAccountCreationPage extends StatelessWidget {
//   const StripeAccountCreationPage({super.key});
//   Future<String> getAccountVerificationLink(String accountId) async {
//     final response = await http.post(
//       Uri.parse('https://api.stripe.com/v1/account_links'),
//       headers: {
//         'Authorization': 'Bearer $SECRET_KEY',
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
//         'account': accountId,
//         'refresh_url':
//             'https://tradehart-83b29.web.app/', // Lien de rafraîchissement pour rediriger l'utilisateur après la rectification
//         'return_url':
//             'https://tradehart-83b29.web.app/', // Lien de retour pour rediriger l'utilisateur après avoir terminé la rectification
//         'type':
//             'account_onboarding', // Type de lien pour le processus de rectification du compte
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonResponse = jsonDecode(response.body);
//       return jsonResponse['url'];
//     } else {
//       throw Exception('Failed to get verification link ${response.body}');
//     }
//   }

//   Future<String> createStripeAccount({
//     required String email,
//     required String firstName,
//     required String lastName,
//     required String address,
//     required String city,
//     required String postalCode,
//     required String countryCode,
//     //required String dob,
//     required String phoneNumber,
//     required String iban,
//   }) async {
//     final response = await http.post(
//       Uri.parse('https://api.stripe.com/v1/accounts'),
//       headers: {
//         'Authorization': 'Bearer $SECRET_KEY',
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       body: {
//         'type': 'express',
//         'country': 'FR',
//         // Code pays pour la France
//       },
//     );

//     if (response.statusCode == 200) {
//       final jsonResponse = jsonDecode(response.body);
//       final accountId = jsonResponse['id'];
//       final rectificationUrl = await getAccountVerificationLink(accountId);
//       launchUrl(Uri.parse(rectificationUrl)
//           // Uri.parse(
//           //     "https://connect.stripe.com/oauth/authorize?response_type=code&client_id=ca_PylQO6OIM2V5wMaeZfiLuQOFfiKQtL78&scope=read_write&stripe_user[account]=$accountId&redirect_uri=https://tradehart-83b29.web.app/"),
//           );

//       return accountId;
//     } else {
//       throw Exception('Failed to create Stripe account');
//     }
//   }

//   // Future<void> registerConsent(String accountId) async {
//   //   final response = await http.post(
//   //     Uri.parse('https://api.stripe.com/v1/account_links'),
//   //     headers: {
//   //       'Authorization': 'Bearer $SECRET_KEY',
//   //       'Content-Type': 'application/x-www-form-urlencoded',
//   //     },
//   //     body: {
//   //       // URL de retour après l'acceptation
//   //       "payouts_enabled": true,
//   //     },
//   //   );

//   //   if (response.statusCode == 200) {
//   //     // Consentement enregistré avec succès
//   //     print('Consentement enregistré avec succès.');
//   //   } else {
//   //     // Erreur lors de l'enregistrement du consentement
//   //     print(
//   //         "Erreur lors de l'enregistrement du consentement : ${response.statusCode}");
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Création de compte Stripe'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () async {
//             try {
//               final accountId = await createStripeAccount(
//                 email: 'test@example.com',
//                 firstName: 'John',
//                 lastName: 'Doe',
//                 address: '123 Main St',
//                 city: 'Anytown',
//                 postalCode: '75004',
//                 countryCode: 'FR',
//                 // dob: '01/01/1990',
//                 phoneNumber: '+33751258837',

//                 iban: 'FR89370400440532013000', // IBAN de test pour la France
//               );
//               // Utilisez l'ID du compte Stripe comme nécessaire
//               print('Compte Stripe créé avec succès. ID: $accountId');
//             } catch (e) {
//               print('Erreur lors de la création du compte Stripe: $e');
//             }
//           },
//           child: const Text('Créer un compte Stripe'),
//         ),
//       ),
//     );
//   }
// }
