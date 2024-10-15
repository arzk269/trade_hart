// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:path_provider/path_provider.dart';

class ShopUpdatingPage extends StatefulWidget {
  const ShopUpdatingPage({super.key});

  @override
  State<ShopUpdatingPage> createState() => _ShopPersonnalisationPageState();
}

class _ShopPersonnalisationPageState extends State<ShopUpdatingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController descriptionController = TextEditingController();
  File? _imageFile = File("");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String imageUrl = "";
  String oldCoverName = "";
  bool isImporting = false;

  Future<void> getShopCutomization() async {
    try {
      // Référence à la collection Firestore
      CollectionReference<Map<String, dynamic>> reference =
          FirebaseFirestore.instance.collection("Users");

      // Obtenir les données du document
      DocumentSnapshot<Map<String, dynamic>> snapshot =
          await reference.doc(_auth.currentUser!.uid).get();

      // Vérifier si le document existe
      if (snapshot.exists) {
        // Accéder aux données du document
        Map<String, dynamic> data = snapshot.data()!;
        Map<String, dynamic> shopData = data["shop"];
        setState(() {
          descriptionController =
              TextEditingController(text: shopData["shop description"]);
        });
        setState(() {
          imageUrl = shopData["cover image"];
          oldCoverName = shopData["image name"];
        });
        // Utiliser les données du document comme nécessaire
        // print('Données du document : $data');
      } else {
        // print('Document non trouvé.');
      }
    } catch (e) {
      //print('Erreur lors de la récupération des données : $e');
    }
  }

  Future<File> compressImage(File file) async {
    final int fileSize = file.lengthSync();

    // Calculate the quality based on the file size
    int quality = 100;
    if (fileSize < 300 * 1024) {
      quality = 95; // Très bonne qualité pour les fichiers < 300 Ko
    } else if (fileSize < 600 * 1024) {
      quality = 90; // Bonne qualité pour les fichiers entre 300 Ko et 600 Ko
    } else if (fileSize < 1000 * 1024) {
      quality = 85; // Qualité moyenne pour les fichiers entre 600 Ko et 1 Mo
    } else if (fileSize < 2000 * 1024) {
      quality = 80; // Qualité acceptable pour les fichiers entre 1 Mo et 2 Mo
    } else {
      quality = 75; // Qualité de base pour les fichiers > 2 Mo
    }

    // Compress the image
    final Directory tempDir = await getTemporaryDirectory();

    final String targetPath =
        '${tempDir.path}/${file.uri.pathSegments.last.split('.').first}_compressed.jpg';

    final XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: quality,
    );

    if (compressedFile == null) {
      throw Exception('Image compression failed');
    }

    return File(compressedFile.path);
  }

  Future<void> ajouterImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      var croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 0.98 * 360, ratioY: 0.3 * 725),
        compressQuality: 100,
      );

      if (croppedFile != null) {
        setState(() {
          _imageFile = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> editDescription(String newDescription) async {
    CollectionReference<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.collection("Users");

    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await reference.doc(_auth.currentUser!.uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      Map<String, dynamic> shopData = data["shop"];
      shopData["shop description"] = newDescription;
      data["shop"] = shopData;
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .update(data);
    }
  }

  Future<void> modifierImage(File imageFile) async {
    // Référence à la collection Firestore
    CollectionReference<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.collection("Users");

    // Obtenir les données du document
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await reference.doc(_auth.currentUser!.uid).get();

    try {
      // Vérifier si le document existe
      if (snapshot.exists) {
        // Accéder aux données du document
        Map<String, dynamic> data = snapshot.data()!;
        Map<String, dynamic> shopData = data["shop"];
        setState(() {
          oldCoverName = shopData["image name"];
        });
        // Utiliser les données du document comme nécessaire
        // print('Données du document : $data');
      } else {
        // print('Document non trouvé.');
      }
    } catch (e) {
      //print('Erreur lors de la récupération des données : $e');
    }
    try {
      String userId = _auth.currentUser!.uid;
      String newImageName =
          '$userId${DateTime.now().millisecondsSinceEpoch.toString()}${imageFile.path.split('/').last}';
      var reference = FirebaseStorage.instance
          .ref()
          .child('shop_images_covers/$newImageName');
      File compressedFile = await compressImage(imageFile);

      await reference.putFile(compressedFile);

      String imageUrl = await reference.getDownloadURL();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        Map<String, dynamic> shopData = data["shop"];
        shopData["cover image"] = imageUrl;
        shopData["image name"] = newImageName;
        data["shop"] = shopData;
        await _firestore.collection('Users').doc(userId).update(data);
      }

      // Mettre à jour le champ cover_image_url dans le document de l'utilisateur

      //print('Image ajoutée avec succès. URL : $imageUrl');
    } catch (e) {
      // print(
      //  'Erreur lors de l\'ajout de l\'image au stockage Firebase : $e');
    }

    try {
      // Supprimer le fichier avec le nom spécifié dans le répertoire shop_images_covers
      await FirebaseStorage.instance
          .ref()
          .child('shop_images_covers/$oldCoverName')
          .delete();
    } catch (e) {
      //
    }
  }

  @override
  void initState() {
    getShopCutomization();
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
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 10),
                ),
                MainBackButton(),
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                Center(
                  child: Text(
                    "Modifier votre boutique",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: manageWidth(context, 17),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.98,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 15)),
                      color:
                          Color.fromARGB(255, 255, 241, 241).withOpacity(0.8),
                      // image: DecorationImage(
                      //   image: AssetImage("images/shop_main_bg.png"),
                      //   fit: BoxFit.cover,
                      // )
                    ),
                    child: _imageFile!.path == ""
                        ? ClipRRect(
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 15)),
                            child: imageUrl.isEmpty
                                ? SizedBox()
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        SizedBox(
                                            height: manageHeight(context, 150),
                                            width: manageWidth(context, 165),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  CupertinoIcons
                                                      .exclamationmark_triangle,
                                                  size:
                                                      manageWidth(context, 30),
                                                ),
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 3),
                                                ),
                                                const Text(
                                                  "Erreur lors du chargement",
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                  textAlign: TextAlign.center,
                                                )
                                              ],
                                            )),
                                  ),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 15)),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                Center(
                  child: Container(
                    height: manageWidth(context, 40),
                    width: manageWidth(context, 40),
                    padding: EdgeInsets.all(manageWidth(context, 1)),
                    child: isImporting
                        ? CircularProgressIndicator(
                            color: AppColors.mainColor,
                          )
                        : Container(
                            color: Colors.transparent,
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            Center(
              child: Text(
                "Ajouter une image d'arrière plan",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: manageWidth(context, 15.5),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            GestureDetector(
              onTap: () {
                // Ouvrir une boîte de dialogue ou une interface utilisateur pour permettre à l'utilisateur de choisir entre l'appareil photo et la galerie
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text(
                        "Choisir une option",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: manageWidth(context, 15.5),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade400,
                                  radius: manageWidth(context, 15),
                                  child: Icon(
                                    CupertinoIcons.camera,
                                    size: manageWidth(context, 16),
                                  ),
                                ),
                                SizedBox(
                                  width: manageWidth(context, 10),
                                ),
                                Text(
                                  "Appareil Photo",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: manageWidth(context, 14),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              ajouterImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade400,
                                  radius: manageWidth(context, 15),
                                  child: Icon(
                                    CupertinoIcons.photo,
                                    size: manageWidth(context, 16),
                                  ),
                                ),
                                SizedBox(
                                  width: manageWidth(context, 10),
                                ),
                                Text(
                                  "Gallerie",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: manageWidth(context, 14),
                                  ),
                                ),
                              ],
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              ajouterImage(ImageSource.gallery);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Center(
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: manageWidth(context, 30),
                  child: Icon(
                    CupertinoIcons.camera,
                    size: manageWidth(context, 25),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 30),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
              width: manageWidth(context, 335),
              height: manageHeight(
                  context, 200), // Ajuster la hauteur selon vos besoins
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(manageWidth(context, 20)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  manageWidth(context, 8),
                  manageHeight(context, 8),
                  manageWidth(context, 8),
                  8,
                ),
                child: TextField(
                  controller: descriptionController,
                  maxLines:
                      null, // Permet à TextField de s'ajuster dynamiquement en hauteur
                  maxLength: 250,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            GestureDetector(
              onTap: () {
                if (_imageFile != null) {
                  modifierImage(_imageFile!);
                }
                if (descriptionController.text.isNotEmpty) {
                  editDescription(descriptionController.text)
                      .then((value) => Navigator.pop(context));
                }
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
                    "Terminer",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: manageWidth(context, 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
