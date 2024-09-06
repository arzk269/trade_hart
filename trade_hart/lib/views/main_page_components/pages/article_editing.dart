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
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/article_size_data.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/model/colors_provider.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/category_page.dart';
import 'package:trade_hart/views/main_page_components/pages/network_color_add_page.dart';
import 'package:trade_hart/views/main_page_components/pages/network_color_size_add_page.dart';
import 'package:path_provider/path_provider.dart';

class EditArticlePage extends StatefulWidget {
  final Article article;
  EditArticlePage({super.key, required this.article});

  @override
  State<EditArticlePage> createState() => _EditArticlePageState();
}

class _EditArticlePageState extends State<EditArticlePage> {
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
  TextEditingController amountController = TextEditingController();
  TextEditingController livraisonController = TextEditingController();
  TextEditingController minDelayController = TextEditingController();
  TextEditingController maxDelayController = TextEditingController();
  TextEditingController deliveryFeesController = TextEditingController();
  bool animation = true;
  Set<NetworkArticleColor> old = {};

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
      }

      setState(() {
        isUploaded = true;
      });
    }
  }

  Future<void> deleteExistingImage(Map<String, dynamic> image) async {
    await FirebaseStorage.instance
        .ref()
        .child('articles_images_urls/${image['image name']}')
        .delete();
    var reference = FirebaseFirestore.instance
        .collection('Articles')
        .doc(widget.article.id);
    await reference.update({
      'images': FieldValue.arrayRemove([image])
    });
  }

  Future<void> editArticleToFireStore(
      String name,
      double price,
      List<String> categories,
      int amount,
      String description,
      String deliveryProvider,
      int minDelay,
      int maxDelay,
      double deliveryFees,
      List<NetworkArticleColor> colors) async {
    Map<String, dynamic> deliveryInformations = {};
    deliveryInformations["delivery provider"] = deliveryProvider;
    deliveryInformations["min delay"] = minDelay;
    deliveryInformations["max delay"] = maxDelay;
    deliveryInformations["delivery fees"] = deliveryFees;
    var ref = FirebaseFirestore.instance
        .collection('Articles')
        .doc(widget.article.id);

    if (images.isNotEmpty) {
      for (var image in images) {
        await ref.update({
          'images': FieldValue.arrayUnion([image])
        });
      }
    }
    await ref.update(
      {
        'name': name[0] + name.substring(1),
        'name to lower case': name.toLowerCase(),
        'price': price,
        'category': categories,
        'amount': amount,
        'description': description,
        'delivery informations': deliveryInformations,
        'colors': colors
            .map((e) => {
                  "amount": e.amount,
                  "image url": e.imageUrl,
                  "name": e.color,
                  "sizes": e.sizes
                })
            .toList()
      },
    );
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
            productImages.add(Image.file(
              File(pickedImage.path),
              fit: BoxFit.cover,
              semanticLabel: 'local image',
            ));

            newImagesToAdd.add(File(croppedFile.path));
            animation = true;
          });
        }
      }
    }
  }

  @override
  void initState() {
    context.read<ColorProvider>().clear();
    for (var image in widget.article.images) {
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
                  CupertinoIcons.exclamationmark_triangle,
                  size: manageWidth(context, 30),
                ),
                SizedBox(
                  height: manageHeight(context, 3),
                ),
                const Text(
                  "Erreur lors du chargement",
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                )
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            )),
      ));
    }

    nameController = TextEditingController(text: widget.article.name);
    descriptionController =
        TextEditingController(text: widget.article.description);
    priceController =
        TextEditingController(text: widget.article.price.toString());
    amountController =
        TextEditingController(text: widget.article.amount.toString());
    livraisonController = TextEditingController(
        text: widget.article.deliveryInformations['delivery provider']);
    minDelayController = TextEditingController(
        text: widget.article.deliveryInformations['min delay'].toString());
    maxDelayController = TextEditingController(
        text: widget.article.deliveryInformations['max delay'].toString());
    deliveryFeesController = TextEditingController(
        text: widget.article.deliveryInformations['delivery fees'].toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: MainBackButton(),
          title: Text(
            "Modifier cet article",
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
                            fontSize: manageWidth(context, 18),
                          ),
                        ),
                      ),
                    )
                  ]
                : productImages.map(
                    (image) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.95,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 15)),
                            color: Color.fromARGB(255, 221, 202, 202)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 15)),
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
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 10))),
                child: PageViewIndicator(
                  length: productImages.length,
                  currentIndex: currentIndex,
                  currentSize: manageWidth(
                    context,
                    8,
                  ),
                  otherSize: manageWidth(
                    context,
                    6,
                  ),
                  margin: EdgeInsets.all(2.5),
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
                          'La suppression de cette image entrainera celle de la couleur qui lui est associée.',
                          style: TextStyle(fontSize: manageWidth(context, 15)),
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
                                if (productImages[currentIndex].semanticLabel !=
                                    'local image') {
                                  for (var element in context
                                      .read<ColorProvider>()
                                      .networkArticleColors) {
                                    if (element.imageUrl ==
                                        productImages[currentIndex]
                                            .semanticLabel) {
                                      setState(() {
                                        widget.article.colors.remove(element);
                                      });
                                    }
                                  }

                                  setState(() {
                                    existingImagesTodelete.add(
                                        widget.article.images[currentIndex]);
                                  });
                                }
                                setState(() {
                                  productImages.clear();
                                  currentIndex = 0;
                                });
                              }
                              if (productImages.length == 2) {
                                if (productImages[currentIndex].semanticLabel !=
                                    'local image') {
                                  for (var element in context
                                      .read<ColorProvider>()
                                      .networkArticleColors) {
                                    if (element.imageUrl ==
                                        productImages[currentIndex]
                                            .semanticLabel) {
                                      setState(() {
                                        widget.article.colors.remove(element);
                                      });
                                    }
                                  }
                                  setState(() {
                                    existingImagesTodelete.add(
                                        widget.article.images[currentIndex]);
                                  });
                                }
                                setState(() {
                                  productImages.removeAt(currentIndex);
                                  currentIndex = 0;
                                  animation = false;
                                });
                              } else {
                                if (productImages[currentIndex].semanticLabel !=
                                    'local image') {
                                  for (var element in context
                                      .read<ColorProvider>()
                                      .networkArticleColors) {
                                    if (element.imageUrl ==
                                        productImages[currentIndex]
                                            .semanticLabel) {
                                      setState(() {
                                        widget.article.colors.remove(element);
                                      });
                                    }
                                  }
                                  setState(() {
                                    existingImagesTodelete.add(
                                        widget.article.images[currentIndex]);
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
                            : Color.fromARGB(255, 206, 86,
                                86), // Couleur des bordures vertes
                        width:
                            manageWidth(context, 1.0), // Épaisseur des bordures
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
                          "Vous avez déjà ajouter cet article.",
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
                radius: 30,
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
                'nom du produit',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: manageWidth(context, 15.0)),
            child: AuthTextField(
                controller: nameController,
                hintText: "nom du produit",
                obscuretext: false),
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
                'description',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              width: manageWidth(context, 335),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(manageHeight(context, 20)),
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
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "ajouter une description"),
                ),
              )),
          SizedBox(height: manageHeight(context, 25)),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 20),
              ),
              Text(
                'prix',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: manageWidth(context, 15.0)),
            child: AuthTextField(
              controller: priceController,
              hintText: "prix",
              obscuretext: false,
              keyboardType: TextInputType.number,
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
                widget.article.amount <= 10 ? "Stock insuffisant" : 'Quantité',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500,
                    color: widget.article.amount <= 10 ? Colors.red : null),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: manageWidth(context, 15.0)),
            child: AuthTextField(
              controller: amountController,
              hintText: "quantité",
              obscuretext: false,
              keyboardType: TextInputType.number,
            ),
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
                  padding: EdgeInsets.only(
                    left: manageWidth(context, 5),
                  ),
                  height: manageHeight(context, 40),
                  width: manageWidth(context, 275),
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
            builder: (context, value, child) {
              context
                  .read<CategoriesProvider>()
                  .getarticleCategories(widget.article.categories);
              return Container(
                margin: EdgeInsets.only(
                  left: manageWidth(context, 10),
                ),
                height: manageHeight(context, 45),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: value.articleCategories
                      .map((e) => Container(
                            padding: EdgeInsets.only(
                                left: manageWidth(
                                  context,
                                  10,
                                ),
                                right: manageWidth(context, 10)),
                            margin: EdgeInsets.fromLTRB(
                                manageWidth(context, 5),
                                manageHeight(context, 5),
                                manageWidth(context, 5),
                                manageHeight(context, 5)),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 180, 92, 159),
                                  width: manageWidth(
                                      context, 1.0), // Épaisseur des bordures
                                ),
                                borderRadius: BorderRadius.circular(
                                    manageHeight(context, 15))),
                            child: Center(
                                child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.article.categories.remove(e);
                                    });
                                    context
                                        .read<CategoriesProvider>()
                                        .removearticleCategory(e);
                                  },
                                  child: Icon(CupertinoIcons.clear,
                                      size: manageWidth(context, 18),
                                      color: Color.fromARGB(255, 180, 92, 159)),
                                ),
                                SizedBox(
                                  width: manageWidth(context, 3),
                                ),
                                Text(
                                  e,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: manageWidth(context, 15),
                                      color: Color.fromARGB(255, 180, 92, 159)),
                                ),
                              ],
                            )),
                          ))
                      .toList(),
                ),
              );
            },
          ),
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
                  if (productImages
                      .where((element) =>
                          element.semanticLabel != 'local image' &&
                          !context
                              .read<ColorProvider>()
                              .networkArticleColors
                              .any((color) =>
                                  color.imageUrl == element.semanticLabel))
                      .isEmpty) {
                    var snackBar = SnackBar(
                      content: Text(
                        "Pour ajouter de nouvelles couleurs vous devez enregistrer de nouvelles images.",
                      ),
                      backgroundColor: Color.fromARGB(255, 223, 44, 44),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else if (clotheSizes.contains(context
                      .read<ColorProvider>()
                      .networkArticleColors
                      .toList()[0]
                      .sizes[0]["size"])) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NetworkColorAddPage(
                                groupSizeValue: 0,
                                images: context
                                        .read<ColorProvider>()
                                        .networkArticleColors
                                        .isEmpty
                                    ? productImages
                                        .where((element) =>
                                            element.semanticLabel !=
                                            'local image')
                                        .toList()
                                    : productImages
                                        .where((element) =>
                                            element.semanticLabel !=
                                                'local image' &&
                                            !context
                                                .read<ColorProvider>()
                                                .networkArticleColors
                                                .any((color) =>
                                                    color.imageUrl ==
                                                    element.semanticLabel))
                                        .toList())));
                  } else if (shoeSizes.contains(context
                      .read<ColorProvider>()
                      .networkArticleColors
                      .toList()[0]
                      .sizes[0]["size"])) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NetworkColorAddPage(
                                groupSizeValue: 1,
                                images: context
                                        .read<ColorProvider>()
                                        .networkArticleColors
                                        .isEmpty
                                    ? productImages
                                        .where((element) =>
                                            element.semanticLabel !=
                                            'local image')
                                        .toList()
                                    : productImages
                                        .where((element) =>
                                            element.semanticLabel !=
                                                'local image' &&
                                            !context
                                                .read<ColorProvider>()
                                                .networkArticleColors
                                                .any((color) =>
                                                    color.imageUrl ==
                                                    element.semanticLabel))
                                        .toList())));
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NetworkColorAddPage(
                                groupSizeValue: 2,
                                images: context
                                        .read<ColorProvider>()
                                        .networkArticleColors
                                        .isEmpty
                                    ? productImages
                                        .where((element) =>
                                            element.semanticLabel !=
                                            'local image')
                                        .toList()
                                    : productImages
                                        .where((element) =>
                                            element.semanticLabel !=
                                                'local image' &&
                                            !context
                                                .read<ColorProvider>()
                                                .networkArticleColors
                                                .any((color) =>
                                                    color.imageUrl ==
                                                    element.semanticLabel))
                                        .toList())));
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(
                    left: manageWidth(context, 5),
                  ),
                  height: manageHeight(context, 40),
                  width: manageWidth(context, 275),
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
                      Text("Ajouter une couleur",
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
              old.addAll(value.networkArticleColors.where((element) =>
                  !widget.article.colors.any((e) => e.color == element.color)));
              value.clear();
              old.addAll(widget.article.colors);
              value.getNetworKColors(old.toList());
              return Container(
                height: manageHeight(context, 430),
                margin: EdgeInsets.fromLTRB(manageWidth(context, 7.5),
                    manageHeight(context, 20), manageWidth(context, 7.5), 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                    width: manageWidth(context, 0.1),
                  ),
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1.5,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: value.networkArticleColors.isEmpty
                    ? Center(
                        child: Text("Aucune couleur ajoutée",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: manageWidth(context, 17),
                              color: Colors.grey.shade700,
                            )),
                      )
                    : ListView(
                        children: value.networkArticleColors
                            .map((e) => Column(
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: manageHeight(context, 30),
                                            left: manageWidth(context, 15),
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                manageHeight(context, 10)),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.2),
                                                spreadRadius: 3,
                                                blurRadius: 4,
                                                offset: Offset(1,
                                                    2), // changement de position de l'ombre
                                              ),
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                manageHeight(context, 10)),
                                            child: Image.network(
                                              e.imageUrl,
                                              width: manageWidth(context, 70),
                                              height: manageHeight(context, 70),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: manageWidth(context, 30),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: manageHeight(context, 25),
                                            ),
                                            Text("Couleur : ${e.color}",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: manageWidth(
                                                      context, 15.5),
                                                  color: Colors.grey.shade800,
                                                )),
                                            SizedBox(
                                                height: manageHeight(
                                                    context, 12.5)),
                                            Text("Quantité : ${e.amount}",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: manageWidth(
                                                      context, 15.5),
                                                  color: e.amount <= 10
                                                      ? Colors.red
                                                      : Colors.grey.shade800,
                                                )),
                                          ],
                                        ),
                                        Spacer(),
                                        Column(
                                          children: [
                                            SizedBox(
                                              height: manageHeight(context, 25),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                if (value.networkArticleColors
                                                        .length >
                                                    1) {
                                                  value.deleteNetowrkColor(e);
                                                  setState(() {
                                                    widget.article.colors
                                                        .remove(e);
                                                  });
                                                } else {
                                                  var snackBar = SnackBar(
                                                    content: Text(
                                                      "Il doit y avoir au moins une couleur.",
                                                    ),
                                                    backgroundColor:
                                                        Color.fromARGB(
                                                            255, 223, 44, 44),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(snackBar);
                                                }
                                              },
                                              child: Icon(
                                                CupertinoIcons.trash,
                                                color: Color.fromARGB(
                                                    255, 206, 86, 86),
                                                size: manageWidth(context, 20),
                                              ),
                                            ),
                                            SizedBox(
                                              height:
                                                  manageHeight(context, 12.5),
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    value.networkMinus(e);
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons
                                                        .minus_circled,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                      manageWidth(context, 2),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    value.networkAdd(e);
                                                  },
                                                  child: Icon(
                                                    CupertinoIcons.add_circled,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: manageWidth(context, 15),
                                        )
                                      ],
                                    ),
                                    SizedBox(
                                      height: manageHeight(context, 10),
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: manageWidth(context, 15),
                                        ),
                                        Text(
                                          "Tailles",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize:
                                                manageWidth(context, 16.5),
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Spacer(),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        NetworkColorSizeAddPage(
                                                            color: e.color)));
                                          },
                                          child: Container(
                                            margin: EdgeInsets.only(
                                              left: manageWidth(context, 10),
                                            ),
                                            padding: EdgeInsets.only(
                                                left: manageWidth(
                                              context,
                                              12,
                                            )),
                                            height: manageHeight(context, 35),
                                            width: 165,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color.fromARGB(
                                                      255,
                                                      255,
                                                      146,
                                                      146), // Couleur des bordures vertes
                                                  width:
                                                      1.0, // Épaisseur des bordures
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        manageHeight(
                                                            context, 15))),
                                            child: Row(
                                              children: [
                                                Text("Ajouter une taille",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: manageWidth(
                                                          context, 14),
                                                      color: Color.fromARGB(
                                                          255, 255, 146, 146),
                                                    )),
                                                SizedBox(
                                                  width:
                                                      manageWidth(context, 5),
                                                ),
                                                Icon(
                                                  Icons.add,
                                                  color: Color.fromARGB(
                                                      255, 255, 146, 146),
                                                  size:
                                                      manageWidth(context, 16),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: manageWidth(context, 5),
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: manageHeight(context, 65),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.95,
                                          child: e.sizes.isEmpty
                                              ? Row(
                                                  children: [
                                                    SizedBox(
                                                      width: manageWidth(
                                                          context, 15),
                                                    ),
                                                    Text(
                                                      "Taille unique",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: manageWidth(
                                                            context, 14),
                                                        color: Colors
                                                            .grey.shade700,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Row(
                                                      children: [
                                                        SizedBox(
                                                          width: manageWidth(
                                                              context, 15),
                                                        ),
                                                        Container(
                                                          height: manageHeight(
                                                              context, 40),
                                                          padding: EdgeInsets.only(
                                                              right:
                                                                  manageWidth(
                                                                      context,
                                                                      15)),
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border
                                                                      .all(
                                                                    color: e.sizes[index]['amount'] <=
                                                                            5
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .grey
                                                                            .shade700, // Couleur des bordures vertes
                                                                    width: manageWidth(
                                                                        context,
                                                                        1.0), // Épaisseur des bordures
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(
                                                                      manageHeight(
                                                                          context,
                                                                          20))),
                                                          child: Center(
                                                            child: Row(
                                                              children: [
                                                                SizedBox(
                                                                  width:
                                                                      manageWidth(
                                                                          context,
                                                                          7.5),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    value.networkDeleteSize(
                                                                        e,
                                                                        index);
                                                                  },
                                                                  child: Icon(
                                                                    CupertinoIcons
                                                                        .clear,
                                                                    size: manageWidth(
                                                                        context,
                                                                        17),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      manageWidth(
                                                                          context,
                                                                          5),
                                                                ),
                                                                Text(
                                                                  e.sizes[index]
                                                                      ['size'],
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                    fontSize: manageWidth(
                                                                        context,
                                                                        16.5),
                                                                    color: e.sizes[index]['amount'] <=
                                                                            5
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .grey
                                                                            .shade700,
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                    width: manageWidth(
                                                                        context,
                                                                        15)),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    value.networkMinusSize(
                                                                        e,
                                                                        index);
                                                                  },
                                                                  child: Icon(
                                                                    CupertinoIcons
                                                                        .minus_circle,
                                                                    size: manageWidth(
                                                                        context,
                                                                        17),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      manageWidth(
                                                                          context,
                                                                          5),
                                                                ),
                                                                Text(
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  e.sizes[index]
                                                                          [
                                                                          'amount']
                                                                      .toString(),
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        manageWidth(
                                                                            context,
                                                                            14),
                                                                    color: e.sizes[index]['amount'] <=
                                                                            5
                                                                        ? Colors
                                                                            .red
                                                                        : Colors
                                                                            .grey
                                                                            .shade700,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width:
                                                                      manageWidth(
                                                                          context,
                                                                          5),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    value.networkAddSize(
                                                                        e,
                                                                        index);
                                                                  },
                                                                  child: Icon(
                                                                    CupertinoIcons
                                                                        .add_circled,
                                                                    size: manageWidth(
                                                                        context,
                                                                        17),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                  itemCount: e.sizes.length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: manageHeight(context, 10),
                                    ),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal:
                                              manageWidth(context, 7.5)),
                                      height: manageHeight(context, 1.7),
                                      color: Colors.grey.withOpacity(0.4),
                                    )
                                  ],
                                ))
                            .toList(),
                      ),
              );
            },
          ),
          SizedBox(
            height: manageHeight(context, 15),
          ),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 18),
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
              height: manageHeight(
            context,
            5,
          )),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 20),
              ),
              Text(
                'livreur',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: manageWidth(context, 15.0)),
            child: AuthTextField(
                controller: livraisonController,
                hintText: "livreur",
                obscuretext: false),
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
                'délais minimum en jours',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: manageWidth(context, 15.0)),
            child: AuthTextField(
              controller: minDelayController,
              hintText: "délais minimum en jour",
              obscuretext: false,
              keyboardType: TextInputType.number,
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
                'délais maximum en jour',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: manageWidth(context, 15.0)),
            child: AuthTextField(
              controller: maxDelayController,
              hintText: "délais maximum en jour",
              obscuretext: false,
              keyboardType: TextInputType.number,
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
                'frais de livraison',
                style: TextStyle(
                    fontSize: manageWidth(context, 15),
                    fontWeight: FontWeight.w500),
              ),
            ],
          ),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: manageWidth(context, 15.0)),
            child: AuthTextField(
              controller: deliveryFeesController,
              hintText: "frais de livraison",
              obscuretext: false,
              keyboardType: TextInputType.number,
            ),
          ),
          SizedBox(
            height: manageHeight(context, 30),
          ),
          Consumer<CategoriesProvider>(
            builder: (context, value, child) => GestureDetector(
              onTap: (amountController.text.isEmpty ||
                      nameController.text.isEmpty ||
                      priceController.text.isEmpty ||
                      value.articleCategories.isEmpty ||
                      descriptionController.text.isEmpty ||
                      minDelayController.text.isEmpty ||
                      maxDelayController.text.isEmpty ||
                      livraisonController.text.isEmpty)
                  ? () {
                      var snackBar = SnackBar(
                        content: Text(
                          "Veuillez remplir tous les champs.",
                        ),
                        backgroundColor: Color.fromARGB(255, 223, 44, 44),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  : isUploaded
                      ? () {
                          var snackBar = SnackBar(
                            content: Text(
                              "Vous avez déjà ajouter cet article.",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                                for (var image in existingImagesTodelete) {
                                  await deleteExistingImage(image);
                                }
                              }

                              if (newImagesToAdd.isNotEmpty) {
                                await uploadImagesToFirebaseStorage(
                                    newImagesToAdd);
                              }

                              await editArticleToFireStore(
                                  nameController.text,
                                  double.parse(priceController.text),
                                  value.articleCategories.toList(),
                                  int.parse(amountController.text),
                                  descriptionController.text,
                                  livraisonController.text,
                                  int.parse(minDelayController.text),
                                  int.parse(maxDelayController.text),
                                  double.parse(deliveryFeesController.text),
                                  old.toList());
                              // ignore: use_build_context_synchronously
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
                            },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 25))),
                child: Center(
                  child: Text("Modifier",
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
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 25))),
              child: Center(
                child: Text("Annuler",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: manageWidth(context, 16))),
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
        ])));
  }
}
