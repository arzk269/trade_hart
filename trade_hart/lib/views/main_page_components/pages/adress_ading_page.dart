import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';

class AdressAddingPage extends StatefulWidget {
  const AdressAddingPage({super.key});

  @override
  State<AdressAddingPage> createState() => _AdressAddingPageState();
}

class _AdressAddingPageState extends State<AdressAddingPage> {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController adressController = TextEditingController();
  TextEditingController codePostalController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController complementController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Ajouter une nouvelle adresse",
            size: manageWidth(context, 16.5)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: manageHeight(context, 15),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  manageWidth(context, 8),
                  manageHeight(context, 8),
                  manageWidth(context, 8),
                  manageHeight(context, 8)),
              child: AuthTextField(
                  controller: adressController,
                  hintText: 'Adresse*',
                  obscuretext: false),
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  manageWidth(context, 8),
                  manageHeight(context, 8),
                  manageWidth(context, 8),
                  manageHeight(context, 8)),
              child: AuthTextField(
                controller: codePostalController,
                hintText: 'Code Postal*',
                obscuretext: false,
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  manageWidth(context, 8),
                  manageHeight(context, 8),
                  manageWidth(context, 8),
                  manageHeight(context, 8)),
              child: AuthTextField(
                  controller: cityController,
                  hintText: 'Ville*',
                  obscuretext: false),
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  manageWidth(context, 8),
                  manageHeight(context, 8),
                  manageWidth(context, 8),
                  manageHeight(context, 8)),
              child: AuthTextField(
                  controller: complementController,
                  hintText: 'Complément',
                  obscuretext: false),
            ),
            GestureDetector(
              onTap: () async {
                if (cityController.text.isEmpty ||
                    adressController.text.isEmpty ||
                    codePostalController.text.isEmpty) {
                  const snackBar = SnackBar(
                    content: Text(
                      'Veuillez remplir tous les champs obligatoires.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else if (complementController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userId)
                      .update({
                    'adress': FieldValue.arrayUnion([
                      {
                        'adress': adressController.text,
                        'code postal': codePostalController.text,
                        'city': cityController.text,
                        'complement': complementController.text
                      }
                    ])
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  await FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userId)
                      .update({
                    'adress': FieldValue.arrayUnion([
                      {
                        'adress': adressController.text,
                        'code postal': codePostalController.text,
                        'city': cityController.text,
                      }
                    ])
                  });
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.4,
                    bottom: manageHeight(context, 10)),
                padding: EdgeInsets.fromLTRB(
                    manageWidth(context, 8),
                    manageHeight(context, 8),
                    manageWidth(context, 8),
                    manageHeight(context, 8)),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        offset: const Offset(0, 0),
                        blurRadius: manageHeight(context, 5),
                        spreadRadius: manageHeight(context, 0.4))
                  ],
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 30)),
                  color: AppColors.mainColor,
                ),
                width: manageWidth(context, 200),
                height: manageHeight(context, 55),
                child: Center(
                  child: Text("Ajouter l'adresse",
                      style: GoogleFonts.workSans(
                        color: Colors.white,
                        fontSize: manageWidth(context, 16.5),
                      )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
