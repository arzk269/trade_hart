import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/authentication_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/stripe_cretation_account_page.dart';



class ShopInformationsPage extends StatefulWidget {
  const ShopInformationsPage({super.key});

  @override
  State<ShopInformationsPage> createState() => _ShopInformationsPageState();
}

class _ShopInformationsPageState extends State<ShopInformationsPage> {
  TextEditingController shopNameController = TextEditingController();
  TextEditingController shopEmailController = TextEditingController();
  TextEditingController shopNumberController = TextEditingController();
  TextEditingController shopAdressController = TextEditingController();
  TextEditingController shopCodePostalController = TextEditingController();
  TextEditingController shopCityController = TextEditingController();

  // Future<String> getAccountVerificationLink(String accountId) async {
  //   final response = await http.post(
  //     Uri.parse('https://api.stripe.com/v1/account_links'),
  //     headers: {
  //       'Authorization': 'Bearer $SECRET_KEY',
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'account': accountId,
  //       'refresh_url': 'https://tradehart-83b29.web.app/',
  //       'return_url': 'https://tradehart-83b29.web.app/',
  //       'type': 'account_onboarding',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final jsonResponse = jsonDecode(response.body);
  //     return jsonResponse['url'];
  //   } else {
  //     throw Exception('Failed to get verification link ${response.body}');
  //   }
  // }

  // Future<String> createStripeAccount() async {
  //   final response = await http.post(
  //     Uri.parse('https://api.stripe.com/v1/accounts'),
  //     headers: {
  //       'Authorization': 'Bearer $SECRET_KEY',
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //     body: {
  //       'type': 'express',
  //       'country': 'FR',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final jsonResponse = jsonDecode(response.body);
  //     final accountId = jsonResponse['id'];
  //     final verificationUrl = await getAccountVerificationLink(accountId);
  //     launchUrl(Uri.parse(verificationUrl));
  //     print(accountId);
  //     return accountId;
  //   } else {
  //     throw Exception('Failed to create Stripe account');
  //   }
  // }

  // Future<Map<String, dynamic>> retrieveStripeAccount(String accountId) async {
  //   final response = await http.get(
  //     Uri.parse('https://api.stripe.com/v1/accounts/$accountId'),
  //     headers: {
  //       'Authorization': 'Bearer $SECRET_KEY',
  //       'Content-Type': 'application/x-www-form-urlencoded',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     return jsonDecode(response.body);
  //   } else {
  //     throw Exception('Failed to retrieve Stripe account: ${response.body}');
  //   }
  // }

  // void checkAccountVerification(String accountId) async {
  //   try {
  //     final accountDetails = await retrieveStripeAccount(accountId);
  //     final bool chargesEnabled = accountDetails['charges_enabled'];
  //     final bool payoutsEnabled = accountDetails['payouts_enabled'];
  //     final String accountStatus = chargesEnabled && payoutsEnabled
  //         ? 'Compte vérifié et opérationnel'
  //         : 'Compte non vérifié ou non opérationnel';

  //     print('Statut du compte: $accountStatus');
  //   } catch (e) {
  //     print('Erreur lors de la vérification du compte: $e');
  //   }
  // }

  @override
  void initState() {
    // checkAccountVerification("acct_1PRazgQcEUbPstrd");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: manageHeight(context, 40),
            ),
            Center(
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade100,
                radius: manageWidth(context, 70),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: manageWidth(context, 65),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 25),
                ),
                Text(
                  "Dites-nous en plus sur votre boutique!",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: manageWidth(context, 15.5),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            AuthTextField(
              controller: shopNameController,
              hintText: "nom de la boutique*",
              obscuretext: false,
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            AuthTextField(
              controller: shopNumberController,
              hintText: "numéro de téléphone de la boutique*",
              obscuretext: false,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            AuthTextField(
              controller: shopEmailController,
              hintText: "email de la boutique*",
              obscuretext: false,
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 25),
                ),
                Text(
                  "Adresse de la boutique (optionnel)",
                  style: GoogleFonts.poppins(
                    fontSize: manageWidth(context, 15.5),
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            AuthTextField(
              controller: shopAdressController,
              hintText: "adresse de la boutique",
              obscuretext: false,
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            AuthTextField(
              controller: shopCodePostalController,
              hintText: "code postal",
              obscuretext: false,
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            AuthTextField(
              controller: shopCityController,
              hintText: "ville",
              obscuretext: false,
            ),
            SizedBox(
              height: manageHeight(context, 70),
            ),
            GestureDetector(
              onTap: () async {
                await AuthService()
                    .addShopInformations(
                  shopNameController.text,
                  shopEmailController.text,
                  int.parse(shopNumberController.text),
                  shopAdressController.text,
                  shopCityController.text,
                  int.parse(shopCodePostalController.text),
                )
                    .then((value) async {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StripeCreationPage(
                                businessType: 0,
                              )));
                });
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
            ),
            SizedBox(height: manageHeight(context, 70)),
          ],
        ),
      ),
    );
  }
}
