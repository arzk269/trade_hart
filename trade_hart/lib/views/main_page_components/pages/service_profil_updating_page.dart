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
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:path_provider/path_provider.dart';

class ServiceUpdatingPage extends StatefulWidget {
  const ServiceUpdatingPage({super.key});

  @override
  State<ServiceUpdatingPage> createState() => _ServiceUpdatingPageState();
}

class _ServiceUpdatingPageState extends State<ServiceUpdatingPage> {
  String oldCoverName = "";
  String oldProfilImageName = "";
  // String coverUrl = "";
  // String profilUrl = "";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController experienceYearsController = TextEditingController();
  File? _coverImageFile;
  File? _profilImageFile;
  bool isImporting = false;

  Future<void> getProfilCutomization() async {
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
        Map<String, dynamic> serviceData = data["service"];
        Map<String, dynamic> imagesData = data["images"];
        setState(() {
          descriptionController =
              TextEditingController(text: serviceData["description"]);
          experienceYearsController =
              TextEditingController(text: serviceData["experience"].toString());
        });
        setState(() {
          // coverUrl = imagesData["cover image"];
          oldCoverName = imagesData["cover file name"];

          // profilUrl = imagesData["profil image"];
          oldProfilImageName = imagesData["profil file name"];
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

  Future<void> modifierImage(
      File? coverimageFile, File? profilImageFile) async {
    CollectionReference<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.collection("Users");

    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await reference.doc(_auth.currentUser!.uid).get();

    Map<String, dynamic> data = snapshot.data()!;

    Map<String, dynamic> imagesData = data["images"];
    try {
      String userId = _auth.currentUser!.uid;

      if (coverimageFile != null) {
        String newCoverImageName =
            '$userId${DateTime.now().millisecondsSinceEpoch.toString()}${coverimageFile.path.split('/').last}';
        var coverReference = FirebaseStorage.instance
            .ref()
            .child('services_providers_images_covers/$newCoverImageName');

        File compressedCoverFile = await compressImage(coverimageFile);

        await coverReference.putFile(compressedCoverFile);

        String coverImageUrl = await coverReference.getDownloadURL();

        imagesData["cover image"] = coverImageUrl;
        imagesData["cover file name"] = newCoverImageName;
        await FirebaseStorage.instance
            .ref()
            .child('services_providers_images_covers/$oldCoverName')
            .delete();
      }

      if (profilImageFile != null) {
        String newProfilImageName =
            '$userId${DateTime.now().millisecondsSinceEpoch.toString()}${profilImageFile.path.split('/').last}';
        var profilImageReference = FirebaseStorage.instance
            .ref()
            .child('services_providers_profil_images/$newProfilImageName');
        File profilImageCompressed = await compressImage(profilImageFile);
        await profilImageReference.putFile(profilImageCompressed);
        String profilImageUrl = await profilImageReference.getDownloadURL();
        imagesData["profil image"] = profilImageUrl;
        imagesData["profil file name"] = newProfilImageName;
        await FirebaseStorage.instance
            .ref()
            .child('services_providers_profil_images/$oldProfilImageName')
            .delete();
      }

      data["images"] = imagesData;

      // Mettre à jour le champ cover_image_url dans le document de l'utilisateur
      await _firestore.collection('Users').doc(userId).update(data);

      //print('Image ajoutée avec succès. URL : $imageUrl');
    } catch (e) {
      // print(
      //  'Erreur lors de l\'ajout de l\'image au stockage Firebase : $e');
    }
  }

  Future<void> choisirCoverImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      var croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 0.98 * 360, ratioY: 0.3 * 725),
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
        aspectRatio: CropAspectRatio(ratioX: 0.98 * 360, ratioY: 0.3 * 725),
        compressQuality: 100,
      );

      if (croppedFile != null) {
        setState(() {
          _profilImageFile = File(croppedFile.path);
        });
      }
    }
  }

  Future<void> editDescription(String description, int experience) async {
    CollectionReference<Map<String, dynamic>> reference =
        FirebaseFirestore.instance.collection("Users");

    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await reference.doc(_auth.currentUser!.uid).get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      Map<String, dynamic> service = data["service"];
      service['description'] = description;
      service['experience'] = experience;
      data["service"] = service;
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .update(data);
    }
  }

  @override
  void initState() {
    getProfilCutomization();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            var data = snapshot.data!.data() as Map<String, dynamic>;
            var images = data["images"] as Map<String, dynamic>;
            // var service = data["service"] as Map<String, dynamic>;
            return SingleChildScrollView(
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
                          // image: DecorationImage(
                          //   image: _coverImageFile == null
                          //       ? NetworkImage(images["cover image"])
                          //       : FileImage(_coverImageFile!) as ImageProvider,
                          //   fit: BoxFit.cover,
                          // ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 20)),
                          child: _coverImageFile == null
                              ? Image.network(
                                  images["cover image"],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      SizedBox(
                                          height: manageHeight(context, 150),
                                          width: manageWidth(context, 165),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                CupertinoIcons
                                                    .exclamationmark_triangle_fill,
                                                size: manageWidth(context, 20),
                                              ),
                                            ],
                                          )),
                                )
                              : Image.file(
                                  _coverImageFile!,
                                  fit: BoxFit.cover,
                                ),
                        )),
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
                                title: Text("Choisir une option",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: manageWidth(context, 15.5),
                                    )),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            radius: manageWidth(context, 15),
                                            child: Icon(
                                              CupertinoIcons.camera,
                                              size: manageWidth(context, 16),
                                            ),
                                          ),
                                          SizedBox(
                                            width: manageWidth(context, 10),
                                          ),
                                          Text("Appareil Photo",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    manageWidth(context, 14),
                                              )),
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
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            radius: manageWidth(context, 15),
                                            child: Icon(
                                              CupertinoIcons.photo,
                                              size: manageWidth(context, 16),
                                            ),
                                          ),
                                          SizedBox(
                                            width: manageWidth(context, 10),
                                          ),
                                          Text("Gallerie",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    manageWidth(context, 14),
                                              )),
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
                          backgroundColor: Color.fromARGB(255, 228, 228, 228),
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
                          child: Container(
                            height: manageWidth(context, 100 * 0.7),
                            width: manageWidth(context, 100 * 0.7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 50 * 0.7)),
                              image: DecorationImage(
                                image: _profilImageFile == null
                                    ? NetworkImage(images["profil image"])
                                    : FileImage(_profilImageFile!)
                                        as ImageProvider,
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
                                title: Text("Choisir une option",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: manageWidth(context, 15.5),
                                    )),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      title: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            radius: manageWidth(context, 15),
                                            child: Icon(
                                              CupertinoIcons.camera,
                                              size: manageWidth(context, 16),
                                            ),
                                          ),
                                          SizedBox(
                                            width: manageWidth(context, 10),
                                          ),
                                          Text("Appareil Photo",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    manageWidth(context, 14),
                                              )),
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
                                            backgroundColor:
                                                Colors.grey.shade400,
                                            radius: manageWidth(context, 15),
                                            child: Icon(
                                              CupertinoIcons.photo,
                                              size: manageWidth(context, 16),
                                            ),
                                          ),
                                          SizedBox(
                                            width: manageWidth(context, 10),
                                          ),
                                          Text("Gallerie",
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize:
                                                    manageWidth(context, 14),
                                              )),
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
                          backgroundColor: Color.fromARGB(255, 228, 228, 228),
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
                  padding: EdgeInsets.symmetric(
                      horizontal: manageWidth(context, 15)),
                  width: manageWidth(context, 335),
                  height: manageHeight(
                      context, 200), // Ajuster la hauteur selon vos besoins
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(manageWidth(context, 20)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(manageWidth(context, 8.0)),
                    child: TextField(
                      controller: descriptionController,
                      maxLines:
                          null, // Permet à TextField de s'ajuster dynamiquement en hauteur
                      maxLength: 250,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Ajouter une description ",
                        hintStyle:
                            TextStyle(fontSize: manageWidth(context, 15)),
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
                      var snackBar = SnackBar(
                        content: Text("veuillez remplir tous les champs"),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {
                        isImporting = false;
                      });
                    } else {
                      modifierImage(_coverImageFile, _profilImageFile);
                      editDescription(descriptionController.text,
                          int.parse(experienceYearsController.text));
                      Navigator.pop(context);
                      setState(() {
                        isImporting = false;
                      });
                    }
                  },
                  child: Container(
                    width: manageWidth(context, 200),
                    height: manageHeight(context, 50),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 25)),
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
            ));
          }),
    );
  }
}
