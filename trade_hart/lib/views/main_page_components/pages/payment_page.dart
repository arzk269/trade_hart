// // ignore_for_file: avoid_print

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:trade_hart/constants.dart';

// class PaymentPage extends StatefulWidget {
//   const PaymentPage({super.key});

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   Map<String, dynamic>? paymentIntent;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment'),
//       ),
//       body: Center(
//           child: ElevatedButton(
//               onPressed: () {
//                 makePayment();
//               },
//               style: TextButton.styleFrom(
//                   backgroundColor: Colors.deepPurple,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(15))),
//               child: const Text(
//                 'Pay',
//                 style: TextStyle(color: Colors.white),
//               ))),
//     );
//   }

//   Future<void> makePayment() async {
//     try {
//       paymentIntent = await createPaymentIntent('1000', 'EUR');
//       await Stripe.instance
//           .initPaymentSheet(
//               paymentSheetParameters: SetupPaymentSheetParameters(
//                   paymentIntentClientSecret: paymentIntent!['client_secret'],
//                   merchantDisplayName: 'TradeHart',
//                   style: ThemeMode.light))
//           .then((value) => null);
//       displayPaymentSheet();
//     } catch (e) {
//       print("error : $e");
//     }
//     paymentIntent = await createPaymentIntent('10', 'EUR');

//     await Stripe.instance
//         .initPaymentSheet(
//             paymentSheetParameters: SetupPaymentSheetParameters(
//                 paymentIntentClientSecret: paymentIntent!['client_secret'],
//                 merchantDisplayName: 'TradeHart'))
//         .then((value) => null);
//   }

//   displayPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet().then((value) {
//         showDialog(
//           context: context,
//           builder: (context) {
//             return const AlertDialog(
//               content: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.check,
//                         color: Colors.green,
//                       ),
//                       Text("Payment successful")
//                     ],
//                   )
//                 ],
//               ),
//             );
//           },
//         );
//       }).onError((error, stackTrace) {
//         print("error : $error $stackTrace");
//       });
//       paymentIntent = null;
//     } on StripeException catch (e) {
//       print('error $e');
//       showDialog(
//         // ignore: use_build_context_synchronously
//         context: context,
//         builder: (context) {
//           return const AlertDialog(
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Row(
//                   children: [
//                     Icon(
//                       Icons.clear,
//                       color: Colors.red,
//                     ),
//                     Text("Cancelled")
//                   ],
//                 )
//               ],
//             ),
//           );
//         },
//       );
//     }
//   }

//   createPaymentIntent(String amount, String currency) async {
//     try {
//       Map<String, dynamic> body = {
//         'amount': calculateAmount(amount),
//         'currency': currency,
//         'payment_method_types[]': 'card'
//       };
//       var response = await http.post(
//           Uri.parse("https://api.stripe.com/v1/payment_intents"),
//           body: body,
//           headers: {
//             'Authorization': 'Bearer $SECRET_KEY',
//             'Content-Type': 'application/x-www-form-urlencoded'
//           });

//       print("Payment Intent Body->>> ${response.body.toString()}");

//       return jsonDecode(response.body);
//     } catch (e) {
//       print("error : $e");
//     }
//   }

//   calculateAmount(String amount) {
//     final calculatedAmount = int.parse(amount) * 100;
//     return calculatedAmount.toString();
//   }
// }
