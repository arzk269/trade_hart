import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/received_message_buble.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/rate_stars_view.dart';
import 'package:trade_hart/views/main_page_components/profile_page_components/user_profile_view.dart';

class SellerRatesPage extends StatefulWidget {
  final String sellerId;
  const SellerRatesPage({super.key, required this.sellerId});

  @override
  State<SellerRatesPage> createState() => _SellerRatesPageState();
}

class _SellerRatesPageState extends State<SellerRatesPage> {
  var userId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController aviController = TextEditingController();
  ScrollController scrollController = ScrollController();
  void showPopup(BuildContext context, id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Voulez-vous vraiment supprimer cet élément ?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Supprimer',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.sellerId)
                    .collection('Avis')
                    .doc(id)
                    .delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Élément supprimé'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    if (widget.sellerId == FirebaseAuth.instance.currentUser!.uid) {
      var ref =
          FirebaseFirestore.instance.collection("Users").doc(widget.sellerId);

      ref.update({"is all comments read": true});
    }
    Future.delayed(const Duration(milliseconds: 200), () {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    super.initState();
  }

  @override
  void dispose() {
    if (widget.sellerId == FirebaseAuth.instance.currentUser!.uid) {
      var ref =
          FirebaseFirestore.instance.collection("Users").doc(widget.sellerId);

      ref.update({"is all comments read": true});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(title: 'Avis', size: manageWidth(context, 19)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Users')
                    .doc(widget.sellerId)
                    .collection('Avis')
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
                  var avis = snapshot.data!.docs;

                  return SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.end,
                          children: avis.map((avi) {
                            Timestamp timestamp = avi["date"];
                            DateTime dateTime = timestamp.toDate();
                            String formattedDate =
                                DateFormat('dd/MM/yyyy').format(dateTime);

                            String formattedTime =
                                DateFormat('HH:mm').format(dateTime);

                            return Column(
                              children: [
                                StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('Users')
                                      .doc(avi['buyer id'])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        width: manageWidth(context, 75),
                                        height: manageHeight(context, 10),
                                        color: Colors.grey.shade200,
                                      );
                                    }

                                    var user = snapshot.data!;
                                    if (!user.exists) {
                                      return const Text(
                                          'utilisateur introuvable');
                                    }

                                    var userData = user.data();
                                    return Row(
                                      children: [
                                        SizedBox(
                                            width: manageWidth(context, 15)),
                                        UserProfileView(
                                          username: userData!["first name"],
                                          withRow: false,
                                          radius: manageHeight(context, 12),
                                        ),
                                        SizedBox(
                                            width: manageWidth(context, 5)),
                                        Text(
                                          userData["first name"],
                                          style: TextStyle(
                                              fontSize:
                                                  manageWidth(context, 12)),
                                        ),
                                        SizedBox(
                                            width: manageWidth(context, 5)),
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
                                          style: TextStyle(
                                              fontSize:
                                                  manageWidth(context, 12)),
                                        ),
                                        SizedBox(
                                            width: manageWidth(context, 5)),
                                        Text(
                                          "à $formattedTime",
                                          style: TextStyle(
                                              fontSize:
                                                  manageWidth(context, 12)),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                                SizedBox(height: manageHeight(context, 5)),
                                Row(
                                  children: [
                                    SizedBox(width: manageWidth(context, 13)),
                                    SizedBox(
                                      child: avi["rate"] == 0
                                          ? null
                                          : RateStars(
                                              rate: avi["rate"],
                                              nbRates: 0,
                                              withText: false,
                                              starsSize:
                                                  manageHeight(context, 15),
                                            ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: manageWidth(context, 5)),
                                    GestureDetector(
                                      onLongPress: () {
                                        if (avi["buyer id"] ==
                                            FirebaseAuth
                                                .instance.currentUser!.uid) {
                                          showPopup(context, avi.id);
                                        }
                                      },
                                      child: ReceivedMessageBuble(
                                        message: avi["comment"],
                                      ),
                                    ),
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
              borderRadius: BorderRadius.circular(manageWidth(context, 20)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: manageHeight(context, 15),
                      ),
                      TextField(
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Donner votre avis...",
                          hintStyle:
                              TextStyle(fontSize: manageWidth(context, 14)),
                          contentPadding: EdgeInsets.zero,
                          isCollapsed: true,
                        ),
                        obscureText: false,
                        controller: aviController,
                        maxLines: null,
                        maxLength: 250,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (aviController.text.isNotEmpty) {
                      var moment = Timestamp.now();
                      var ref = FirebaseFirestore.instance
                          .collection("Users")
                          .doc(widget.sellerId);

                      ref.collection("Avis").add({
                        "seller id": widget.sellerId,
                        "buyer id": userId,
                        "comment": aviController.text,
                        "date": moment,
                        "rate": 0
                      });

                      ref.update(
                        {
                          "is all comments read": false,
                        },
                      );

                      aviController.clear();
                      // Faire défiler jusqu'à la fin
                      Future.delayed(const Duration(milliseconds: 100), () {
                        scrollController
                            .jumpTo(scrollController.position.maxScrollExtent);
                      });
                    }
                  },
                  icon: const Icon(
                    CupertinoIcons.paperplane,
                    color: AppColors.mainColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}