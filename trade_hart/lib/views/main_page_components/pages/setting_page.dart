// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/login_page.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/reauth_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isLoading = false;
  var nameController = TextEditingController();
  var firstNameController = TextEditingController();
  var userId = FirebaseAuth.instance.currentUser!.uid;

  void getData() async {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection("Users").doc(userId).get();

    setState(() {
      firstNameController.text = snapshot.data()!["first name"];
      nameController.text = snapshot.data()!["name"];
    });
  }

  showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirmation',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ?\n Ceci entrainera la supression de toutes vos données. Meme celles associées à votre boutique et vos services si vous en avez.',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Annuler',
                style: GoogleFonts.poppins(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Supprimer',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ReAuthPage()));
                // Ajoutez ici le code pour supprimer le compte
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
          title: "Paramètres",
          size: manageWidth(context, 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: manageWidth(context, 25)),
                  child: Text("Prénom"),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(manageWidth(context, 10)),
              child: AuthTextField(
                  controller: firstNameController,
                  hintText: "",
                  obscuretext: false),
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: manageWidth(context, 25)),
                  child: Text("Nom"),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(manageWidth(context, 10)),
              child: AuthTextField(
                  controller: nameController, hintText: "", obscuretext: false),
            ),
            SizedBox(
              height: manageHeight(context, 50),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                await FirebaseFirestore.instance
                    .collection('Users')
                    .doc(userId)
                    .update({
                  'first name': firstNameController.text,
                  'name': nameController.text[0].toUpperCase() +
                      nameController.text.substring(1),
                });
                setState(() {
                  isLoading = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                    "Modification effectuée avec succès!",
                    style: TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.green,
                ));
              },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 25))),
                child: Center(
                  child: Text("Modifier",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16))),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            CircularProgressIndicator(
              color: !isLoading ? Colors.transparent : AppColors.mainColor,
            ),
            SizedBox(
              height: manageHeight(context, 60),
            ),
            Padding(
              padding: EdgeInsets.all(manageWidth(context, 15)),
              child: Row(
                children: [
                  Icon(
                    Icons.logout,
                    size: manageWidth(context, 15),
                    color: Colors.deepPurple,
                  ),
                  TextButton(
                      onPressed: () {
                        // if (FirebaseAuth.instance.currentUser!.providerData
                        //         .first.providerId !=
                        //     "google.com") {
                        //   Navigator.pop(context);
                        // } else {
                        //   Navigator.pop(context);
                        // }
                        GoogleSignIn().signOut();

                        FirebaseAuth.instance.signOut();

                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                            (route) => false);
                      },
                      child: Text(
                        "Se déconnecter",
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                        ),
                      ))
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(manageWidth(context, 15)),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.trash,
                    size: manageWidth(context, 15),
                    color: Colors.red,
                  ),
                  TextButton(
                      onPressed: () {
                        showConfirmationDialog(context);
                      },
                      child: Text(
                        "Supprimer mon compte",
                        style: GoogleFonts.poppins(
                            fontSize: 15, color: Colors.red),
                      ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
