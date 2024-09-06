// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/model/article_size_data.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_container.dart';
import 'package:trade_hart/views/main_page_components/pages/colors_added_page.dart';

class SizeAddingPage extends StatefulWidget {
  const SizeAddingPage({super.key});

  @override
  State<SizeAddingPage> createState() => _SizeAddingPageState();
}

class _SizeAddingPageState extends State<SizeAddingPage> {
  int groupValue = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Ajouter des tailles", size: manageWidth(context, 18)),
        leading: MainBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                Radio(
                  value: 0,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value!;
                    });
                  },
                ),
                SizedBox(
                  width: manageWidth(context, 5),
                ),
                Text(
                  "Vetements",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: manageWidth(context, 15.5),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 5),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                Radio(
                  value: 1,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value!;
                    });
                  },
                ),
                SizedBox(
                  width: manageWidth(context, 5),
                ),
                Text(
                  "Chaussures",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: manageWidth(context, 15.5),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 5),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                Radio(
                  value: 2,
                  groupValue: groupValue,
                  onChanged: (value) {
                    setState(() {
                      groupValue = value!;
                    });
                  },
                ),
                SizedBox(
                  width: manageWidth(context, 5),
                ),
                Text(
                  "Autre",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: manageWidth(context, 15.5),
                  ),
                ),
              ],
            ),
            Container(
              height: manageHeight(context, 480),
              margin: EdgeInsets.fromLTRB(
                manageWidth(context, 7.5),
                manageHeight(context, 13),
                manageWidth(context, 7.5),
                0,
              ),
              padding: EdgeInsets.only(
                left: manageWidth(context, 10),
                top: manageHeight(context, 5),
              ),
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
              child: ListView.builder(
                itemBuilder: (context, index) {
                  switch (groupValue) {
                    case 0:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            child:
                                ArticleSizeContainer(size: clotheSizes[index]),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ColorsAddedPage(
                                  categorie: 0,
                                  size: clotheSizes[index],
                                );
                              }));
                            },
                          ),
                        ],
                      );
                    case 1:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            child: ArticleSizeContainer(size: shoeSizes[index]),
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ColorsAddedPage(
                                  categorie: 1,
                                  size: shoeSizes[index],
                                );
                              }));
                            },
                          ),
                        ],
                      );
                    default:
                      return SizedBox();
                  }
                },
                itemCount: groupValue == 0
                    ? clotheSizes.length
                    : groupValue == 1
                        ? shoeSizes.length
                        : 1,
              ),
            ),
            SizedBox(
              height: manageHeight(context, 40),
            )
          ],
        ),
      ),
    );
  }
}
