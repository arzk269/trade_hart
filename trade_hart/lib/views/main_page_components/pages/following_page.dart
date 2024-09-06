import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/main_page_components/app_bar_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_divider.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_page.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  TextEditingController controller = TextEditingController();
  String search = "";
  bool eshopSelection = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarView(title: "Abonnements").appBarsetter(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: manageWidth(context, 10),
                      top: manageHeight(context, 3)),
                  width: manageWidth(context, 335),
                  height: manageHeight(context, 52),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 27.5)),
                    border: Border.all(
                      color: Colors.grey,
                      width: manageWidth(context, 0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.23),
                        spreadRadius: manageHeight(context, 1.5),
                        blurRadius: manageHeight(context, 8),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(width: manageWidth(context, 15)),
                      Icon(
                        Icons.search,
                        size: manageWidth(context, 20),
                      ),
                      SizedBox(
                        width: manageWidth(context, 225),
                        height: manageHeight(context, 50),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              search = controller.text;
                            });
                          },
                          autofocus: true,
                          controller: controller,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search...',
                            contentPadding: EdgeInsets.fromLTRB(
                                manageWidth(context, 15.5),
                                manageHeight(context, 15.5),
                                manageWidth(context, 15.5),
                                manageHeight(context, 15.5)),
                            hintStyle: TextStyle(
                                color: const Color.fromARGB(255, 128, 128, 128),
                                fontSize: manageWidth(context, 16),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: manageHeight(context, 13)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SelectionButton(
                  selection: "e-shop",
                  changeSelection: () {
                    setState(() {
                      eshopSelection = true;
                    });
                  },
                  buttonColor:
                      eshopSelection ? AppColors.mainColor : Colors.white,
                  textColor:
                      eshopSelection ? Colors.white : AppColors.mainColor,
                ),
                const SelectionDivider(),
                SelectionButton(
                  selection: "services",
                  changeSelection: () {
                    setState(() {
                      eshopSelection = false;
                    });
                  },
                  buttonColor:
                      eshopSelection ? Colors.white : AppColors.mainColor,
                  textColor:
                      eshopSelection ? AppColors.mainColor : Colors.white,
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 25),
            ),
            StreamBuilder(
                stream: eshopSelection
                    ? FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('Boutiques suivies')
                        .orderBy('seller name')
                        .startAt([search.toLowerCase()]).snapshots()
                    : FirebaseFirestore.instance
                        .collection('Users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('Prestataires suivis')
                        .orderBy('seller name')
                        .startAt([search.toLowerCase()]).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (!snapshot.hasData) {
                    return const Text("Aucune résultat de recherche");
                  }

                  var data = snapshot.data!.docs;

                  if (data.isEmpty) {
                    return const Text("Aucune résultat de recherche");
                  }

                  return Container(
                    height: manageHeight(context, 475),
                    width: MediaQuery.of(context).size.width * 0.96,
                    margin: EdgeInsets.fromLTRB(manageWidth(context, 7.5), 0,
                        manageWidth(context, 7.5), 0),
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.grey,
                        width: manageWidth(context, 0.1),
                      ),
                      borderRadius: BorderRadius.circular(
                        manageHeight(context, 15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: manageHeight(context, 1.5),
                          blurRadius: manageHeight(context, 5),
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: !snapshot.hasData
                        ? const Center(
                            child: Text(
                                "Aucune donnée relative à votre recherche n'a été trouvée"))
                        : ListView(
                            children: data.map((e) {
                              var donnee = e.data();
                              return Column(
                                children: [
                                  SizedBox(
                                    height: manageHeight(context, 20),
                                  ),
                                  ListTile(
                                    trailing: GestureDetector(
                                      onTap: () async {
                                        String currentUserId = FirebaseAuth
                                            .instance.currentUser!.uid;
                                        // Rechercher une conversation existante entre les deux utilisateurs
                                        var existingConversations1 =
                                            await FirebaseFirestore.instance
                                                .collection('Conversations')
                                                .where(
                                          'users',
                                          isEqualTo: [
                                            currentUserId,
                                            e["seller id"]
                                          ],
                                        ).get();

                                        var existingData1 =
                                            existingConversations1.docs;

                                        var existingConversations2 =
                                            await FirebaseFirestore.instance
                                                .collection('Conversations')
                                                .where(
                                          'users',
                                          isEqualTo: [
                                            e["seller id"],
                                            currentUserId
                                          ],
                                        ).get();

                                        var existingData2 =
                                            existingConversations2.docs;

                                        //Si une conversation existe, naviguer vers la page de conversation avec l'ID de la conversation
                                        if (existingData1.isNotEmpty ||
                                            existingData2.isNotEmpty) {
                                          if (existingData1.isNotEmpty) {
                                            String conversationId =
                                                existingData1[0].id;
                                            //ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ConversationPage(
                                                        conversationId:
                                                            conversationId,
                                                        memberId:
                                                            e["seller id"],
                                                      )),
                                            );
                                          } else {
                                            String conversationId =
                                                existingData2[0].id;
                                            //ignore: use_build_context_synchronously
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ConversationPage(
                                                        conversationId:
                                                            conversationId,
                                                        memberId:
                                                            e["seller id"],
                                                      )),
                                            );
                                          }
                                        } else {
                                          // Si aucune conversation n'existe , créer une nouvelle conversation
                                          DocumentReference newConversationRef =
                                              await FirebaseFirestore.instance
                                                  .collection('Conversations')
                                                  .add({
                                            'users': [
                                              currentUserId,
                                              e["seller id"]
                                            ],
                                            'last message': "",
                                            'last time': Timestamp.now(),
                                            "is all read": {
                                              "sender": true,
                                              "receiver": false
                                            }
                                          });
                                          String conversationId =
                                              newConversationRef.id;
                                          //  ignore: use_build_context_synchronously
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ConversationPage(
                                                      conversationId:
                                                          conversationId,
                                                      memberId: e["seller id"],
                                                    )),
                                          );
                                        }
                                      },
                                      child: Icon(
                                        color: Colors.deepPurple,
                                        CupertinoIcons.chat_bubble_text_fill,
                                        size: manageWidth(context, 20),
                                      ),
                                    ),
                                    onTap: eshopSelection
                                        ? () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SellerPage(
                                                        sellerId:
                                                            e["seller id"])))
                                        : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ServiceProviderPage(
                                                        id: e["seller id"]))),
                                    title: Text(
                                      (donnee["seller name"][0]
                                              .toString()
                                              .toUpperCase()) +
                                          (donnee["seller name"]
                                              .toString()
                                              .substring(1)),
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                          fontSize: manageWidth(context, 16),
                                          color: Colors.grey.shade800,
                                          fontWeight: FontWeight.w500),
                                    ),
                                    leading: StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(e["seller id"])
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container(
                                              height: manageHeight(context, 60),
                                              width: manageWidth(
                                                context,
                                                60,
                                              ),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(
                                                              0.2), // Couleur de l'ombre
                                                      spreadRadius: manageHeight(
                                                          context,
                                                          1.5), // Distance d'expansion de l'ombre
                                                      blurRadius: manageHeight(
                                                          context,
                                                          5), // Flou de l'ombre
                                                      offset: const Offset(0,
                                                          1.5), // Position de l'ombre (horizontal, vertical)
                                                    ),
                                                  ],
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              manageHeight(
                                                                  context,
                                                                  30)))),
                                            );
                                          }

                                          var data = snapshot.data!;

                                          if (data.exists) {
                                            var userData = data.data();
                                            return Container(
                                              height: manageHeight(context, 60),
                                              width: manageWidth(
                                                context,
                                                60,
                                              ),
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(
                                                              0.2), // Couleur de l'ombre
                                                      spreadRadius: manageHeight(
                                                          context,
                                                          1.5), // Distance d'expansion de l'ombre
                                                      blurRadius: manageHeight(
                                                          context,
                                                          5), // Flou de l'ombre
                                                      offset: const Offset(0,
                                                          1.5), // Position de l'ombre (horizontal, vertical)
                                                    ),
                                                  ],
                                                  color: Colors.grey.shade200,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              manageHeight(
                                                                  context,
                                                                  30)))),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  manageHeight(context, 30),
                                                ),
                                                child: Image.network(
                                                  eshopSelection
                                                      ? userData!["shop"]
                                                          ["cover image"]
                                                      : userData!["images"]
                                                          ["profil image"],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                          stackTrace) =>
                                                      SizedBox(
                                                          height: manageHeight(
                                                              context, 150),
                                                          width: manageWidth(
                                                              context, 165),
                                                          child: Column(
                                                            children: [
                                                              Icon(
                                                                CupertinoIcons
                                                                    .person,
                                                                size:
                                                                    manageWidth(
                                                                        context,
                                                                        25),
                                                              ),
                                                            ],
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                          )),
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox();
                                        }),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
