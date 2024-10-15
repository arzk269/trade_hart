import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/seller_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int navIndex = 0;
  var navScrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitleText(title: "Historique", size: 18),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              controller: navScrollController,
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          navIndex = 0;
                        });
                        navScrollController.animateTo(
                          navScrollController.position.minScrollExtent,
                          duration: const Duration(milliseconds: 100),
                          curve: Curves.decelerate,
                        );
                      },
                      child: Text(
                        "Articles",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: 17,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      width: 55,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: navIndex != 0
                              ? Colors.transparent
                              : const Color.fromARGB(200, 87, 199, 197)),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          navIndex = 1;
                        });
                      },
                      child: Text(
                        "Services",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: 17,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      width: 55,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: navIndex != 1
                              ? Colors.transparent
                              : const Color.fromARGB(200, 87, 199, 197)),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          navIndex = 2;
                        });
                        navScrollController.animateTo(
                          navScrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        "Vendeurs",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: 17,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      width: 70,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: navIndex != 2
                              ? Colors.transparent
                              : const Color.fromARGB(200, 87, 199, 197)),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          navIndex = 3;
                        });
                        navScrollController.animateTo(
                          navScrollController.position.maxScrollExtent,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        "Prestataires de service",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: 17,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15),
                      width: 150,
                      height: 5,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: navIndex != 3
                              ? Colors.transparent
                              : const Color.fromARGB(200, 87, 199, 197)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('History')
                  .orderBy('time')
                  .where('type',
                      isEqualTo: navIndex == 0
                          ? "article"
                          : navIndex == 1
                              ? "service"
                              : navIndex == 2
                                  ? "seller"
                                  : "provider")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.data!.docs.isEmpty || !snapshot.hasData) {
                  return const AppBarTitleText(title: "Historique vide", size: 15.5);
                }
                // } else if (!snapshot.hasError) {
                //   return AppBarTitleText(
                //       title: "Une erreur s'est produite!", size: 15.5);
                // }
                var data = snapshot.data!.docs;
                return Expanded(
                  child: ListView(
                    children: data.map((e) {
                      var item = e.data();
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    switch (navIndex) {
                                      case 0:
                                        return ArticleDetailsPage(
                                            articleId: item["id"]);
                                      case 1:
                                        return ServiceDetailPage(
                                            serviceId: item["id"]);

                                      case 2:
                                        return SellerPage(sellerId: item["id"]);

                                      default:
                                        return ServiceProviderPage(
                                            id: item["id"]);
                                    }
                                  }));
                                },
                                child: Text(
                                  item["name"],
                                  style: const TextStyle(fontSize: 17),
                                  overflow: TextOverflow.ellipsis,
                                )),
                            const Spacer(),
                            IconButton(
                                onPressed: () {
                                  e.reference.delete();
                                },
                                icon: const Icon(
                                  CupertinoIcons.clear,
                                  size: 18,
                                ))
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                );
              })
        ],
      ),
    );
  }
}
