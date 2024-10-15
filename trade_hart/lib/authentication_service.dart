import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:trade_hart/model/notification_api.dart';

String errorMessage = "";
String isConnected = "";
String signUpErrorMessage = "";
String isCreated = "";
String resetMessage = "";

final FirebaseAuth _auth = FirebaseAuth.instance;

class AuthService {
  //sign in

  Future<User?> signInWithGoogle() async {
    // Authentification avec Google
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      // L'utilisateur a annulé la connexion
      return null;
    }

    GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

    AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    User? user = userCredential.user;

    if (user == null) {
      // Une erreur est survenue
      return null;
    }

    // Récupérer les informations de l'utilisateur
    String? displayName = user.displayName;
    String? email = user.email;

    // Séparer le nom complet en prénom et nom
    List<String>? nameParts = displayName?.split(' ');
    String firstName = '';
    String name = '';

    if (nameParts != null && nameParts.isNotEmpty) {
      firstName = nameParts.first;
      name =
          nameParts.sublist(1).join(' '); // Gère les noms et prénoms composés
    }

    CollectionReference users = FirebaseFirestore.instance.collection('Users');

    // Vérifier si l'utilisateur existe déjà
    DocumentSnapshot doc = await users.doc(user.uid).get();

    if (!doc.exists) {
      String fcmtoken = await FirebaseApi().requestPermission();
      // Si l'utilisateur n'existe pas, ajouter les informations dans Firestore
      await users.doc(user.uid).set({
        'email': user.email,
        'first name': firstName,
        'name': name[0].toUpperCase() + name.substring(1),
        'user type': 'buyer',
        'fcmtoken': fcmtoken
      });
    }

    print(user.displayName);

    return user;
    // Référence à la collection 'Users' dans Firestore
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      isConnected = "connecté!";
      errorMessage = "";

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        // Problème de connexion Internet.
        errorMessage =
            "Problème de connexion Internet. Veuillez vérifier votre connexion.";
        isConnected = "non connecté";
      } else if (e.code == 'invalid-credential') {
        // Informations non valides
        errorMessage = "email ou mot de passe invalide";
        isConnected = "non connecté";
      } else if (e.code == 'invalid-email') {
        //Email mal formaté
        errorMessage = "email invalide";
        isConnected = "non connecté";
      } else {
        // Autres erreurs non gérées.
        errorMessage = "Erreur de connexion. Veuillez réessayer.";
        isConnected = "non connecté";
      }
      return null;
    }
  }

