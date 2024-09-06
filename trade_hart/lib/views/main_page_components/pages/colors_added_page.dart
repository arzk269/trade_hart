import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/color_selection.dart';
import 'package:trade_hart/model/colors_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';

class ColorsAddedPage extends StatefulWidget {
  final int categorie;
  final String size;
  const ColorsAddedPage(
      {super.key, required this.categorie, required this.size});

  @override
  State<ColorsAddedPage> createState() => _ColorsAddedPageState();
}

class _ColorsAddedPageState extends State<ColorsAddedPage> {
  List<ColorSelection> colors = [];
  @override
  void initState() {
    colors = context.read<ColorProvider>().articleColors.map((color) {
      color.amount = 0;
      return ColorSelection(color: color, isSelected: false);
    }).toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitleText(
              title: "Ajouter des couleur", size: manageWidth(context, 17)),
          leading: const MainBackButton(),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                  height: manageHeight(context, 550),
                  margin: EdgeInsets.fromLTRB(manageWidth(context, 7.5),
                      manageHeight(context, 13), manageWidth(context, 7.5), 0),
                  padding: EdgeInsets.only(
                      top: manageHeight(context, 10),
                      bottom: manageHeight(context, 10)),
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
                    itemCount: colors.length,
                    itemBuilder: (contex, index) {
                      return Column(
                        children: [
                          Row(children: [
                            SizedBox(
                              width: manageWidth(context, 15),
                            ),
                            Checkbox(
                                value: colors[index].isSelected,
                                onChanged: (newValue) {
                                  setState(() {
                                    colors[index].isSelected = newValue!;
                                  });
                                  for (var color in colors) {
                                    print(color.isSelected);
                                  }
                                }),
                            SizedBox(
                              width: manageWidth(context, 25),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                right: manageWidth(context, 20),
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    manageHeight(context, 10)),
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
                                  colors[index].color.imageFile,
                                  width: manageWidth(
                                    context,
                                    70,
                                  ),
                                  height: manageHeight(context, 70),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: manageWidth(context, 15)),
                                width: manageWidth(context, 110),
                                height: manageHeight(
                                  context,
                                  60,
                                ),
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(
                                        manageHeight(context, 20))),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      manageWidth(context, 8),
                                      manageHeight(context, 8),
                                      manageWidth(context, 8),
                                      manageHeight(context, 8)),
                                  child: TextField(
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "quantité",
                                    ),
                                    onChanged: (value) {
                                      if (colors[index].isSelected) {}
                                      setState(() {
                                        colors[index].color.amount =
                                            int.tryParse(value) ?? 0;
                                      });

                                      for (var color in colors) {
                                        print(color.color.amount);
                                      }
                                    },
                                  ),
                                ))
                          ]),
                          SizedBox(
                            height: manageHeight(context, 25),
                          )
                        ],
                      );
                    },
                  )),
              GestureDetector(
                onTap: () {},
                child: Container(
                  margin: EdgeInsets.only(top: manageHeight(context, 15)),
                  width: manageWidth(context, 200),
                  height: manageHeight(
                    context,
                    50,
                  ),
                  padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
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
              )
            ],
          ),
        ));
  }
}
