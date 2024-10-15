import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/home_add_to_favorite.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/service_view.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_rate_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';

class ServiceProviderPage extends StatefulWidget {
  final String? id;
  const ServiceProviderPage({super.key, this.id});

  @override
  State<ServiceProviderPage> createState() => _ServiceProviderPageState();
}

class _ServiceProviderPageState extends State<ServiceProviderPage> {
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

          var snackBar = const SnackBar(
            content: Text("Service ajouté dans la Wish List"),
            backgroundColor: Colors.green,
          );

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          var snackBar = const SnackBar(
            content: Text("Cette service est déjà dans votre Wish List"),
            backgroundColor: Colors.red,
          );

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }
    } catch (error) {
      var snackBar = const SnackBar(
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
    String? providerId;
    if (data != null) {
      providerId = (data as Map)["providerId"];
    }
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
          size: manageWidth(context, 18),
          title: "Mes services TradHart",
        ),
        leading: GestureDetector(
          onTap: () {
            if (widget.id == null) {
              Navigator.pushAndRemoveUntil(
                  (context),
                  MaterialPageRoute(builder: (context) => const MainPage()),
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
      ),
      body: SingleChildScrollView(
          child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.id ?? providerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!(snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.hasError)) {
                  var data = snapshot.data!.data() as Map<String, dynamic>;
                  var images = data["images"] as Map<String, dynamic>?;
                  var service = data["service"] as Map<String, dynamic>?;

                  if (service != null && images != null) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: manageHeight(
                                      context,
                                      MediaQuery.sizeOf(context).height *
                                          (1 / 3.75)),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        manageWidth(context, 10)),
                                    color: Colors.white,
                                    // image: DecorationImage(
                                    //   image: images["cover image"] == null
                                    //       ? AssetImage(
                                    //               "images/service_provider_cover.png")
                                    //           as ImageProvider
                                    //       : NetworkImage(images["cover image"]),
                                    //   fit: BoxFit.cover,
                                    // ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        manageWidth(context, 10)),
                                    child: InstaImageViewer(
                                      imageUrl: images["cover image"],
                                      child: Image.network(
                                          images["cover image"],
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
                                                  size:
                                                      manageWidth(context, 30),
                                                ),
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 3),
                                                ),
                                                const Text(
                                                  "Erreur lors du chargement",
                                                  style: TextStyle(
                                                      color: Colors.red),
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
                                Container(
                                  width: manageWidth(context, 103 * 0.72),
                                  height: manageHeight(context, 103 * 0.72),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        manageWidth(context, 103 * 0.72 * 0.5)),
                                    color: Colors.white,
                                  ),
                                  margin: EdgeInsets.only(
                                    top: manageHeight(context, 165),
                                    left: manageWidth(context, 12),
                                  ),
                                  child: Center(
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey.shade100,
                                      radius: manageWidth(context, 50 * 0.7),
                                      child: Container(
                                        height: manageWidth(context, 100 * 0.7),
                                        width: manageWidth(context, 100 * 0.7),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              manageWidth(context, 50 * 0.7)),
                                          // image: DecorationImage(
                                          //   image: images["profil image"] ==
                                          //           null
                                          //       ? AssetImage(
                                          //               "images/service_provider_cover.png")
                                          //           as ImageProvider
                                          //       : NetworkImage(
                                          //           images["profil image"]),
                                          //   fit: BoxFit.cover,
                                          // ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              manageWidth(context, 50 * 0.7)),
                                          child: InstaImageViewer(
                                            imageUrl: images["profil image"],
                                            child: Image.network(
                                                images["profil image"],
                                                fit: BoxFit.cover, errorBuilder:
                                                    (context, error,
                                                        stackTrace) {
                                              return SizedBox(
                                                  height: manageHeight(
                                                      context, 150),
                                                  width:
                                                      manageWidth(context, 165),
                                                  child: Column(
                                                    children: [
                                                      Icon(
                                                        CupertinoIcons
                                                            .exclamationmark_triangle,
                                                        size: manageWidth(
                                                            context, 20),
                                                      ),
                                                    ],
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                  ));
                                            }),
                                          ),
                                        ),
                                      ),
                                    ),
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
                            SizedBox(width: manageWidth(context, 15)),
                            Text(
                              service["name"],
                              style: GoogleFonts.poppins(
                                color: const Color.fromARGB(255, 74, 74, 74),
                                fontWeight: FontWeight.w500,
                                fontSize: manageWidth(context, 17),
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () async {
                                var ref1 = await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('Prestataires suivis')
                                    .where("seller id",
                                        isEqualTo: widget.id ?? providerId)
                                    .get();

                                if (ref1.docs.isEmpty) {
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('Prestataires suivis')
                                      .add({
                                    "seller id": widget.id ?? providerId,
                                    "seller name":
                                        service["name"].toString().toLowerCase()
                                  });
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(widget.id ?? providerId)
                                      .collection('Abonnes')
                                      .add({
                                    "user id":
                                        FirebaseAuth.instance.currentUser!.uid
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      "Prestataire ajouté à ceux que vous suivez!",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ));
                                } else {
                                  var refA = await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(widget.id ?? providerId)
                                      .collection('Abonnes')
                                      .where("user id",
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser!.uid)
                                      .get();

                                  var id1 = refA.docs.first.id;
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(widget.id ?? providerId)
                                      .collection('Abonnes')
                                      .doc(id1)
                                      .delete();

                                  var refB = await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('Prestataires suivis')
                                      .where("seller id",
                                          isEqualTo: widget.id ?? providerId)
                                      .get();

                                  var id2 = refB.docs.first.id;
                                  await FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(FirebaseAuth
                                          .instance.currentUser!.uid)
                                      .collection('Prestataires suivis')
                                      .doc(id2)
                                      .delete();
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "Prestataire retiré de ceux que vous suivez.",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ));
                                }
                              },
                              child: StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(FirebaseAuth.instance.currentUser!.uid)
                                    .collection('Prestataires suivis')
                                    .where("seller id",
                                        isEqualTo: widget.id ?? providerId)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                      height: manageHeight(context, 30),
                                      width: manageWidth(context, 125),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.mainColor,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            manageWidth(context, 15)),
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
                                          color: AppColors.mainColor,
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                            manageWidth(context, 15)),
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
                                        color: AppColors.mainColor,
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          manageWidth(context, 15)),
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
                              padding: EdgeInsets.only(
                                  left: manageWidth(context, 5)),
                              height: manageHeight(context, 40),
                              width: manageWidth(context, 150),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade700,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(
                                    manageWidth(context, 15)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: manageWidth(context, 5)),
                                  Icon(
                                    Icons.person,
                                    color: Colors.grey.shade700,
                                    size: manageWidth(context, 16),
                                  ),
                                  SizedBox(width: manageWidth(context, 5)),
                                  StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(widget.id ?? providerId)
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
                                ],
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SellerRatesPage(
                                        sellerId: widget.id ?? providerId!),
                                  ),
                                );
                              },
                              child: Text(
                                "Voir tous les avis",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: manageWidth(context, 13),
                                  color: Colors.blue.shade400,
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
                            GestureDetector(
                              onTap: () async {
                                String currentUserId =
                                    FirebaseAuth.instance.currentUser!.uid;
                                // Rechercher une conversation existante entre les deux utilisateurs
                                var existingConversations1 =
                                    await FirebaseFirestore
                                        .instance
                                        .collection('Conversations')
                                        .where('users', isEqualTo: [
                                  currentUserId,
                                  widget.id ?? providerId
                                ]).get();

                                var existingData1 = existingConversations1.docs;

                                var existingConversations2 =
                                    await FirebaseFirestore
                                        .instance
                                        .collection('Conversations')
                                        .where('users', isEqualTo: [
                                  widget.id ?? providerId,
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
                                          builder: (context) =>
                                              ConversationPage(
                                                conversationId: conversationId,
                                                memberId:
                                                    widget.id ?? providerId,
                                              )),
                                    );
                                  } else {
                                    String conversationId = existingData2[0].id;
                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ConversationPage(
                                                conversationId: conversationId,
                                                memberId:
                                                    widget.id ?? providerId,
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
                                      widget.id ?? providerId
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
                                              memberId: widget.id ?? providerId,
                                            )),
                                  );
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.only(
                                    left: manageWidth(context, 10)),
                                padding: EdgeInsets.only(
                                    left: manageWidth(context, 22.5)),
                                height: manageHeight(context, 40),
                                width: manageWidth(context, 240),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey
                                          .shade700, // Couleur des bordures
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
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  LinkProviderService().shareLink(
                                      "",
                                      "Venez découvirir les services de ${service["name"]} sur TradHart",
                                      null,
                                      null,
                                      null,
                                      widget.id ?? providerId,
                                      '/ProviderPage',
                                      images["profil image"]);
                                },
                                icon: const Icon(Icons.ios_share))
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.all(manageWidth(context, 10)),
                          child: Text(service["description"] ?? "",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w400,
                                fontSize: manageWidth(context, 15),
                                color: Colors.grey.shade800,
                              )),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          child: Text(service["location"] ?? "",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: manageWidth(context, 15),
                                color: const Color.fromARGB(255, 159, 102, 156),
                              )),
                        ),
                        SizedBox(
                          height: manageHeight(context, 5),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          child: Text(
                              "Années d'expérience : ${service["experience"] ?? "".toString()}",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: manageWidth(context, 15),
                                color: const Color.fromARGB(255, 74, 74, 74),
                              )),
                        ),
                        SizedBox(
                          height: manageHeight(context, 5),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 10)),
                          child: Text("Nos prestations :",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w500,
                                fontSize: manageWidth(context, 19),
                                color: const Color.fromARGB(255, 74, 74, 74),
                              )),
                        ),
                        Container(
                          height: manageHeight(context, 490),
                          width: manageWidth(context, 345),
                          margin: EdgeInsets.fromLTRB(
                              manageWidth(context, 7.5),
                              manageHeight(context, 13),
                              manageWidth(context, 7.5),
                              0),
                          padding: EdgeInsets.all(manageWidth(context, 5)),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.grey,
                              width: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(15),
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
                                  .collection('Services')
                                  .where('sellerId',
                                      isEqualTo: widget.id ?? providerId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator(
                                    color: AppColors.mainColor,
                                  ));
                                }
                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text("Une erreur s'est produite!",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: manageWidth(context, 20),
                                          color:
                                              const Color.fromARGB(255, 180, 44, 44),
                                        )),
                                  );
                                }
                                if (!snapshot.hasData ||
                                    snapshot.data!.docs.isEmpty) {
                                  return Center(
                                    child: Text("Aucun service",
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: manageWidth(context, 20),
                                          color:
                                              const Color.fromARGB(255, 74, 74, 74),
                                        )),
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
                                    childAspectRatio: 0.6,
                                  ),
                                  itemBuilder: (context, index) {
                                    Map<String, dynamic> serviceData =
                                        snapshot.data!.docs[index].data();

                                    var service = Service(
                                        location: serviceData['location'],
                                        id: snapshot.data!.docs[index].id,
                                        name: serviceData['name'],
                                        price: serviceData['price'] * 1.0,
                                        categories: serviceData['categories'],
                                        sellerId: serviceData['sellerId'],
                                        duration: serviceData['duration'],
                                        description: serviceData['description'],
                                        averageRate:
                                            serviceData['average rate'] * 1.0,
                                        date: (serviceData['date'] as Timestamp)
                                            .toDate(),
                                        images: serviceData['images'],
                                        ratesNumber:
                                            serviceData['rates number'],
                                        sellerName: serviceData['seller name'],
                                        status: serviceData['status'],
                                        totalPoints:
                                            serviceData['total points'] * 1.0,
                                        creneauReservationStatus: serviceData[
                                            "creneau reservation status"],
                                        crenaux: serviceData["crenaux"]);

                                    return Stack(
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return ServiceDetailPage(
                                                    serviceId: service.id);
                                              }));
                                            },
                                            child:
                                                ServiceView(service: service)),
                                        Padding(
                                            padding: EdgeInsets.only(
                                                top: manageHeight(context, 95)),
                                            child: StreamBuilder(
                                                stream: FirebaseFirestore
                                                    .instance
                                                    .collection('Users')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return const HomeAddToFavorite(
                                                        color: Colors.grey);
                                                  }
                                                  var data =
                                                      snapshot.data!.data();
                                                  var favourites = (!data!
                                                          .containsKey(
                                                              "wishlist"))
                                                      ? []
                                                      : data["wishlist"];
                                                  return GestureDetector(
                                                    child: HomeAddToFavorite(
                                                      color: (favourites
                                                                  as List)
                                                              .contains(
                                                                  service.id)
                                                          ? const Color.fromARGB(164,
                                                              253, 120, 162)
                                                          : Colors.blueGrey,
                                                    ),
                                                    onTap: () {
                                                      addToWishlist(
                                                          service.id!);
                                                    },
                                                  );
                                                }))
                                      ],
                                    );
                                  },
                                );
                              }),
                        ),
                        SizedBox(
                          height: manageHeight(context, 20),
                        )
                      ],
                    );
                  }
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: manageHeight(context, 200),
                    ),
                    const Center(child: CircularProgressIndicator()),
                  ],
                );
              })),
    );
  }
}
