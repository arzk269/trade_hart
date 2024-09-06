// // ignore_for_file: empty_catches, avoid_print

// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:trade_hart/constants.dart';

// class TestArticlePage extends StatefulWidget {
//   const TestArticlePage({super.key});

//   @override
//   State<TestArticlePage> createState() => _TestArticlePageState();
// }

// class _TestArticlePageState extends State<TestArticlePage> {
//   Map<String, dynamic>? paymentIntent;
//   double calculateTotalPrice() {
//     double totalPrice = 0;
//     for (var article in selectedArticles) {
//       // totalPrice += article.price;
//     }
//     return totalPrice;
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
//       }).onError((error, stackTrace) {});
//       paymentIntent = null;
//     } on StripeException catch (e) {
//       print(e.toJson());
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

//   Future<void> transferToSeller(String sellerAccountId, double amount) async {
//     try {
//       var response = await http.post(
//         Uri.parse('https://api.stripe.com/v1/transfers'),
//         headers: {
//           'Authorization': 'Bearer $SECRET_KEY',
//           'Content-Type': 'application/x-www-form-urlencoded',
//         },
//         body: {
//           'amount': calculateAmount((amount / 100).toString()),
//           'currency': 'eur',
//           'destination': sellerAccountId,
//           // Attendre confirmation manuelle
//           // Autres paramètres nécessaires selon vos besoins
//         },
//       );
//       if (response.statusCode == 200) {
//         print('Transfert au vendeur initié avec succès');
//       } else {
//         throw Exception('Erreur lors de l\'initiation du transfert au vendeur');
//       }
//     } catch (e) {
//       throw Exception(
//           'Erreur lors de l\'initiation du transfert au vendeur : $e');
//     }
//   }

//   Future<void> makePayment() async {
//     try {
//       paymentIntent =
//           await createPaymentIntent(calculateTotalPrice().toString(), 'EUR');
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
//     final calculatedAmount = (double.parse(amount) * 100).toInt();
//     return calculatedAmount.toString();
//   }

//   List<Article> selectedArticles = [];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Articles disponibles'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: articles.length,
//               itemBuilder: (context, index) {
//                 final article = articles[index];
//                 return ListTile(
//                   title: Text(article.name),
//                   subtitle: Text('Prix: ${article.price} EUR'),
//                   trailing: ElevatedButton(
//                     onPressed: () {
//                       setState(() {
//                         selectedArticles.add(article);
//                       });
//                     },
//                     child: const Text('Ajouter au panier'),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Center(
//               child: ElevatedButton(
//                   onPressed: () {
//                     makePayment();

//                     transferToSeller('acct_1PB3kaQlJepRbC6P', 100);
//                   },
//                   style: TextButton.styleFrom(
//                       backgroundColor: Colors.deepPurple,
//                       shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(15))),
//                   child: const Text(
//                     'Pay',
//                     style: TextStyle(color: Colors.white),
//                   )))
//         ],
//       ),
//       bottomNavigationBar: BottomAppBar(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text(
//             'Prix total: ${calculateTotalPrice()} EUR',
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class Article {
//   final String name;
//   final double price;
//   final String sellerStripeId;

//   Article(
//       {required this.name, required this.price, required this.sellerStripeId});
// }

// List<Article> articles = [
//   Article(name: 'Pomme', price: 10.0, sellerStripeId: 'acct_1PB3kaQlJepRbC6P'),
//   Article(name: 'Patate', price: 15.0, sellerStripeId: 'acct_1PB2QaQeeiuhamW5'),
// ];
