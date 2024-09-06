// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/article_size.dart';
import 'package:trade_hart/model/article_size_data.dart';
import 'package:trade_hart/model/colors_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_container.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_selector.dart';

class SizeAddPage extends StatefulWidget {
  final int index;
  final int groupSizeValue;
  const SizeAddPage(
      {super.key, required this.index, required this.groupSizeValue});

  @override
  State<SizeAddPage> createState() => _SizeAddPageState();
}

class _SizeAddPageState extends State<SizeAddPage> {
  List<ArticleSizeRepresentation> sizes = [];
  List<ArticleSizeRepresentation> sizes1 = [];
  List<ArticleSize> sizes2 = [];
  @override
  void initState() {
    if (widget.groupSizeValue == 0) {
      sizes = clotheSizes
          .where((element) => !context
              .read<ColorProvider>()
              .articleColors
              .toList()[widget.index]
              .sizes
              .any((size) => size.size == element))
          .map((size) => ArticleSizeRepresentation(
              size: ArticleSize(size: size, amount: 0), isSelected: false))
          .toList();
    } else if (widget.groupSizeValue == 1) {
      sizes = shoeSizes
          .where((element) => !context
              .read<ColorProvider>()
              .articleColors
              .toList()[widget.index]
              .sizes
              .any((size) => size.size == element))
          .map((size) => ArticleSizeRepresentation(
              size: ArticleSize(size: size, amount: 0), isSelected: false))
          .toList();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Ajouter des tailles", size: manageWidth(context, 17.5)),
        leading: MainBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 15),
                ),
                Text(
                  "Couleur : ${context.read<ColorProvider>().articleColors.toList()[widget.index].color}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: manageWidth(context, 16),
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(
                  height: manageHeight(context, 20),
                ),
              ],
            ),
            Row(
              children: [
                SizeSelector(
                  sizeCategory: widget.groupSizeValue,
                  color: Color.fromARGB(255, 218, 137, 180),
                ),
              ],
            ),
            Container(
              height: manageHeight(context, 455),
              margin: EdgeInsets.fromLTRB(
                manageWidth(context, 7.5),
                manageHeight(context, 13),
                manageWidth(context, 7.5),
                0,
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
                itemCount: widget.groupSizeValue == 2
                    ? sizes2.length + 1
                    : sizes.length,
                itemBuilder: (context, index) {
                  if (widget.groupSizeValue == 2) {
                    if (index == 0) {
                      TextEditingController sizeController =
                          TextEditingController();
                      TextEditingController amountController =
                          TextEditingController();
                      return Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: manageWidth(context, 15),
                              top: manageHeight(context, 15),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: manageWidth(context, 15)),
                            width: manageWidth(context, 110),
                            height: manageHeight(context, 60),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 20)),
                            ),
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                manageWidth(context, 8),
                                manageHeight(context, 8),
                                manageWidth(context, 8),
                                manageHeight(context, 8),
                              ),
                              child: TextField(
                                controller: sizeController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "taille",
                                ),
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: manageWidth(context, 15),
                              top: manageHeight(context, 15),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: manageWidth(context, 15)),
                            width: manageWidth(context, 110),
                            height: manageHeight(context, 60),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 20)),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(manageWidth(context, 8.0)),
                              child: TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "quantité",
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (amountController.text.isNotEmpty &&
                                  sizeController.text.isNotEmpty) {
                                setState(() {
                                  sizes2.add(ArticleSize(
                                      size: sizeController.text,
                                      amount:
                                          int.tryParse(amountController.text) ??
                                              0));
                                  amountController.clear();
                                  sizeController.clear();
                                });
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(
                                left: manageWidth(context, 30),
                                top: manageHeight(context, 15),
                              ),
                              height: manageHeight(context, 40),
                              width: manageWidth(context, 40),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color.fromARGB(255, 255, 146, 146),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(
                                    manageWidth(context, 25)),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.add,
                                  color: Color.fromARGB(255, 255, 146, 146),
                                  size: manageWidth(context, 25),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: manageHeight(context, 15),
                            left: manageWidth(context, 15),
                          ),
                          height: manageHeight(context, 40),
                          padding:
                              EdgeInsets.only(right: manageWidth(context, 15)),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade700,
                              width: 1.0,
                            ),
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 20)),
                          ),
                          child: Center(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: manageWidth(context, 15),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      sizes2.removeAt(index - 1);
                                    });
                                  },
                                  child: Icon(
                                    CupertinoIcons.clear,
                                    size: manageWidth(context, 17),
                                  ),
                                ),
                                SizedBox(
                                  width: manageWidth(context, 5),
                                ),
                                Text(
                                  sizes2[index - 1].size,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: manageWidth(context, 16.5),
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  width: manageWidth(context, 15),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (sizes2[index - 1].amount > 1) {
                                      setState(() {
                                        sizes2[index - 1].amount--;
                                      });
                                    } else {
                                      setState(() {
                                        sizes2.removeAt(index - 1);
                                      });
                                    }
                                  },
                                  child: Icon(
                                    CupertinoIcons.minus_circle,
                                    size: manageWidth(context, 17),
                                  ),
                                ),
                                SizedBox(
                                  width: manageWidth(context, 5),
                                ),
                                Text(
                                  sizes2[index - 1].amount.toString(),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: manageWidth(context, 14),
                                    color: Colors.grey.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  width: manageWidth(context, 5),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (sizes2[index - 1].amount < 999) {
                                      setState(() {
                                        sizes2[index - 1].amount++;
                                      });
                                    }
                                  },
                                  child: Icon(
                                    CupertinoIcons.add_circled,
                                    size: manageWidth(context, 17),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      SizedBox(
                        height: manageHeight(context, 10),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: manageWidth(context, 15),
                          ),
                          Checkbox(
                            value: sizes[index].isSelected,
                            onChanged: (newValue) {
                              setState(() {
                                sizes[index].isSelected = newValue!;
                              });
                            },
                          ),
                          SizedBox(
                            width: manageWidth(context, 25),
                          ),
                          ArticleSizeContainer(size: sizes[index].size.size),
                          Container(
                            margin:
                                EdgeInsets.only(left: manageWidth(context, 15)),
                            padding: EdgeInsets.symmetric(
                                horizontal: manageWidth(context, 15)),
                            width: manageWidth(context, 110),
                            height: manageHeight(context, 60),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 20)),
                            ),
                            child: Padding(
                              padding:
                                  EdgeInsets.all(manageWidth(context, 8.0)),
                              child: TextField(
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "quantité",
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    sizes[index].size.amount =
                                        int.tryParse(value) ?? 0;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: manageHeight(context, 25),
                      ),
                    ],
                  );
                },
              ),
            ),
            Consumer<ColorProvider>(
              builder: (context, value, child) {
                return GestureDetector(
                  onTap: () {
                    if (widget.groupSizeValue == 2) {
                      context
                          .read<ColorProvider>()
                          .addColorSize(widget.index, sizes2);
                    }
                    context.read<ColorProvider>().addColorSize(
                        widget.index,
                        sizes
                            .where((element) => element.isSelected)
                            .map((e) => ArticleSize(
                                size: e.size.size, amount: e.size.amount))
                            .toList());
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      top: manageHeight(context, 30),
                      bottom: manageHeight(context, 20),
                    ),
                    width: manageWidth(context, 200),
                    height: manageHeight(context, 50),
                    padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                    decoration: BoxDecoration(
                      color: AppColors.mainColor,
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 25)),
                    ),
                    child: Center(
                      child: Text(
                        "Ajouter",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