// Sign Up
  Future<User?> signUpWithEmailAndPassword(
      String email, String password) async {
    // Vérifier la longueur minimale de 8 caractères

    try {
      if (password.length < 8) {
        signUpErrorMessage =
            "Le mot de passe est trop faible. Il doit contenir au moins 8 caractères dont une majuscule, un caractère spéCial et un chiffre.";

        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Le mot de passe doit contenir au moins 8 caractères.',
        );
      }

      // Vérifier la présence d'au moins une majuscule
      if (!password.contains(RegExp(r'[A-Z]'))) {
        signUpErrorMessage =
            "Le mot de passe est trop faible. Il doit contenir au moins 8 caractères dont une majuscule, un caractère spéCial et un chiffre.";

        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Le mot de passe doit contenir au moins une majuscule.',
        );
      }

      // Vérifier la présence d'au moins un chiffre
      if (!password.contains(RegExp(r'[0-9]'))) {
        signUpErrorMessage =
            "Le mot de passe est trop faible. Il doit contenir au moins 8 caractères dont une majuscule, un caractère spéCial et un chiffre.";

        throw FirebaseAuthException(
          code: 'weak-password',
          message: 'Le mot de passe doit contenir au moins un chiffre.',
        );
      }

      // Vérifier la présence d'au moins un caractère spécial
      if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        signUpErrorMessage =
            "Le mot de passe est trop faible. Il doit contenir au moins 8 caractères dont une majuscule, un caractère spéCial et un chiffre.";

        throw FirebaseAuthException(
          code: 'weak-password',
          message:
              'Le mot de passe doit contenir au moins un caractère spécial.',
        );
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      isCreated = "connecté!";
      signUpErrorMessage = "";

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        signUpErrorMessage =
            "Problème de connexion Internet. Veuillez vérifier votre connexion.";
        isCreated = "non connecté";
      } else if (e.code == 'email-already-in-use') {
        signUpErrorMessage = "Cet email est déjà utilisé par un autre compte.";
      } else if (e.code == 'invalid-email') {
        signUpErrorMessage = "Email mal formaté.";
      } else if (e.code == 'weak-password') {
        signUpErrorMessage =
            "Le mot de passe est trop faible. Il doit contenir au moins 8 caractères dont une majuscule, un caractère spéCial et un chiffre.";
      } else {
        signUpErrorMessage =
            "Erreur lors de la création du compte. Veuillez réessayer.";
        isCreated = "non connecté";
      }
      return null;
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        resetMessage = "Email mal formaté.";
      } else if (e.code == 'invalid-credential') {
        // Informations non valides
        resetMessage = "email ou mot de passe invalide";
      }
      //print("Erreur de réinitialisation de mot de passe: $e");
      else {
        resetMessage =
            "Erreur lors de la réinitialisation du mot de passe veuillez réessayer.";
      }
    }
  }

  // Add user inforations
  Future<void> addBuyerInformations(
    String name,
    String firstName,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //print("Utilisateur actuel : ${user.uid}");

      if (firstName.isNotEmpty && name.isNotEmpty) {
        // Continuez seulement si le code postal a pu être converti.

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        String fcmtoken = await FirebaseApi().requestPermission();
        try {
          await firestore.collection('Users').doc(user.uid).set({
            'email': user.email,
            'first name': firstName,
            'name': name[0].toUpperCase() + name.substring(1),
            'user type': 'buyer',
            'fcmtoken': fcmtoken
          });

          // print("Données ajoutées avec succès à la collection Buyers");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'network-request-failed') {
            isCreated = "Problème de connexion";
          } else {
            isCreated =
                "Une erreur s'est produite lors de l'ajout de vos informations.";
          }
          // print("Erreur lors de l'ajout des données : $e");
        }
      }
    }
  }

  Future<void> addSellerInformations(
    String name,
    String firstName,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //print("Utilisateur actuel : ${user.uid}");

      if (firstName.isNotEmpty && name.isNotEmpty) {
        // Continuez seulement si le code postal a pu être converti.

        FirebaseFirestore firestore = FirebaseFirestore.instance;

        String fcmtoken = await FirebaseApi().requestPermission();

        try {
          await firestore.collection('Users').doc(user.uid).set({
            'email': user.email,
            'first name': firstName[0].toUpperCase() + firstName.substring(1),
            'name': name[0].toUpperCase() + name.substring(1),
            'user type': 'seller',
            'fcmtoken': fcmtoken
          });

          // print("Données ajoutées avec succès à la collection Buyers");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'network-request-failed') {
            isCreated = "Problème de connexion";
          } else {
            isCreated =
                "Une erreur s'est produite lors de l'ajout de vos informations.";
          }
          // print("Erreur lors de l'ajout des données : $e");
        }
      }
    }
  }
  //add provider informations

  Future<void> addProviderInformations(
    String name,
    String firstName,
  ) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //print("Utilisateur actuel : ${user.uid}");

      if (firstName.isNotEmpty && name.isNotEmpty) {
        // Continuez seulement si le code postal a pu être converti.

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        String fcmtoken = await FirebaseApi().requestPermission();
        try {
          await firestore.collection('Users').doc(user.uid).set({
            'email': user.email,
            'first name': firstName[0].toUpperCase() + firstName.substring(1),
            'name': name[0].toUpperCase() + name.substring(1),
            'name to lower case': name.toLowerCase(),
            'first name to lower case': firstName.toLowerCase(),
            'user type': 'provider',
            'fcmtoken': fcmtoken
          });

          // print("Données ajoutées avec succès à la collection Buyers");
        } on FirebaseAuthException catch (e) {
          if (e.code == 'network-request-failed') {
            isCreated = "Problème de connexion";
          } else {
            isCreated =
                "Une erreur s'est produite lors de l'ajout de vos informations.";
          }
          // print("Erreur lors de l'ajout des données : $e");
        }
      }
    }
  }

  //add shop informations

  Future<void> addShopInformations(String name, String email, int number,
      String? adress, String? city, int? codePostal) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //print("Utilisateur actuel : ${user.uid}");

      if (name.isNotEmpty && email.isNotEmpty) {
        // Continuez seulement si le code postal a pu être converti.

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        var sellers = await firestore
            .collection('Users')
            .where('user type', isEqualTo: 'seller')
            .where('shop.name',
                isEqualTo: name[0].toUpperCase() + name.substring(1))
            .get();

        if (sellers.docs.isNotEmpty) {
          isCreated =
              "Une boutique TradeHart porte le meme nom que vous avez mentionner";
        } else {
          try {
            await firestore.collection('Users').doc(user.uid).update({
              "shop": {
                'name': name[0].toUpperCase() + name.substring(1),
                'name to lower case': name.toLowerCase(),
                "email": email,
                "number": number,
                "adress": {
                  "adress": adress ?? "",
                  "city": city ?? "",
                  "code postal": codePostal ?? 0
                }
              }
            });

            // print("Données ajoutées avec succès à la collection Buyers");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'network-request-failed') {
              isCreated = "Problème de connexion";
            } else {
              isCreated =
                  "Une erreur s'est produite lors de l'ajout de vos informations.";
            }
            // print("Erreur lors de l'ajout des données : $e");
          }
        }
      }
    }
  }

  //Add Service Provider informations
  Future<void> addServiceProviderInformations(
      String name, int number, String? adress) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      //print("Utilisateur actuel : ${user.uid}");

      if (name.isNotEmpty) {
        // Continuez seulement si le code postal a pu être converti.

        FirebaseFirestore firestore = FirebaseFirestore.instance;
        var providers = await firestore
            .collection('Users')
            .where('user type', isEqualTo: 'provider')
            .where('service.name',
                isEqualTo: name[0].toUpperCase() + name.substring(1))
            .get();
        if (providers.docs.isNotEmpty) {
          isCreated = "Le nom de prestataire mentionné est indisponible.";
        } else {
          try {
            await firestore.collection('Users').doc(user.uid).update({
              "service": {
                'name': name[0].toUpperCase() + name.substring(1),
                'name to lower case': name.toLowerCase(),
                "email": user.email,
                "number": number,
                "location": adress
              }
            });

            // print("Données ajoutées avec succès à la collection Buyers");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'network-request-failed') {
              isCreated = "Problème de connexion";
            } else {
              isCreated =
                  "Une erreur s'est produite lors de l'ajout de vos informations.";
            }
            // print("Erreur lors de l'ajout des données : $e");
          }
        }
      }
    }
  }
}
