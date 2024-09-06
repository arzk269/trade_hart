import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/colors_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/pages/article_added_images.dart';
import 'package:trade_hart/views/main_page_components/pages/size_add_page.dart';

class AddColorToArticlePage extends StatefulWidget {
  final List<File> articleImages;
  const AddColorToArticlePage({super.key, required this.articleImages});

  @override
  State<AddColorToArticlePage> createState() => _AddColorToArticlePageState();
}

class _AddColorToArticlePageState extends State<AddColorToArticlePage> {
  TextEditingController colorController = TextEditingController();
  TextEditingController colorAmountController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Ajouter une couleur", size: manageWidth(context, 17)),
        leading: const MainBackButton(),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AuthTextField(
                controller: colorController,
                hintText: 'couleur',
                obscuretext: false),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            AuthTextField(
              controller: colorAmountController,
              hintText: 'quantité',
              obscuretext: false,
              keyboardType: TextInputType.number,
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Center(
              child: Text(
                "Ajouter une image",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: manageWidth(context, 15.5)),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  if (colorController.text.isNotEmpty ||
                      colorAmountController.text.isNotEmpty) {
                    int amount = int.parse(colorAmountController.text);
                    String color = colorController.text;

                    setState(() {
                      colorController.clear();
                      colorAmountController.clear();
                    });

                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AddedImagesPage(
                        color: color,
                        articlesImages: widget.articleImages,
                        amount: amount,
                      );
                    }));
                  } else {
                    const snackBar = SnackBar(
                      content: Text(
                        "remplissez les deux champs",
                      ),
                      backgroundColor: Color.fromARGB(255, 223, 44, 44),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  radius: manageHeight(context, 30),
                  child: Icon(
                    CupertinoIcons.camera,
                    size: manageWidth(context, 25),
                  ),
                ),
              ),
            ),
            Consumer<ColorProvider>(
              builder: (context, value, child) {
                return Container(
                  height: manageHeight(context, 500),
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
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (contex, index) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    top: manageHeight(context, 30),
                                    left: manageWidth(context, 15)),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: manageHeight(context, 3),
                                      blurRadius: manageHeight(context, 4),
                                      offset: const Offset(1,
                                          2), // changement de position de l'ombre
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      manageHeight(context, 10)),
                                  child: Image.file(
                                    value.articleColors
                                        .toList()[index]
                                        .imageFile,
                                    width: manageWidth(context, 70),
                                    height: manageHeight(context, 70),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: manageWidth(context, 30),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: manageHeight(context, 25),
                                  ),
                                  Text(
                                      "Couleur : ${value.articleColors.toList()[index].color}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: manageWidth(context, 15.5),
                                        color: Colors.grey.shade800,
                                      )),
                                  SizedBox(height: manageHeight(context, 12.5)),
                                  Text(
                                      "Quantité : ${value.articleColors.toList()[index].amount}",
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w500,
                                        fontSize: manageWidth(context, 15.5),
                                        color: Colors.grey.shade800,
                                      )),
                                ],
                              ),
                              const Spacer(),
                              Column(
                                children: [
                                  SizedBox(
                                    height: manageHeight(context, 25),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      contex.read<ColorProvider>().removeColor(
                                          value.articleColors.toList()[index]);
                                    },
                                    child: Icon(
                                      CupertinoIcons.trash,
                                      color: const Color.fromARGB(
                                          255, 206, 86, 86),
                                      size: manageWidth(context, 20),
                                    ),
                                  ),
                                  SizedBox(
                                    height: manageHeight(context, 12.5),
                                  ),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          context.read<ColorProvider>().minus(
                                              value.articleColors
                                                  .toList()[index]);
                                        },
                                        child: Icon(
                                          CupertinoIcons.minus_circled,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      SizedBox(
                                        width: manageWidth(context, 2),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          context.read<ColorProvider>().add(
                                              value.articleColors
                                                  .toList()[index]);
                                        },
                                        child: Icon(
                                          CupertinoIcons.add_circled,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: manageWidth(context, 15),
                              )
                            ],
                          ),
                          SizedBox(
                            height: manageHeight(context, 10),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: manageWidth(context, 15),
                              ),
                              Text(
                                "Tailles",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: manageWidth(context, 16.5),
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SizeAddPage(
                                                index: index,
                                                groupSizeValue: value
                                                    .articleColors
                                                    .toList()[index]
                                                    .articleGroupSizeValue,
                                              )));
                                  print(value.articleColors
                                      .toList()[index]
                                      .articleGroupSizeValue);
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: manageWidth(context, 10)),
                                  padding: EdgeInsets.only(
                                    left: manageWidth(context, 12),
                                  ),
                                  height: manageHeight(context, 35),
                                  width: manageWidth(context, 165),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color.fromARGB(
                                            255,
                                            255,
                                            146,
                                            146), // Couleur des bordures vertes
                                        width: manageWidth(context,
                                            1.0), // Épaisseur des bordures
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          manageHeight(context, 15))),
                                  child: Row(
                                    children: [
                                      Text("Ajouter une taille",
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w400,
                                            fontSize: manageWidth(context, 14),
                                            color: const Color.fromARGB(
                                                255, 255, 146, 146),
                                          )),
                                      SizedBox(
                                        width: manageWidth(context, 5),
                                      ),
                                      Icon(
                                        Icons.add,
                                        color: const Color.fromARGB(
                                            255, 255, 146, 146),
                                        size: manageWidth(context, 16),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: manageWidth(context, 5),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: manageHeight(context, 65),
                                width: MediaQuery.of(context).size.width * 0.95,
                                child: value.articleColors
                                        .toList()[index]
                                        .sizes
                                        .isEmpty
                                    ? Row(
                                        children: [
                                          SizedBox(
                                            width: manageWidth(context, 15),
                                          ),
                                          Text(
                                            "Taille unique",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize:
                                                  manageWidth(context, 14),
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      )
                                    : ListView.builder(
                                        shrinkWrap: true,
                                        itemBuilder: (context, index2) {
                                          return Row(
                                            children: [
                                              SizedBox(
                                                width: manageWidth(context, 15),
                                              ),
                                              Container(
                                                height:
                                                    manageHeight(context, 40),
                                                padding: const EdgeInsets.only(
                                                    right: 15),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey
                                                          .shade700, // Couleur des bordures vertes
                                                      width: manageWidth(
                                                          context,
                                                          1.0), // Épaisseur des bordures
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            manageHeight(
                                                                context, 20))),
                                                child: Center(
                                                  child: Row(
                                                    children: [
                                                      SizedBox(
                                                        width: manageWidth(
                                                            context, 7.5),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          value.deleteSize(
                                                              index, index2);
                                                        },
                                                        child: Icon(
                                                          CupertinoIcons.clear,
                                                          size: manageWidth(
                                                              context, 17),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: manageWidth(
                                                            context, 5),
                                                      ),
                                                      Text(
                                                        value.articleColors
                                                            .toList()[index]
                                                            .sizes[index2]
                                                            .size,
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: manageWidth(
                                                              context, 16.5),
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(
                                                          width: manageWidth(
                                                              context, 15)),
                                                      GestureDetector(
                                                        onTap: () {
                                                          value.minusSize(
                                                              value.articleColors
                                                                      .toList()[
                                                                  index],
                                                              index2);
                                                        },
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .minus_circle,
                                                          size: manageWidth(
                                                              context, 17),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: manageWidth(
                                                            context, 5),
                                                      ),
                                                      Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        value.articleColors
                                                            .toList()[index]
                                                            .sizes[index2]
                                                            .amount
                                                            .toString(),
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: manageWidth(
                                                              context, 14),
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: manageWidth(
                                                            context, 5),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () {
                                                          value.addSize(
                                                              value.articleColors
                                                                      .toList()[
                                                                  index],
                                                              index2);
                                                        },
                                                        child: Icon(
                                                          CupertinoIcons
                                                              .add_circled,
                                                          size: manageWidth(
                                                              context, 17),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                        itemCount: value.articleColors
                                            .toList()[index]
                                            .sizes
                                            .length,
                                        scrollDirection: Axis.horizontal,
                                      ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: manageHeight(context, 10),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: manageWidth(context, 7.5)),
                            height: manageHeight(context, 1.7),
                            color: Colors.grey.withOpacity(0.4),
                          )
                        ],
                      );
                    },
                    itemCount: value.articleColors.length,
                  ),
                );
              },
            ),
            SizedBox(
              height: manageHeight(context, 30),
            ),
          ],
        ),
      ),
    );
  }
}
