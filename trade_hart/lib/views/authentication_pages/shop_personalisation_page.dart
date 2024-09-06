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
import 'package:trade_hart/personalisation_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/main_page_components/pages/shop_page_seller.dart';
import 'package:path_provider/path_provider.dart';

class ShopPersonnalisationPage extends StatefulWidget {
  const ShopPersonnalisationPage({super.key});

  @override
  State<ShopPersonnalisationPage> createState() =>
      _ShopPersonnalisationPageState();
}

class _ShopPersonnalisationPageState extends State<ShopPersonnalisationPage> {
  TextEditingController descriptionController = TextEditingController();
  File? _imageFile;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String imageUrl = "";
  bool isImporting = false;

  Future<void> choisirImage(ImageSource source) async {
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

  Future<void> personnalisation(File imageFile) async {
    setState(() async {
      try {
        String userId = _auth.currentUser!.uid;
        String imageName =
            '$userId${DateTime.now().millisecondsSinceEpoch.toString()}${imageFile.path.split('/').last}';
        var reference = FirebaseStorage.instance
            .ref()
            .child('shop_images_covers/$imageName');

        File compressedFile = await compressImage(_imageFile!);

        await reference.putFile(compressedFile);

        String imageUrl = await reference.getDownloadURL();

        // Mettre à jour le champ cover_image_url dans le document de l'utilisateur
        await _firestore.collection('Users').doc(userId).set({
          'shop': {
            'cover image': imageUrl,
            'image name': imageName,
          }
        }, SetOptions(merge: true));

        //print('Image ajoutée avec succès. URL : $imageUrl');
      } catch (e) {
        // print(
        //  'Erreur lors de l\'ajout de l\'image au stockage Firebase : $e');
      }

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
            imageUrl = shopData["cover image"];
          });

          // Utiliser les données du document comme nécessaire
          // print('Données du document : $data');
        } else {
          // print('Document non trouvé.');
        }
      } catch (e) {
        //print('Erreur lors de la récupération des données : $e');
      }
      //await Future.delayed(const Duration(seconds: 4));

      setState(() {
        isImporting = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: manageHeight(context, 50),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.98,
                    height: MediaQuery.of(context).size.height * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: const Color.fromARGB(255, 255, 241, 241)
                          .withOpacity(0.8),
                    ),
                    child: _imageFile == null
                        ? Image.asset(
                            "images/shop_main_bg.png",
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _imageFile!,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                Center(
                  child: Container(
                    height: manageHeight(context, 40),
                    width: manageWidth(context, 40),
                    padding: const EdgeInsets.all(1),
                    child: isImporting
                        ? const CircularProgressIndicator(
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
                                  child: const Icon(
                                    CupertinoIcons.camera,
                                    size: 16,
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
                              choisirImage(ImageSource.camera);
                            },
                          ),
                          ListTile(
                            title: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey.shade400,
                                  radius: manageWidth(context, 15),
                                  child: const Icon(
                                    CupertinoIcons.photo,
                                    size: 16,
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
                              choisirImage(ImageSource.gallery);
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
                  child: const Icon(
                    CupertinoIcons.camera,
                    size: 25,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 30),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: manageWidth(context, 15),
              ),
              width: manageWidth(context, 335),
              height: manageHeight(context, 200),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(manageWidth(context, 8.0)),
                child: TextField(
                  controller: descriptionController,
                  maxLines: null,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ajouter une description à votre boutique",
                    hintStyle: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            GestureDetector(
              onTap: () {
                if (descriptionController.text.isNotEmpty) {
                  setState(() {
                    isImporting = true;
                  });

                  try {
                    personnalisation(_imageFile!);
                    ShopPersonnalisationService()
                        .addShopDescription(descriptionController.text);
                  } catch (e) {
                    setState(() {
                      isImporting = false;
                    });
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ShopPageSeller(),
                    ),
                  );
                }
              },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                decoration: BoxDecoration(
                  color: AppColors.mainColor,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Center(
                  child: Text(
                    "Suivant",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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
