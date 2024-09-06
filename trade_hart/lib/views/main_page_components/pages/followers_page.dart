import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
import 'package:trade_hart/views/main_page_components/profile_page_components/user_profile_view.dart';

class FollowersPage extends StatefulWidget {
  const FollowersPage({super.key});

  @override
  State<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends State<FollowersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            AppBarTitleText(title: "Abonnés", size: manageHeight(context, 20)),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Abonnes')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          var data = snapshot.data!.docs;
          if (data.isEmpty) {
            return const Text("Pas encore d'abonnés");
          }
          return SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: ListView(
                children: data
                    .map((e) => StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(e['user id'])
                            .snapshots(),
                        builder: (context, snapshot2) {
                          if (snapshot2.connectionState ==
                              ConnectionState.waiting) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(
                                  manageWidth(context, 8),
                                  manageHeight(context, 8),
                                  manageWidth(context, 8),
                                  manageHeight(context, 8)),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.grey.shade400,
                                    radius: manageHeight(context, 24),
                                  ),
                                  Container(
                                    height: manageHeight(context, 10),
                                    margin: EdgeInsets.only(
                                        left: manageWidth(context, 10)),
                                    width: manageWidth(context, 80),
                                    color: Colors.grey.shade400,
                                  )
                                ],
                              ),
                            );
                          }
                          var user = snapshot2.data!;
                          if (!user.exists) {
                            return SizedBox();
                          }
                          var userData = user.data();
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                                manageWidth(context, 8),
                                manageHeight(context, 8),
                                manageWidth(context, 8),
                                manageHeight(context, 8)),
                            child: Row(
                              children: [
                                UserProfileView(
                                  username: userData!['first name'],
                                  withRow: false,
                                ),
                                SizedBox(
                                  width: manageWidth(context, 10),
                                ),
                                Text(
                                  userData['first name'],
                                  style: GoogleFonts.poppins(
                                      fontSize: manageHeight(context, 16),
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  width: manageWidth(context, 10),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    String currentUserId =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    // Rechercher une conversation existante entre les deux utilisateurs
                                    var existingConversations1 =
                                        await FirebaseFirestore.instance
                                            .collection('Conversations')
                                            .where(
                                      'users',
                                      isEqualTo: [currentUserId, user.id],
                                    ).get();

                                    var existingData1 =
                                        existingConversations1.docs;

                                    var existingConversations2 =
                                        await FirebaseFirestore.instance
                                            .collection('Conversations')
                                            .where(
                                      'users',
                                      isEqualTo: [user.id, currentUserId],
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
                                                    memberId: user.id,
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
                                                    memberId: user.id,
                                                  )),
                                        );
                                      }
                                    } else {
                                      // Si aucune conversation n'existe , créer une nouvelle conversation
                                      DocumentReference newConversationRef =
                                          await FirebaseFirestore.instance
                                              .collection('Conversations')
                                              .add({
                                        'users': [currentUserId, user.id],
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
                                                  memberId: user.id,
                                                )),
                                      );
                                    }
                                  },
                                  child: Icon(
                                    color: Colors.deepPurple,
                                    CupertinoIcons.chat_bubble_text_fill,
                                    size: manageHeight(context, 20),
                                  ),
                                )
                              ],
                            ),
                          );
                        }))
                    .toList(),
              ));
        },
      ),
    );
  }
}
