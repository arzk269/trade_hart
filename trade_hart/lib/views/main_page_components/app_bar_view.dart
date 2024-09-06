import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/main_page_components/pages/cart_page.dart';

AppBar appBar(BuildContext context) {
  return AppBar(
    leading: const Icon(Icons.filter_list_sharp),
    centerTitle: true,
    toolbarHeight: manageHeight(context, 55),
    title: const AppBarTitleText(
      title: "TradeHart",
      size: 26,
    ),
    backgroundColor: Colors.white,
    actions: [
      SizedBox(
        child: GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return CartPage();
              },
            ));
          },
          child: Stack(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: manageWidth(context, 30),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsetsDirectional.all(manageWidth(context, 0.8)),
                  height: manageWidth(context, 13.5),
                  width: manageWidth(context, 13.5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 7.75))),
                  child: Container(
                    margin: EdgeInsets.only(top: 0),
                    height: manageWidth(context, 12.5),
                    width: manageWidth(context, 12.5),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6.25)),
                    child: Center(
                      child: Text(
                        "4",
                        style: TextStyle(
                            fontSize: manageWidth(context, 8),
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class AppBarView {
  final String title;
  const AppBarView({required this.title});

  AppBar appBarsetter(BuildContext context) {
    return AppBar(
      toolbarHeight: 55,
      title: AppBarTitleText(
        title: title,
        size: 26,
      ),
      actions: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CartPage();
                  },
                ));
              },
              child: Stack(
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 30,
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Cart')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('Items')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox();
                          }
                          var data = snapshot.data!.docs;
                          int itemsNumber = data.length;
                          return Container(
                            padding: const EdgeInsetsDirectional.all(0.8),
                            height: 13.5,
                            width: 13.5,
                            decoration: BoxDecoration(
                                color: itemsNumber > 0
                                    ? Colors.white
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7.75)),
                            child: Container(
                              margin: const EdgeInsets.only(top: 0),
                              height: 12.5,
                              width: 12.5,
                              decoration: BoxDecoration(
                                  color: itemsNumber > 0
                                      ? Colors.red
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6.25)),
                              child: Center(
                                child: Text(
                                  itemsNumber > 0 ? itemsNumber.toString() : "",
                                  style: TextStyle(
                                      fontSize: itemsNumber > 0 ? 8 : 0.1,
                                      color: itemsNumber > 0
                                          ? Colors.white
                                          : Colors.transparent),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        )
      ],
    );
  }
}
