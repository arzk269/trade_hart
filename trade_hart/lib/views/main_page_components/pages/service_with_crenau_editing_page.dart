// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_view_indicator/flutter_page_view_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/model/service_reservation_method_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/category_page.dart';
import 'package:trade_hart/views/main_page_components/pages/crenau_add_page.dart';
import 'package:trade_hart/views/main_page_components/pages/crenau_with_day_add_page.dart';

class ServiceWithCreneauxEditingPage extends StatefulWidget {
  final Service service;
  ServiceWithCreneauxEditingPage({super.key, required this.service});

  @override
  State<ServiceWithCreneauxEditingPage> createState() =>
      _ServiceWithCreneauxEditingPageState();
}

class _ServiceWithCreneauxEditingPageState
    extends State<ServiceWithCreneauxEditingPage> {
  List<Map<String, dynamic>> existingImagesTodelete = [];
  List<File> newImagesToAdd = [];
  bool isUploaded = false;
  bool isLoading = false;
  int currentIndex = 0;
  List<Map<String, dynamic>> images = [];
  List<Image> productImages = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  bool animation = true;
  String timeUnitValue = "heure(s)";

  Future<void> pickImage(ImageSource source) async {
    if (productImages.length < 5) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        setState(() {
          productImages.add(Image.file(
            File(pickedImage.path),
            fit: BoxFit.cover,
            semanticLabel: 'local image',
          ));

          newImagesToAdd.add(File(pickedImage.path));
          animation = true;
        });
      }
    }
  }

  Future<void> uploadImagesToFirebaseStorage(List<File> imagePaths) async {
    if (!isUploaded) {
      for (File image in imagePaths) {
        String fileName = FirebaseAuth.instance.currentUser!.uid +
            DateTime.now().millisecondsSinceEpoch.toString() +
            image.path.split('/').last;
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('services_images_urls')
            .child(fileName);
        UploadTask uploadTask = ref.putFile(image);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        images.add({"image url": downloadUrl, "image name": fileName});
      }

      setState(() {
        isUploaded = true;
      });
    }
  }

  Future<void> deleteExistingImage(Map<String, dynamic> image) async {
    await FirebaseStorage.instance
        .ref()
        .child('services_images_urls/${image['image name']}')
        .delete();
    var reference = FirebaseFirestore.instance
        .collection('Services')
        .doc(widget.service.id);
    await reference.update({
      'images': FieldValue.arrayRemove([image])
    });
  }

  Future<void> editServiceToFireStore(String name, String description,
      List<String> categories, double price, String duration) async {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection("Services")
        .doc(widget.service.id)
        .get();
    var serviceData = snapshot.data();
    serviceData!["name"] = name;
    serviceData["categories"] = categories;
    serviceData["description"] = description;
    serviceData["price"] = price;
    serviceData["duration"] = "$duration $timeUnitValue";
    serviceData["images"].addAll(images);
    // ignore: use_build_context_synchronously
    serviceData["crenaux"] = context
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
        .toList();
    await FirebaseFirestore.instance
        .collection("Services")
        .doc(widget.service.id)
        .update(serviceData);
  }

  @override
  void initState() {
    for (var image in widget.service.images) {
      productImages.add(Image.network(
        image['image url'],
        fit: BoxFit.cover,
        semanticLabel: image['image url'],
        errorBuilder: (context, error, stackTrace) => SizedBox(
            height: manageHeight(context, 150),
            width: manageWidth(context, 165),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: manageWidth(context, 20),
                ),
              ],
            )),
      ));
    }

    nameController = TextEditingController(text: widget.service.name);
    descriptionController =
        TextEditingController(text: widget.service.description);
    priceController =
        TextEditingController(text: widget.service.price.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Modifier ce service", size: manageWidth(context, 20)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSlider(
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
              items: productImages.isEmpty
                  ? [
                      Container(
                        width: manageWidth(context, 0.95),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.grey.shade200,
                        ),
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
                  : productImages.map(
                      (image) {
                        return Container(
                          width: manageWidth(context, 0.95),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Color.fromARGB(255, 221, 202, 202),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: image,
                          ),
                        );
                      },
                    ).toList(),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: manageWidth(context, 145),
                ),
                Container(
                  width: productImages.length * 1.2 * 15,
                  margin: EdgeInsets.only(
                    top: manageHeight(context, 5),
                    left: manageWidth(context, 5),
                    right: manageWidth(context, 5),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: PageViewIndicator(
                    length: productImages.length,
                    currentIndex: currentIndex,
                    currentSize: manageWidth(context, 8),
                    otherSize: manageWidth(context, 6),
                    margin: EdgeInsets.all(manageWidth(context, 2.5)),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Confirmation'),
                          content: Text(
                            'Êtes-vous sûr de vouloir supprimer cette image ?',
                            style:
                                TextStyle(fontSize: manageWidth(context, 15)),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Annuler'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text(
                                'Supprimer',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: manageWidth(context, 15),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                if (productImages.length == 1) {
                                  if (productImages[currentIndex]
                                          .semanticLabel !=
                                      'local image') {
                                    setState(() {
                                      existingImagesTodelete.add(
                                          widget.service.images[currentIndex]);
                                    });
                                  }
                                  setState(() {
                                    productImages.clear();
                                    currentIndex = 0;
                                  });
                                }
                                if (productImages.length == 2) {
                                  if (productImages[currentIndex]
                                          .semanticLabel !=
                                      'local image') {
                                    setState(() {
                                      existingImagesTodelete.add(
                                          widget.service.images[currentIndex]);
                                    });
                                  }
                                  setState(() {
                                    productImages.removeAt(currentIndex);
                                    currentIndex = 0;
                                    animation = false;
                                  });
                                } else {
                                  if (productImages[currentIndex]
                                          .semanticLabel !=
                                      'local image') {
                                    setState(() {
                                      existingImagesTodelete.add(
                                          widget.service.images[currentIndex]);
                                    });
                                  }
                                  setState(() async {
                                    productImages.removeAt(currentIndex);
                                    currentIndex--;
                                    animation = false;
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      top: manageHeight(context, 10),
                      left: manageWidth(context, 12.5),
                      right: manageWidth(context, 12.5),
                    ),
                    padding: EdgeInsets.only(
                      left: manageWidth(context, 12.5),
                    ),
                    height: manageHeight(context, 27),
                    width: manageWidth(context, 110),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: productImages.isEmpty
                            ? Colors.transparent
                            : Color.fromARGB(255, 206, 86, 86),
                        width: manageWidth(context, 1.0),
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "Supprimer",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: manageWidth(context, 12),
                            color: productImages.isEmpty
                                ? Colors.transparent
                                : Color.fromARGB(255, 206, 86, 86),
                          ),
                        ),
                        SizedBox(
                          width: manageWidth(context, 5),
                        ),
                        Icon(
                          CupertinoIcons.trash,
                          color: productImages.isEmpty
                              ? Colors.transparent
                              : Color.fromARGB(255, 206, 86, 86),
                          size: manageWidth(context, 16),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: manageWidth(context, 10),
                )
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
              onTap: productImages.length < 5
                  ? () {
                      if (isUploaded) {
                        var snackBar = SnackBar(
                          content: Text(
                            "Vous avez déjà ajouté ce service.",
                          ),
                          backgroundColor: Color.fromARGB(255, 223, 44, 44),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
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
                      var snackBar = SnackBar(
                        content: Text(
                          "Vous n'avez droit qu'à 5 images maximum.",
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
              height: manageHeight(context, 25),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 20),
                ),
                Text(
                  'Nom du service',
                  style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AuthTextField(
              controller: nameController,
              hintText: "Nom du service",
              obscuretext: false,
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 20),
                ),
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: manageWidth(context, 15),
              ),
              width: manageWidth(context, 335),
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
                    hintText: "Ajouter une description",
                  ),
                ),
              ),
            ),
            SizedBox(height: manageHeight(context, 25)),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 20),
                ),
                Text(
                  'Prix',
                  style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AuthTextField(
              controller: priceController,
              hintText: "Prix",
              obscuretext: false,
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: manageHeight(context, 25)),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                AuthTextField(
                  controller: durationController,
                  hintText: "Durée de la prestation",
                  obscuretext: false,
                  keyboardType: TextInputType.number,
                  width: manageWidth(context, 205),
                ),
                Spacer(),
                DropdownButton(
                  hint: Text(
                    timeUnitValue,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: manageWidth(context, 15),
                      color: Colors.grey.shade700,
                    ),
                  ),
                  underline: Container(
                    height: manageHeight(context, 2),
                    color: Colors.grey.withOpacity(0.7),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: "heure(s)",
                      child: Text(
                        "Heure(s)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "jour(s)",
                      child: Text(
                        "Jour(s)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "minute(s)",
                      child: Text(
                        "Minute(s)",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: "mois",
                      child: Text(
                        "Mois",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 15),
                          color: Colors.grey.shade700,
                        ),
                      ),
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
            SizedBox(height: manageHeight(context, 25)),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryPage(categories: serviceFilters),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.only(
                      left: manageWidth(context, 5),
                    ),
                    height: manageHeight(context, 40),
                    width: manageWidth(context, 275),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 1.0,
                      ),
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 15)),
                    ),
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
                        Text(
                          "Ajouter une catégorie de filtre",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: manageWidth(context, 15),
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: manageHeight(context, 10)),
            Consumer<CategoriesProvider>(
              builder: (context, value, child) {
                return Container(
                  margin: EdgeInsets.only(
                    left: manageWidth(context, 10),
                  ),
                  height: manageHeight(context, 45),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: value.serviceCategories
                        .map(
                          (e) => Container(
                            padding: EdgeInsets.only(
                              left: manageWidth(context, 10),
                              right: manageWidth(context, 10),
                            ),
                            margin: EdgeInsets.all(manageWidth(context, 5)),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Color.fromARGB(255, 180, 92, 159),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(
                                manageWidth(context, 15),
                              ),
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      context
                                          .read<CategoriesProvider>()
                                          .removeServiceCategory(e);
                                    },
                                    child: Icon(
                                      CupertinoIcons.clear,
                                      size: manageWidth(context, 18),
                                      color: Color.fromARGB(255, 180, 92, 159),
                                    ),
                                  ),
                                  SizedBox(
                                    width: manageWidth(context, 3),
                                  ),
                                  Text(
                                    e,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: manageWidth(context, 15),
                                      color: Color.fromARGB(255, 180, 92, 159),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                );
              },
            ),
            SizedBox(height: manageHeight(context, 15)),
            Consumer<ServiceReservationMethodProvider>(
              builder: (context, value, child) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CrenauAddPage(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                      Container(
                        padding: EdgeInsets.only(
                          left: manageWidth(context, 5),
                        ),
                        height: manageHeight(context, 40),
                        width: manageWidth(context, 275),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.shade700,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                            manageWidth(context, 15),
                          ),
                        ),
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
                            Text(
                              "Ajouter des créneaux horaires",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: manageWidth(context, 15),
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: manageHeight(context, 15)),
            Consumer<ServiceReservationMethodProvider>(
              builder: (context, value, child) {
                return SizedBox(
                  height: value.daysWithCrenau
                              .any((element) => element.crenaux.isEmpty) &&
                          value.reservationType == 2
                      ? manageHeight(context, 45)
                      : 0.1,
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
                                              CrenauWithDayAdd(day: e.day),
                                        ),
                                      ),
                                      child: Container(
                                        width: manageWidth(context, 135),
                                        height: manageHeight(context, 40),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromARGB(
                                                255, 218, 137, 180),
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            manageWidth(context, 20),
                                          ),
                                        ),
                                        child: Center(
                                          child: Row(
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  value.clearDayCreneau(e.day);
                                                },
                                                icon: Icon(
                                                  CupertinoIcons.clear,
                                                  size:
                                                      manageWidth(context, 16),
                                                  color: Color.fromARGB(
                                                      255, 218, 137, 180),
                                                ),
                                              ),
                                              Text(
                                                e.day,
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: manageWidth(
                                                      context, 16.5),
                                                  color: Color.fromARGB(
                                                      255, 218, 137, 180),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                              .toList())
                      : SizedBox(
                          height: 0.1,
                        ),
                );
              },
            ),
            SizedBox(height: manageHeight(context, 50)),
            Consumer<CategoriesProvider>(
              builder: (context, value, child) => GestureDetector(
                onTap: (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        descriptionController.text.isEmpty ||
                        durationController.text.isEmpty)
                    ? () {
                        var snackBar = SnackBar(
                          content: Text(
                            "Veuillez remplir tous les champs.",
                          ),
                          backgroundColor: Color.fromARGB(255, 223, 44, 44),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    : value.serviceCategories.isEmpty
                        ? () {
                            var snackBar = SnackBar(
                              content: Text(
                                "Vous devez ajouter au moins une catégorie",
                              ),
                              backgroundColor: Color.fromARGB(255, 223, 44, 44),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        : isUploaded
                            ? () {
                                var snackBar = SnackBar(
                                  content: Text(
                                    "Vous avez déjà ajouté ce service.",
                                  ),
                                  backgroundColor:
                                      Color.fromARGB(255, 223, 44, 44),
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            : productImages.isEmpty
                                ? () {
                                    var snackBar = SnackBar(
                                      content: Text(
                                        "Vous devez ajouter au moins une image",
                                      ),
                                      backgroundColor:
                                          Color.fromARGB(255, 223, 44, 44),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                : () async {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    if (existingImagesTodelete.isNotEmpty) {
                                      for (var image
                                          in existingImagesTodelete) {
                                        await deleteExistingImage(image);
                                      }
                                    }

                                    if (newImagesToAdd.isNotEmpty) {
                                      await uploadImagesToFirebaseStorage(
                                          newImagesToAdd);
                                    }

                                    editServiceToFireStore(
                                      nameController.text,
                                      descriptionController.text,
                                      value.serviceCategories.toList(),
                                      double.parse(priceController.text),
                                      durationController.text,
                                    ).then((value) {
                                      context
                                          .read<CategoriesProvider>()
                                          .articleCategoriesclear();

                                      var snackBar = SnackBar(
                                        content: Text(
                                          "Article modifié avec succès.",
                                        ),
                                        backgroundColor:
                                            Color.fromARGB(255, 26, 73, 26),
                                      );
                                      // ignore: use_build_context_synchronously
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      // ignore: use_build_context_synchronously
                                      Navigator.pop(context);
                                    });
                                    // ignore: use_build_context_synchronously
                                  },
                child: Container(
                  width: manageWidth(context, 200),
                  height: manageHeight(context, 50),
                  padding: EdgeInsets.only(
                    bottom: manageHeight(context, 2),
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius:
                        BorderRadius.circular(manageWidth(context, 25)),
                  ),
                  child: Center(
                    child: Text(
                      "Modifier",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: manageWidth(context, 16),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: manageHeight(context, 15)),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(
                  bottom: manageHeight(context, 2),
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 232, 88, 88),
                  borderRadius: BorderRadius.circular(manageWidth(context, 25)),
                ),
                child: Center(
                  child: Text(
                    "Annuler",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: manageWidth(context, 16),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: manageHeight(context, 15)),
            CircularProgressIndicator(
              color: isLoading ? AppColors.mainColor : Colors.transparent,
            ),
            SizedBox(height: manageHeight(context, 15)),
          ],
        ),
      ),
    );
  }
}
