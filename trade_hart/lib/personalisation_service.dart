import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopPersonnalisationService {
  Future<void> addShopDescription(String description) async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'shop': {
        'shop description': description,
      }
    }, SetOptions(merge: true));
  }
}

class ServicePersonnalisationService {
  Future<void> addProviderDescription(
      String description, int experience) async {
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'service': {'description': description, 'experience': experience}
    }, SetOptions(merge: true));
  }
}
