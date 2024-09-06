import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/conversation_provider.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/received_message_buble.dart';
import 'package:trade_hart/tools/widgets/sent_message_buble.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/pages/report_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_page.dart';

class ConversationPage extends StatefulWidget {
  final String? conversationId;
  final String? memberId;
  const ConversationPage({super.key, this.conversationId, this.memberId});

  @override
  State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController messageController = TextEditingController();
  TextEditingController reportController = TextEditingController();
  ScrollController scrollController = ScrollController();
  // void upDateReadStatus() async {
  //   var conv = await FirebaseFirestore.instance
  //       .collection('Conversations')
  //       .doc(widget.conversationId)
  //       .get();
  //   var data = conv.data();

  //   if (data!["sender"] == widget.memberId) {
  //     data["is all read"]["receiver"] = true;
  //     FirebaseFirestore.instance
  //         .collection('Conversations')
  //         .doc(widget.conversationId)
  //         .update(data);
  //   }
  // }

  void upDateReadStatus(String? memberId, String? conversationId) async {
    var conv = await FirebaseFirestore.instance
        .collection('Conversations')
        .doc(widget.conversationId ?? conversationId)
        .get();
    var data = conv.data();

    if (data != null) {
      if ((data["is all read"] as Map<String, dynamic>)["receiver"] == false &&
              ((data["last message"] as Map<String, dynamic>)["sender"]
                      as String ==
                  widget.memberId) ||
          (data["last message"] as Map<String, dynamic>)["sender"] as String ==
              memberId) {
        data["is all read"]["receiver"] = true;
        FirebaseFirestore.instance
            .collection('Conversations')
            .doc(widget.conversationId ?? conversationId)
            .update(data);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    upDateReadStatus(context.read<ConversationProvider>().memberId,
        context.read<ConversationProvider>().conversationId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments;
    String? conversationId;
    String? memberId;
    if (message != null) {
      conversationId = (message as Map<String, dynamic>)["conversationId"];
      memberId = message["senderId"];
      context.read<ConversationProvider>().getIds(memberId!, conversationId!);
    }
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            if (widget.memberId == null) {
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
          PopupMenuButton(
            icon: Container(
              margin: EdgeInsets.only(
                right: manageWidth(context, 18),
                bottom: manageHeight(context, 15),
              ),
              height: manageWidth(context, 22),
              width: manageWidth(context, 22),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 218, 215, 215).withOpacity(0.6),
                borderRadius: BorderRadius.circular(manageWidth(context, 20)),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.ellipsis,
                  size: manageWidth(context, 16),
                ),
              ),
            ),
            itemBuilder: (context2) {
              return {
                'Voir le profil',
                'Signaler',
              }.map((String choice) {
                return PopupMenuItem(
                  value: choice,
                  child: Text(
                    choice,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: manageWidth(context, 15),
                      color: Color.fromARGB(255, 74, 74, 74),
                    ),
                  ),
                );
              }).toList();
            },
            onSelected: (value) async {
              var member = await FirebaseFirestore.instance
                  .collection('Users')
                  .doc(widget.memberId ?? memberId)
                  .get();

              if (value == 'Voir le profil' && member["user type"] != "buyer") {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  if (member["user type"] == "provider") {
                    return ServiceProviderPage(
                      id: widget.memberId ?? memberId,
                    );
                  }
                  return SellerPage(
                    sellerId: widget.memberId ?? memberId,
                  );
                }));
              }

