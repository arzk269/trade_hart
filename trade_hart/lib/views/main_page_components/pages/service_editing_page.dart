// ignore_for_file: prefer_const_constructors

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
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/category_page.dart';
import 'package:path_provider/path_provider.dart';

class EditServicePage extends StatefulWidget {
  final Service service;
  const EditServicePage({super.key, required this.service});

  @override
  State<EditServicePage> createState() => _EditServicePageState();
}

class _EditServicePageState extends State<EditServicePage> {
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
    if (productImages.length < 10) {
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
    serviceData!["name"] = name[0].toUpperCase() + name.substring(1);
    serviceData["name to lower case"] = name.toLowerCase();
    serviceData["categories"] = categories;
    serviceData["description"] = description;
    serviceData["price"] =
        double.parse((price * 1.13402061).toStringAsFixed(2));
    serviceData["duration"] = "$duration $timeUnitValue";
    serviceData["images"].addAll(images);
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
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  size: manageWidth(context, 20),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
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
                        width: manageWidth(
                            context, MediaQuery.of(context).size.width * 0.95),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
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
                  : productImages.map(
                      (image) {
                        return Container(
                          width: manageWidth(context,
                              MediaQuery.of(context).size.width * 0.95),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Color.fromARGB(255, 221, 202, 202)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: image),
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
                  width: manageWidth(context, productImages.length * 1.2 * 15),
                  margin: EdgeInsets.only(top: manageHeight(context, 5)),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10)),
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
                            'Etes-vous sur de vouloir supprimer cette image ?',
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
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                // ignore: use_build_context_synchronously
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
                    ),
                    padding: EdgeInsets.only(left: manageWidth(context, 12.5)),
                    height: manageHeight(context, 27),
                    width: manageWidth(context, 110),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: productImages.isEmpty
                              ? Colors.transparent
                              : Color.fromARGB(255, 206, 86, 86),
                          width: manageWidth(context, 1.0),
                        ),
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      children: [
                        Text("Supprimer",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: manageWidth(context, 12),
                              color: productImages.isEmpty
                                  ? Colors.transparent
                                  : Color.fromARGB(255, 206, 86, 86),
                            )),
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
              onTap: productImages.length < 10
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
                                  fontSize: 15.5,
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
                      fontWeight: FontWeight.w500),
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
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            Container(
              padding:
                  EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
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
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            AuthTextField(
              controller: priceController,
              hintText: "Prix",
              obscuretext: false,
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
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
                        "heure(s)",
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
                        "jour(s)",
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
                        "minute(s)",
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
                        "mois",
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
            SizedBox(
              height: manageHeight(context, 25),
            ),
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
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Consumer<CategoriesProvider>(
              builder: (context, value, child) {
                return Container(
                  margin: EdgeInsets.only(left: manageWidth(context, 10)),
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
                                width: 1.0, // Épaisseur des bordures
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
            SizedBox(
              height: manageHeight(context, 50),
            ),
            Consumer<CategoriesProvider>(
              builder: (context, value, child) => GestureDetector(
                onTap: (nameController.text.isEmpty ||
                        priceController.text.isEmpty ||
                        descriptionController.text.isEmpty ||
                        durationController.text.isEmpty)
                    ? () {
                        var snackBar = SnackBar(
                          content: Text("Veuillez remplir tous les champs."),
                          backgroundColor: Color.fromARGB(255, 223, 44, 44),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }
                    : value.serviceCategories.isEmpty
                        ? () {
                            var snackBar = SnackBar(
                              content: Text(
                                  "Vous devez ajouter au moins une catégorie"),
                              backgroundColor: Color.fromARGB(255, 223, 44, 44),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        : isUploaded
                            ? () {
                                var snackBar = SnackBar(
                                  content:
                                      Text("Vous avez déjà ajouté ce service."),
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
                                          "Vous devez ajouter au moins une image"),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                      Navigator.pop(context);
                                    });
                                  },
                child: Container(
                  width: manageWidth(context, 200),
                  height: manageHeight(context, 50),
                  padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                  decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(
                      manageWidth(context, 25),
                    ),
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
            SizedBox(
              height: manageHeight(context, 15),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 232, 88, 88),
                  borderRadius: BorderRadius.circular(
                    manageWidth(context, 25),
                  ),
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
            SizedBox(
              height: manageHeight(context, 15),
            ),
            CircularProgressIndicator(
              color: isLoading ? AppColors.mainColor : Colors.transparent,
            ),
            SizedBox(
              height: manageHeight(context, 15),
            ),
          ],
        ),
      ),
    );
  }
}
