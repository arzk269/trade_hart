// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:trade_hart/constants.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// Future<String> generateStripeDashboardLink(String vendorId) async {
//   String url = 'https://api.stripe.com/v1/account_links';

//   final headers = {
//     'Authorization': 'Bearer $SECRET_KEY',
//     'Content-Type': 'application/x-www-form-urlencoded',
//   };

//   final body = {
//     'type': 'account_onboarding',
//     'account': vendorId,
//     'refresh_url':
//         'https://dashboard.stripe.com/test/connect/accounts/acct_1PB3kaQlJepRbC6P/activity', // Lien de rafraîchissement pour rediriger l'utilisateur après la rectification
//     'return_url':
//         'https://dashboard.stripe.com/test/connect/accounts/acct_1PB3kaQlJepRbC6P/activity', // Lien de retour pour rediriger l'utilisateur après avoir terminé la rectification
//   };

//   final response =
//       await http.post(Uri.parse(url), headers: headers, body: body);

//   if (response.statusCode != 200) {
//     throw Exception(
//         'Failed to generate Stripe dashboard link: ${response.body}');
//   }

//   final jsonResponse = json.decode(response.body);
//   final link = jsonResponse['url'];

//   return link;
// }

// class StripeWebView extends StatefulWidget {
//   const StripeWebView({super.key});

//   @override
//   State<StripeWebView> createState() => _StripeWebViewState();
// }

// class _StripeWebViewState extends State<StripeWebView> {
//   initController(WebViewController controller) async {
//     controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..loadRequest(Uri.parse(
//           await generateStripeDashboardLink("acct_1PB3kaQlJepRbC6P")));
//   }

//   final controller = WebViewController()
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..loadRequest(Uri.parse("https://dashboard.stripe.com/test/dashboard"));
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(child: WebViewWidget(controller: controller)),
//     );
//   }
// }
