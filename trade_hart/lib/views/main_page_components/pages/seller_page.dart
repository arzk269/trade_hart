import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/article_view.dart';
import 'package:trade_hart/views/authentication_pages/login_page.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/home_add_to_favorite.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';

class SellerPage extends StatefulWidget {
  final String? sellerId;
  const SellerPage({super.key, this.sellerId});

  @override
  State<SellerPage> createState() => _SellerPageState();
}

class _SellerPageState extends State<SellerPage> {
  var currentUser = FirebaseAuth.instance.currentUser;
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

          const snackBar = SnackBar(
            content: Text("Article ajouté dans la Wish List"),
            backgroundColor: Colors.green,
          );

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          const snackBar = SnackBar(
            content: Text("Cette article est déjà dans votre Wish List"),
            backgroundColor: Colors.red,
          );

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (error) {
      const snackBar = SnackBar(
        content: Text(
            "Une erreur s'est produite, impossible de poursuivre cette action."),
        backgroundColor: Colors.red,
      );

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = ModalRoute.of(context)!.settings.arguments;
    String? sellerId;
    if (data != null) {
      sellerId = (data as Map)["sellerId"];
    }
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            if (widget.sellerId == null) {
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
        title:
            AppBarTitleText(title: "TradeHart", size: manageWidth(context, 17)),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Users')
              .doc(widget.sellerId ?? sellerId ?? sellerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
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
                      height: manageHeight(
                          context, MediaQuery.of(context).size.height * 0.3),
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(manageHeight(context, 15)),
                        color: const Color.fromARGB(255, 255, 241, 241)
                            .withOpacity(0.8),
                      ),
                      child: shopData["cover image"] == null
                          ? Image.asset(
                              "images/shop_main_bg.png",
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  manageHeight(context, 15)),
                              child: InstaImageViewer(
                                imageUrl: shopData["cover image"],
                                child: Image.network(shopData["cover image"],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
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
                          color: const Color.fromARGB(255, 74, 74, 74),
                          fontWeight: FontWeight.w500,
                          fontSize: manageWidth(context, 17),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          } else {
                            if (currentUser == null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            } else {
                              var ref1 = await FirebaseFirestore.instance
                                  .collection('Users')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('Boutiques suivies')
                                  .where("seller id",
                                      isEqualTo: widget.sellerId ??
                                          sellerId ??
                                          sellerId)
                                  .get();

                              if (ref1.docs.isEmpty) {
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('Boutiques suivies')
                                    .add({
                                  "seller id":
                                      widget.sellerId ?? sellerId ?? sellerId,
                                  "seller name":
                                      shopData["name"].toString().toLowerCase()
                                });
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(
                                        widget.sellerId ?? sellerId ?? sellerId)
                                    .collection('Abonnes')
                                    .add({
                                  "user id":
                                      FirebaseAuth.instance.currentUser!.uid
                                });
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          "Boutique ajoutée à celles que vous suivez!",
                                          style: TextStyle(color: Colors.white),
                                        )));
                              } else {
                                var refA = await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(widget.sellerId ?? sellerId)
                                    .collection('Abonnes')
                                    .where("user id",
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .get();

                                var id1 = refA.docs.first.id;
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(widget.sellerId ?? sellerId)
                                    .collection('Abonnes')
                                    .doc(id1)
                                    .delete();

                                var refB = await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('Boutiques suivies')
                                    .where("seller id",
                                        isEqualTo: widget.sellerId ?? sellerId)
                                    .get();

                                var id2 = refB.docs.first.id;
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('Boutiques suivies')
                                    .doc(id2)
                                    .delete();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "Boutique retirée à celles que vous suivez",
                                          style: TextStyle(color: Colors.white),
                                        )));
                              }
                            }
                          }
                        },
                        child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .collection('Boutiques suivies')
                              .where("seller id",
                                  isEqualTo: widget.sellerId ?? sellerId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: manageHeight(context, 30),
                                width: manageWidth(context, 125),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors
                                        .mainColor, // Couleur des bordures vertes
                                    width: manageWidth(
                                        context, 1.0), // Épaisseur des bordures
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      manageHeight(context, 15)),
                                ),
                              );
                            }

                            if (snapshot.data!.docs.isEmpty ||
                                !snapshot.hasData) {
                              return Container(
                                height: manageHeight(context, 30),
                                width: manageWidth(context, 125),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors
                                        .mainColor, // Couleur des bordures vertes
                                    width: manageWidth(
                                        context, 1.0), // Épaisseur des bordures
                                  ),
                                  borderRadius: BorderRadius.circular(
                                      manageHeight(context, 15)),
                                ),
                                child: Center(
                                  child: Text(
                                    "S'abonner",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      fontSize: manageWidth(context, 16),
                                      color: AppColors.mainColor,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return Container(
                              height: manageHeight(context, 30),
                              width: manageWidth(context, 125),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors
                                      .mainColor, // Couleur des bordures vertes
                                  width: manageWidth(
                                      context, 1.0), // Épaisseur des bordures
                                ),
                                borderRadius: BorderRadius.circular(
                                    manageHeight(context, 15)),
                              ),
                              child: Center(
                                child: Text(
                                  "Abonné",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: manageWidth(context, 16),
                                    color: AppColors.mainColor,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(width: manageWidth(context, 5)),
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),

                  // Row(
                  //   children: [
                  //     const SizedBox(width: 10),
                  //     Container(
                  //       padding: const EdgeInsets.only(left: 5),
                  //       height: 40,
                  //       width: 150,
                  //       decoration: BoxDecoration(
                  //           border: Border.all(
                  //             color: Colors
                  //                 .grey.shade700, // Couleur des bordures vertes
                  //             width: 1.0, // Épaisseur des bordures
                  //           ),
                  //           borderRadius: BorderRadius.circular(15)),
                  //       child: Row(
                  //         children: [
                  //           const SizedBox(
                  //             width: 5,
                  //           ),
                  //           Icon(
                  //             Icons.person,
                  //             color: Colors.grey.shade700,
                  //             size: 16,
                  //           ),
                  //           const SizedBox(
                  //             width: 5,
                  //           ),
                  //           StreamBuilder(
                  //               stream: FirebaseFirestore.instance
                  //                   .collection('Users')
                  //                   .doc(widget.sellerId??sellerId)
                  //                   .collection("Abonnes")
                  //                   .snapshots(),
                  //               builder: (context, snapshot) {
                  //                 if (snapshot.connectionState ==
                  //                     ConnectionState.waiting) {
                  //                   return Text("Abonnés: ",
                  //                       style: GoogleFonts.poppins(
                  //                         fontWeight: FontWeight.w400,
                  //                         fontSize: 15,
                  //                         color: Colors.grey.shade700,
                  //                       ));
                  //                 }

                  //                 if (snapshot.data!.docs.isEmpty ||
                  //                     !snapshot.hasData) {
                  //                   return Text("Abonnés: 0",
                  //                       style: GoogleFonts.poppins(
                  //                         fontWeight: FontWeight.w400,
                  //                         fontSize: 15,
                  //                         color: Colors.grey.shade700,
                  //                       ));
                  //                 }
                  //                 return Text(
                  //                     "Abonnés: ${snapshot.data!.docs.length}",
                  //                     style: GoogleFonts.poppins(
                  //                       fontWeight: FontWeight.w400,
                  //                       fontSize: 15,
                  //                       color: Colors.grey.shade700,
                  //                     ));
                  //               }),
                  //         ],
                  //       ),
                  //     ),
                  //     const Spacer(),
                  //     GestureDetector(
                  //       onTap: () => Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => SellerRatesPage(
                  //                   sellerId: widget.sellerId??sellerId))),
                  //       child: Text("Voir les avis de la boutique",
                  //           style: GoogleFonts.poppins(
                  //             fontWeight: FontWeight.w400,
                  //             fontSize: 12,
                  //             color: Colors.blue.shade400,
                  //           )),
                  //     ),
                  //     const SizedBox(
                  //       width: 10,
                  //     ),
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  // GestureDetector(
                  //   onTap: () async {
                  //     String currentUserId =
                  //         FirebaseAuth.instance.currentUser!.uid;
                  //     // Rechercher une conversation existante entre les deux utilisateurs
                  //     var existingConversations1 = await FirebaseFirestore
                  //         .instance
                  //         .collection('Conversations')
                  //         .where(
                  //       'users',
                  //       isEqualTo: [currentUserId, widget.sellerId??sellerId],
                  //     ).get();

                  //     var existingData1 = existingConversations1.docs;

                  //     var existingConversations2 = await FirebaseFirestore
                  //         .instance
                  //         .collection('Conversations')
                  //         .where(
                  //       'users',
                  //       isEqualTo: [widget.sellerId??sellerId, currentUserId],
                  //     ).get();

                  //     var existingData2 = existingConversations2.docs;

                  //     //Si une conversation existe, naviguer vers la page de conversation avec l'ID de la conversation
                  //     if (existingData1.isNotEmpty ||
                  //         existingData2.isNotEmpty) {
                  //       if (existingData1.isNotEmpty) {
                  //         String conversationId = existingData1[0].id;
                  //         //ignore: use_build_context_synchronously
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => ConversationPage(
                  //                     conversationId: conversationId,
                  //                     memberId: widget.sellerId??sellerId,
                  //                   )),
                  //         );
                  //       } else {
                  //         String conversationId = existingData2[0].id;
                  //         //ignore: use_build_context_synchronously
                  //         Navigator.push(
                  //           context,
                  //           MaterialPageRoute(
                  //               builder: (context) => ConversationPage(
                  //                     conversationId: conversationId,
                  //                     memberId: widget.sellerId??sellerId,
                  //                   )),
                  //         );
                  //       }
                  //     } else {
                  //       // Si aucune conversation n'existe , créer une nouvelle conversation
                  //       DocumentReference newConversationRef =
                  //           await FirebaseFirestore.instance
                  //               .collection('Conversations')
                  //               .add({
                  //         'users': [currentUserId, widget.sellerId??sellerId],
                  //         'last message': "",
                  //         'last time': Timestamp.now(),
                  //         "is all read": {"sender": true, "receiver": false}
                  //       });
                  //       String conversationId = newConversationRef.id;
                  //       //  ignore: use_build_context_synchronously
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (context) => ConversationPage(
                  //                   conversationId: conversationId,
                  //                   memberId: widget.sellerId??sellerId,
                  //                 )),
                  //       );
                  //     }
                  //   },
                  //   child: Container(
                  //     margin: const EdgeInsets.only(left: 10),
                  //     padding: const EdgeInsets.only(left: 22.5),
                  //     height: 40,
                  //     width: 240,
                  //     decoration: BoxDecoration(
                  //         border: Border.all(
                  //           color: //const Color.fromARGB(255, 255, 146,
                  //               Colors.grey
                  //                   .shade700, //146), // Couleur des bordures vertes
                  //           width: 1.0, // Épaisseur des bordures
                  //         ),
                  //         borderRadius: BorderRadius.circular(15)),
                  //     child: Row(
                  //       children: [
                  //         Text("Envoyer un messsage",
                  //             style: GoogleFonts.poppins(
                  //               fontWeight: FontWeight.w400,
                  //               fontSize: 16,
                  //               color: Colors
                  //                   .grey.shade700, //const Color.fromARGB(
                  //               //     255, 255, 146, 146),
                  //             )),
                  //         const SizedBox(
                  //           width: 5,
                  //         ),
                  //         Icon(
                  //           CupertinoIcons.chat_bubble,
                  //           color: Colors.grey
                  //               .shade700, //Color.fromARGB(255, 255, 146, 146),
                  //           size: 18,
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  // Padding(
                  //   padding: const EdgeInsets.all(10),
                  //   child: Text(shopData["shop description"],
                  //       style: GoogleFonts.poppins(
                  //         fontWeight: FontWeight.w400,
                  //         fontSize: 15,
                  //         color: Colors.grey.shade800,
                  //       )),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 10),
                  //   child: Text("Nos articles:",
                  //       style: GoogleFonts.poppins(
                  //         fontWeight: FontWeight.w500,
                  //         fontSize: 19,
                  //         color: const Color.fromARGB(255, 74, 74, 74),
                  //       )),
                  // ),
                  // Container(
                  //     height: 490,
                  //     width: 460 * 0.75,
                  //     margin: const EdgeInsets.fromLTRB(7.5, 13, 7.5, 0),
                  //     padding: const EdgeInsets.all(5),
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       border: Border.all(
                  //         color: Colors.grey,
                  //         width: 0.1,
                  //       ),
                  //       borderRadius: BorderRadius.circular(15),
                  //       boxShadow: [
                  //         BoxShadow(
                  //           color: Colors.grey.withOpacity(0.3),
                  //           spreadRadius: 1.5,
                  //           blurRadius: 5,
                  //           offset: const Offset(0, 2),
                  //         ),
                  //       ],
                  //     ),
                  //     child: /*Center(
                  //     child: Text("Aucun article",
                  //         style: GoogleFonts.poppins(
                  //           fontWeight: FontWeight.w500,
                  //           fontSize: 20,
                  //           color: const Color.fromARGB(255, 74, 74, 74),
                  //         )),
                  //   ),*/

                  //         StreamBuilder(
                  //       stream: FirebaseFirestore.instance
                  //           .collection('Articles')
                  //           .where('sellerId',
                  //               isEqualTo: widget
                  //                   .sellerId) // sellerId est l'ID du vendeur connecté
                  //           .snapshots(),
                  //       builder: (BuildContext context,
                  //           AsyncSnapshot<QuerySnapshot> snapshot) {
                  //         if (snapshot.connectionState ==
                  //             ConnectionState.waiting) {
                  //           return const Center(
                  //               child: CircularProgressIndicator(
                  //             color: AppColors.mainColor,
                  //           ));
                  //         }
                  //         if (snapshot.hasError) {
                  //           return Center(
                  //             child: Text("Une erreur s'est produite!",
                  //                 style: GoogleFonts.poppins(
                  //                   fontWeight: FontWeight.w500,
                  //                   fontSize: 20,
                  //                   color:
                  //                       const Color.fromARGB(255, 180, 44, 44),
                  //                 )),
                  //           );
                  //         }
                  //         if (!snapshot.hasData ||
                  //             snapshot.data!.docs.isEmpty) {
                  //           return Center(
                  //             child: Text("Aucun article",
                  //                 style: GoogleFonts.poppins(
                  //                   fontWeight: FontWeight.w500,
                  //                   fontSize: 20,
                  //                   color:
                  //                       const Color.fromARGB(255, 74, 74, 74),
                  //                 )),
                  //           );
                  //         }
                  //         return GridView.builder(
                  //           itemCount: snapshot.data!.docs.length,
                  //           cacheExtent: 2800,
                  //           gridDelegate:
                  //               const SliverGridDelegateWithFixedCrossAxisCount(
                  //             crossAxisCount: 2,
                  //             mainAxisSpacing: 10,
                  //             crossAxisSpacing: 10,
                  //             childAspectRatio: 0.6,

                  //             // Ratio largeur/hauteur des éléments
                  //           ),
                  //           itemBuilder: (BuildContext context, int index) {
                  //             Map<String, dynamic> articleData =
                  //                 snapshot.data!.docs[index].data()
                  //                     as Map<String, dynamic>;
                  //             List<NetworkArticleColor> colors = [];

                  //             for (var element in articleData['colors']) {
                  //               colors.add(NetworkArticleColor(
                  //                   color: element['name'],
                  //                   imageUrl: element['image url'],
                  //                   amount: element['amount'],
                  //                   sizes: element['sizes']));
                  //             }
                  //             var article = Article(
                  //                 id: snapshot.data!.docs[index].id,
                  //                 name: articleData['name'],
                  //                 price: articleData['price'],
                  //                 categories: articleData['category'],
                  //                 sellerId: articleData['sellerId'],
                  //                 amount: articleData['amount'],
                  //                 description: articleData['description'],
                  //                 averageRate:
                  //                     articleData['average rate'] * 1.0,
                  //                 totalPoints: articleData['total points'],
                  //                 ratesNumber: articleData['rates number'],
                  //                 date: (articleData['date'] as Timestamp)
                  //                     .toDate(),
                  //                 status: articleData['status'],
                  //                 sellerName: articleData['seller name'],
                  //                 deliveryInformations:
                  //                     articleData['delivery informations'],
                  //                 images: articleData['images'],
                  //                 colors: colors);

                  //             return Stack(
                  //               children: [
                  //                 GestureDetector(
                  //                     onTap: () {
                  //                       Navigator.push(context,
                  //                           MaterialPageRoute(
                  //                               builder: (context) {
                  //                         return ArticleDetailsPage(
                  //                             articleId: article.id);
                  //                       }));
                  //                     },
                  //                     child: ArticleView(article: article)),
                  //                 Padding(
                  //                   padding: const EdgeInsets.only(top: 95),
                  //                   child: StreamBuilder(
                  //                       stream: FirebaseFirestore.instance
                  //                           .collection('Users')
                  //                           .doc(FirebaseAuth
                  //                               .instance.currentUser!.uid)
                  //                           .snapshots(),
                  //                       builder: (context, snapshot) {
                  //                         if (snapshot.connectionState ==
                  //                             ConnectionState.waiting) {
                  //                           return const HomeAddToFavorite(
                  //                             color: Colors.grey,
                  //                           );
                  //                         }
                  //                         var data = snapshot.data;
                  //                         var favourites =
                  //                             (data!["wishlist"]) ?? [];
                  //                         return GestureDetector(
                  //                           child: HomeAddToFavorite(
                  //                             color: (favourites as List)
                  //                                     .contains(article.id)
                  //                                 ? const Color.fromARGB(
                  //                                     164, 253, 120, 162)
                  //                                 : Colors.blueGrey,
                  //                           ),
                  //                           onTap: () {
                  //                             addToWishlist(article.id);
                  //                           },
                  //                         );
                  //                       }),
                  //                 )
                  //               ],
                  //             );
                  //           },
                  //         );
                  //       },
                  //     )),
                  // const SizedBox(
                  //   height: 40,
                  // )

                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()));
                          } else {
                            if (currentUser == null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LoginPage()));
                            } else {
                              String currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              // Rechercher une conversation existante entre les deux utilisateurs
                              var existingConversations1 =
                                  await FirebaseFirestore.instance
                                      .collection('Conversations')
                                      .where('users', isEqualTo: [
                                currentUserId,
                                widget.sellerId ?? sellerId
                              ]).get();

                              var existingData1 = existingConversations1.docs;

                              var existingConversations2 =
                                  await FirebaseFirestore.instance
                                      .collection('Conversations')
                                      .where('users', isEqualTo: [
                                widget.sellerId ?? sellerId,
                                currentUserId
                              ]).get();

                              var existingData2 = existingConversations2.docs;

                              // Si une conversation existe, naviguer vers la page de conversation avec l'ID de la conversation
                              if (existingData1.isNotEmpty ||
                                  existingData2.isNotEmpty) {
                                if (existingData1.isNotEmpty) {
                                  String conversationId = existingData1[0].id;
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConversationPage(
                                              conversationId: conversationId,
                                              memberId:
                                                  widget.sellerId ?? sellerId,
                                            )),
                                  );
                                } else {
                                  String conversationId = existingData2[0].id;
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConversationPage(
                                              conversationId: conversationId,
                                              memberId:
                                                  widget.sellerId ?? sellerId,
                                            )),
                                  );
                                }
                              } else {
                                // Si aucune conversation n'existe, créer une nouvelle conversation
                                DocumentReference newConversationRef =
                                    await FirebaseFirestore.instance
                                        .collection('Conversations')
                                        .add({
                                  'users': [
                                    currentUserId,
                                    widget.sellerId ?? sellerId
                                  ],
                                  'last message': "",
                                  'last time': Timestamp.now(),
                                  "is all read": {
                                    "sender": true,
                                    "receiver": false
                                  }
                                });
                                String conversationId = newConversationRef.id;
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ConversationPage(
                                            conversationId: conversationId,
                                            memberId:
                                                widget.sellerId ?? sellerId,
                                          )),
                                );
                              }
                            }
                          }
                        },
                        child: Container(
                          margin:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 22.5)),
                          height: manageHeight(context, 40),
                          width: manageWidth(context, 240),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors
                                    .grey.shade700, // Couleur des bordures
                                width: 1.0, // Épaisseur des bordures
                              ),
                              borderRadius: BorderRadius.circular(15)),
                          child: Row(
                            children: [
                              Text("Envoyer un message",
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w400,
                                    fontSize: manageWidth(context, 16),
                                    color: Colors.grey.shade700,
                                  )),
                              SizedBox(
                                width: manageWidth(context, 5),
                              ),
                              Icon(
                                CupertinoIcons.chat_bubble,
                                color: Colors.grey.shade700,
                                size: manageWidth(context, 18),
                              )
                            ],
                          ),
                        ),
                      ),
                      Spacer(),
                      IconButton(
                          onPressed: () {
                            LinkProviderService().shareLink(
                                "",
                                "Venez découvirir la boutique ${shopData["name"]} sur TradeHart",
                                null,
                                null,
                                widget.sellerId ?? sellerId,
                                null,
                                '/SellerPage',
                                shopData["cover image"]);
                          },
                          icon: Icon(Icons.ios_share))
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.all(manageWidth(context, 10)),
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
                        color: const Color.fromARGB(255, 74, 74, 74),
                      ),
                    ),
                  ),
                  Container(
                    height: manageHeight(context, 490),
                    width: manageWidth(context, 345),
                    margin: EdgeInsets.fromLTRB(
                      manageWidth(context, 7.5),
                      manageHeight(context, 13),
                      manageWidth(context, 7.5),
                      0,
                    ),
                    padding: EdgeInsets.fromLTRB(
                        manageWidth(context, 5),
                        manageHeight(context, 5),
                        manageWidth(context, 5),
                        manageHeight(context, 5)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: 0.1,
                      ),
                      borderRadius:
                          BorderRadius.circular(manageHeight(context, 15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1.5,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Articles')
                          .where('sellerId',
                              isEqualTo: widget.sellerId ?? sellerId)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
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
                                color: const Color.fromARGB(255, 180, 44, 44),
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
                                color: const Color.fromARGB(255, 74, 74, 74),
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
                            mainAxisSpacing: 10,
                            crossAxisSpacing: manageWidth(context, 10),
                            childAspectRatio: 0.6,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            Map<String, dynamic> articleData =
                                snapshot.data!.docs[index].data()
                                    as Map<String, dynamic>;
                            List<NetworkArticleColor> colors = [];

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
                                    Navigator.push(context, MaterialPageRoute(
                                      builder: (context) {
                                        return ArticleDetailsPage(
                                            articleId: article.id);
                                      },
                                    ));
                                  },
                                  child: ArticleView(article: article),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      top: manageHeight(context, 95)),
                                  child: StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const HomeAddToFavorite(
                                          color: Colors.grey,
                                        );
                                      }
                                      var data = snapshot.data;
                                      var favourites =
                                          !data!.data()!.containsKey("wishlist")
                                              ? []
                                              : (data["wishlist"]) ?? [];
                                      return GestureDetector(
                                        child: HomeAddToFavorite(
                                          color: (favourites as List)
                                                  .contains(article.id)
                                              ? const Color.fromARGB(
                                                  164, 253, 120, 162)
                                              : Colors.blueGrey,
                                        ),
                                        onTap: () {
                                          addToWishlist(article.id!);
                                        },
                                      );
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
                  SizedBox(height: manageHeight(context, 40)),
                ],
              ),
            );
          }),
    );
  }
}
