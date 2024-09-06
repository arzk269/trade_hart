// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/article_size.dart';
import 'package:trade_hart/model/article_size_data.dart';
import 'package:trade_hart/model/colors_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_container.dart';
import 'package:trade_hart/views/authentication_pages/widgets/size_selector.dart';

class NetworkColorAddPage extends StatefulWidget {
  final List<Image> images;
  final int groupSizeValue;
  NetworkColorAddPage(
      {super.key, required this.groupSizeValue, required this.images});

  @override
  State<NetworkColorAddPage> createState() => _NetworkColorAddPageState();
}

class _NetworkColorAddPageState extends State<NetworkColorAddPage> {
  TextEditingController colorController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  List<ArticleSizeRepresentation> commonSizes = [];
  List<ArticleSize> otherSizes = [];
  List<ArticleSize> commonSizesToAdd = [];
  int groupValue = 0;

  @override
  void initState() {
    if (widget.groupSizeValue == 0) {
      commonSizes = clotheSizes
          .map((e) => ArticleSizeRepresentation(
              size: ArticleSize(size: e, amount: 0), isSelected: false))
          .toList();
    }
    if (widget.groupSizeValue == 1) {
      commonSizes = shoeSizes
          .map((e) => ArticleSizeRepresentation(
              size: ArticleSize(size: e, amount: 0), isSelected: false))
          .toList();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitleText(title: "Ajouter une couleur", size: 19),
          leading: MainBackButton(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: manageHeight(context, 15)),
              Row(children: [
                Container(
                  margin: EdgeInsets.only(left: manageWidth(context, 15)),
                  padding: EdgeInsets.symmetric(
                      horizontal: manageWidth(context, 15)),
                  width: manageWidth(context, 160),
                  height: manageHeight(context, 60),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 20)),
                  ),
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          manageWidth(context, 8),
                          manageHeight(context, 8),
                          manageWidth(context, 8),
                          manageHeight(context, 8)),
                      child: TextField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "couleur",
                        ),
                        controller: colorController,
                      )),
                ),
                Spacer(),
                Container(
                  margin: EdgeInsets.only(right: manageWidth(context, 15)),
                  padding: EdgeInsets.symmetric(
                      horizontal: manageWidth(context, 15)),
                  width: manageWidth(context, 135),
                  height: manageHeight(context, 60),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 20)),
                  ),
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          manageWidth(context, 8),
                          manageHeight(context, 8),
                          manageWidth(context, 8),
                          manageHeight(context, 8)),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "quantité",
                        ),
                        controller: amountController,
                      )),
                ),
              ]),
              SizedBox(
                height: manageHeight(context, 15),
              ),
              Container(
                height: manageHeight(context, 460),
                margin: EdgeInsets.fromLTRB(manageWidth(context, 7.5),
                    manageHeight(context, 13), manageWidth(context, 7.5), 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                    width: manageWidth(context, 0.1),
                  ),
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: manageHeight(context, 1.5),
                      blurRadius: manageHeight(context, 5),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemBuilder: (contex, index) {
                    return Row(
                      children: [
                        SizedBox(
                            width: manageWidth(
                          context,
                          15,
                        )),
                        Radio(
                            value: index,
                            groupValue: groupValue,
                            onChanged: (value) {
                              setState(() {
                                groupValue = value!;
                              });
                            }),
                        SizedBox(
                            width: manageWidth(
                          context,
                          25,
                        )),
                        Container(
                          margin:
                              EdgeInsets.only(top: manageHeight(context, 30)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: manageHeight(
                                  context,
                                  3,
                                ),
                                blurRadius: manageHeight(context, 4),
                                offset: Offset(
                                    1, 2), // changement de position de l'ombre
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 10)),
                            child: Image.network(
                              widget.images[index].semanticLabel!,
                              width: manageWidth(
                                context,
                                70,
                              ),
                              height: manageHeight(context, 70),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  SizedBox(
                                      height: manageHeight(context, 150),
                                      width: manageWidth(context, 165),
                                      child: Column(
                                        children: [
                                          Icon(
                                            CupertinoIcons
                                                .exclamationmark_triangle_fill,
                                            size: manageWidth(context, 15),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      )),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  itemCount: widget.images.length,
                ),
              ),
              SizedBox(
                height: manageHeight(context, 15),
              ),
              Row(
                children: [
                  SizedBox(
                      width: manageWidth(
                    context,
                    15,
                  )),
                  AppBarTitleText(
                      title: "Tailles", size: manageWidth(context, 18))
                ],
              ),
              Row(
                children: [
                  SizeSelector(
                      sizeCategory: widget.groupSizeValue,
                      color: Color.fromARGB(255, 218, 137, 180)),
                ],
              ),
              Container(
                height: manageHeight(context, 470),
                margin: EdgeInsets.fromLTRB(manageWidth(context, 7.5),
                    manageHeight(context, 13), manageWidth(context, 7.5), 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.grey,
                    width: manageWidth(context, 0.1),
                  ),
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: manageHeight(context, 1.5),
                      blurRadius: manageHeight(context, 5),
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.groupSizeValue == 0 || widget.groupSizeValue == 1
                    ? ListView.builder(
                        itemCount: commonSizes.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              SizedBox(
                                height: manageHeight(context, 10),
                              ),
                              Row(children: [
                                SizedBox(
                                    width: manageWidth(
                                  context,
                                  15,
                                )),
                                Checkbox(
                                  value: commonSizes[index].isSelected,
                                  onChanged: (newValue) {
                                    setState(() {
                                      commonSizes[index].isSelected = newValue!;
                                    });
                                  },
                                ),
                                SizedBox(
                                    width: manageWidth(
                                  context,
                                  25,
                                )),
                                ArticleSizeContainer(
                                    size: commonSizes[index].size.size),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: manageWidth(context, 15)),
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  width: manageWidth(context, 110),
                                  height: manageHeight(context, 60),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                        manageHeight(context, 20)),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.fromLTRB(
                                          manageWidth(context, 8),
                                          manageHeight(context, 8),
                                          manageWidth(context, 8),
                                          manageHeight(context, 8)),
                                      child: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "quantité",
                                        ),
                                        onChanged: (value) {
                                          setState(() {
                                            commonSizes[index].size.amount =
                                                int.tryParse(value) ?? 0;
                                          });
                                        },
                                      )),
                                ),
                              ]),
                              SizedBox(
                                height: manageHeight(context, 25),
                              )
                            ],
                          );
                        },
                      )
                    : ListView.builder(
                        itemBuilder: (context, index) {
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
                                      top: manageHeight(context, 15)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: manageWidth(context, 15)),
                                  width: manageWidth(context, 110),
                                  height: manageHeight(context, 60),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                        manageHeight(context, 20)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        manageWidth(context, 8),
                                        manageHeight(context, 8),
                                        manageWidth(context, 8),
                                        manageHeight(context, 8)),
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
                                      top: manageHeight(context, 15)),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: manageWidth(context, 15)),
                                  width: manageWidth(context, 110),
                                  height: manageHeight(context, 60),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                        manageHeight(context, 20)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(
                                        manageWidth(context, 8),
                                        manageHeight(context, 8),
                                        manageWidth(context, 8),
                                        manageHeight(context, 8)),
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
                                        otherSizes.add(ArticleSize(
                                            size: sizeController.text,
                                            amount: int.tryParse(
                                                    amountController.text) ??
                                                0));
                                        amountController.clear();
                                        sizeController.clear();
                                      });
                                    }
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(
                                          left: manageWidth(context, 30),
                                          top: manageHeight(context, 15)),
                                      height: manageHeight(context, 40),
                                      width: manageWidth(
                                        context,
                                        40,
                                      ),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Color.fromARGB(255, 255, 146,
                                                146), // Couleur des bordures vertes
                                            width: manageWidth(context,
                                                1.0), // Épaisseur des bordures
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              manageHeight(context, 25))),
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Color.fromARGB(
                                              255, 255, 146, 146),
                                          size: manageWidth(context, 25),
                                        ),
                                      )),
                                ),
                              ],
                            );
                          }
                          return Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: manageHeight(context, 15),
                                    left: manageWidth(context, 15)),
                                height: manageHeight(context, 40),
                                padding: EdgeInsets.only(
                                    right: manageWidth(context, 15)),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey
                                          .shade700, // Couleur des bordures vertes
                                      width: manageWidth(context,
                                          1.0), // Épaisseur des bordures
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        manageHeight(context, 20))),
                                child: Center(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: manageWidth(
                                        context,
                                        15,
                                      )),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            otherSizes.removeAt(index - 1);
                                          });
                                        },
                                        child: Icon(
                                          CupertinoIcons.clear,
                                          size: manageWidth(context, 17),
                                        ),
                                      ),
                                      SizedBox(
                                          width: manageWidth(
                                        context,
                                        5,
                                      )),
                                      Text(
                                        otherSizes[index - 1].size,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: manageWidth(context, 16.5),
                                          color: Colors.grey.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(width: manageWidth(context, 15)),
                                      GestureDetector(
                                        onTap: () {
                                          if (otherSizes[index - 1].amount >
                                              1) {
                                            setState(() {
                                              otherSizes[index - 1].amount--;
                                            });
                                          } else {
                                            setState(() {
                                              otherSizes.removeAt(index - 1);
                                            });
                                          }
                                        },
                                        child: Icon(
                                          CupertinoIcons.minus_circle,
                                          size: manageWidth(context, 17),
                                        ),
                                      ),
                                      SizedBox(
                                          width: manageWidth(
                                        context,
                                        5,
                                      )),
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        otherSizes[index - 1].amount.toString(),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: manageWidth(context, 14),
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(
                                          width: manageWidth(
                                        context,
                                        5,
                                      )),
                                      GestureDetector(
                                        onTap: () {
                                          if (otherSizes[index - 1].amount <
                                              999) {
                                            setState(() {
                                              otherSizes[index - 1].amount++;
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
                              Spacer()
                            ],
                          );
                        },
                        itemCount:
                            otherSizes.isEmpty ? 1 : otherSizes.length + 1,
                      ),
              ),
              Consumer<ColorProvider>(
                builder: (context, value, child) {
                  return GestureDetector(
                    onTap: () {
                      if (amountController.text.isEmpty ||
                          colorController.text.isEmpty) {
                        var snackBar = SnackBar(
                          content: Text(
                            "Veuillez remplir tous les champs.",
                          ),
                          backgroundColor: Color.fromARGB(255, 223, 44, 44),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else if (widget.groupSizeValue == 0 ||
                          widget.groupSizeValue == 1) {
                        commonSizesToAdd = commonSizes
                            .where((element) => element.isSelected)
                            .map((e) {
                          if (e.size.amount == 0) {
                            e.size.amount++;
                          }
                          return ArticleSize(
                            size: e.size.size,
                            amount: e.size.amount,
                          );
                        }).toList();

                        value.networkAddColor(NetworkArticleColor(
                            color: colorController.text,
                            imageUrl: widget.images[groupValue].semanticLabel!,
                            amount: int.tryParse(amountController.text) ?? 0,
                            sizes: commonSizesToAdd
                                .map(
                                    (e) => {"amount": e.amount, "size": e.size})
                                .toList()));
                        Navigator.pop(context);
                      } else {
                        value.networkAddColor(NetworkArticleColor(
                            color: colorController.text,
                            imageUrl: widget.images[groupValue].semanticLabel!,
                            amount: int.tryParse(amountController.text) ?? 0,
                            sizes: otherSizes.map((e) {
                              if (e.amount == 0) {
                                e.amount++;
                              }
                              return {"amount": e.amount, "size": e.size};
                            }).toList()));
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                          top: manageHeight(context, 30),
                          bottom: manageHeight(context, 20)),
                      width: manageWidth(context, 200),
                      height: manageHeight(context, 50),
                      padding:
                          EdgeInsets.only(bottom: manageHeight(context, 2)),
                      decoration: BoxDecoration(
                          color: AppColors.mainColor,
                          borderRadius:
                              BorderRadius.circular(manageHeight(context, 25))),
                      child: Center(
                        child: Text("Ajouter",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: manageWidth(context, 16))),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
