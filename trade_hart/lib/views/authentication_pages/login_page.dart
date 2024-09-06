import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/authentication_service.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/business_choice_page.dart';
import 'package:trade_hart/views/authentication_pages/reset_pass_word_page.dart';
import 'package:trade_hart/views/authentication_pages/service_provider_informations_page.dart';
import 'package:trade_hart/views/authentication_pages/service_provider_personnalization_page.dart';
import 'package:trade_hart/views/authentication_pages/shop_informations_page.dart';
import 'package:trade_hart/views/authentication_pages/shop_personalisation_page.dart';
import 'package:trade_hart/views/authentication_pages/sign_up_page.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/authentication_pages/widgets/square_auth_provider.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/pages/stripe_cretation_account_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    LinkProviderService().listenDynamicLinks(context);
    super.initState();
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController passWordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          children: [
            SizedBox(height: manageHeight(context, 50)),
            AppBarTitleText(title: "TradHart", size: manageWidth(context, 32)),
            SizedBox(
              height: manageHeight(context, 45),
            ),
            Padding(
              padding: EdgeInsets.only(left: manageWidth(context, 17)),
              child: Row(
                children: [
                  Text(
                    "Pas encore de compte?",
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w700),
                  ),
                  SizedBox(
                    width: manageWidth(context, 5),
                  ),
                  // Création compte
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpPage(type: "buyer"),
                        ),
                      );
                    },
                    child: Text(
                      "S'inscrire,",
                      style: TextStyle(color: AppColors.mainColor),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return BusinessChoicePage();
                      }));
                    },
                    child: Text(
                      " Compte pro",
                      style:
                          TextStyle(color: Color.fromARGB(255, 250, 59, 142)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            // Champ de saisie email
            AuthTextField(
              controller: emailController,
              hintText: "email",
              obscuretext: false,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            // Champ de saisie mot de passe
            AuthTextField(
              controller: passWordController,
              hintText: "mot de passe",
              obscuretext: true,
              keyboardType: TextInputType.visiblePassword,
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            // Changer de mot de passe
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResetPassWordPage()),
                );
              },
              child: Text(
                "mot de passe oublié?",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            // Bouton de connexion
            GestureDetector(
              onTap: () async {
                print(
                    "width: ${MediaQuery.of(context).size.width} height: ${MediaQuery.of(context).size.height}");
                if (emailController.text.isEmpty ||
                    passWordController.text.isEmpty) {
                  setState(() {
                    errorMessage = "Veuillez remplir tous les champs.";
                    isConnected = "non connecté";
                  });
                } else {
                  await AuthService()
                      .signInWithEmailAndPassword(
                          emailController.text, passWordController.text)
                      .then((value) async {
                    var currentUser = FirebaseAuth.instance.currentUser;

                    if (currentUser != null) {
                      var userData = await FirebaseFirestore.instance
                          .collection("Users")
                          .doc(currentUser.uid)
                          .get();

                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (context) {
                        if (!userData!.exists) {
                          return Scaffold(
                            body: Text("Utilisataur introuvable"),
                          );
                        } else if (userData.data()!["user type"] == "seller") {
                          if (!userData.data()!.containsKey("shop")) {
                            return ShopInformationsPage();
                          } else if (!userData
                              .data()!
                              .containsKey("stripe account id")) {
                            return StripeCreationPage(
                              businessType: 0,
                            );
                          } else if (!(userData.data()!["shop"]
                                  as Map<String, dynamic>)
                              .containsKey("cover image")) {
                            return ShopPersonnalisationPage();
                          }
                        } else if (userData.data()!["user type"] ==
                            "provider") {
                          if (!userData.data()!.containsKey("service")) {
                            return ServiceProviderInformationsPage();
                          } else if (!userData
                              .data()!
                              .containsKey("stripe account id")) {
                            return StripeCreationPage(
                              businessType: 1,
                            );
                          } else if (!userData.data()!.containsKey("images")) {
                            return ServiceProviderPersonalizationPage();
                          }
                        }

                        return MainPage();
                      }), (route) => false);
                    }
                  });
                }

                setState(() {});
              },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(25)),
                child: Center(
                  child: Text("connexion",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16))),
                ),
              ),
            ),
            Text(isConnected),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
              child: Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 40),
            ),
            Row(
              children: [
                Expanded(
                  child: Divider(thickness: 0.5, color: Colors.grey),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: manageWidth(context, 10)),
                  child: Text(
                    "S'identifier avec",
                    style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Divider(thickness: 0.5, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 40),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    await AuthService().signInWithGoogle().then((value) {
                      if (value != null) {
                        Navigator.pushAndRemoveUntil(context,
                            MaterialPageRoute(builder: (context) {
                          return MainPage();
                        }), (route) => false);
                      }
                    });
                  },
                  child: SquareAuthProvider(
                      imagePath: "images/login_images/google_logo.png"),
                ),
                SizedBox(
                  width: manageWidth(context, 20),
                ),
                SquareAuthProvider(
                    imagePath: "images/login_images/apple_logo.png"),
              ],
            ),
          ],
        )),
      ),
    );
  }
}
