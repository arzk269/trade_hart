import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/service_reservation_method_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/main_page_components/pages/crenau_with_day_add_page.dart';

class CrenauAddPage extends StatefulWidget {
  const CrenauAddPage({super.key});

  @override
  State<CrenauAddPage> createState() => _CrenauAddPageState();
}

class _CrenauAddPageState extends State<CrenauAddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: AppBarTitleText(
              title: "Ajouter des crénaux", size: manageWidth(context, 18))),
      body: Column(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Consumer<ServiceReservationMethodProvider>(
                  builder: (context, value, child) {
                    return Container(
                      height: manageHeight(context, 620),
                      width: manageWidth(context, 460) * 0.75,
                      margin: EdgeInsets.fromLTRB(
                          manageWidth(context, 7.5),
                          manageHeight(context, 13),
                          manageWidth(
                            context,
                            7.5,
                          ),
                          0),
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
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView(
                        children: value.daysWithCrenau
                            .map((dayWithCrenau) => Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                            width: manageWidth(
                                          context,
                                          10,
                                        )),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return CrenauWithDayAdd(
                                                  day: dayWithCrenau.day);
                                            }));
                                          },
                                          child: Container(
                                            width: manageWidth(context, 135),
                                            height: manageHeight(
                                              context,
                                              40,
                                            ),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                      255,
                                                      218,
                                                      137,
                                                      180), // Couleur des bordures vertes
                                                  width:
                                                      manageWidth(context, 1.0),
                                                  // Épaisseur des bordures
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        manageHeight(
                                                            context, 20))),
                                            child: Center(
                                                child: Text(
                                              dayWithCrenau.day,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w400,
                                                fontSize:
                                                    manageWidth(context, 16.5),
                                                color: const Color.fromARGB(
                                                    255, 218, 137, 180),
                                              ),
                                            )),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: value.daysWithCrenau
                                              .firstWhere((element) =>
                                                  element.day ==
                                                  dayWithCrenau.day)
                                              .crenaux
                                              .isEmpty
                                          ? manageHeight(context, 30)
                                          : manageHeight(context, 10),
                                    ),
                                    SizedBox(
                                      height: value.daysWithCrenau
                                              .firstWhere((element) =>
                                                  element.day ==
                                                  dayWithCrenau.day)
                                              .crenaux
                                              .isEmpty
                                          ? 0.5
                                          : manageHeight(context, 120),
                                      child:
                                          value.daysWithCrenau
                                                  .firstWhere((element) =>
                                                      element.day ==
                                                      dayWithCrenau.day)
                                                  .crenaux
                                                  .isEmpty
                                              ? SizedBox(
                                                  height: manageHeight(
                                                      context, 0.2))
                                              : ListView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  children: value.daysWithCrenau
                                                      .firstWhere((element) =>
                                                          element.day ==
                                                          dayWithCrenau.day)
                                                      .crenaux
                                                      .map((e) => Row(
                                                            children: [
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    left: manageWidth(
                                                                        context,
                                                                        10),
                                                                    bottom: manageHeight(
                                                                        context,
                                                                        10)),
                                                                padding: EdgeInsets.only(
                                                                    left: manageWidth(
                                                                        context,
                                                                        22.5)),
                                                                height:
                                                                    manageHeight(
                                                                        context,
                                                                        100),
                                                                width:
                                                                    manageWidth(
                                                                        context,
                                                                        326),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(
                                                                      manageHeight(
                                                                          context,
                                                                          40)),
                                                                  border: Border
                                                                      .all(
                                                                    color: Colors
                                                                        .grey,
                                                                    width: manageWidth(
                                                                        context,
                                                                        1.0),
                                                                  ), // Couleur des bordures vertes
                                                                ),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width: manageWidth(
                                                                              context,
                                                                              10),
                                                                        ),
                                                                        Text(
                                                                            "Heure :  ${e.heure} h ${e.minutes}",
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: manageWidth(context, 16),
                                                                            )),
                                                                        SizedBox(
                                                                          width: manageWidth(
                                                                              context,
                                                                              5),
                                                                        ),
                                                                        IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              value.remouveCrenau(dayWithCrenau.day, e.heure, e.minutes, e.nombreDePlace);
                                                                            },
                                                                            icon:
                                                                                const Icon(
                                                                              CupertinoIcons.trash,
                                                                              color: Color.fromARGB(255, 255, 146, 146),
                                                                            ))
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        SizedBox(
                                                                          width: manageWidth(
                                                                              context,
                                                                              10),
                                                                        ),
                                                                        Text(
                                                                            "Nombre de palce : ",
                                                                            style:
                                                                                GoogleFonts.poppins(
                                                                              fontWeight: FontWeight.w500,
                                                                              fontSize: manageWidth(context, 16),
                                                                            )),
                                                                        SizedBox(
                                                                          width: manageWidth(
                                                                              context,
                                                                              5),
                                                                        ),
                                                                        IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              if (e.nombreDePlace > 1) {
                                                                                value.reducePlace(dayWithCrenau.day, e.heure, e.minutes);
                                                                              }
                                                                            },
                                                                            icon:
                                                                                const Icon(CupertinoIcons.minus_circled)),
                                                                        SizedBox(
                                                                          width: manageWidth(
                                                                              context,
                                                                              5),
                                                                        ),
                                                                        Text(
                                                                          e.nombreDePlace
                                                                              .toString(),
                                                                          style: TextStyle(
                                                                              fontSize: manageWidth(context, 16),
                                                                              fontWeight: FontWeight.w500),
                                                                        ),
                                                                        SizedBox(
                                                                          width: manageWidth(
                                                                              context,
                                                                              5),
                                                                        ),
                                                                        IconButton(
                                                                            onPressed:
                                                                                () {
                                                                              if (e.nombreDePlace < 99) {
                                                                                value.addPlace(dayWithCrenau.day, e.heure, e.minutes);
                                                                              }
                                                                            },
                                                                            icon:
                                                                                const Icon(CupertinoIcons.add_circled)),
                                                                        SizedBox(
                                                                          width: manageWidth(
                                                                              context,
                                                                              5),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ))
                                                      .toList(),
                                                ),
                                    ),
                                  ],
                                ))
                            .toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
