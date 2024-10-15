import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_page_view_indicator/flutter_page_view_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/model/service_reservation_method_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/article_adding_page.dart';
import 'package:trade_hart/views/main_page_components/pages/category_page.dart';
import 'package:trade_hart/views/main_page_components/pages/crenau_add_page.dart';
import 'package:trade_hart/views/main_page_components/pages/crenau_with_day_add_page.dart';
import 'package:path_provider/path_provider.dart';

class ServiceAddPage extends StatefulWidget {
  const ServiceAddPage({super.key});

  @override
  State<ServiceAddPage> createState() => _ServiceAddPageState();
}

class _ServiceAddPageState extends State<ServiceAddPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController capacityController = TextEditingController();
  String timeUnitValue = "heure(s)";
  bool isUploaded = false;
  bool isLoading = false;
  int currentIndex = 0;
  bool animation = true;
  CarouselSliderController carouselController = CarouselSliderController();

  List<File> images = [];

  List<Map<String, String>> serviceImages = [];

  Future<void> pickImage(ImageSource source) async {
    if (images.length < 10) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        var croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: const CropAspectRatio(ratioX: 11.8, ratioY: 10),
          compressQuality: 100,
        );

        if (croppedFile != null) {
          setState(() {
            images.add(File(croppedFile.path));
            animation = true;
          });
        }
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

  Future<void> uploadImagesToFirebaseStorage(List<File> imageFiles) async {
    if (!isUploaded) {
      for (File image in imageFiles) {
        File compressedImage = await compressImage(image);

        String fileName = FirebaseAuth.instance.currentUser!.uid +
            DateTime.now().millisecondsSinceEpoch.toString() +
            image.path.split('/').last;

        Reference ref = FirebaseStorage.instance
            .ref()
            .child('services_images_urls')
            .child(fileName);
        UploadTask uploadTask = ref.putFile(compressedImage);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        serviceImages.add({"image url": downloadUrl, "image name": fileName});
        // ignore: use_build_context_synchronously
      }

      setState(() {
        isUploaded = true;
      });
    }
  }

  Future<void> addServiceToFirestore(
      String name,
      double price,
      List<String> categories,
      String sellerId,
      String description,
      int reservationCategory,
      String duration) async {
    var sellerSnapShot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> serviceData = sellerSnapShot.data()!['service'];
    String sellerName = serviceData['name'];
    String location = serviceData['location'];
    if (reservationCategory == 1) {
      var service =
          await FirebaseFirestore.instance.collection('Services').add({
        'name to lower case': name.toLowerCase(),
        'name': name,
        'price': price,
        'categories': categories,
        'sellerId': sellerId,
        'gelocation':  sellerSnapShot.data()!['gelocation'],
        'images': serviceImages,
        'description': description,
        'average rate': 0,
        'total points': calculerScoreTemps(DateTime.now()),
        'rates number': 0,
        'date': Timestamp.now(),
        'status': true,
        'creneau reservation status': false,
        'seller name': sellerName,
        'duration': '${durationController.text} $timeUnitValue',
        'location': location
      });

      var ref = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Abonnes')
          .get();

      // ignore: use_build_context_synchronously

      // ignore: use_build_context_synchronously

      if (ref.docs.isNotEmpty) {
        for (var item in ref.docs) {
          var user = await FirebaseFirestore.instance
              .collection('Users')
              .doc(item.data()["user id"])
              .get();

          if (user.exists) {
            sendNotification(
                token: user.data()!["fcmtoken"],
                title: sellerName,
                body: "Nouvel article mis en ligne",
                route: "/ServiceDetailsPage",
                serviceId: service.id);
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    }

    if (reservationCategory == 2) {
      var service =
          await FirebaseFirestore.instance.collection('Services').add({
        'name to lower case': name.toLowerCase(),
        'name': name[0].toUpperCase() + name.substring(1),
        'price': price,
        'categories': categories,
        'sellerId': sellerId,
        'images': serviceImages,
        'description': description,
        'average rate': 0,
        'total points': calculerScoreTemps(DateTime.now()),
        'rates number': 0,
        'date': Timestamp.now(),
        'status': true,
        'creneau reservation status': true,
        'seller name': sellerName,
        'location': location,
        'duration': '${durationController.text} $timeUnitValue',
        'gelocation':  sellerSnapShot.data()!['gelocation'],
        // ignore: use_build_context_synchronously
        'crenaux': context
            .read<ServiceReservationMethodProvider>()
            .daysWithCrenau
            .where((e) => e.crenaux.isNotEmpty)
            .map((e) => {
                  "jour": e.day,
                  "horaires": e.crenaux.map((e) => {
                        "heure": e.heure,
                        "minutes": e.minutes,
                        "capacite": e.nombreDePlace
                      })
                })
            .toList()
      });
      var ref = await FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Abonnes')
          .get();

      if (ref.docs.isNotEmpty) {
        for (var item in ref.docs) {
          var user = await FirebaseFirestore.instance
              .collection('Users')
              .doc(item.data()["user id"])
              .get();

          if (user.exists) {
            sendNotification(
                token: user.data()!["fcmtoken"],
                title: sellerName,
                body: "Nouvel article mis en ligne",
                route: "/ServiceDetailsPage",
                serviceId: service.id);
          }
        }
      }

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Ajouter un service", size: manageWidth(context, 18)),
        leading: const MainBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              onPageChanged: (index, reason) {
                setState(() {
                  currentIndex = index;
                  if (!animation) {
                    animation = true;
                  }
                });
              },
              enableInfiniteScroll: false,
              enlargeCenterPage: animation,
              aspectRatio: 11.8 / 10,
              viewportFraction: 0.98,
              initialPage: 0,
              autoPlay: false,
            ),
            items: images.isEmpty
                ? [
                    Container(
                      width: manageWidth(context, 395),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 15)),
                          color: Colors.grey.shade200),
                      child: Center(
                        child: Text(
                          "Aucune image",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: manageWidth(context, 18),
                          ),
                        ),
                      ),
                    )
                  ]
                : images.map((imageFile) {
                    return Container(
                      width: manageWidth(context, 395),
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 15))),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(manageWidth(context, 15)),
                        child: Image.file(
                          imageFile,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: manageWidth(context, 145),
              ),
              Container(
                width: manageWidth(context, images.length * 1.2 * 15),
                margin: EdgeInsets.only(top: manageHeight(context, 5)),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius:
                        BorderRadius.circular(manageWidth(context, 10))),
                child: PageViewIndicator(
                  length: images.isEmpty ? images.length : images.length,
                  currentIndex: currentIndex,
                  currentSize: manageWidth(context, 8),
                  otherSize: manageWidth(context, 6),
                  margin: EdgeInsets.all(manageWidth(context, 2.5)),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  if (images.length == 1) {
                    setState(() {
                      images.clear();
                      currentIndex = 0;
                      animation = false;
                    });
                  } else if (images.length == 2) {
                    setState(() {
                      images.removeAt(currentIndex);
                      animation = false;
                      currentIndex = 0;
                    });
                  } else {
                    setState(() {
                      images.removeAt(currentIndex);
                      currentIndex--;
                      animation = false;
                    });
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: manageHeight(context, 10)),
                  padding: EdgeInsets.only(left: manageWidth(context, 12.5)),
                  height: manageHeight(context, 27),
                  width: manageWidth(context, 110),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: images.isEmpty
                            ? Colors.transparent
                            : const Color.fromARGB(255, 206, 86,
                                86), // Couleur des bordures vertes
                        width: 1.0, // Épaisseur des bordures
                      ),
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 15))),
                  child: Row(
                    children: [
                      Text("Supprimer",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: manageWidth(context, 12),
                            color: images.isEmpty
                                ? Colors.transparent
                                : const Color.fromARGB(255, 206, 86, 86),
                          )),
                      SizedBox(
                        width: manageWidth(context, 5),
                      ),
                      Icon(
                        CupertinoIcons.trash,
                        color: images.isEmpty
                            ? Colors.transparent
                            : const Color.fromARGB(255, 206, 86, 86),
                        size: manageWidth(context, 16),
                      )
                    ],
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
              "Ajouter une image",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: manageWidth(context, 15.5),
              ),
            ),
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          GestureDetector(
            onTap: images.length < 10
                ? () {
                    if (isUploaded) {
                      const snackBar = SnackBar(
                        content: Text(
                          "Vous avez déjà ajouté cet article.",
                        ),
                        backgroundColor: Color.fromARGB(255, 223, 44, 44),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }

                    // Ouvrir une boîte de dialogue ou une interface utilisateur pour permettre à l'utilisateur de choisir entre l'appareil photo et la galerie
                    else {
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
                                      Text("Appareil Photo",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: manageWidth(context, 14),
                                          )),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    pickImage(ImageSource.camera);
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
                                      Text("Gallerie",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: manageWidth(context, 14),
                                          )),
                                    ],
                                  ),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    pickImage(ImageSource.gallery);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  }
                : () {
                    const snackBar = SnackBar(
                      content: Text(
                        "Vous n'avez droit qu'à 10 images maximum.",
                      ),
                      backgroundColor: Color.fromARGB(255, 213, 89, 80),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
            height: manageHeight(context, 20),
          ),
          AuthTextField(
            controller: nameController,
            hintText: "nom du service",
            obscuretext: false,
            width: manageWidth(context, 340),
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: manageWidth(context, 15),
            ),
            width: manageWidth(context, 340),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(manageWidth(context, 20)),
            ),
            child: Padding(
              padding: EdgeInsets.all(manageWidth(context, 8)),
              child: TextField(
                controller: descriptionController,
                maxLines: null,
                maxLength: 250,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "ajouter une description"),
              ),
            ),
          ),
          SizedBox(height: manageHeight(context, 15)),
          AuthTextField(
            controller: priceController,
            hintText: "prix",
            obscuretext: false,
            keyboardType: TextInputType.number,
            width: manageWidth(context, 340),
          ),
          SizedBox(height: manageHeight(context, 25)),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 15),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return CategoryPage(categories: serviceFilters);
                  }));
                },
                child: Container(
                  padding: EdgeInsets.only(left: manageWidth(context, 5)),
                  height: manageHeight(context, 40),
                  width: manageWidth(context, 275),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Colors.grey.shade700, // Couleur des bordures vertes
                        width: 1.0, // Épaisseur des bordures
                      ),
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 15))),
                  child: Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 5),
                      ),
                      Icon(
                        Icons.filter_list_rounded,
                        color: Colors.grey.shade700,
                        size: manageWidth(context, 16),
                      ),
                      SizedBox(
                        width: manageWidth(context, 5),
                      ),
                      Text("Ajouter une catégorie de filtre",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: manageWidth(context, 15),
                            color: Colors.grey.shade700,
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: manageHeight(context, 10),
          ),
          Consumer<CategoriesProvider>(
            builder: (context, value, child) => Container(
              margin: EdgeInsets.only(left: manageWidth(context, 10)),
              height: value.serviceCategories.isEmpty
                  ? manageHeight(context, 1)
                  : manageHeight(context, 45),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: value.serviceCategories.isEmpty
                    ? [const SizedBox()]
                    : value.serviceCategories
                        .map((e) => Container(
                              padding: EdgeInsets.fromLTRB(
                                  manageWidth(context, 10),
                                  manageHeight(context, 5),
                                  manageWidth(context, 10),
                                  manageHeight(context, 5)),
                              margin: EdgeInsets.fromLTRB(
                                  manageWidth(context, 5),
                                  manageHeight(context, 5),
                                  manageWidth(context, 5),
                                  manageHeight(context, 5)),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 180, 92, 159),
                                    width: 1.0, // Épaisseur des bordures
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      manageWidth(context, 15))),
                              child: Center(
                                  child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<CategoriesProvider>()
                                          .removeServiceCategory(e);
                                    },
                                    child: Icon(CupertinoIcons.clear,
                                        size: manageWidth(context, 18),
                                        color:
                                            const Color.fromARGB(255, 180, 92, 159)),
                                  ),
                                  SizedBox(
                                    width: manageWidth(context, 3),
                                  ),
                                  Text(
                                    e,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: manageWidth(context, 15),
                                        color:
                                            const Color.fromARGB(255, 180, 92, 159)),
                                  ),
                                ],
                              )),
                            ))
                        .toList(),
              ),
            ),
          ),
          SizedBox(
            height: manageHeight(context, 20),
          ),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 15),
              ),
              AuthTextField(
                controller: durationController,
                hintText: "durée de la prestation",
                obscuretext: false,
                keyboardType: TextInputType.number,
                width: manageWidth(context, 205),
              ),
              const Spacer(),
              DropdownButton(
                hint: Text(timeUnitValue,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: manageWidth(context, 15),
                      color: Colors.grey.shade700,
                    )),
                underline: Container(
                  height: manageHeight(context, 2),
                  color: Colors.grey.withOpacity(0.7),
                ),
                items: [
                  DropdownMenuItem(
                    value: "heure(s)",
                    child: Text("heure(s)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        )),
                  ),
                  DropdownMenuItem(
                    value: "jour(s)",
                    child: Text("jour(s)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        )),
                  ),
                  DropdownMenuItem(
                    value: "minute(s)",
                    child: Text("minute(s)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        )),
                  ),
                  DropdownMenuItem(
                    value: "mois",
                    child: Text("mois",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        )),
                  )
                ],
                onChanged: (value) {
                  setState(() {
                    timeUnitValue = value!;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 35),
              )
            ],
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 15),
              ),
              Text("Mode de réservation :",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: manageWidth(context, 15.5),
                  )),
            ],
          ),
          SizedBox(
            height: manageHeight(context, 5),
          ),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 15),
              ),
              Consumer<ServiceReservationMethodProvider>(
                builder: (context, value, child) {
                  return Radio(
                    value: 1,
                    groupValue: value.reservationType,
                    onChanged: (newValue) {
                      value.changeReservationType(newValue!);
                    },
                  );
                },
              ),
              Text("A la commande",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: manageWidth(context, 15),
                    color: Colors.grey.shade700,
                  )),
              PopupMenuButton(
                icon: Container(
                  width: manageWidth(context, 20),
                  height: manageHeight(context, 20),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 10))),
                  child: const Center(
                      child: Text(
                    "?",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text(
                          "L'utilisateur n'aura qu'à selectionner une date et sa commande apparaitera dans votre tableau de bord, vous n'aurez qu'à confirmmer sa commande.",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: manageWidth(context, 15),
                            color: Colors.grey.shade700,
                          )),
                    )
                  ];
                },
              )
            ],
          ),
          SizedBox(
            height: manageHeight(context, 5),
          ),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 15),
              ),
              Consumer<ServiceReservationMethodProvider>(
                builder: (context, value, child) {
                  return Radio(
                    value: 2,
                    groupValue: value.reservationType,
                    onChanged: (newValue) {
                      value.changeReservationType(newValue!);
                    },
                  );
                },
              ),
              Text("Par crénau horaire",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: manageWidth(context, 15),
                    color: Colors.grey.shade700,
                  )),
              PopupMenuButton(
                icon: Container(
                  width: manageWidth(context, 20),
                  height: manageHeight(context, 20),
                  decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.6),
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 10))),
                  child: const Center(
                      child: Text(
                    "?",
                    style: TextStyle(color: Colors.white),
                  )),
                ),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      child: Text(
                          "L'utilisateur devra selectionner un crénau parmi ceux qui sont disponibles pour la date qu'il a selectionné et sa commande apparaitera dans votre tableau de bord, vous n'aurez qu'à confirmmer sa commande.",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: manageWidth(context, 15),
                            color: Colors.grey.shade700,
                          )),
                    )
                  ];
                },
              )
            ],
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          Consumer<ServiceReservationMethodProvider>(
            builder: (context, value, child) {
              return GestureDetector(
                onTap: () {
                  if (value.reservationType == 2) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CrenauAddPage()));
                  }
                },
                child: Row(
                  children: [
                    SizedBox(
                      width: manageWidth(context, 15),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: manageWidth(context, 5)),
                      height: manageHeight(context, 40),
                      width: manageWidth(context, 275),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors
                                .grey.shade700, // Couleur des bordures vertes
                            width: 1.0, // Épaisseur des bordures
                          ),
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        children: [
                          SizedBox(
                            width: manageWidth(context, 5),
                          ),
                          Icon(
                            Icons.lock_clock,
                            color: Colors.grey.shade700,
                            size: manageWidth(context, 16),
                          ),
                          SizedBox(
                            width: manageWidth(context, 5),
                          ),
                          Text("Ajouter des crénaux horaires",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: manageWidth(context, 15),
                                color: Colors.grey.shade700,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          Consumer<ServiceReservationMethodProvider>(
            builder: (context, value, child) => SizedBox(
              height: value.daysWithCrenau
                          .any((element) => element.crenaux.isEmpty) &&
                      value.reservationType == 2
                  ? manageHeight(context, 45)
                  : manageHeight(context, 0.1),
              child: value.daysWithCrenau
                          .any((element) => element.crenaux.isEmpty) &&
                      value.reservationType == 2
                  ? ListView(
                      scrollDirection: Axis.horizontal,
                      children: value.daysWithCrenau
                          .where((element) => element.crenaux.isNotEmpty)
                          .map(
                            (e) => Row(
                              children: [
                                SizedBox(
                                  width: manageWidth(context, 15),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CrenauWithDayAdd(day: e.day))),
                                  child: Container(
                                    width: manageWidth(context, 135),
                                    height: manageHeight(context, 40),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255,
                                              218,
                                              137,
                                              180), // Couleur des bordures vertes
                                          width: 1.0, // Épaisseur des bordures
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Center(
                                        child: Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              value.clearDayCreneau(e.day);
                                            },
                                            icon: const Icon(
                                              CupertinoIcons.clear,
                                              size: 16,
                                              color: Color.fromARGB(
                                                  255, 218, 137, 180),
                                            )),
                                        Text(
                                          e.day,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                            fontSize:
                                                manageWidth(context, 16.5),
                                            color: const Color.fromARGB(
                                                255, 218, 137, 180),
                                          ),
                                        ),
                                      ],
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList())
                  : const SizedBox(
                      height: 0.1,
                    ),
            ),
          ),
          SizedBox(
            height: manageHeight(context, 25),
          ),
          Consumer<ServiceReservationMethodProvider>(
            builder: (context, value, child) => GestureDetector(
              onTap: () async {
                if (nameController.text.isEmpty ||
                    priceController.text.isEmpty ||
                    durationController.text.isEmpty ||
                    durationController.text.isEmpty) {
                  const snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        "Veuillez remplir tous les champs",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else if (value.reservationType == 2 &&
                    !value.daysWithCrenau
                        .any((element) => element.crenaux.isNotEmpty)) {
                  const snackBar = SnackBar(
                      content: Text(
                    "Aucun créneau renseigné",
                    style: TextStyle(
                        color: Colors.white, backgroundColor: Colors.red),
                  ));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else if (isUploaded) {
                  const snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        "Vous avez déjà ajouté ce service",
                        style: TextStyle(color: Colors.white),
                      ));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else if (images.isEmpty) {
                  const snackBar = SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        "Vous devez ajouter au moins une image",
                        style: TextStyle(color: Colors.white),
                      ));

                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else if (!isLoading) {
                  setState(() {
                    isLoading = true;
                  });

                  await uploadImagesToFirebaseStorage(images);
                  await addServiceToFirestore(
                      nameController.text,
                      double.parse(priceController.text),
                      context
                          .read<CategoriesProvider>()
                          .serviceCategories
                          .toList(),
                      FirebaseAuth.instance.currentUser!.uid,
                      descriptionController.text,
                      value.reservationType,
                      durationController.text);

                  const snackBar = SnackBar(
                      backgroundColor: Colors.green,
                      content: Text(
                        "Service ajouté avec succès",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ));
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  value.clearAllCrenau();
                  context.read<CategoriesProvider>().serviceCategoriesclear();
                  Navigator.pop(context);
                }
              },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius:
                        BorderRadius.circular(manageWidth(context, 25))),
                child: Center(
                  child: Text("Ajouter",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16))),
                ),
              ),
            ),
          ),
          SizedBox(
            height: manageHeight(context, 10),
          ),
          CircularProgressIndicator(
            color: isLoading ? AppColors.mainColor : Colors.transparent,
          ),
          SizedBox(
            height: manageHeight(context, 25),
          ),
        ]),
      ),
    );
  }
}
