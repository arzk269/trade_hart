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
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_profil_page.dart';
import 'package:path_provider/path_provider.dart';

class ServiceProviderPersonalizationPage extends StatefulWidget {
  const ServiceProviderPersonalizationPage({super.key});

  @override
  State<ServiceProviderPersonalizationPage> createState() =>
      _ServiceProviderPersonalizationPageState();
}

class _ServiceProviderPersonalizationPageState
    extends State<ServiceProviderPersonalizationPage> {
  String coverUrl = "";
  String profilUrl = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController experienceYearsController = TextEditingController();
  File? _coverImageFile;
  File? _profilImageFile;
  bool isImporting = false;

  Future<void> personnalisation(
    File coverImageFile,
    File profilImageFile,
  ) async {
    setState(() async {
      try {
        String userId = _auth.currentUser!.uid;
        String coverImageName =
            '$userId${DateTime.now().millisecondsSinceEpoch.toString()}${coverImageFile.path.split('/').last}';
        var coverReference = FirebaseStorage.instance
            .ref()
            .child('services_providers_images_covers/$coverImageName');
        File coverImageCompressed = await compressImage(_coverImageFile!);

        await coverReference.putFile(coverImageCompressed);
        String coverImageUrl = await coverReference.getDownloadURL();
        File profilImageCompressed = await compressImage(_profilImageFile!);
        String profilImageName =
            '$userId${DateTime.now().millisecondsSinceEpoch.toString()}${profilImageFile.path.split('/').last}';
        var profilImageReference = FirebaseStorage.instance
            .ref()
            .child('services_providers_profil_images/$profilImageName');
        await profilImageReference.putFile(profilImageCompressed);
        String profilImageUrl = await profilImageReference.getDownloadURL();

        // Mettre à jour le champ cover_image_url dans le document de l'utilisateur
        await _firestore.collection('Users').doc(userId).set({
          'images': {
            'cover image': coverImageUrl,
            'profil image': profilImageUrl,
            'cover file name': coverImageName,
            'profil file name': profilImageName
            // 'image name': imageName,
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
          Map<String, dynamic> imageData = data["images"];
          setState(() {
            coverUrl = imageData["cover image"];
            profilUrl = imageData["profil image"];
          });

          // Utiliser les données du document comme nécessaire
          // print('Données du document : $data');
        } else {
          // print('Document non trouvé.');
        }
      } catch (e) {
        //print('Erreur lors de la récupération des données : $e');
      }
      //await Future.delayed( Duration(seconds: 4));

      setState(() {
        isImporting = false;
      });
    });
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

  Future<void> choisirCoverImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      var croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 0.98 * 360, ratioY: 0.3 * 725),
        compressQuality: 100,
      );

      if (croppedFile != null) {
        setState(() {
          _coverImageFile = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> choisirProfilImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      var croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 0.98 * 360, ratioY: 0.3 * 725),
        compressQuality: 100,
      );

      if (croppedFile != null) {
        setState(() {
          _profilImageFile = File(croppedFile.path);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: manageHeight(context, 35),
            ),
            Stack(
              children: [
                Container(
                  height: MediaQuery.sizeOf(context).height * (1 / 3.8),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(manageWidth(context, 20)),
                    color: Colors.white,
                    image: DecorationImage(
                      image: _coverImageFile == null
                          ? const AssetImage("images/service_provider_cover.png")
                          : coverUrl.isEmpty
                              ? FileImage(_coverImageFile!) as ImageProvider
                              : NetworkImage(coverUrl),
                      fit: coverUrl.isEmpty && _coverImageFile == null
                          ? BoxFit.fitHeight
                          : BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.sizeOf(context).height * (1 / 4.1),
                    left: manageWidth(context, 320),
                  ),
                  child: GestureDetector(
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
                                    choisirCoverImage(ImageSource.camera);
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
                                        "Galerie",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: manageWidth(context, 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    choisirCoverImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 228, 228, 228),
                      radius: manageWidth(context, 15),
                      child: Icon(CupertinoIcons.add,
                          size: manageWidth(context, 16)),
                    ),
                  ),
                ),
                Container(
                  width: manageWidth(context, 103 * 0.72),
                  height: manageWidth(context, 103 * 0.72),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        manageWidth(context, 103 * 0.72 * 0.5)),
                    color: Colors.white,
                  ),
                  margin: EdgeInsets.only(
                    top: manageHeight(context, 165),
                    left: manageWidth(context, 12),
                  ),
                  child: Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.grey.shade100,
                      radius: manageWidth(context, 50 * 0.7),
                      child: _profilImageFile == null
                          ? Center(
                              child: Icon(
                                CupertinoIcons.person,
                                size: manageWidth(context, 45 * 0.7),
                              ),
                            )
                          : Container(
                              height: manageWidth(context, 100 * 0.7),
                              width: manageWidth(context, 100 * 0.7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    manageWidth(context, 50 * 0.7)),
                                image: DecorationImage(
                                  image: profilUrl.isEmpty
                                      ? FileImage(_profilImageFile!)
                                          as ImageProvider
                                      : NetworkImage(profilUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: MediaQuery.sizeOf(context).height * (1 / 3.3),
                    left: manageWidth(context, 55),
                  ),
                  child: GestureDetector(
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
                                    choisirProfilImage(ImageSource.camera);
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
                                        "Galerie",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: manageWidth(context, 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    choisirProfilImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: const Color.fromARGB(255, 228, 228, 228),
                      radius: manageWidth(context, 15 * 0.7),
                      child: Icon(CupertinoIcons.add,
                          size: manageWidth(context, 16 * 0.7)),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
              width: manageWidth(context, 335),
              height: manageHeight(context, 200),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(manageWidth(context, 20)),
              ),
              child: Padding(
                padding: EdgeInsets.all(manageWidth(context, 8.0)),
                child: TextField(
                  controller: descriptionController,
                  maxLines: null,
                  maxLength: 250,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Ajouter une description ",
                    hintStyle: TextStyle(fontSize: manageWidth(context, 15)),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 20),
            ),
            AuthTextField(
              controller: experienceYearsController,
              hintText: "nombre d'années d'expérience ",
              obscuretext: false,
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: manageHeight(context, 40),
            ),
            GestureDetector(
              onTap: () async {
                setState(() {
                  isImporting = true;
                });
                if (descriptionController.text.isEmpty ||
                    experienceYearsController.text.isEmpty) {
                  var snackBar = const SnackBar(
                    content: Text("veuillez remplir tous les champs"),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    isImporting = false;
                  });
                } else if (_profilImageFile == null ||
                    _coverImageFile == null) {
                  var snackBar = const SnackBar(
                    content: Text(
                        "veuillez importer les images de profil et de couverture"),
                    backgroundColor: Colors.red,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  setState(() {
                    isImporting = false;
                  });
                } else {
                  personnalisation(_coverImageFile!, _profilImageFile!);
                  ServicePersonnalisationService()
                      .addProviderDescription(descriptionController.text,
                          int.parse(experienceYearsController.text))
                      .then((value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ServiceProviderProfilPage())));
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
            SizedBox(
              height: manageHeight(context, 20),
            ),
            CircularProgressIndicator(
              color: isImporting ? AppColors.mainColor : Colors.transparent,
            ),
            SizedBox(
              height: manageHeight(context, 50),
            ),
          ],
        ),
      ),
    );
  }
}
