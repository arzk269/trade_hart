// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/model/color_index_provider.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/article_view.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/main_page_components/pages/article_adding_page.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
//import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/article_editing.dart';
import 'package:trade_hart/views/main_page_components/pages/article_stats_page.dart';
import 'package:trade_hart/views/main_page_components/pages/followers_page.dart';
import 'package:trade_hart/views/main_page_components/pages/shop_updating_page.dart';

class ShopPageSeller extends StatefulWidget {
  const ShopPageSeller({super.key});

  @override
  State<ShopPageSeller> createState() => _ShopPageSellerState();
}

class _ShopPageSellerState extends State<ShopPageSeller> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var sellerId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        leading: MainBackButton(),
        title: AppBarTitleText(
            title: "Ma boutique TradHart", size: manageWidth(context, 17)),
      ),
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
            var shopData = data["shop"] as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.98,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(manageWidth(context, 15)),
                        color:
                            Color.fromARGB(255, 255, 241, 241).withOpacity(0.8),
                      ),
                      child: shopData["cover image"] == null
                          ? Image.asset(
                              "images/shop_main_bg.png",
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 15)),
                              child: InstaImageViewer(
                                imageUrl: shopData["cover image"],
                                child: Image.network(shopData["cover image"],
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
                    ),
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  Row(
                    children: [
                      SizedBox(width: manageWidth(context, 10)),
                      Text(
                        shopData["name"],
                        style: GoogleFonts.poppins(
                          color: Color.fromARGB(255, 74, 74, 74),
                          fontWeight: FontWeight.w500,
                          fontSize: manageWidth(context, 17),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (kIsWeb) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "Vous devez télécharger l'application mobile",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ));
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ShopUpdatingPage();
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
                              color: AppColors.mainColor,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 15)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Edit",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: manageWidth(context, 16),
                                  color: AppColors.mainColor,
                                ),
                              ),
                              SizedBox(
                                width: manageWidth(context, 5),
                              ),
                              Icon(
                                Icons.edit,
                                color: AppColors.mainColor,
                                size: manageWidth(context, 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: manageWidth(context, 10)),
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  Row(
                    children: [
                      SizedBox(width: manageWidth(context, 10)),
                      Container(
                        padding: EdgeInsets.only(left: manageWidth(context, 5)),
                        height: manageHeight(context, 40),
                        width: manageWidth(context, 150),
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
                              Icons.person,
                              color: Colors.grey.shade700,
                              size: manageWidth(context, 16),
                            ),
                            SizedBox(
                              width: manageWidth(context, 5),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return FollowersPage();
                                }));
                              },
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection("Abonnes")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Text(
                                      "Abonnés: ",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: manageWidth(context, 15),
                                        color: Colors.grey.shade700,
                                      ),
                                    );
                                  }
                                  if (snapshot.data!.docs.isEmpty ||
                                      !snapshot.hasData) {
                                    return Text(
                                      "Abonnés: 0",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w400,
                                        fontSize: manageWidth(context, 15),
                                        color: Colors.grey.shade700,
                                      ),
                                    );
                                  }
                                  return Text(
                                    "Abonnés: ${snapshot.data!.docs.length}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: manageWidth(context, 15),
                                      color: Colors.grey.shade700,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      Text(
                        "Voir les avis de la boutique",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w400,
                          fontSize: manageWidth(context, 12),
                          color: Colors.blue.shade400,
                        ),
                      ),
                      SizedBox(
                        width: manageWidth(context, 10),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (kIsWeb) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                "Vous devez télécharger l'application mobile",
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ));
                          } else {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return AddArticlePage();
                            }));
                          }
                        },
                        child: Container(
                          margin:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 22.5)),
                          height: manageHeight(context, 40),
                          width: manageWidth(context, 200),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Color.fromARGB(255, 255, 146, 146),
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 15)),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Ajouter un article",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: manageWidth(context, 16),
                                  color: Color.fromARGB(255, 255, 146, 146),
                                ),
                              ),
                              SizedBox(
                                width: manageWidth(context, 5),
                              ),
                              Icon(
                                Icons.add,
                                color: Color.fromARGB(255, 255, 146, 146),
                                size: manageWidth(context, 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () {
                            LinkProviderService().shareLink(
                                "",
                                "Venez découvrir la boutique ${shopData["name"]} sur TradeHart",
                                null,
                                null,
                                sellerId,
                                null,
                                '/SellerPage',
                                shopData['cover image']);
                          },
                          icon: Icon(
                            Icons.ios_share,
                            size: manageWidth(context, 18),
                          ))
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      manageWidth(context, 10),
                      manageHeight(context, 10),
                      manageWidth(context, 10),
                      manageHeight(context, 10),
                    ),
                    child: Text(
                      shopData["shop description"],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: manageWidth(context, 15),
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: manageWidth(context, 10)),
                    child: Text(
                      "Nos articles:",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: manageWidth(context, 19),
                        color: Color.fromARGB(255, 74, 74, 74),
                      ),
                    ),
                  ),
                  Container(
                    height: manageHeight(context, 490),
                    width: manageWidth(context, 460 * 0.75),
                    margin: EdgeInsets.fromLTRB(
                      manageWidth(context, 7.5),
                      manageHeight(context, 13),
                      manageWidth(context, 7.5),
                      manageHeight(context, 0),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      manageWidth(context, 8),
                      manageHeight(context, 8),
                      manageWidth(context, 8),
                      manageHeight(context, 8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.1,
                      ),
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: manageWidth(context, 1.5),
                          blurRadius: manageWidth(context, 5),
                          offset: Offset(0, manageHeight(context, 2)),
                        ),
                      ],
                    ),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Articles')
                          .where('sellerId',
                              isEqualTo:
                                  sellerId) // sellerId est l'ID du vendeur connecté
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: AppColors.mainColor,
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Une erreur s'est produite!",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: manageWidth(context, 20),
                                color: Color.fromARGB(255, 180, 44, 44),
                              ),
                            ),
                          );
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                            child: Text(
                              "Aucun article",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: manageWidth(context, 20),
                                color: Color.fromARGB(255, 74, 74, 74),
                              ),
                            ),
                          );
                        }
                        return GridView.builder(
                          itemCount: snapshot.data!.docs.length,
                          cacheExtent: 2800,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: manageHeight(context, 10),
                            crossAxisSpacing: manageWidth(context, 10),
                            childAspectRatio:
                                0.6, // Ratio largeur/hauteur des éléments
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            List<NetworkArticleColor> colors = [];

                            Map<String, dynamic> articleData =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            for (var element in articleData['colors']) {
                              colors.add(NetworkArticleColor(
                                color: element['name'],
                                imageUrl: element['image url'],
                                amount: element['amount'],
                                sizes: element['sizes'],
                              ));
                            }
                            var article = Article(
                              id: snapshot.data!.docs[index].id,
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
                              colors: colors,
                            );

                            return Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    context
                                        .read<ColorIndexProvider>()
                                        .resetIndex();
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return ArticleDetailsPage(
                                          articleId: article.id);
                                    }));
                                  },
                                  child: ArticleView(article: article),
                                ),
                                PopupMenuButton(
                                  icon: Container(
                                    margin: EdgeInsets.only(
                                      right: manageWidth(context, 18),
                                      bottom: manageHeight(context, 15),
                                    ),
                                    height: manageWidth(context, 22),
                                    width: manageWidth(context, 22),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 218, 215, 215)
                                          .withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(
                                          manageWidth(context, 20)),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        CupertinoIcons.ellipsis,
                                        size: manageWidth(context, 16),
                                      ),
                                    ),
                                  ),
                                  itemBuilder: (context) {
                                    return {
                                      'modifier',
                                      'supprimer',
                                      'partager',
                                      'résultats'
                                    }.map((String choice) {
                                      return PopupMenuItem(
                                        value: choice,
                                        child: Text(
                                          choice,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: manageWidth(context, 15),
                                            color:
                                                Color.fromARGB(255, 74, 74, 74),
                                          ),
                                        ),
                                      );
                                    }).toList();
                                  },
                                  onSelected: (value) {
                                    if (value == 'résultats') {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ArticleStatsPage(
                                                      articleId: article.id!)));
                                    }
                                    if (value == 'supprimer') {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Confirmation'),
                                            content: Text(
                                              'Êtes-vous sûr de vouloir supprimer cet élément ?',
                                              style: TextStyle(
                                                  fontSize:
                                                      manageWidth(context, 15)),
                                            ),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('Non'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: Text('Oui'),
                                                onPressed: () async {
                                                  var imagesNames = article
                                                      .images
                                                      .map((image) =>
                                                          image['image name'])
                                                      .toList();
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Articles')
                                                      .doc(article.id)
                                                      .delete()
                                                      .then((value) {
                                                    for (var image
                                                        in imagesNames) {
                                                      FirebaseStorage.instance
                                                          .ref()
                                                          .child(
                                                              'articles_images_urls/$image')
                                                          .delete();
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }

                                    if (value == 'modifier') {
                                      if (kIsWeb) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(
                                            "Vous devez télécharger l'application mobile",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          backgroundColor: Colors.red,
                                        ));
                                      } else {
                                        context
                                            .read<CategoriesProvider>()
                                            .articleCategoriesclear();
                                        setState(() {});
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return EditArticlePage(
                                              article: article);
                                        }));
                                      }
                                    }

                                    if (value == 'partager') {
                                      LinkProviderService().shareLink(
                                          article.name,
                                          "Découvrez cet article dans ma boutique TradHart",
                                          article.id,
                                          null,
                                          null,
                                          null,
                                          '/ArticleDetailsPage',
                                          article.images.first['image url']);
                                    }
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    left: manageWidth(context, 130),
                                    top: manageHeight(context, 160),
                                  ),
                                  child: PopupMenuButton(
                                    icon: Container(
                                      margin: EdgeInsets.only(
                                        right: manageWidth(context, 18),
                                        bottom: manageHeight(context, 15),
                                      ),
                                      height: manageWidth(context, 22),
                                      width: manageWidth(context, 22),
                                      decoration: BoxDecoration(
                                        color: !article.colors.any((element) =>
                                                element.sizes.any((element) =>
                                                    element['amount'] <= 5))
                                            ? Colors.transparent
                                            : Color.fromARGB(255, 218, 215, 215)
                                                .withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(
                                            manageWidth(context, 20)),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          CupertinoIcons.graph_circle,
                                          color: article.colors.any((element) =>
                                                  element.sizes.any((element) =>
                                                      element['amount'] <= 5))
                                              ? Colors.red
                                              : Colors.transparent,
                                          size: manageWidth(context, 16),
                                        ),
                                      ),
                                    ),
                                    itemBuilder: (context) {
                                      if (!article.colors.any((element) =>
                                          element.sizes.any((element) =>
                                              element['amount'] <= 5))) {
                                        return [];
                                      }
                                      return {'stock à revisiter'}
                                          .map((String choice) {
                                        return PopupMenuItem(
                                          value: choice,
                                          child: Text(
                                            choice,
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize:
                                                  manageWidth(context, 15),
                                              color: Colors.red,
                                            ),
                                          ),
                                        );
                                      }).toList();
                                    },
                                    onSelected: (value) {
                                      if (article.colors.any((element) =>
                                          element.sizes.any((element) =>
                                              element['amount'] <= 5))) {
                                        context
                                            .read<CategoriesProvider>()
                                            .articleCategoriesclear();
                                        setState(() {});
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return EditArticlePage(
                                              article: article);
                                        }));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: manageHeight(context, 40),
                  )
                ],
              ),
            );
          }),
    );
  }
}
