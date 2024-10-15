import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/authentication_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/service_provider_informations_page.dart';
import 'package:trade_hart/views/authentication_pages/shop_informations_page.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpPage extends StatefulWidget {
  final String type;
  const SignUpPage({super.key, required this.type});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isLoading = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitleText(
              title: "TradeHart Inscription", size: manageWidth(context, 20)),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: manageWidth(context, 70),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.person,
                      size: manageWidth(context, 65),
                    ),
                  ),
                ),
                SizedBox(
                  height: manageHeight(context, 20),
                ),
                // Champ de saisie nom
                AuthTextField(
                    controller: nameController,
                    hintText: "Nom",
                    obscuretext: false),
                SizedBox(
                  height: manageHeight(context, 20),
                ),
                // Champ de saisie prénom
                AuthTextField(
                    controller: firstNameController,
                    hintText: "Prénom",
                    obscuretext: false),
                SizedBox(
                  height: manageHeight(context, 20),
                ),
                // Champ de saisie pour l'email
                AuthTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscuretext: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: manageHeight(context, 20)),
                // Champ de saisie pour le mot de passe
                AuthTextField(
                  controller: passwordController,
                  hintText: "Mot de passe",
                  obscuretext: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(height: manageHeight(context, 20)),
                AuthTextField(
                  controller: confirmPasswordController,
                  hintText: "Confirmer le mot de passe",
                  obscuretext: true,
                  keyboardType: TextInputType.visiblePassword,
                ),
                SizedBox(
                  height: manageHeight(context, 15),
                ),

                Padding(
                  padding: EdgeInsets.fromLTRB(manageWidth(context, 12),
                      manageWidth(context, 12), manageWidth(context, 12), 0),
                  child: Text(
                    "En poursuivant, vous approuvez toute la politque de confidentiaté de TradHart ainsi que les conditions générales d'utilisation. Sachez qu'afin d'améliorer votre expérience utilisateur, TradHart collecte certaines de vos données.",
                    style:
                        GoogleFonts.poppins(fontSize: manageWidth(context, 11)),
                  ),
                ),

                TextButton(
                    onPressed: () {
                      launchUrl(Uri.parse("https://tradhart.com"));
                    },
                    child: const Text("En savoir plus")),
                // Bouton pour s'inscrire
                GestureDetector(
                  onTap: () async {
                    if (confirmPasswordController.text !=
                        passwordController.text) {
                      setState(() {
                        signUpErrorMessage =
                            "Les deux mots de passe ne sont pas identiques.";
                      });
                    } else if (nameController.text.isEmpty ||
                        firstNameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        passwordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      setState(() {
                        signUpErrorMessage =
                            "Veuillez remplir tous les champs.";
                      });
                    } else {
                      setState(() {
                        isLoading = true;
                      });

                      switch (widget.type) {
                        case "buyer":
                          await AuthService()
                              .signUpWithEmailAndPassword(
                                  emailController.text, passwordController.text)
                              .then((value) async {
                            if (value != null) {
                              await AuthService()
                                  .addBuyerInformations(nameController.text,
                                      firstNameController.text)
                                  .then((value) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const MainPage();
                                }));
                              });
                            }
                          });

                          break;

                        case "seller":
                          await AuthService()
                              .signUpWithEmailAndPassword(
                                  emailController.text, passwordController.text)
                              .then((value) async {
                            if (value != null) {
                              await AuthService()
                                  .addSellerInformations(nameController.text,
                                      firstNameController.text)
                                  .then((value) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const ShopInformationsPage();
                                }));
                              });
                            }
                          });
                          break;

                        case "provider":
                          await AuthService()
                              .signUpWithEmailAndPassword(
                                  emailController.text, passwordController.text)
                              .then((value) async {
                            if (value != null) {
                              await AuthService()
                                  .addProviderInformations(nameController.text,
                                      firstNameController.text)
                                  .then((value) {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ServiceProviderInformationsPage();
                                }));
                              });
                            }
                          });

                          break;
                      }

                      setState(() {
                        isLoading = false;
                      });
                    }
                  },
                  child: Container(
                    width: manageWidth(context, 200),
                    height: manageHeight(context, 50),
                    decoration: BoxDecoration(
                      color:
                          isLoading ? Colors.transparent : AppColors.mainColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mainColor,
                            ),
                          )
                        : Center(
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

                Text(
                  signUpErrorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
                Text(isCreated)
              ],
            ),
          ),
        ));
  }
}
