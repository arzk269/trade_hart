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
import 'package:trade_hart/model/colors_provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_container.dart';
import 'package:trade_hart/views/main_page_components/pages/article_colors_adding.dart';
import 'package:trade_hart/views/main_page_components/pages/category_page.dart';
import 'package:path_provider/path_provider.dart';

double calculerScoreTemps(DateTime datePublication) {
  DateTime dateOrigine = DateTime(2024, 8, 1);
  int differenceJours = datePublication.difference(dateOrigine).inDays;
  double scoreTemps = differenceJours / 365.0;

  return scoreTemps;
}

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});
  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  CarouselSliderController carouselController = CarouselSliderController();
  int currentColorIndex = 0;
  bool isUploaded = false;
  bool isLoading = false;
  int currentIndex = 0;
  List<Map<String, dynamic>> images = [];
  List<Map<String, dynamic>> colors = [];
  List<File> productImages = [];
  bool animation = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController livraisonController = TextEditingController();
  TextEditingController minDelayController = TextEditingController();
  TextEditingController maxDelayController = TextEditingController();
  TextEditingController deliveryFeesController = TextEditingController();

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

  Future<void> uploadImagesToFirebaseStorage(
      List<File> imageFiles, BuildContext context) async {
    if (!isUploaded) {
      for (File image in imageFiles) {
        File compressedImage = await compressImage(image);
        String fileName = FirebaseAuth.instance.currentUser!.uid +
            DateTime.now().millisecondsSinceEpoch.toString() +
            image.path.split('/').last;
        Reference ref = FirebaseStorage.instance
            .ref()
            .child('articles_images_urls')
            .child(fileName);
        UploadTask uploadTask = ref.putFile(compressedImage);
        TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        images.add({"image url": downloadUrl, "image name": fileName});
        // ignore: use_build_context_synchronously
        var colorProvider = context.read<ColorProvider>();
        if (colorProvider.articleColors.isNotEmpty) {
          for (var element in colorProvider.articleColors) {
            if (image.path == element.imageFile.path) {
              colors.add({
                "image url": downloadUrl,
                "name": element.color,
                "amount": element.amount,
                "sizes": element.sizes
                    .map((e) => {"size": e.size, "amount": e.amount})
                    .toList()
              });
            }
          }
        }
      }

      setState(() {
        isUploaded = true;
      });
    }
  }

  Future<void> addProductToFirestore(
    String name,
    double price,
    List<String> categories,
    String sellerId,
    int amount,
    String description,
  ) async {
    Map<String, dynamic> deliveryInformations = {};
    deliveryInformations["delivery provider"] = livraisonController.text;
    deliveryInformations["min delay"] = int.parse(minDelayController.text);
    deliveryInformations["max delay"] = int.parse(maxDelayController.text);
    deliveryInformations["delivery fees"] =
        double.parse(deliveryFeesController.text);
    var sellerSnapShot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    Map<String, dynamic> shopData = sellerSnapShot.data()!['shop'];
    String sellerName = shopData['name'];

    var article = await FirebaseFirestore.instance.collection('Articles').add({
      'name to lower case': name.toLowerCase(),
      'name': name[0].toUpperCase() + name.substring(1),
      'price': price,
      'category': categories,
      'sellerId': sellerId,
      'images': images,
      'colors': colors,
      'amount': amount,
      'description': description,
      'average rate': 0,
      'total points': calculerScoreTemps(DateTime.now()),
      'rates number': 0,
      'date': Timestamp.now(),
      'status': true,
      'seller name': sellerName,
      'delivery informations': deliveryInformations
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
              route: "/ArticleDetailsPage",
              articleId: article.id);
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    if (productImages.length < 10) {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: source);
      if (pickedImage != null) {
        var croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: CropAspectRatio(ratioX: 11.8, ratioY: 10),
          compressQuality: 100,
        );

        if (croppedFile != null) {
          setState(() {
            productImages.add(File(croppedFile.path));
            animation = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const MainBackButton(),
          title: Text(
            "Ajouter un article",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: manageWidth(context, 17),
            ),
          ),
          centerTitle: true,
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
            items: productImages.isEmpty
                ? [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(manageHeight(context, 15)),
                          color: Colors.grey.shade200),
                      child: Center(
                        child: Text(
                          "Aucune image",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w400,
                            fontSize: manageHeight(context, 18),
                          ),
                        ),
                      ),
                    )
                  ]
                : productImages.map((imageFile) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.95,
                      decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(manageHeight(context, 15))),
                      child: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(manageHeight(context, 15)),
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
                width: manageWidth(context, productImages.length * 1.2 * 15),
                margin: EdgeInsets.only(top: manageHeight(context, 5)),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10)),
                child: PageViewIndicator(
                  length: productImages.isEmpty
                      ? productImages.length
                      : productImages.length,
                  currentIndex: currentIndex,
                  currentSize: manageWidth(context, 8),
                  otherSize: manageWidth(context, 6),
                  margin: EdgeInsets.fromLTRB(
                      manageWidth(context, 2.5),
                      manageHeight(context, 2.5),
                      manageWidth(context, 2.5),
                      manageHeight(context, 2.5)),
                ),
              ),
              const Spacer(),
              Consumer<ColorProvider>(builder: (context, value, child) {
                return GestureDetector(
                  onTap: () {
                    if (value.articleColors.isNotEmpty) {
                      context
                          .read<ColorProvider>()
                          .removeColorByFile(productImages[currentIndex]);
                      currentColorIndex = 0;
                    }

                    if (productImages.length == 1) {
                      setState(() {
                        productImages.clear();
                        currentIndex = 0;
                        animation = false;
                      });
                    } else if (productImages.length == 2) {
                      setState(() {
                        productImages.removeAt(currentIndex);
                        animation = false;
                        currentIndex = 0;
                      });
                    } else {
                      setState(() {
                        productImages.removeAt(currentIndex);
                        currentIndex--;
                        animation = false;
                      });
                    }
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
                              : const Color.fromARGB(255, 206, 86,
                                  86), // Couleur des bordures vertes
                          width: manageWidth(
                              context, 1.0), // Épaisseur des bordures
                        ),
                        borderRadius:
                            BorderRadius.circular(manageHeight(context, 15))),
                    child: Row(
                      children: [
                        Text("Supprimer",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: manageWidth(context, 12),
                              color: productImages.isEmpty
                                  ? Colors.transparent
                                  : const Color.fromARGB(255, 206, 86, 86),
                            )),
                        SizedBox(
                          width: manageWidth(context, 5),
                        ),
                        Icon(
                          CupertinoIcons.trash,
                          color: productImages.isEmpty
                              ? Colors.transparent
                              : const Color.fromARGB(255, 206, 86, 86),
                          size: manageWidth(context, 16),
                        )
                      ],
                    ),
                  ),
                );
              }),
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
            onTap: productImages.length < 8
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
                                        radius: 15,
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
                                        radius: 15,
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
                radius: 30,
                child: Icon(
                  CupertinoIcons.camera,
                  size: manageWidth(context, 25),
                ),
              ),
            ),
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          AuthTextField(
              controller: nameController,
              hintText: "nom du produit",
              obscuretext: false),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          Container(
              padding:
                  EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
              width: manageWidth(context, 335),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                    manageWidth(context, 8),
                    manageHeight(context, 8),
                    manageWidth(context, 8),
                    manageHeight(context, 8)),
                child: TextField(
                  controller: descriptionController,
                  maxLines: null,
                  maxLength: 250,
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "ajouter une description"),
                ),
              )),
          SizedBox(height: manageHeight(context, 15)),
          AuthTextField(
            controller: priceController,
            hintText: "prix",
            obscuretext: false,
            keyboardType: TextInputType.number,
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          AuthTextField(
            controller: amountController,
            hintText: "quantité",
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
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CategoryPage(categories: articlesFilters)));
                },
                child: Container(
                  padding: EdgeInsets.only(left: manageWidth(context, 5)),
                  height: manageHeight(context, 40),
                  width: manageWidth(context, 275),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Colors.grey.shade700, // Couleur des bordures vertes
                        width: manageWidth(
                          context, 1.0, // Épaisseur des bordures
                        ),
                      ),
                      borderRadius:
                          BorderRadius.circular(manageHeight(context, 15))),
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
                            fontSize: 15,
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
                    height: value.articleCategories.isEmpty
                        ? 1
                        : manageHeight(context, 45),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: value.articleCategories.isEmpty
                          ? [const SizedBox()]
                          : value.articleCategories
                              .map((e) => Container(
                                    padding: EdgeInsets.only(
                                        left: manageWidth(context, 10),
                                        right: manageWidth(context, 10)),
                                    margin: EdgeInsets.fromLTRB(
                                        manageWidth(context, 5),
                                        manageHeight(context, 5),
                                        manageWidth(context, 5),
                                        manageHeight(context, 5)),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color.fromARGB(
                                              255, 180, 92, 159),
                                          width: manageWidth(context,
                                              1.0), // Épaisseur des bordures
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            manageHeight(context, 15))),
                                    child: Center(
                                        child: Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            context
                                                .read<CategoriesProvider>()
                                                .removearticleCategory(e);
                                          },
                                          child: Icon(CupertinoIcons.clear,
                                              size: manageWidth(context, 18),
                                              color: const Color.fromARGB(
                                                  255, 180, 92, 159)),
                                        ),
                                        SizedBox(
                                          width: manageWidth(context, 3),
                                        ),
                                        Text(
                                          e,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                              color: const Color.fromARGB(
                                                  255, 180, 92, 159)),
                                        ),
                                      ],
                                    )),
                                  ))
                              .toList(),
                    ),
                  )),
          SizedBox(
            height: manageHeight(context, 10),
          ),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 15),
              ),
              GestureDetector(
                onTap: () {
                  if (productImages.isEmpty) {
                    const snackBar = SnackBar(
                      content: Text(
                        "Vous devez ajouter au moins une image.",
                      ),
                      backgroundColor: Color.fromARGB(255, 213, 89, 80),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AddColorToArticlePage(
                        articleImages: productImages,
                      );
                    }));
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(left: manageWidth(context, 5)),
                  height: manageHeight(context, 40),
                  width: manageWidth(context, 200),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            Colors.grey.shade700, // Couleur des bordures vertes
                        width:
                            manageWidth(context, 1.0), // Épaisseur des bordures
                      ),
                      borderRadius:
                          BorderRadius.circular(manageHeight(context, 15))),
                  child: Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 5),
                      ),
                      Icon(
                        Icons.color_lens,
                        color: Colors.grey.shade700,
                        size: manageWidth(context, 16),
                      ),
                      SizedBox(
                        width: manageWidth(context, 5),
                      ),
                      Text("Ajouter des couleurs",
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
          Consumer<ColorProvider>(
            builder: (context, value, child) {
              return Row(
                children: [
                  SizedBox(
                    width: manageWidth(context, 20),
                  ),
                  Text(
                      value.articleColors.isEmpty
                          ? 'Aucune couleur'
                          : 'Couleur: ${value.articleColors.toList()[currentColorIndex].color}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: manageWidth(context, 16),
                        color: Colors.grey.shade800,
                      )),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (value.articleColors.isNotEmpty) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return AddColorToArticlePage(
                              articleImages: productImages);
                        }));
                      }
                    },
                    child: Container(
                      padding:
                          EdgeInsets.only(left: manageWidth(context, 22.5)),
                      height: manageHeight(context, 30),
                      width: manageWidth(context, 90),
                      decoration: BoxDecoration(
                          border: Border.all(
                            color: value.articleColors.isEmpty
                                ? Colors.transparent
                                : AppColors
                                    .mainColor, // Couleur des bordures vertes
                            width: manageWidth(
                                context, 1.0), // Épaisseur des bordures
                          ),
                          borderRadius:
                              BorderRadius.circular(manageHeight(context, 15))),
                      child: Row(
                        children: [
                          Text("Edit",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: manageWidth(context, 16),
                                color: value.articleColors.isEmpty
                                    ? Colors.transparent
                                    : AppColors.mainColor,
                              )),
                          SizedBox(
                            width: manageWidth(context, 5),
                          ),
                          Icon(
                            Icons.edit,
                            color: value.articleColors.isEmpty
                                ? Colors.transparent
                                : AppColors.mainColor,
                            size: manageWidth(context, 16),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: manageWidth(context, 15),
                  )
                ],
              );
            },
          ),
          Consumer<ColorProvider>(
            builder: (context, value, child) {
              return Container(
                margin: EdgeInsets.fromLTRB(
                    manageWidth(context, 5),
                    manageHeight(context, 5),
                    manageWidth(context, 5),
                    manageHeight(context, 5)),
                height:
                    value.articleColors.isEmpty ? 1 : manageHeight(context, 70),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    if (value.articleColors.isEmpty) {
                      return const SizedBox();
                    }
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          currentColorIndex = index;
                        });

                        carouselController.animateToPage(productImages.indexOf(
                            productImages.firstWhere((element) =>
                                element.path ==
                                value.articleColors
                                    .toList()[index]
                                    .imageFile
                                    .path)));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: index == currentColorIndex
                                  ? const Color.fromARGB(77, 129, 180, 174)
                                  : Colors.grey.withOpacity(0.2),
                              spreadRadius: 3,
                              blurRadius: 4,
                              offset: const Offset(
                                  1, 2), // changement de position de l'ombre
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            value.articleColors.toList()[index].imageFile,
                            width: manageWidth(context, 70),
                            height: manageHeight(context, 70),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                  itemCount: value.articleColors.isEmpty
                      ? 1
                      : value.articleColors.length,
                ),
              );
            },
          ),
          SizedBox(
            height: manageHeight(context, 5),
          ),
          Consumer<ColorProvider>(
            builder: (context, value, child) {
              return Row(
                children: [
                  SizedBox(
                    width: manageWidth(context, 18),
                  ),
                  Text(
                    value.articleColors.isEmpty
                        ? ""
                        : value.articleColors
                                .toList()[currentColorIndex]
                                .sizes
                                .isNotEmpty
                            ? "Tailles"
                            : "",
                    style: GoogleFonts.poppins(
                        fontSize: manageWidth(context, 14),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800),
                  ),
                ],
              );
            },
          ),
          Consumer<ColorProvider>(
            builder: (context, value, child) {
              if (value.articleColors.isNotEmpty &&
                  value.articleColors
                      .toList()[currentColorIndex]
                      .sizes
                      .isEmpty) {
                return Row(
                  children: [
                    SizedBox(
                      width: manageWidth(context, 18),
                    ),
                    Text(
                      "Taille non renseignée",
                      style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 14),
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800),
                    ),
                  ],
                );
              }
              return SizedBox(
                height:
                    value.articleColors.isEmpty ? 1 : manageHeight(context, 55),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    if (value.articleColors.isEmpty) {
                      return const SizedBox();
                    }
                    return ArticleSizeContainer(
                        size: value.articleColors
                            .toList()[currentColorIndex]
                            .sizes[index]
                            .size);
                  },
                  itemCount: value.articleColors.isEmpty
                      ? 1
                      : value.articleColors
                          .toList()[currentColorIndex]
                          .sizes
                          .length,
                  scrollDirection: Axis.horizontal,
                ),
              );
            },
          ),
          SizedBox(
            height: manageHeight(context, 5),
          ),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 20),
              ),
              Text("Mode livraison:",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: manageWidth(context, 16),
                    color: Colors.grey.shade800,
                  )),
            ],
          ),
          SizedBox(
            height: manageHeight(context, 5),
          ),
          AuthTextField(
              controller: livraisonController,
              hintText: "livreur",
              obscuretext: false),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          AuthTextField(
            controller: minDelayController,
            hintText: "délais minimum en jour",
            obscuretext: false,
            keyboardType: TextInputType.number,
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          AuthTextField(
            controller: maxDelayController,
            hintText: "délais maximum en jour",
            obscuretext: false,
            keyboardType: TextInputType.number,
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          AuthTextField(
            controller: deliveryFeesController,
            hintText: "frais de livraison",
            obscuretext: false,
            keyboardType: TextInputType.number,
          ),
          SizedBox(
            height: manageHeight(context, 30),
          ),
          Consumer<CategoriesProvider>(
            builder: (context, value, child) => GestureDetector(
              onTap: (amountController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      // value.categories.isEmpty ||
                      descriptionController.text.isEmpty ||
                      minDelayController.text.isEmpty ||
                      maxDelayController.text.isEmpty ||
                      livraisonController.text.isEmpty)
                  ? () {
                      const snackBar = SnackBar(
                        content: Text(
                          "Veuillez remplir tous les champs.",
                        ),
                        backgroundColor: Color.fromARGB(255, 223, 44, 44),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  : value.articleCategories.isEmpty
                      ? () {
                          const snackBar = SnackBar(
                            content: Text(
                              "Vous devez renseigner au moins une catégorie.",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                      : context.read<ColorProvider>().articleColors.isEmpty
                          ? () {
                              const snackBar = SnackBar(
                                content: Text(
                                  "Vous devez aujouter au moins une couleur.",
                                ),
                                backgroundColor:
                                    Color.fromARGB(255, 223, 44, 44),
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          : isUploaded
                              ? () {
                                  const snackBar = SnackBar(
                                    content: Text(
                                      "Vous avez déjà ajouter cet article.",
                                    ),
                                    backgroundColor:
                                        Color.fromARGB(255, 223, 44, 44),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : productImages.isEmpty
                                  ? () {
                                      const snackBar = SnackBar(
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
                                      await uploadImagesToFirebaseStorage(
                                          productImages, context);
                                      await addProductToFirestore(
                                          nameController.text,
                                          double.parse(priceController.text),
                                          value.articleCategories.toList(),
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          int.parse(amountController.text),
                                          descriptionController.text);
                                      // ignore: use_build_context_synchronously
                                      context
                                          .read<CategoriesProvider>()
                                          .articleCategoriesclear();
                                      // ignore: use_build_context_synchronously
                                      context.read<ColorProvider>().clear();
                                      const snackBar = SnackBar(
                                        content: Text(
                                          "Article Ajouté avec succès.",
                                        ),
                                        backgroundColor:
                                            Color.fromARGB(255, 26, 73, 26),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);

                                      Navigator.pop(context);
                                    },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.circular(25)),
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
            height: manageHeight(context, 15),
          ),
          CircularProgressIndicator(
            color: isLoading ? AppColors.mainColor : Colors.transparent,
          ),
          SizedBox(
            height: manageHeight(context, 30),
          ),
        ])));
  }
}
