import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/reset_pass_word_page.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/authentication_pages/widgets/square_auth_provider.dart';

class ReAuthPage extends StatefulWidget {
  const ReAuthPage({super.key});

  @override
  State<ReAuthPage> createState() => _ReAuthPageState();
}

class _ReAuthPageState extends State<ReAuthPage> {
  var emailController = TextEditingController();
  var passWordController = TextEditingController();
  String errorMessage = "";
  String isConnected = "";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(title: "Suppression de Compte", size: 18),
      ),
      body: Column(
        children: [
          SizedBox(
            height: manageHeight(context, 20),
          ),
          AppBarTitleText(title: "Veuillez vous réauthentifier.", size: 16),

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
          // Bouton de ré-authentification et suppression de compte
          GestureDetector(
            onTap: () async {
              if (emailController.text.isEmpty ||
                  passWordController.text.isEmpty) {
                setState(() {
                  errorMessage = "Veuillez remplir tous les champs.";
                  isConnected = "non connecté";
                });
              } else {
                bool success = await _reauthenticateWithEmailAndDeleteAccount(
                  emailController.text,
                  passWordController.text,
                );
                if (success) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                }
              }
            },
            child: Container(
              width: manageWidth(context, 200),
              height: manageHeight(context, 50),
              padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
              decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: BorderRadius.circular(25)),
              child: Center(
                child: Text("Supprimer mon compte",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: manageWidth(context, 16))),
              ),
            ),
          ),
          Text(isConnected),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
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
                padding:
                    EdgeInsets.symmetric(horizontal: manageWidth(context, 10)),
                child: Text(
                  "S'identifier avec",
                  style: TextStyle(
                      color: Colors.grey.shade600, fontWeight: FontWeight.w600),
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
                  bool success =
                      await _reauthenticateWithGoogleAndDeleteAccount();
                  if (success) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                  }
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
      ),
    );
  }

  Future<bool> _reauthenticateWithEmailAndDeleteAccount(
      String email, String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
        var result = await user.reauthenticateWithCredential(credential);
        var ref = _firestore.collection('Users').doc(user.uid);
        var data = await ref.get();
        String userType = data.data()!["user type"];
        var reservations = await FirebaseFirestore.instance
            .collection('Reservations')
            .where("buyer id", isEqualTo: _auth.currentUser!.uid)
            .where("status", isEqualTo: "En cours de traitement")
            .get();
        var docs = reservations.docs;
        if (docs.isNotEmpty) {
          setState(() {
            errorMessage = "Vous avez des réservations en cours de traitement";
          });
          return false;
        }
        var commands = await FirebaseFirestore.instance
            .collection('Commands')
            .where("seller id", isEqualTo: _auth.currentUser!.uid)
            .where("status", isEqualTo: "En cours de traitement")
            .get();
        var commandsDocs = commands.docs;
        if (commandsDocs.isNotEmpty) {
          setState(() {
            errorMessage = "Vous avez des commandes en cours de traitement";
          });
          return false;
        }
        if (userType == "provider") {
          var reservations = await FirebaseFirestore.instance
              .collection('Reservations')
              .where("seller id", isEqualTo: _auth.currentUser!.uid)
              .where("status", isEqualTo: "En cours de traitement")
              .get();
          var docs = reservations.docs;
          if (docs.isNotEmpty) {
            setState(() {
              errorMessage =
                  "Vous avez des réservations en cours de traitement";
            });
            return false;
          }
        }
        if (userType == "seller") {
          var reservations = await FirebaseFirestore.instance
              .collection('Commands')
              .where("seller id", isEqualTo: _auth.currentUser!.uid)
              .where("status", isEqualTo: "En cours de traitement")
              .get();
          var docs = reservations.docs;
          if (docs.isNotEmpty) {
            setState(() {
              errorMessage = "Vous avez des commandes en cours de traitement";
            });
            return false;
          }
        }

        await _firestore.collection('Users').doc(user.uid).delete();

        var articles = await _firestore
            .collection('Articles')
            .where('sellerId', isEqualTo: user.uid)
            .get();

        var services = await _firestore
            .collection('Services')
            .where('sellerId', isEqualTo: user.uid)
            .get();

        if (articles.docs.isNotEmpty) {
          for (var element in articles.docs) {
            _firestore.collection('Articles').doc(element.id).delete();
          }
        }

        if (services.docs.isNotEmpty) {
          for (var element in services.docs) {
            _firestore.collection('Services').doc(element.id).delete();
          }
        }

        result.user!.delete();

        return true;
      }
    } catch (e) {
      setState(() {
        errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
      });
    }
    return false;
  }

  Future<bool> _reauthenticateWithGoogleAndDeleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          return false; // L'utilisateur a annulé l'opération de connexion
        }
        var reservations = await FirebaseFirestore.instance
            .collection('Reservations')
            .where("buyer id", isEqualTo: _auth.currentUser!.uid)
            .where("status", isEqualTo: "En cours de traitement")
            .get();
        var docs = reservations.docs;
        if (docs.isNotEmpty) {
          setState(() {
            errorMessage = "Vous avez des réservations en cours de traitement";
          });
          return false;
        }
        var commands = await FirebaseFirestore.instance
            .collection('Commands')
            .where("seller id", isEqualTo: _auth.currentUser!.uid)
            .where("status", isEqualTo: "En cours de traitement")
            .get();
        var commandsDocs = commands.docs;
        if (commandsDocs.isNotEmpty) {
          setState(() {
            errorMessage = "Vous avez des commandes en cours de traitement";
          });
          return false;
        }
        GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        var result = await user.reauthenticateWithCredential(credential);
        await _firestore.collection('Users').doc(user.uid).delete();
        result.user!.delete();
        return true;
      }
    } catch (e) {
      setState(() {
        errorMessage = "Une erreur s'est produite. Veuillez réessayer.";
      });
    }
    return false;
  }
}