              if (value == 'Signaler') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReportPage(
                              memberId: widget.memberId ?? memberId!,
                            )));
              }
            },
          )
        ],
        title: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("Users")
                .doc(widget.memberId ?? memberId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: [
                    Container(
                      height: manageHeight(context, 10),
                      width: manageWidth(context, 50),
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    SizedBox(
                      width: manageWidth(context, 20),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.grey.withOpacity(0.5),
                      radius: manageWidth(context, 20),
                      child: const Icon(CupertinoIcons.person),
                    )
                  ],
                );
              } else if (!snapshot.hasData) {
                return const Text("Utilisateur introuvablle");
              }

              var member = snapshot.data!;

              return Row(
                children: [
                  AppBarTitleText(
                      title: member["user type"] == "buyer"
                          ? member["first name"]
                          : member["user type"] == "provider"
                              ? (member["service"]
                                  as Map<String, dynamic>)["name"]
                              : (member["shop"]
                                  as Map<String, dynamic>)["name"],
                      size: 17),
                  SizedBox(
                    width: manageWidth(context, 20),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    radius: manageWidth(context, 20),
                    child: member["user type"] == "buyer"
                        ? Icon(
                            CupertinoIcons.person,
                            size: manageWidth(context, 25),
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 20)),
                            child: SizedBox(
                              height: manageWidth(context, 40),
                              width: manageWidth(context, 40),
                              child: Image.network(
                                member["user type"] == "provider"
                                    ? (member["images"]
                                        as Map<String, dynamic>)["profil image"]
                                    : (member["shop"]
                                        as Map<String, dynamic>)["cover image"],
                                errorBuilder: (context, error, stackTrace) =>
                                    SizedBox(
                                        height: manageWidth(context, 40),
                                        width: manageWidth(context, 40),
                                        child: Column(
                                          children: [
                                            Icon(
                                              CupertinoIcons.person,
                                              size: manageWidth(context, 25),
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        )),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                ],
              );
            }),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Conversations')
                    .doc(widget.conversationId ?? conversationId)
                    .collection('Messages')
                    .orderBy("date")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const SizedBox();
                  }
                  var messages = snapshot.data!.docs;

                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.end,
                          children: messages.map((message) {
                            Timestamp timestamp = message["date"];
                            DateTime dateTime = timestamp.toDate();
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(dateTime);

                            String formattedTime =
                                DateFormat('HH:mm').format(dateTime);
                            if (message["sender"] != userId) {
                              return Column(
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: manageWidth(context, 20),
                                      ),
                                      Text(
                                        formattedDate ==
                                                DateFormat('dd/MM/yyyy')
                                                    .format(DateTime.now())
                                            ? "aujourd'hui"
                                            : formattedDate ==
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(DateTime.now()
                                                            .subtract(
                                                                const Duration(
                                                                    days: 1)))
                                                ? "Hier"
                                                : formattedDate,
                                        style: const TextStyle(fontSize: 12),
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      ReceivedMessageBuble(
                                          message: message["content"]),
                                      SizedBox(
                                          width: manageWidth(
                                        context,
                                        5,
                                      )),
                                      Text(
                                        formattedTime,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      formattedDate ==
                                              DateFormat('dd/MM/yyyy')
                                                  .format(DateTime.now())
                                          ? "aujourd'hui"
                                          : formattedDate ==
                                                  DateFormat('dd/MM/yyyy')
                                                      .format(DateTime.now()
                                                          .subtract(
                                                              const Duration(
                                                                  days: 1)))
                                              ? "hier"
                                              : formattedDate,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                      width: manageWidth(context, 15),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Spacer(),
                                    Text(
                                      formattedTime,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    SizedBox(
                                        width: manageWidth(
                                      context,
                                      5,
                                    )),
                                    SentMessageBuble(
                                        message: message["content"])
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),
          ),
          Container(
            margin: EdgeInsets.only(bottom: manageHeight(context, 5)),
            padding: EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.7)),
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(manageHeight(context, 20))),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: manageHeight(context, 10),
                      ),
                      TextField(
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Entrer votre message...",
                          hintStyle: TextStyle(fontSize: 14),
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                        obscureText: false,
                        controller: messageController,
                        maxLines: null,
                        maxLength: 250,
                      ),
                    ],
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      if (messageController.text.isNotEmpty) {
                        var moment = Timestamp.now();
                        FirebaseFirestore.instance
                            .collection("Conversations")
                            .doc(widget.conversationId ?? conversationId)
                            .collection("Messages")
                            .add({
                          "sender": userId,
                          "content": messageController.text,
                          "date": moment
                        });

                        FirebaseFirestore.instance
                            .collection("Conversations")
                            .doc(widget.conversationId ?? conversationId)
                            .update({
                          "last time": moment,
                          "last message": {
                            "content": messageController.text,
                            "sender": userId
                          },
                          "is all read": {"sender": true, "receiver": false}
                        });

                        var ref = FirebaseFirestore.instance
                            .collection('Users')
                            .doc(FirebaseAuth.instance.currentUser!.uid);
                        var user = await ref.get();
                        var userData = user.data();

                        String name = userData!["user type"] == "buyer"
                            ? userData["first name"]
                            : userData["user type"] == "provider"
                                ? (userData["service"]
                                    as Map<String, dynamic>)["name"]
                                : (userData["shop"]
                                    as Map<String, dynamic>)["name"];
                        var sellerData = await FirebaseFirestore.instance
                            .collection('Users')
                            .doc(widget.memberId ?? memberId)
                            .get();

                        sendNotification(
                            token: sellerData.data()!["fcmtoken"],
                            title: name,
                            body: messageController.text,
                            route: '/ConversationPage',
                            senderId: FirebaseAuth.instance.currentUser!.uid,
                            conversationId:
                                widget.conversationId ?? conversationId);
                        messageController.clear();
                        // Faire défiler jusqu'à la fin
                        Future.delayed(const Duration(milliseconds: 100), () {
                          scrollController.jumpTo(
                              scrollController.position.maxScrollExtent);
                        });
                      }
                    },
                    icon: const Icon(
                      CupertinoIcons.paperplane,
                      color: AppColors.mainColor,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
