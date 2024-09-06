// ignore_for_file: use_build_context_synchronously, duplicate_ignore

import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_page_view_indicator/flutter_page_view_indicator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/amount_article_command_provider.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/color_index_provider.dart';

import 'package:trade_hart/model/detail_article_index_provider.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/model/size_index_privider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/authentication_pages/login_page.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_container.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/rate_stars_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/pages/article_rates_page.dart';
import 'package:trade_hart/views/main_page_components/pages/cart_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

class ArticleDetailsPage extends StatefulWidget {
  final String? articleId;
  const ArticleDetailsPage({super.key, this.articleId});

  @override
  State<ArticleDetailsPage> createState() => _ArticleDetailsPageState();
}

class _ArticleDetailsPageState extends State<ArticleDetailsPage> {
  var currentUser = FirebaseAuth.instance.currentUser;
  // int currentIndex = 0;
  CarouselSliderController carouselController = CarouselSliderController();

  @override
  void initState() {
    if (context.read<DetailsIndexProvider>().index != 0) {
      context.read<DetailsIndexProvider>().reset();
    }

    if (context.read<SizeIndexProvider>().currentSizeIndex != 0) {
      context.read<SizeIndexProvider>().updateIndex(0);
    }

    if (context.read<ColorIndexProvider>().currenColortIndex != 0) {
      context.read<ColorIndexProvider>().updateIndex(0);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _showOverlay(BuildContext context) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).size.height * 0.5,
        left: MediaQuery.of(context).size.width * 0.075,
        width: MediaQuery.of(context).size.width * 0.85,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(manageHeight(context, 10)),
              ),
              padding: EdgeInsets.fromLTRB(
                  manageWidth(context, 20),
                  manageHeight(context, 20),
                  manageWidth(context, 20),
                  manageHeight(context, 20)),
              child: Text(
                'Stock insufisant par rapport à la quantité demandée.',
                style: TextStyle(
                    color: Colors.white, fontSize: manageWidth(context, 15)),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Widget buildBottomSheetContent(Article article) {
    return BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: 0.8, sigmaY: 0.8), // Ajustez le flou selon vos préférences
        child: ClipRRect(
          // Couleur de fond avec opacité réduite
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(manageHeight(context, 20)),
            topRight: Radius.circular(manageHeight(context, 20)),
          ),
          child: SizedBox(
            height: manageHeight(context, 580),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: manageHeight(context, 5),
                ),
                Center(
                  child: Container(
                    height: manageHeight(context, 3),
                    width: manageWidth(context, 45),
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(
                  height: manageHeight(context, 15),
                ),
                Center(
                  child: Text(
                    article.name,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                        fontSize: manageWidth(context, 18),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800),
                  ),
                ),
                SizedBox(height: manageHeight(context, 10)),
                Row(
                  children: [
                    SizedBox(
                      width: manageWidth(context, 15),
                    ),
                    Consumer<ColorIndexProvider>(
                      builder: (context, value, child) => Text(
                          "Couleur : ${article.colors.isNotEmpty ? article.colors[value.currenColortIndex].color : 'Non renseignée'}",
                          style: GoogleFonts.poppins(
                              fontSize: manageWidth(context, 16),
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800)),
                    ),
                  ],
                ),
                SizedBox(
                  height: manageHeight(context, 10),
                ),
                SizedBox(
                  height:
                      (article.colors.isEmpty) ? 1 : manageHeight(context, 100),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (article.colors.isEmpty) {
                        return SizedBox(
                          height: manageHeight(context, 0.5),
                        );
                      }
                      return Consumer<ColorIndexProvider>(
                        builder: (context, value, child) {
                          return GestureDetector(
                            onTap: () {
                              //BuildContext context;
                              value.updateIndex(index);
                              carouselController.animateToPage(article.images
                                  .indexOf(article.images.firstWhere(
                                      (element) =>
                                          element['image url'] ==
                                          article.colors[index].imageUrl)));
                            },
                            child: Container(
                                width: manageWidth(context, 120),
                                height: manageHeight(context, 100),
                                margin: EdgeInsets.only(
                                    left: manageWidth(context, 15)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      manageWidth(context, 10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: index ==
                                              context
                                                  .read<ColorIndexProvider>()
                                                  .currenColortIndex
                                          ? const Color.fromARGB(
                                              77, 129, 180, 174)
                                          : Colors.grey.withOpacity(0.2),
                                      spreadRadius: manageHeight(context, 3),
                                      blurRadius: manageHeight(context, 4),
                                      offset: const Offset(1,
                                          2), // changement de position de l'ombre
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        manageWidth(context, 10)),
                                    child: Image.network(
                                      article.colors[index].imageUrl,
                                      fit: BoxFit.cover,
                                    ))),
                          );
                        },
                      );
                    },
                    itemCount:
                        article.colors.isEmpty ? 1 : article.colors.length,
                  ),
                ),
                SizedBox(
                  height: manageHeight(context, 10),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: manageWidth(context, 15),
                    ),
                    Consumer<SizeIndexProvider>(
                      builder: (context, value, child) => Text(
                          article
                                  .colors[context
                                      .read<ColorIndexProvider>()
                                      .currenColortIndex]
                                  .sizes
                                  .where((element) => element["amount"] > 0)
                                  .isEmpty
                              ? ""
                              : "Taille : ${article.colors[context.read<ColorIndexProvider>().currenColortIndex].sizes.where((element) => element["amount"] > 0).toList()[context.read<SizeIndexProvider>().currentSizeIndex]['size']}",
                          style: GoogleFonts.poppins(
                            fontSize: manageWidth(context, 15),
                            fontWeight: FontWeight.w500,
                          )),
                    ),
                  ],
                ),
                Consumer<SizeIndexProvider>(
                  builder: (context, value, child) {
                    return SizedBox(
                      height: manageHeight(context, 50),
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          if (article
                              .colors[context
                                  .read<ColorIndexProvider>()
                                  .currenColortIndex]
                              .sizes
                              .where((element) => element["amount"] > 0)
                              .isEmpty) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  left: manageWidth(context, 15)),
                              child: Text("Aucune taille n'est disponible",
                                  style: GoogleFonts.poppins(
                                    fontSize: manageWidth(context, 14),
                                    fontWeight: FontWeight.w500,
                                  )),
                            );
                          }
                          return GestureDetector(
                            onTap: () {
                              value.updateIndex(index);
                              if (article
                                          .colors[context
                                              .read<ColorIndexProvider>()
                                              .currenColortIndex]
                                          .sizes
                                          .where((element) => element["amount"] > 0)
                                          .toList()[value.currentSizeIndex]
                                      ['amount'] <
                                  context
                                      .read<AmountArticleCommandProvider>()
                                      .amount) {
                                while (context
                                        .read<AmountArticleCommandProvider>()
                                        .amount >
                                    article
                                            .colors[context
                                                .read<ColorIndexProvider>()
                                                .currenColortIndex]
                                            .sizes
                                            .where((element) =>
                                                element["amount"] > 0)
                                            .toList()[value.currentSizeIndex]
                                        ['amount']) {
                                  context
                                      .read<AmountArticleCommandProvider>()
                                      .reduce();
                                }
                              }
                            },
                            child: ArticleSizeContainer(
                                color: context
                                            .read<SizeIndexProvider>()
                                            .currentSizeIndex ==
                                        index
                                    ? AppColors.mainColor
                                    : Colors.grey.shade700,
                                size: article
                                    .colors[context
                                        .read<ColorIndexProvider>()
                                        .currenColortIndex]
                                    .sizes
                                    .where((element) => element["amount"] > 0)
                                    .toList()[index]['size']),
                          );
                        },
                        itemCount: article
                                .colors[context
                                    .read<ColorIndexProvider>()
                                    .currenColortIndex]
                                .sizes
                                .where((element) => element["amount"] > 0)
                                .isEmpty
                            ? 1
                            : article
                                .colors[context
                                    .read<ColorIndexProvider>()
                                    .currenColortIndex]
                                .sizes
                                .where((element) => element["amount"] > 0)
                                .length,
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
                    Text("Vendu par :",
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 14),
                          fontWeight: FontWeight.w500,
                        )),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SellerPage(sellerId: article.sellerId))),
                      child: SellerNameView(
                        name: article.sellerName,
                        iconSize: manageWidth(context, 17),
                        fontSize: manageWidth(context, 15),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: manageHeight(context, 10),
                ),
                Consumer<AmountArticleCommandProvider>(
                    builder: (context, value, child) => Row(
                          children: [
                            SizedBox(
                              width: manageWidth(context, 15),
                            ),
                            Text("Quantité :",
                                style: GoogleFonts.poppins(
                                    fontSize: manageWidth(context, 17),
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade800)),
                            SizedBox(
                              width: manageWidth(context, 5),
                            ),
                            IconButton(
                                onPressed: () {
                                  value.reduce();
                                },
                                icon: const Icon(CupertinoIcons.minus_circle)),
                            Text(
                              value.amount.toString(),
                              style:
                                  TextStyle(fontSize: manageWidth(context, 16)),
                            ),
                            IconButton(
                                onPressed: () {
                                  if (article
                                              .colors[context
                                                  .read<ColorIndexProvider>()
                                                  .currenColortIndex]
                                              .sizes
                                              .where((element) =>
                                                  element["amount"] > 0)
                                              .toList()[
                                          context
                                              .read<SizeIndexProvider>()
                                              .currentSizeIndex]['amount'] >
                                      value.amount) {
                                    value.add();
                                  } else {
                                    _showOverlay(context);
                                  }
                                },
                                icon: const Icon(CupertinoIcons.add_circled)),
                            SizedBox(
                              width: manageWidth(context, 35),
                            ),
                            FloatingActionButton(
                              splashColor: Colors.deepPurple,
                              onPressed: () async {
                                if (article
                                    .colors[context
                                        .read<ColorIndexProvider>()
                                        .currenColortIndex]
                                    .sizes
                                    .where((element) => element["amount"] > 0)
                                    .isNotEmpty) {
                                  Navigator.pop(context);
                                  String userId =
                                      FirebaseAuth.instance.currentUser!.uid;

                                  // Référence du document "panier" de l'utilisateur
                                  DocumentReference userCartRef =
                                      FirebaseFirestore.instance
                                          .collection('Cart')
                                          .doc(userId);
                                  var items = await userCartRef
                                      .collection('Items')
                                      .get();
                                  var itemDocs = items.docs;

                                  var itemDoc = itemDocs.where((element) =>
                                      element["article id"] == article.id &&
                                      element["seller id"] ==
                                          article.sellerId &&
                                      element["color index"] ==
                                          context
                                              .read<ColorIndexProvider>()
                                              .currenColortIndex &&
                                      element["size index"] ==
                                          context
                                              .read<SizeIndexProvider>()
                                              .currentSizeIndex);
                                  if (itemDoc.isNotEmpty) {
                                    if (itemDoc.first["amount"] +
                                            context
                                                .read<
                                                    AmountArticleCommandProvider>()
                                                .amount >
                                        article
                                                .colors[context
                                                    .read<ColorIndexProvider>()
                                                    .currenColortIndex]
                                                .sizes[
                                            context
                                                .read<SizeIndexProvider>()
                                                .currentSizeIndex]["amount"]) {
                                      _showOverlay(context);
                                    } else {
                                      userCartRef
                                          .collection('Items')
                                          .doc(itemDoc.first.id)
                                          .update({
                                        "amount": itemDoc.first["amount"] +
                                            context
                                                .read<
                                                    AmountArticleCommandProvider>()
                                                .amount
                                      });
                                    }
                                  } else {
                                    var seller = await userCartRef
                                        .collection('Items')
                                        .add({
                                      "article id": article.id,
                                      "seller id": article.sellerId,
                                      // ignore: use_build_context_synchronously
                                      "amount": context
                                          .read<AmountArticleCommandProvider>()
                                          .amount,
                                      // ignore: use_build_context_synchronously
                                      "color index": context
                                          .read<ColorIndexProvider>()
                                          .currenColortIndex,
                                      // ignore: use_build_context_synchronously
                                      "size index": context
                                          .read<SizeIndexProvider>()
                                          .currentSizeIndex,
                                      "time": Timestamp.now(),
                                      "isSelected": true,
                                    });
                                  }
                                } else {
                                  _showOverlay(context);
                                }
                              },
                              child: Container(
                                  height: manageHeight(context, 60),
                                  width: manageWidth(context, 60),
                                  decoration: BoxDecoration(
                                      color: article
                                              .colors[context
                                                  .read<ColorIndexProvider>()
                                                  .currenColortIndex]
                                              .sizes
                                              .where((element) =>
                                                  element["amount"] > 0)
                                              .isEmpty
                                          ? Colors.grey.shade200
                                          : AppColors.mainColor
                                              .withOpacity(0.8),
                                      borderRadius: BorderRadius.circular(
                                          manageHeight(context, 10))),
                                  child: const Icon(
                                    Icons.add_shopping_cart_rounded,
                                    color: Colors.white,
                                  )),
                            ),
                          ],
                        )),
              ],
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments;
    String? articleId;
    if (message != null) {
      articleId = (message as Map)["articleId"];
    }
    context.read<ColorIndexProvider>().resetIndex();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TradeHart',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: manageWidth(context, 20),
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            if (widget.articleId == null) {
              Navigator.pushAndRemoveUntil(
                  (context),
                  MaterialPageRoute(builder: (context) => MainPage()),
                  (Route<dynamic> route) => false);
            } else {
              Navigator.pop(context);
            }
          },
          child: Icon(
            CupertinoIcons.clear_thick_circled,
            color: const Color.fromARGB(255, 141, 141, 141).withOpacity(0.8),
            size: manageWidth(context, 25),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: manageWidth(context, 15)),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Cart')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('Items')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }

                  var data = snapshot.data!.docs;
                  int itemsNumber = data.length;
                  if (data.isEmpty) {
                    return const SizedBox();
                  }
                  return IconButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => CartPage()));
                    },
                    icon: Stack(
                      children: [
                        Container(
                          width: manageWidth(context, 30),
                          height: manageHeight(context, 30),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: const Color.fromARGB(255, 208, 207, 207)
                                .withOpacity(0.2),
                          ),
                          child: Icon(
                            Icons.shopping_cart_outlined,
                            size: manageWidth(context, 20),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(
                                manageWidth(context, 0.8),
                                manageHeight(context, 0.8),
                                manageWidth(context, 0.8),
                                manageHeight(context, 0.8)),
                            height: manageHeight(context, 13.5),
                            width: manageWidth(context, 13.5),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    manageHeight(context, 7.75))),
                            child: Container(
                              margin: const EdgeInsets.only(top: 0),
                              height: manageHeight(context, 12.5),
                              width: manageWidth(context, 12.5),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(
                                      manageHeight(context, 6.25))),
                              child: Center(
                                child: Text(
                                  itemsNumber.toString(),
                                  style: TextStyle(
                                      fontSize: manageWidth(context, 8),
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Articles')
            .doc(widget.articleId ?? articleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: AppColors.mainColor,
            ));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Article not found'));
          }
          var articleData = snapshot.data!.data() as Map<String, dynamic>;
          List<NetworkArticleColor> colors = [];
          for (var color in articleData['colors']) {
            colors.add(NetworkArticleColor(
                color: color['name'],
                imageUrl: color['image url'],
                amount: color['amount'],
                sizes: color['sizes']));
          }
          Article article = Article(
              id: widget.articleId ?? articleId,
              name: articleData['name'],
              price: articleData['price'] * 1.0,
              categories: articleData['category'],
              sellerId: articleData['sellerId'],
              amount: articleData['amount'],
              description: articleData['description'],
              averageRate: articleData['average rate'] * 1.0,
              totalPoints: articleData['total points'] * 1.0,
              ratesNumber: articleData['rates number'],
              date: (articleData['date'] as Timestamp).toDate(),
              status: articleData['status'],
              sellerName: articleData['seller name'],
              deliveryInformations: articleData['delivery informations'],
              images: articleData['images'],
              colors: colors);
          return SingleChildScrollView(
            child: Consumer<DetailsIndexProvider>(
              builder: (context, value, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselSlider(
                    carouselController: carouselController,
                    items: article.images
                        .map((image) => Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.shade200),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    manageHeight(context, 15)),
                                child: InstaImageViewer(
                                  imageUrl: image['image url'],
                                  child: Image.network(image['image url'],
                                      fit: BoxFit.cover, errorBuilder:
                                          (context, error, stackTrace) {
                                    return SizedBox(
                                        height: manageHeight(context, 150),
                                        width: manageWidth(context, 165),
                                        child: Column(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .exclamationmark_triangle,
                                              size: manageWidth(context, 30),
                                            ),
                                            SizedBox(
                                              height: manageHeight(context, 3),
                                            ),
                                            const Text(
                                              "Erreur lors du chargement",
                                              style:
                                                  TextStyle(color: Colors.red),
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ));
                                  }),
                                ))))
                        .toList(),
                    options: CarouselOptions(
                      onPageChanged: (index, reason) {
                        context.read<DetailsIndexProvider>().upDateIndex(index);
                      },
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      aspectRatio: 11.8 / 10,
                      viewportFraction: 0.98,
                      initialPage: context.read<DetailsIndexProvider>().index,
                      autoPlay: false,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: manageWidth(
                          context, article.images.length * 1.2 * 15),
                      margin: EdgeInsets.only(
                        top: manageHeight(context, 5),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius:
                              BorderRadius.circular(manageHeight(context, 10))),
                      child: PageViewIndicator(
                        length: article.images.length,
                        currentIndex: value.index,
                        currentSize: manageWidth(context, 8),
                        otherSize: manageWidth(context, 6),
                        margin: EdgeInsets.fromLTRB(
                            manageWidth(context, 2.5),
                            manageHeight(context, 2.5),
                            manageWidth(context, 2.5),
                            manageHeight(context, 2.5)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                      Text(article.name,
                          style: GoogleFonts.poppins(
                              fontSize: manageWidth(context, 18),
                              fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Text('\$${article.price}',
                          style: GoogleFonts.poppins(
                            fontSize: manageWidth(context, 18),
                          )),
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 7),
                      ),
                      RateStars(
                          rate: article.averageRate.round(),
                          nbRates: article.ratesNumber),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ArticleRatePage(
                                          article: article,
                                        )));
                          }
                        },
                        child: Text("voir tous les avis",
                            style: GoogleFonts.poppins(
                                fontSize: manageWidth(context, 14),
                                fontWeight: FontWeight.w500,
                                color: Colors.blueAccent)),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
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
                      SizedBox(
                        height: manageHeight(context, 20),
                        width: manageWidth(context, 200),
                        child: Text("Vendu par : ${article.sellerName}",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: manageWidth(context, 14),
                              fontWeight: FontWeight.w500,
                            )),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return SellerPage(sellerId: article.sellerId);
                            }));
                          }
                        },
                        child: Text("visiter la boutique",
                            style: GoogleFonts.poppins(
                                fontSize: manageWidth(context, 12),
                                color: Colors.blueAccent)),
                      ),
                      SizedBox(
                        width: manageWidth(context, 23.5),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                          onPressed: () {
                            LinkProviderService().shareLink(
                                article.name,
                                "Découvrez cet article sur TradHart",
                                article.id,
                                null,
                                null,
                                null,
                                '/ArticleDetailsPage',
                                article.images.first["image url"]);
                          },
                          child: const Text("Partager")),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: manageWidth(context, 15),
                        right: manageWidth(context, 10)),
                    child: Text(article.description,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 15.5),
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                  SizedBox(height: manageHeight(context, 10)),
                  Padding(
                    padding: EdgeInsets.only(left: manageWidth(context, 15)),
                    child: Text(
                        "Couleur : ${article.colors.isNotEmpty ? article.colors[context.read<ColorIndexProvider>().currenColortIndex].color : 'Unique'}",
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 14),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  SizedBox(
                    height: (article.colors.isEmpty)
                        ? 1
                        : manageHeight(context, 70),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (article.colors.isEmpty) {
                          return SizedBox(
                            height: manageHeight(context, 0.5),
                          );
                        }
                        return Consumer<ColorIndexProvider>(
                          builder: (context, value, child) {
                            return GestureDetector(
                              onTap: () {
                                //BuildContext context;
                                context
                                    .read<ColorIndexProvider>()
                                    .updateIndex(index);
                                carouselController.animateToPage(article.images
                                    .indexOf(article.images.firstWhere(
                                        (element) =>
                                            element['image url'] ==
                                            article.colors[index].imageUrl)));
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: manageWidth(context, 15)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      manageWidth(context, 10)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: index ==
                                              context
                                                  .read<ColorIndexProvider>()
                                                  .currenColortIndex
                                          ? const Color.fromARGB(
                                              77, 129, 180, 174)
                                          : Colors.grey.withOpacity(0.2),
                                      spreadRadius: manageWidth(context, 3),
                                      blurRadius: manageWidth(context, 4),
                                      offset: const Offset(1,
                                          2), // changement de position de l'ombre
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      manageHeight(context, 10)),
                                  child: Image.network(
                                      article.colors[index].imageUrl,
                                      width: manageWidth(context, 70),
                                      height: manageWidth(context, 70),
                                      fit: BoxFit.cover, errorBuilder:
                                          (context, error, stackTrace) {
                                    return SizedBox(
                                        height: manageHeight(context, 70),
                                        width: manageWidth(context, 70),
                                        child: Column(
                                          children: [
                                            Icon(
                                              CupertinoIcons
                                                  .exclamationmark_triangle,
                                              size: manageWidth(context, 20),
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ));
                                  }),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      itemCount:
                          article.colors.isEmpty ? 1 : article.colors.length,
                    ),
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: manageWidth(context, 15.0)),
                    child: Text("Taille(s)",
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 15),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  Consumer<SizeIndexProvider>(
                    builder: (context, value, child) {
                      return SizedBox(
                        height: manageHeight(context, 50),
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            if (article
                                .colors[context
                                    .read<ColorIndexProvider>()
                                    .currenColortIndex]
                                .sizes
                                .where((element) => element["amount"] > 0)
                                .toList()
                                .isEmpty) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    left: manageWidth(context, 15)),
                                child: Text("Aucune taille disponible",
                                    style: GoogleFonts.poppins(
                                      fontSize: manageWidth(context, 14),
                                      fontWeight: FontWeight.w500,
                                    )),
                              );
                            }
                            return GestureDetector(
                              onTap: () {
                                value.updateIndex(index);
                              },
                              child: ArticleSizeContainer(
                                  color: context
                                              .read<SizeIndexProvider>()
                                              .currentSizeIndex ==
                                          index
                                      ? AppColors.mainColor
                                      : Colors.grey.shade700,
                                  size: article
                                      .colors[context
                                          .read<ColorIndexProvider>()
                                          .currenColortIndex]
                                      .sizes
                                      .where((element) => element["amount"] > 0)
                                      .toList()[index]['size']),
                            );
                          },
                          itemCount: article
                                  .colors[context
                                      .read<ColorIndexProvider>()
                                      .currenColortIndex]
                                  .sizes
                                  .where((element) => element["amount"] > 0)
                                  .toList()
                                  .isEmpty
                              ? 1
                              : article
                                  .colors[context
                                      .read<ColorIndexProvider>()
                                      .currenColortIndex]
                                  .sizes
                                  .where((element) => element["amount"] > 0)
                                  .toList()
                                  .length,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: manageHeight(context, 5)),
                  Padding(
                    padding: EdgeInsets.only(left: manageWidth(context, 15)),
                    child: Text("Livraison",
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 15.5),
                          fontWeight: FontWeight.w500,
                        )),
                  ),
                  SizedBox(height: manageHeight(context, 5)),
                  Padding(
                    padding: EdgeInsets.only(left: manageWidth(context, 15)),
                    child: Text(
                        'Effectuée par ${article.deliveryInformations['delivery provider']} entre ${article.deliveryInformations['min delay']} et ${article.deliveryInformations['max delay']} jours.',
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 15),
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                  SizedBox(
                    height: manageHeight(context, 5),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: manageWidth(context, 15)),
                    child: Text(
                        'frais de livraison: ${article.deliveryInformations['delivery fees']}\$',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 14),
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                  SizedBox(
                    height: manageHeight(context, 5),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: manageWidth(context, 15)),
                    child: Text('voir la politique des frais de livraison',
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: manageWidth(context, 14),
                            color: Colors.blueAccent)),
                  ),
                  SizedBox(
                    height: manageHeight(context, 50),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          } else {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return buildBottomSheetContent(article);
                                });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.fromLTRB(
                              manageWidth(context, 8),
                              manageHeight(context, 8),
                              manageWidth(context, 8),
                              manageHeight(context, 8)),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: const Offset(0, 0),
                                  blurRadius: 5,
                                  spreadRadius: 0.4)
                            ],
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 30)),
                            color: const Color.fromARGB(255, 250, 102, 92),
                          ),
                          width: manageWidth(context, 200),
                          height: manageHeight(context, 55),
                          child: Center(
                            child: Text("Add To Cart",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: manageWidth(context, 16.5),
                                )),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                            manageWidth(context, 8),
                            manageHeight(context, 8),
                            manageWidth(context, 8),
                            manageHeight(context, 8)),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(0, 0),
                                blurRadius: manageHeight(context, 5),
                                spreadRadius: manageHeight(context, 0.4))
                          ],
                          borderRadius:
                              BorderRadius.circular(manageHeight(context, 30)),
                          color: const Color.fromARGB(255, 119, 101, 172)
                              .withOpacity(0.4),
                        ),
                        width: manageWidth(context, 80),
                        height: manageHeight(context, 55),
                        child: Icon(
                          CupertinoIcons.heart,
                          color: const Color.fromARGB(255, 255, 111, 101),
                          size: manageWidth(context, 32),
                        ),
                      ),
                      SizedBox(
                        width: manageWidth(context, 15),
                      )
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 15),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
