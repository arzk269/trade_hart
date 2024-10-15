import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/main_page_components/chat_page_components/chat_view.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';

class MainChatPage extends StatefulWidget {
  const MainChatPage({super.key});

  @override
  State<MainChatPage> createState() => _MainChatPageState();
}

class _MainChatPageState extends State<MainChatPage> {
  var auth = FirebaseAuth.instance.currentUser;
  String search = "";
  var searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    if (auth == null) {
      return const Center(child: Text("Vous n'etes pas connecté"));
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: manageHeight(context, 8.0),
                bottom: manageHeight(context, 6),
                left: manageWidth(context, 12),
                right: manageWidth(context, 12)),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(15)),
              height: manageHeight(
                context,
                40,
              ), // Hauteur réduite
              // Couleur de fond pertinente
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    search = value;
                  });
                },
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                      vertical: manageHeight(
                          context, 5)), // Ajuste la hauteur du texte
                  hintText: 'Recherche...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Conversations')
                  .orderBy("last time", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (!snapshot.hasData) {
                  return Center(
                    child: AppBarTitleText(
                        title: "Aucune conversation",
                        size: manageWidth(context, 20)),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: AppBarTitleText(
                        title: "Une erreur s'est produite.",
                        size: manageWidth(context, 20)),
                  );
                }
                var data = snapshot.data!.docs
                    .where((element) =>
                        element['last message'] != "" &&
                        (element["users"] as List).contains(auth!.uid))
                    .toList();

                return Container(
                  height: manageHeight(context, 537),
                  margin:
                      EdgeInsets.fromLTRB(0, manageHeight(context, 5), 0, 0),
                  padding: EdgeInsets.only(top: manageHeight(context, 5)),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(manageHeight(context, 25)),
                          topRight: Radius.circular(manageHeight(context, 25))),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: manageHeight(context, 1.5),
                          blurRadius: manageHeight(context, 5),
                          offset: const Offset(0, 2),
                        ),
                      ]),
                  child: StreamBuilder(
                      stream: null,
                      builder: (context, snapshot) {
                        return ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: (index == 0)
                                  ? [
                                      StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(((data[index]["users"]
                                                      as List)
                                                  .firstWhere(
                                                      (element) =>
                                                          element != auth!.uid,
                                                      orElse: () =>
                                                          auth!.uid) as String))
                                              .snapshots(),
                                          builder: (context, snapshot2) {
                                            if (snapshot2.connectionState ==
                                                ConnectionState.waiting) {
                                              return ListTile(
                                                leading: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    CircleAvatar(
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      radius: manageWidth(
                                                          context, 5),
                                                    ),
                                                    SizedBox(
                                                      width: manageWidth(
                                                          context, 5),
                                                    ),
                                                    CircleAvatar(
                                                      radius: manageWidth(
                                                          context, 25),
                                                      backgroundColor: Colors
                                                          .grey
                                                          .withOpacity(0.3),
                                                    ),
                                                  ],
                                                ),
                                                title: Row(
                                                  children: [
                                                    Container(
                                                      height: manageHeight(
                                                          context, 15),
                                                      width: manageWidth(
                                                          context, 60),
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  manageHeight(
                                                                      context,
                                                                      3))),
                                                    ),
                                                    const Spacer(),
                                                    Container(
                                                      height: manageHeight(
                                                          context, 15),
                                                      width: manageWidth(
                                                          context, 40),
                                                      decoration: BoxDecoration(
                                                          color: Colors
                                                              .grey.shade200,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  manageHeight(
                                                                      context,
                                                                      3))),
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Container(
                                                  padding: EdgeInsets.only(
                                                      left: manageWidth(
                                                          context, 8)),
                                                  height:
                                                      manageHeight(context, 15),
                                                  width:
                                                      manageWidth(context, 100),
                                                  decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade200,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              manageHeight(
                                                                  context, 3))),
                                                ),
                                              );
                                            } else if (!snapshot2.hasData) {
                                              return Center(
                                                child: AppBarTitleText(
                                                    title:
                                                        "Aucune conversation",
                                                    size: manageWidth(
                                                        context, 20)),
                                              );
                                            } else if (!snapshot2
                                                .data!.exists) {
                                              return const SizedBox();
                                            } else if (snapshot2.hasError) {
                                              return Center(
                                                child: AppBarTitleText(
                                                    title:
                                                        "Une erreur s'est produite.",
                                                    size: manageWidth(
                                                        context, 20)),
                                              );
                                            }
                                            var talker = snapshot2.data!;

                                            if (talker.exists) {}
                                            if ((talker["user type"] ==
                                                    "buyer") &&
                                                !(talker.data()!["first name"]
                                                        as String)
                                                    .toLowerCase()
                                                    .trim()
                                                    .startsWith(search
                                                        .toLowerCase()
                                                        .trim())) {
                                              return const SizedBox();
                                            }

                                            if ((talker["user type"] ==
                                                    "seller") &&
                                                !(talker.data()!["shop"]["name"]
                                                        as String)
                                                    .toLowerCase()
                                                    .trim()
                                                    .startsWith(search
                                                        .toLowerCase()
                                                        .trim())) {
                                              return const SizedBox();
                                            }

                                            if ((talker["user type"] ==
                                                    "provider") &&
                                                !(talker.data()!["service"]
                                                        ["name"] as String)
                                                    .toLowerCase()
                                                    .trim()
                                                    .startsWith(search
                                                        .toLowerCase()
                                                        .trim())) {
                                              return const SizedBox();
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ConversationPage(
                                                                conversationId:
                                                                    data[index]
                                                                        .id,
                                                                memberId: talker
                                                                    .id)));
                                              },
                                              child: ChatView(
                                                profilImage: talker[
                                                            "user type"] ==
                                                        "buyer"
                                                    ? null
                                                    : talker["user type"] ==
                                                            "provider"
                                                        ? (talker["images"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "profil image"]
                                                        : (talker["shop"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "cover image"],
                                                name: talker["user type"] ==
                                                        "buyer"
                                                    ? talker["first name"]
                                                    : talker["user type"] ==
                                                            "provider"
                                                        ? (talker["service"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "name"]
                                                        : (talker["shop"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "name"],
                                                message: (data[index]
                                                        ["last message"]
                                                    as Map<String,
                                                        dynamic>)["content"],
                                                time: DateFormat('dd/MM/yyyy')
                                                            .format((data[index]
                                                                        ["last time"]
                                                                    as Timestamp)
                                                                .toDate()) ==
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(
                                                                DateTime.now())
                                                    ? "aujourd'hui"
                                                    : DateFormat('dd/MM/yyyy').format(
                                                                (data[index]["last time"]
                                                                        as Timestamp)
                                                                    .toDate()) ==
                                                            DateFormat('dd/MM/yyyy')
                                                                .format(DateTime.now().subtract(const Duration(days: 1)))
                                                        ? "Hier"
                                                        : DateFormat('dd/MM/yyyy').format((data[index]["last time"] as Timestamp).toDate()),
                                                isAllRead: (data[index]
                                                                    ['last message']
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "sender"] ==
                                                        auth!.uid
                                                    ? true
                                                    : (data[index]
                                                                ["is all read"]
                                                            as Map<String,
                                                                dynamic>)[
                                                        "receiver"] as bool,
                                              ),
                                            );
                                          }),
                                    ]
                                  : [
                                      StreamBuilder(
                                          stream: FirebaseFirestore.instance
                                              .collection('Users')
                                              .doc(((data[index]["users"]
                                                      as List)
                                                  .firstWhere(
                                                      (element) =>
                                                          element != auth!.uid,
                                                      orElse: () =>
                                                          auth!.uid) as String))
                                              .snapshots(),
                                          builder: (context, snapshot2) {
                                            if (snapshot2.connectionState ==
                                                ConnectionState.waiting) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            } else if (!snapshot2.hasData) {
                                              return Center(
                                                child: AppBarTitleText(
                                                    title:
                                                        "Aucune conversation",
                                                    size: manageWidth(
                                                        context, 20)),
                                              );
                                            } else if (snapshot2.hasError) {
                                              return Center(
                                                child: AppBarTitleText(
                                                    title:
                                                        "Une erreur s'est produite.",
                                                    size: manageWidth(
                                                        context, 20)),
                                              );
                                            }
                                            var talker = snapshot2.data!;
if(talker.exists){
  if ((talker["user type"] ==
                                                    "buyer") &&
                                                !(talker.data()!["first name"]
                                                        as String)
                                                    .toLowerCase()
                                                    .trim()
                                                    .startsWith(search
                                                        .toLowerCase()
                                                        .trim())) {
                                              return const SizedBox();
                                            }

                                            if ((talker["user type"] ==
                                                    "seller") &&
                                                !(talker.data()!["shop"]["name"]
                                                        as String)
                                                    .toLowerCase()
                                                    .trim()
                                                    .startsWith(search
                                                        .toLowerCase()
                                                        .trim())) {
                                              return const SizedBox();
                                            }

                                            if ((talker["user type"] ==
                                                    "provider") &&
                                                !(talker.data()!["service"]
                                                        ["name"] as String)
                                                    .toLowerCase()
                                                    .trim()
                                                    .startsWith(search
                                                        .toLowerCase()
                                                        .trim())) {
                                              return const SizedBox();
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ConversationPage(
                                                                conversationId:
                                                                    data[index]
                                                                        .id,
                                                                memberId: talker
                                                                    .id)));
                                              },
                                              child: ChatView(
                                                profilImage: talker[
                                                            "user type"] ==
                                                        "buyer"
                                                    ? null
                                                    : talker["user type"] ==
                                                            "provider"
                                                        ? (talker["images"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "profil image"]
                                                        : (talker["shop"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "cover image"],
                                                name: talker["user type"] ==
                                                        "buyer"
                                                    ? talker["first name"]
                                                    : talker["user type"] ==
                                                            "provider"
                                                        ? (talker["service"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "name"]
                                                        : (talker["shop"]
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "name"],
                                                message: (data[index]
                                                        ["last message"]
                                                    as Map<String,
                                                        dynamic>)["content"],
                                                time: DateFormat('dd/MM/yyyy')
                                                            .format((data[index]
                                                                        ["last time"]
                                                                    as Timestamp)
                                                                .toDate()) ==
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(
                                                                DateTime.now())
                                                    ? "aujourd'hui"
                                                    : DateFormat('dd/MM/yyyy').format(
                                                                (data[index]["last time"]
                                                                        as Timestamp)
                                                                    .toDate()) ==
                                                            DateFormat('dd/MM/yyyy')
                                                                .format(DateTime.now().subtract(const Duration(days: 1)))
                                                        ? "Hier"
                                                        : DateFormat('dd/MM/yyyy').format((data[index]["last time"] as Timestamp).toDate()),
                                                isAllRead: (data[index]
                                                                    ['last message']
                                                                as Map<String,
                                                                    dynamic>)[
                                                            "sender"] ==
                                                        auth!.uid
                                                    ? true
                                                    : (data[index]
                                                                ["is all read"]
                                                            as Map<String,
                                                                dynamic>)[
                                                        "receiver"] as bool,
                                              ),
                                            );
}
                                            return const SizedBox();
                                          }),
                                    ],
                            );
                          },
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
