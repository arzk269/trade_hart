// ignore_for_file: use_build_context_synchronously

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/amount_article_command_provider.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/color_index_provider.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/model/size_index_privider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/article_view.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_container.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/service_view.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:trade_hart/views/main_page_components/wish_list_page_components/add_to_cart_buttton.dart';

class WishArticlesFeed extends StatefulWidget {
  WishArticlesFeed({super.key});

  @override
  State<WishArticlesFeed> createState() => _WishArticlesFeedState();
}

class _WishArticlesFeedState extends State<WishArticlesFeed> {
  get carouselController => null;

  Future<void> addToWishlist(String articleID) async {
    try {
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(FirebaseAuth.instance.currentUser!.uid);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        var data = userSnapshot.data() as Map<String, dynamic>;
        List<String> wishlist = List.from(data['wishlist'] ?? []);

        // Vérifier si l'article est déjà présent dans la wishlist
        if (!wishlist.contains(articleID)) {
          // Utiliser FieldValue.arrayUnion pour ajouter l'article à la wishlist
          await userRef.update({
            'wishlist': FieldValue.arrayUnion([articleID])
          });

          var snackBar = SnackBar(
            content: Text("Article ajouté dans la Wish List"),
            backgroundColor: Colors.green,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          var snackBar = SnackBar(
            content: Text("Cette article est déjà dans votre Wish List"),
            backgroundColor: Colors.red,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (error) {
      var snackBar = SnackBar(
        content: Text(
            "Une erreur s'est produite, impossible de poursuivre cette action."),
        backgroundColor: Colors.red,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
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
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(manageWidth(context, 20)),
              child: Text(
                'Stock insufisant par rapport à la quantité demandée.',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(overlayEntry);

    Future.delayed(Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  Widget buildBottomSheetContent(Article article) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 0.8,
        sigmaY: 0.8,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(manageWidth(context, 20)),
          topRight: Radius.circular(manageWidth(context, 20)),
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
                    color: Colors.grey.shade800,
                  ),
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
                      "Couleur : ${article.colors.isNotEmpty ? article.colors[value.currenColortIndex].color : 'Unique'}",
                      style: GoogleFonts.poppins(
                        fontSize: manageWidth(context, 16),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
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
                            value.updateIndex(index);
                            carouselController.animateToPage(
                              article.images.indexOf(article.images.firstWhere(
                                  (element) =>
                                      element['image url'] ==
                                      article.colors[index].imageUrl)),
                            );
                          },
                          child: Container(
                            width: manageWidth(context, 120),
                            height: manageHeight(context, 100),
                            margin:
                                EdgeInsets.only(left: manageWidth(context, 15)),
                            decoration: BoxDecoration(
                              // image: DecorationImage(
                              //   image: NetworkImage(
                              //       article.colors[index].imageUrl),
                              //   fit: BoxFit.cover,
                              // ),
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 10)),

                              boxShadow: [
                                BoxShadow(
                                  color: index ==
                                          context
                                              .read<ColorIndexProvider>()
                                              .currenColortIndex
                                      ? Color.fromARGB(77, 129, 180, 174)
                                      : Colors.grey.withOpacity(0.2),
                                  spreadRadius: manageWidth(context, 3),
                                  blurRadius: manageWidth(context, 4),
                                  offset: Offset(manageWidth(context, 1),
                                      manageWidth(context, 2)),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 10)),
                              child: Image.network(
                                  article.colors[index].imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
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
                                          style: TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        )
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
                  itemCount: article.colors.isEmpty ? 1 : article.colors.length,
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
                      ),
                    ),
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
                            .toList()
                            .isEmpty) {
                          return Padding(
                            padding:
                                EdgeInsets.only(left: manageWidth(context, 15)),
                            child: Text(
                              "Taille non renseignée",
                              style: GoogleFonts.poppins(
                                fontSize: manageWidth(context, 14),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
                              while (
                                  context
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
                                .toList()[index]['size'],
                          ),
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
              SizedBox(
                height: manageHeight(context, 10),
              ),
              Row(
                children: [
                  SizedBox(
                    width: manageWidth(context, 15),
                  ),
                  Text(
                    "Vendu par :",
                    style: GoogleFonts.poppins(
                      fontSize: manageWidth(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SellerPage(sellerId: article.sellerId),
                      ),
                    ),
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
                    Text(
                      "Quantité :",
                      style: GoogleFonts.poppins(
                        fontSize: manageWidth(context, 17),
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(
                      width: manageWidth(context, 5),
                    ),
                    IconButton(
                      onPressed: () {
                        value.reduce();
                      },
                      icon: Icon(CupertinoIcons.minus_circle),
                    ),
                    Text(
                      value.amount.toString(),
                      style: TextStyle(fontSize: manageWidth(context, 16)),
                    ),
                    IconButton(
                      onPressed: () {
                        if (article
                                    .colors[context
                                        .read<ColorIndexProvider>()
                                        .currenColortIndex]
                                    .sizes
                                    .where((element) => element["amount"] > 0)
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
                      icon: Icon(CupertinoIcons.add_circled),
                    ),
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
                          DocumentReference userCartRef = FirebaseFirestore
                              .instance
                              .collection('Cart')
                              .doc(userId);
                          var items =
                              await userCartRef.collection('Items').get();
                          var itemDocs = items.docs;
                          var itemDoc = itemDocs.where((element) =>
                              element["article id"] == article.id &&
                              element["seller id"] == article.sellerId &&
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
                                        .read<AmountArticleCommandProvider>()
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
                                        .read<AmountArticleCommandProvider>()
                                        .amount,
                              });
                            }
                          } else {
                            await userCartRef.collection('Items').add({
                              "article id": article.id,
                              "seller id": article.sellerId,
                              "amount": context
                                  .read<AmountArticleCommandProvider>()
                                  .amount,
                              "color index": context
                                  .read<ColorIndexProvider>()
                                  .currenColortIndex,
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
                        height: manageWidth(context, 60),
                        width: manageWidth(context, 60),
                        decoration: BoxDecoration(
                          color: AppColors.mainColor.withOpacity(0.8),
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 10)),
                        ),
                        child: Icon(
                          Icons.add_shopping_cart_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Articles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }
                var userData = snapshot2.data!.data();
                List wishlist = userData!["wishlist"] ?? [];
                var data = snapshot.data!.docs
                    .where((element) => wishlist.contains(element.id))
                    .toList();
                return GridView.builder(
                  cacheExtent: 2800,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: manageWidth(context, 10),
                    childAspectRatio: 0.6,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var articleData = data[index].data();

                    List<NetworkArticleColor> colors = [];

                    for (var element in articleData['colors']) {
                      colors.add(NetworkArticleColor(
                          color: element['name'],
                          imageUrl: element['image url'],
                          amount: element['amount'],
                          sizes: element['sizes']));
                    }
                    var article = Article(
                        id: data[index].id,
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
                        deliveryInformations:
                            articleData['delivery informations'],
                        images: articleData['images'],
                        colors: colors);

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ArticleDetailsPage(articleId: article.id);
                            }));
                          },
                          child: ArticleView(article: article),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: manageHeight(context, 95),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return buildBottomSheetContent(article);
                                },
                              );
                            },
                            child: AddToCartButton(),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            top: manageHeight(context, 2),
                            left: manageWidth(context, 2),
                          ),
                          child: GestureDetector(
                            child: Icon(
                              CupertinoIcons.minus_circle_fill,
                              color: Colors.grey.shade400,
                            ),
                            onTap: () {
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                'wishlist': FieldValue.arrayRemove([article.id])
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              });
        });
  }
}

class WishServicesFeed extends StatefulWidget {
  WishServicesFeed({super.key});

  @override
  State<WishServicesFeed> createState() => _ServicesFeedState();
}

class _ServicesFeedState extends State<WishServicesFeed> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Services').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox();
          }
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return SizedBox();
                }
                var userData = snapshot2.data!.data();
                List wishlist = userData!["wishlist"] ?? [];
                var data = snapshot.data!.docs
                    .where((element) => wishlist.contains(element.id))
                    .toList();

                return GridView.builder(
                  cacheExtent: 2800,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: manageWidth(context, 10),
                    childAspectRatio: 0.6,
                  ),
                  itemCount: snapshot.data!.docs
                      .where((element) => wishlist.contains(element.id))
                      .length,
                  itemBuilder: (context, index) {
                    var serviceData = data[index].data();

                    var service = Service(
                        location: serviceData['location'],
                        id: data[index].id,
                        name: serviceData['name'],
                        price: serviceData['price'] * 1.0,
                        categories: serviceData['categories'],
                        sellerId: serviceData['sellerId'],
                        duration: serviceData['duration'],
                        description: serviceData['description'],
                        averageRate: serviceData['average rate'] * 1.0,
                        date: (serviceData['date'] as Timestamp).toDate(),
                        images: serviceData['images'],
                        ratesNumber: serviceData['rates number'],
                        sellerName: serviceData['seller name'],
                        status: serviceData['status'],
                        totalPoints: serviceData['total points'] * 1.0,
                        creneauReservationStatus:
                            serviceData["creneau reservation status"],
                        crenaux: serviceData["crenaux"]);

                    return Stack(
                      children: [
                        GestureDetector(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ServiceDetailPage(serviceId: service.id);
                              }));
                            },
                            child: ServiceView(
                              service: service,
                            )),
                        Padding(
                          padding: EdgeInsets.only(
                              top: manageHeight(context, 2),
                              left: manageWidth(context, 2)),
                          child: GestureDetector(
                            child: Icon(
                              CupertinoIcons.minus_circle_fill,
                              color: Colors.grey.shade400,
                            ),
                            onTap: () {
                              FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .update({
                                'wishlist': FieldValue.arrayRemove([service.id])
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              });
        });
  }
}

List<Widget> wishfeed = [WishArticlesFeed(), WishServicesFeed()];
