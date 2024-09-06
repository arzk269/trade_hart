// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/crenau.dart';
import 'package:trade_hart/model/service_reservation_method_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';

class CrenauWithDayAdd extends StatefulWidget {
  final String day;
  const CrenauWithDayAdd({super.key, required this.day});

  @override
  State<CrenauWithDayAdd> createState() => _CrenauWithDayAddState();
}

class _CrenauWithDayAddState extends State<CrenauWithDayAdd> {
  TextEditingController capacityController = TextEditingController();
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            AppBarTitleText(title: widget.day, size: manageWidth(context, 18)),
      ),
      body: SingleChildScrollView(
        child: Consumer<ServiceReservationMethodProvider>(
          builder: (context, value, child) => Column(children: [
            Row(
              children: [
                SizedBox(
                  width: manageWidth(context, 10),
                ),
                AuthTextField(
                  controller: hourController,
                  hintText: "heure",
                  obscuretext: false,
                  keyboardType: TextInputType.number,
                  width: manageWidth(context, 90),
                ),
                SizedBox(
                  width: manageWidth(context, 7.5),
                ),
                Text(
                  ":",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: manageWidth(context, 18)),
                ),
                SizedBox(
                  width: manageWidth(context, 7.5),
                ),
                AuthTextField(
                  controller: minuteController,
                  hintText: "minutes",
                  obscuretext: false,
                  keyboardType: TextInputType.number,
                  width: manageWidth(context, 90),
                ),
                SizedBox(
                  width: manageWidth(context, 20),
                ),
                AuthTextField(
                  controller: capacityController,
                  hintText: "places",
                  obscuretext: false,
                  keyboardType: TextInputType.number,
                  width: manageWidth(context, 110),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 15),
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    if (hourController.text.isNotEmpty &&
                        minuteController.text.isNotEmpty &&
                        capacityController.text.isNotEmpty) {
                      value.addCrenau(
                          widget.day,
                          Crenau(
                              heure: hourController.text,
                              minutes: minuteController.text,
                              nombreDePlace:
                                  int.tryParse(capacityController.text) ?? 0));

                      hourController.clear();
                      minuteController.clear();
                      capacityController.clear();
                    } else {
                      var snackBar = SnackBar(
                          content: Text("Remplissez tous les champs"),
                          backgroundColor: Colors.red);
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: manageWidth(context, 10)),
                    padding: EdgeInsets.only(left: manageWidth(context, 22.5)),
                    height: manageHeight(context, 40),
                    width: manageWidth(context, 125),
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 255, 146,
                              146), // Couleur des bordures vertes
                          width: manageWidth(
                              context, 1.0), // Épaisseur des bordures
                        ),
                        borderRadius:
                            BorderRadius.circular(manageHeight(context, 15))),
                    child: Row(
                      children: [
                        Text("Ajouter",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              fontSize: manageWidth(context, 16),
                              color: Color.fromARGB(255, 255, 146, 146),
                            )),
                        SizedBox(
                            width: manageWidth(
                          context,
                          5,
                        )),
                        Icon(
                          Icons.add,
                          color: Color.fromARGB(255, 255, 146, 146),
                          size: manageWidth(context, 18),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 10),
            ),
            Container(
              height: manageHeight(context, 480),
              width: manageWidth(context, 460) * 0.75,
              margin: EdgeInsets.fromLTRB(manageWidth(context, 7.5),
                  manageHeight(context, 13), manageWidth(context, 7.5), 0),
              padding: EdgeInsets.only(top: manageHeight(context, 15)),
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
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: value.daysWithCrenau
                      .firstWhere(
                        (element) => element.day == widget.day,
                      )
                      .crenaux
                      .isEmpty
                  ? Center(
                      child: AppBarTitleText(
                          title: "Aucun Crénau ajouté",
                          size: manageWidth(context, 18)),
                    )
                  : ListView(
                      children: value.daysWithCrenau
                          .firstWhere((element) => element.day == widget.day)
                          .crenaux
                          .map((e) => Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: manageWidth(context, 10),
                                        bottom: manageHeight(context, 20)),
                                    padding: EdgeInsets.only(
                                        left: manageWidth(context, 22.5)),
                                    height: manageHeight(context, 100),
                                    width: manageWidth(context, 326),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          manageHeight(context, 40)),
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: manageWidth(context, 1.0),
                                      ), // Couleur des bordures vertes
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: manageWidth(context, 10),
                                            ),
                                            Text(
                                                "Heure :  ${e.heure} h ${e.minutes}",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      manageWidth(context, 16),
                                                )),
                                            SizedBox(
                                                width: manageWidth(
                                              context,
                                              5,
                                            )),
                                            IconButton(
                                                onPressed: () {
                                                  value.remouveCrenau(
                                                      widget.day,
                                                      e.heure,
                                                      e.minutes,
                                                      e.nombreDePlace);
                                                },
                                                icon: Icon(
                                                  CupertinoIcons.trash,
                                                  color: Color.fromARGB(
                                                      255, 255, 146, 146),
                                                ))
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: manageWidth(context, 10),
                                            ),
                                            Text("Nombre de palce : ",
                                                style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize:
                                                      manageWidth(context, 16),
                                                )),
                                            SizedBox(
                                                width: manageWidth(
                                              context,
                                              5,
                                            )),
                                            IconButton(
                                                onPressed: () {
                                                  if (e.nombreDePlace > 1) {
                                                    value.reducePlace(
                                                        widget.day,
                                                        e.heure,
                                                        e.minutes);
                                                  }
                                                },
                                                icon: Icon(CupertinoIcons
                                                    .minus_circled)),
                                            SizedBox(
                                                width: manageWidth(
                                              context,
                                              5,
                                            )),
                                            Text(
                                              e.nombreDePlace.toString(),
                                              style: TextStyle(
                                                  fontSize:
                                                      manageWidth(context, 16),
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                                width: manageWidth(
                                              context,
                                              5,
                                            )),
                                            IconButton(
                                                onPressed: () {
                                                  if (e.nombreDePlace < 99) {
                                                    value.addPlace(widget.day,
                                                        e.heure, e.minutes);
                                                  }
                                                },
                                                icon: Icon(CupertinoIcons
                                                    .add_circled)),
                                            SizedBox(
                                                width: manageWidth(
                                              context,
                                              5,
                                            )),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ))
                          .toList(),
                    ),
            )
          ]),
        ),
      ),
    );
  }
}
