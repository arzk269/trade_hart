import 'dart:io';
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

class AddedImagesPage extends StatefulWidget {
  final String color;
  final List<File> articlesImages;
  final int amount;
  const AddedImagesPage(
      {super.key,
      required this.articlesImages,
      required this.color,
      required this.amount});

  @override
  State<AddedImagesPage> createState() => _AddedImagesPageState();
}

class _AddedImagesPageState extends State<AddedImagesPage> {
  List<ArticleSizeRepresentation> sizes0 = [];
  List<ArticleSizeRepresentation> sizes1 = [];
  List<ArticleSize> sizes2 = [];
  int groupValue = 0;
  int groupSizeValue = 0;
  List<ArticleSize> sizes = [];

  @override
  void initState() {
    sizes0 = clotheSizes
        .map((size) => ArticleSizeRepresentation(
              size: ArticleSize(
                size: size,
                amount: 0,
              ),
              isSelected: false,
            ))
        .toList();
    sizes1 = shoeSizes
        .map((size) => ArticleSizeRepresentation(
            size: ArticleSize(
              size: size,
              amount: 0,
            ),
            isSelected: false))
        .toList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitleText(
              title: "Ajouter une image", size: manageWidth(context, 17)),
          leading: const MainBackButton(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
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
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListView.builder(
                  itemBuilder: (contex, index) {
                    return Row(
                      children: [
                        SizedBox(
                          width: manageWidth(context, 15),
                        ),
                        Radio(
                            value: index,
                            groupValue: groupValue,
                            onChanged: (value) {
                              setState(() {
                                groupValue = value!;
                              });
                            }),
                        SizedBox(
                          width: manageWidth(context, 25),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(top: manageHeight(context, 30)),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 10)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: manageHeight(context, 3),
                                blurRadius: manageHeight(context, 4),
                                offset: const Offset(
                                    1, 2), // changement de position de l'ombre
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 10)),
                            child: Image.file(
                              widget.articlesImages[index],
                              width: manageWidth(context, 70),
                              height: manageHeight(context, 70),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  itemCount: widget.articlesImages.length,
                ),
              ),
              SizedBox(
                height: manageHeight(context, 10),
              ),
              SizedBox(
                height: manageHeight(context, 60),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (sizes1.any((element) => element.isSelected)) {
                          var snackBar = const SnackBar(
                            content: Text(
                              "Impossible d'ajouter des tailles vetement alors que des tailles chaussure ou autre sont selectionnées",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else if (sizes1
                                .any((element) => element.size.amount > 0) ||
                            sizes2.isNotEmpty) {
                          var snackBar = const SnackBar(
                            content: Text(
                              "Pour continuer cette action, aucune taille de type chaussure ou autre ne doit avoir une quantité non nulle.",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          setState(() {
                            for (var size in sizes1) {
                              size.size.amount = 0;
                            }
                            groupSizeValue = 0;
                          });
                        }
                      },
                      child: SizeSelector(
                          sizeCategory: 0,
                          color: groupSizeValue == 0
                              ? const Color.fromARGB(255, 218, 137, 180)
                              : Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (sizes0.any((element) => element.isSelected)) {
                          var snackBar = const SnackBar(
                            content: Text(
                              "Impossible d'ajouter des tailles chaussure alors que des tailles vetement sont selectionnées",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else if (sizes0
                                .any((element) => element.size.amount > 0) ||
                            sizes2.isNotEmpty) {
                          var snackBar = const SnackBar(
                            content: Text(
                              "Pour continuer cette action, aucune taille de type vetement ou autre ne doit avoir une quantité non nulle.",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          setState(() {
                            for (var size in sizes0) {
                              size.size.amount = 0;
                            }
                            groupSizeValue = 1;
                          });
                        }
                      },
                      child: SizeSelector(
                          sizeCategory: 1,
                          color: groupSizeValue == 1
                              ? const Color.fromARGB(255, 218, 137, 180)
                              : Colors.grey.shade700),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (sizes0.any((element) => element.isSelected) ||
                            sizes1.any((element) => element.isSelected)) {
                          var snackBar = const SnackBar(
                            content: Text(
                              "Pour effectuer cette action aucune taille de type vetement ou chaussure ne doit etre selectionnée.",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else if (sizes0
                                .any((element) => element.size.amount > 0) ||
                            sizes1.any((element) => element.size.amount > 0)) {
                          var snackBar = const SnackBar(
                            content: Text(
                              "Pour continuer cette action, aucune taille de type vetement ou chaussure ne doit avoir une quantité non nulle.",
                            ),
                            backgroundColor: Color.fromARGB(255, 223, 44, 44),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        } else {
                          setState(() {
                            groupSizeValue = 2;
                          });
                        }
                      },
                      child: SizeSelector(
                          sizeCategory: 2,
                          color: groupSizeValue == 2
                              ? const Color.fromARGB(255, 218, 137, 180)
                              : Colors.grey.shade700),
                    ),
                  ],
                ),
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
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: manageHeight(context, 1.5),
                      blurRadius: manageHeight(context, 5),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: groupSizeValue == 0 || groupSizeValue == 1
                    ? ListView.builder(
                        itemCount:
                            groupSizeValue == 0 ? sizes0.length : sizes1.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              SizedBox(
                                height: manageHeight(context, 10),
                              ),
                              Row(children: [
                                SizedBox(
                                  width: manageWidth(context, 15),
                                ),
                                Checkbox(
                                  value: groupSizeValue == 0
                                      ? sizes0[index].isSelected
                                      : sizes1[index].isSelected,
                                  onChanged: (newValue) {
                                    setState(() {
                                      if (groupSizeValue == 0) {
                                        sizes0[index].isSelected = newValue!;
                                      }
                                      if (groupSizeValue == 1) {
                                        sizes1[index].isSelected = newValue!;
                                      }
                                    });
                                  },
                                ),
                                SizedBox(
                                  width: manageWidth(context, 25),
                                ),
                                ArticleSizeContainer(
                                    size: groupSizeValue == 0
                                        ? sizes0[index].size.size
                                        : sizes1[index].size.size),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: manageWidth(context, 15)),
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
                                    child: groupSizeValue == 0
                                        ? TextField(
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "quantité",
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                sizes0[index].size.amount =
                                                    int.tryParse(value) ?? 0;
                                              });

                                              // Afficher les tailles et les quantités pour le débogage

                                              if (groupSizeValue == 0) {
                                                for (var size in sizes0) {
                                                  print(
                                                      "${size.size.size} \t ${size.size.amount}");
                                                }
                                              }
                                            },
                                          )
                                        : TextField(
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "quantité",
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                sizes1[index].size.amount =
                                                    int.tryParse(value) ?? 0;
                                              });

                                              // Afficher les tailles et les quantités pour le débogage

                                              if (groupSizeValue == 1) {
                                                for (var size in sizes1) {
                                                  print(
                                                      "${size.size.size} \t ${size.size.amount}");
                                                }
                                              }
                                            },
                                          ),
                                  ),
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
                                      decoration: const InputDecoration(
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
                                      decoration: const InputDecoration(
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
                                          top: manageHeight(context, 10)),
                                      height: manageHeight(context, 40),
                                      width: manageWidth(context, 40),
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
                                              manageHeight(context, 25))),
                                      child: Center(
                                        child: Icon(
                                          Icons.add,
                                          color: const Color.fromARGB(
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
                                          width: manageWidth(
                                        context,
                                        5,
                                      )),
                                      Text(
                                        sizes2[index - 1].size,
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
                                          width: manageWidth(
                                        context,
                                        5,
                                      )),
                                      Text(
                                        overflow: TextOverflow.ellipsis,
                                        sizes2[index - 1].amount.toString(),
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
                              const Spacer()
                            ],
                          );
                        },
                        itemCount: sizes2.isEmpty ? 1 : sizes2.length + 1,
                      ),
              ),
              Consumer<ColorProvider>(
                builder: (context, value, child) {
                  return GestureDetector(
                    onTap: () {
                      if (groupSizeValue == 0) {
                        sizes = sizes0
                            .where((element) => element.isSelected)
                            .map((e) => ArticleSize(
                                  size: e.size.size,
                                  amount: e.size.amount,
                                ))
                            .toList();
                      }

                      if (groupSizeValue == 1) {
                        sizes = sizes1
                            .where((element) => element.isSelected)
                            .map((e) => ArticleSize(
                                  size: e.size.size,
                                  amount: e.size.amount,
                                ))
                            .toList();
                      }

                      if (sizes.isNotEmpty) {
                        context.read<ColorProvider>().addColor(ArticleColor(
                            articleGroupSizeValue: groupSizeValue,
                            color: widget.color,
                            imageFile: widget.articlesImages[groupValue],
                            amount: widget.amount,
                            sizes: sizes));
                        for (var element
                            in context.read<ColorProvider>().articleColors) {
                          print(element.color);
                          for (var size in element.sizes) {
                            print("${size.size} \t ${size.amount}");
                          }
                        }
                      } else if (sizes2.isNotEmpty) {
                        context.read<ColorProvider>().addColor(ArticleColor(
                            articleGroupSizeValue: groupSizeValue,
                            color: widget.color,
                            imageFile: widget.articlesImages[groupValue],
                            amount: widget.amount,
                            sizes: sizes2));
                      }
                      Navigator.pop(context);
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
