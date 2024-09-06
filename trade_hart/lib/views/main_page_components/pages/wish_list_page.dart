// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/selection_divider.dart';
import 'package:trade_hart/views/main_page_components/wish_list_page_components/wish_feed.dart';

class WishListPage extends StatefulWidget {
  WishListPage({super.key});

  @override
  State<WishListPage> createState() => _WishListPageState();
}

class _WishListPageState extends State<WishListPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
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
                textColor: eshopSelection ? Colors.white : AppColors.mainColor,
              ),
              SelectionDivider(),
              SelectionButton(
                selection: "services",
                changeSelection: () {
                  setState(() {
                    eshopSelection = false;
                  });
                },
                buttonColor:
                    eshopSelection ? Colors.white : AppColors.mainColor,
                textColor: eshopSelection ? AppColors.mainColor : Colors.white,
              ),
            ],
          ),
          Container(
            height: manageHeight(context, 520),
            width: MediaQuery.of(context).size.width * 0.96,
            margin: EdgeInsets.fromLTRB(
              manageWidth(context, 7.5),
              manageHeight(context, 13),
              manageWidth(context, 7.5),
              0,
            ),
            padding: EdgeInsets.all(manageWidth(context, 5)),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey,
                width: 0.1,
              ),
              borderRadius: BorderRadius.circular(manageWidth(context, 15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1.5,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IndexedStack(
              index: eshopSelection ? 0 : 1,
              children: wishfeed,
            ),
          ),
        ],
      ),
    );
  }
}
