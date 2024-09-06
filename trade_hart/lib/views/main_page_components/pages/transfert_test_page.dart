// import 'package:flutter/material.dart';
// import 'package:trade_hart/constants.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// Future<Map<String, dynamic>> createTransfer(
//     String stripeSecretKey, String connectedAccountId, int amount,
//     {String? currency, String? destination}) async {
//   String url = 'https://api.stripe.com/v1/transfers';

//   final headers = {
//     'Authorization': 'Bearer $stripeSecretKey',
//     'Content-Type': 'application/x-www-form-urlencoded',
//   };

//   final body = {
//     'amount': amount.toString(),
//     'currency': currency ?? 'EUR',
//     'destination': destination ?? connectedAccountId,
//   };

//   final response =
//       await http.post(Uri.parse(url), headers: headers, body: body);

//   if (response.statusCode == 200) {
//     final jsonResponse = json.decode(response.body);
//     return jsonResponse;
//   } else {
//     throw Exception('Failed to create transfer: ${response.body}');
//   }
// }

// class TransFertPageTest extends StatefulWidget {
//   const TransFertPageTest({super.key});

//   @override
//   State<TransFertPageTest> createState() => _TransFertPageTestState();
// }

// class _TransFertPageTestState extends State<TransFertPageTest> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: TextButton(
//                 onPressed: () async {
//                   createTransfer(SECRET_KEY, "acct_1PB3kaQlJepRbC6P", 100);
//                 },
//                 child: const Text("Transfert")),
//           )
//         ],
//       ),
//     );
//   }
// }
