import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_container.dart';
import 'package:trade_hart/views/main_page_components/cart_page_components/cart_price_view.dart';
import 'package:trade_hart/views/main_page_components/cart_page_components/cart_product_image_view.dart';
import 'package:trade_hart/views/main_page_components/cart_page_components/cart_product_name_view.dart';
import 'package:trade_hart/views/main_page_components/cart_page_components/cart_seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';

class CartProductView extends StatefulWidget {
  final String itemId;

  const CartProductView({super.key, required this.itemId});

  @override
  State<CartProductView> createState() => _CartProductViewState();
}

class _CartProductViewState extends State<CartProductView> {
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

  buildBottomSheetContent() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Cart')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Items')
            .doc(widget.itemId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: manageHeight(context, 580),
            );
          }

          if (!snapshot.data!.exists) {
            return SizedBox(
              height: manageHeight(context, 580),
            );
          }
          var data = snapshot.data!.data();

          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Articles')
                  .doc(data!['article id'])
                  .snapshots(),
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: manageHeight(context, 580),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                var articleData =
                    snapshot2.data!.data() as Map<String, dynamic>;
                List<NetworkArticleColor> colors = [];
                for (var color in articleData['colors']) {
                  colors.add(NetworkArticleColor(
                      color: color['name'],
                      imageUrl: color['image url'],
                      amount: color['amount'],
                      sizes: color['sizes']));
                }
                Article article = Article(
                    id: snapshot2.data!.id,
                    name: articleData['name'],
                    price: articleData['price']*1.0,
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
                return BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 0.8,
                      sigmaY: 0.8), // Ajustez le flou selon vos préférences
                  child: ClipRRect(
                    // Couleur de fond avec opacité réduite
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
                          SizedBox(height: manageHeight(context, 5)),
                          Center(
                            child: Container(
                              height: manageHeight(context, 3),
                              width: manageWidth(context, 45),
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(height: manageHeight(context, 15)),
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
                              SizedBox(width: manageWidth(context, 15)),
                              Text(
                                "Couleur : ${article.colors.isNotEmpty ? article.colors[data['color index']].color : 'Unique'}",
                                style: GoogleFonts.poppins(
                                  fontSize: manageWidth(context, 16),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: manageHeight(context, 10)),
                          SizedBox(
                            height: article.colors.isEmpty
                                ? manageHeight(context, 1)
                                : manageHeight(context, 100),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                if (article.colors.isEmpty) {
                                  return SizedBox(
                                      height: manageHeight(context, 0.5));
                                }
                                return GestureDetector(
                                  onTap: () {
                                    FirebaseFirestore.instance
                                        .collection('Cart')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('Items')
                                        .doc(widget.itemId)
                                        .update({'color index': index});
                                  },
                                  child: Container(
                                    width: manageWidth(context, 120),
                                    height: manageHeight(context, 100),
                                    margin: EdgeInsets.only(
                                        left: manageWidth(context, 15)),
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                            article.colors[index].imageUrl),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: index == data['color index']
                                              ? const Color.fromARGB(
                                                  77, 129, 180, 174)
                                              : Colors.grey.withOpacity(0.2),
                                          spreadRadius: 3,
                                          blurRadius: 4,
                                          offset: const Offset(1,
                                              2), // changement de position de l'ombre
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              itemCount: article.colors.isEmpty
                                  ? 1
                                  : article.colors.length,
                            ),
                          ),
                          SizedBox(height: manageHeight(context, 10)),
                          Row(
                            children: [
                              SizedBox(width: manageWidth(context, 15)),
                              Text(
                                "Taille : ${article.colors[data['color index']].sizes[data['size index']]['size']}",
                                style: GoogleFonts.poppins(
                                  fontSize: manageWidth(context, 15),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: manageHeight(context, 50),
                            child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                if (article.colors[data['color index']].sizes
                                    .isEmpty) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        left: manageWidth(context, 15)),
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
                                    if (data['amount'] >
                                        article.colors[data['color index']]
                                            .sizes[index]['amount']) {
                                      FirebaseFirestore.instance
                                          .collection('Cart')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('Items')
                                          .doc(widget.itemId)
                                          .update({
                                        'size index': index,
                                        'amount': article
                                                .colors[data['color index']]
                                                .sizes[index]['amount'] -
                                            1
                                      });
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('Cart')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('Items')
                                          .doc(widget.itemId)
                                          .update({'size index': index});
                                    }
                                  },
                                  child: ArticleSizeContainer(
                                    color: index == data['size index']
                                        ? AppColors.mainColor
                                        : Colors.grey.shade700,
                                    size: article.colors[data['color index']]
                                        .sizes[index]['size'],
                                  ),
                                );
                              },
                              itemCount: article
                                      .colors[data['color index']].sizes.isEmpty
                                  ? 1
                                  : article
                                      .colors[data['color index']].sizes.length,
                            ),
                          ),
                          SizedBox(height: manageHeight(context, 10)),
                          Row(
                            children: [
                              SizedBox(width: manageWidth(context, 15)),
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
                          SizedBox(height: manageHeight(context, 10)),
                          Row(
                            children: [
                              SizedBox(width: manageWidth(context, 15)),
                              Text(
                                "Quantité :",
                                style: GoogleFonts.poppins(
                                  fontSize: manageWidth(context, 17),
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              SizedBox(width: manageWidth(context, 5)),
                              IconButton(
                                onPressed: () {
                                  if (data['amount'] == 1) {
                                    Navigator.pop(context);
                                    FirebaseFirestore.instance
                                        .collection('Cart')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('Items')
                                        .doc(widget.itemId)
                                        .delete();
                                  } else {
                                    FirebaseFirestore.instance
                                        .collection('Cart')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('Items')
                                        .doc(widget.itemId)
                                        .update({
                                      'amount': FieldValue.increment(-1)
                                    });
                                  }
                                },
                                icon: const Icon(CupertinoIcons.minus_circle),
                              ),
                              Text(
                                data['amount'].toString(),
                                style: TextStyle(
                                    fontSize: manageWidth(context, 16)),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (data['amount'] <
                                      article.colors[data['color index']]
                                              .sizes[data['size index']]
                                          ['amount']) {
                                    FirebaseFirestore.instance
                                        .collection('Cart')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .collection('Items')
                                        .doc(widget.itemId)
                                        .update({
                                      'amount': FieldValue.increment(1)
                                    });
                                  } else {
                                    _showOverlay(context);
                                  }
                                },
                                icon: const Icon(CupertinoIcons.add_circled),
                              ),
                              SizedBox(width: manageWidth(context, 35)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Cart')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Items')
            .doc(widget.itemId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: manageWidth(context, 17),
                    ),
                    Container(
                      width: manageWidth(context, 80),
                      height: manageHeight(context, 80),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    SizedBox(
                      width: manageWidth(context, 40),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: manageHeight(context, 7),
                        ),
                        Container(
                          width: manageWidth(context, 105),
                          margin:
                              EdgeInsets.only(left: manageWidth(context, 15)),
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 22.5)),
                          height: manageHeight(context, 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        SizedBox(
                          height: manageHeight(context, 7),
                        ),
                        Container(
                          width: manageWidth(context, 105),
                          margin:
                              EdgeInsets.only(left: manageWidth(context, 15)),
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 22.5)),
                          height: manageHeight(context, 15),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: manageHeight(context, 10),
                ),
                Row(
                  children: [
                    Container(
                      width: manageWidth(context, 105),
                      margin: EdgeInsets.only(left: manageWidth(context, 15)),
                      padding:
                          EdgeInsets.only(left: manageWidth(context, 22.5)),
                      height: manageHeight(context, 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      width: manageWidth(context, 105),
                      margin: EdgeInsets.only(left: manageWidth(context, 15)),
                      padding:
                          EdgeInsets.only(left: manageWidth(context, 22.5)),
                      height: manageHeight(context, 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
                Divider(
                  indent: manageWidth(context, 15),
                  endIndent: manageWidth(context, 15),
                ),
                SizedBox(
                  height: manageHeight(context, 25),
                ),
              ],
            );
          }

          if (!snapshot.data!.exists) {
            return const SizedBox(
              height: 0.05,
            );
          }

          var data = snapshot.data!.data();
          return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Articles')
                  .doc(data!['article id'])
                  .snapshots(),
              builder: (context, snapshot2) {
                if (snapshot2.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: manageWidth(context, 17),
                          ),
                          Container(
                            width: manageWidth(context, 80),
                            height: manageHeight(context, 80),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          SizedBox(
                            width: manageWidth(context, 40),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: manageHeight(context, 7),
                              ),
                              Container(
                                width: manageWidth(context, 105),
                                margin: EdgeInsets.only(
                                    left: manageWidth(context, 15)),
                                padding: EdgeInsets.only(
                                    left: manageWidth(context, 22.5)),
                                height: manageHeight(context, 15),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              SizedBox(
                                height: manageHeight(context, 7),
                              ),
                              Container(
                                width: manageWidth(context, 105),
                                margin: EdgeInsets.only(
                                    left: manageWidth(context, 15)),
                                padding: EdgeInsets.only(
                                    left: manageWidth(context, 22.5)),
                                height: manageHeight(context, 15),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: manageHeight(context, 10),
                      ),
                      Row(
                        children: [
                          Container(
                            width: manageWidth(context, 105),
                            margin:
                                EdgeInsets.only(left: manageWidth(context, 15)),
                            padding: EdgeInsets.only(
                                left: manageWidth(context, 22.5)),
                            height: manageHeight(context, 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          Container(
                            width: manageWidth(context, 105),
                            margin:
                                EdgeInsets.only(left: manageWidth(context, 15)),
                            padding: EdgeInsets.only(
                                left: manageWidth(context, 22.5)),
                            height: manageHeight(context, 10),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ],
                      ),
                      Divider(
                        indent: manageWidth(context, 15),
                        endIndent: manageWidth(context, 15),
                      ),
                      SizedBox(
                        height: manageHeight(context, 25),
                      ),
                    ],
                  );
                }
                if (snapshot2.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot2.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Article not found'));
                }
                var articleData =
                    snapshot2.data!.data() as Map<String, dynamic>;
                List<NetworkArticleColor> colors = [];
                for (var color in articleData['colors']) {
                  colors.add(NetworkArticleColor(
                      color: color['name'],
                      imageUrl: color['image url'],
                      amount: color['amount'],
                      sizes: color['sizes']));
                }
                Article article = Article(
                    id: data['article id'],
                    name: articleData['name'],
                    price: articleData['price']*1.0,
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
                return Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: manageWidth(context, 17),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ArticleDetailsPage(
                                    articleId: data['article id'],
                                  );
                                },
                              ),
                            );
                          },
                          child: CartProductImageView(
                            imagePath:
                                article.colors[data['color index']].imageUrl,
                          ),
                        ),
                        SizedBox(
                          width: manageWidth(context, 40),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CartProductNameView(name: article.name),
                            SizedBox(
                              height: manageHeight(context, 7),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SellerPage(
                                    sellerId: data['seller id'],
                                  ),
                                ),
                              ),
                              child:
                                  CartSellerNameView(name: article.sellerName),
                            ),
                            SizedBox(
                              height: manageHeight(context, 7),
                            ),
                            CartPriceView(price: article.price),
                          ],
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
                        Text(
                          "Quantité :",
                          style: GoogleFonts.poppins(
                            fontSize: manageWidth(context, 16),
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (data['amount'] == 1) {
                              FirebaseFirestore.instance
                                  .collection('Cart')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('Items')
                                  .doc(widget.itemId)
                                  .delete();
                            } else {
                              FirebaseFirestore.instance
                                  .collection('Cart')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('Items')
                                  .doc(widget.itemId)
                                  .update({'amount': FieldValue.increment(-1)});
                            }
                          },
                          icon: const Icon(CupertinoIcons.minus_circle),
                        ),
                        Text(
                          data['amount'].toString(),
                          style:
                              TextStyle(fontSize: manageWidth(context, 16.5)),
                        ),
                        IconButton(
                          onPressed: () {
                            if (data['amount'] <
                                article.colors[data['color index']]
                                    .sizes[data['size index']]['amount']) {
                              FirebaseFirestore.instance
                                  .collection('Cart')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('Items')
                                  .doc(widget.itemId)
                                  .update({'amount': FieldValue.increment(1)});
                            } else {
                              const snackBar = SnackBar(
                                backgroundColor: Colors.red,
                                content: Text(
                                  "Stock insuffisant pour la quantité demandée.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              );

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          },
                          icon: const Icon(CupertinoIcons.add_circled),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return buildBottomSheetContent();
                              },
                            );
                          },
                          child: Container(
                            width: manageWidth(context, 108),
                            margin:
                                EdgeInsets.only(left: manageWidth(context, 15)),
                            padding: EdgeInsets.only(
                                left: manageWidth(context, 22.5)),
                            height: manageHeight(context, 25),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade800,
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "${article.colors[data['color index']].color},",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: manageWidth(context, 12),
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                Text(
                                  " ${article.colors[data['color index']].sizes[data['size index']]['size']}",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: manageWidth(context, 12),
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                                SizedBox(
                                  width: manageWidth(context, 5),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.shade800,
                                  size: manageWidth(context, 16),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    Divider(
                      indent: manageWidth(context, 15),
                      endIndent: manageWidth(context, 15),
                    ),
                    SizedBox(
                      height: manageHeight(context, 25),
                    )
                  ],
                );
              });
        });
  }
}
