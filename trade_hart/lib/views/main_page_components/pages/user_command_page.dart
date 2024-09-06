// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/model/command.dart';
import 'package:trade_hart/size_manager.dart';

import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/command_view.dart';

class UserCommandsPage extends StatefulWidget {
  const UserCommandsPage({super.key});

  @override
  UserCommandsPageState createState() => UserCommandsPageState();
}

class UserCommandsPageState extends State<UserCommandsPage> {
  String filter = "Toutes";
  int currentStep = 2;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Mes commandes", size: manageWidth(context, 19)),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          manageWidth(context, 8),
          manageHeight(context, 8),
          manageWidth(context, 8),
          manageHeight(context, 8),
        ),
        child: StreamBuilder(
            stream: filter == "Toutes"
                ? FirebaseFirestore.instance
                    .collection('Commands')
                    .where(
                      'buyer id',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .orderBy('time', descending: true)
                    .snapshots()
                : filter == "Annulée(s)"
                    ? FirebaseFirestore.instance
                        .collection('Commands')
                        .where(
                          'buyer id',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .where('status', isEqualTo: 'Annulé')
                        .orderBy('time', descending: true)
                        .snapshots()
                    : filter == "Signalée(s)"
                        ? FirebaseFirestore.instance
                            .collection('Commands')
                            .where(
                              'buyer id',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                            )
                            .where('status', isEqualTo: 'Signalé')
                            .orderBy('time', descending: true)
                            .snapshots()
                        : filter == "En cours de traitement"
                            ? FirebaseFirestore.instance
                                .collection('Commands')
                                .where(
                                  'buyer id',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid,
                                )
                                .where('status',
                                    isEqualTo: 'En cours de traitement')
                                .orderBy('time', descending: true)
                                .snapshots()
                            : filter == "En attente d'expédition"
                                ? FirebaseFirestore.instance
                                    .collection('Commands')
                                    .where(
                                      'buyer id',
                                      isEqualTo: FirebaseAuth
                                          .instance.currentUser!.uid,
                                    )
                                    .where('status',
                                        isEqualTo: "En attente d'expédition")
                                    .orderBy('time', descending: true)
                                    .snapshots()
                                : filter == "Expédiée(s)"
                                    ? FirebaseFirestore.instance
                                        .collection('Commands')
                                        .where(
                                          'buyer id',
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser!.uid,
                                        )
                                        .where('status', isEqualTo: "Expédié!")
                                        .orderBy('time', descending: true)
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('Commands')
                                        .where(
                                          'buyer id',
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser!.uid,
                                        )
                                        .where('status', isEqualTo: "Livré")
                                        .orderBy('time', descending: true)
                                        .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              var data = snapshot.data!.docs;
              if (data.isEmpty) {
                return Center(
                  child: AppBarTitleText(
                      title: "Aucune Commande", size: manageWidth(context, 18)),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 8),
                      ),
                      DropdownButton(
                        hint: Text(filter),
                        items: [
                          DropdownMenuItem(
                            child: Text("Toutes"),
                            value: "Toutes",
                          ),
                          DropdownMenuItem(
                            child: Text("En cours de traitement"),
                            value: "En cours de traitement",
                          ),
                          DropdownMenuItem(
                            child: Text("En attente d'expédition"),
                            value: "En attente d'expédition",
                          ),
                          DropdownMenuItem(
                            child: Text("Expédiée(s)"),
                            value: "Expédiée(s)",
                          ),
                          DropdownMenuItem(
                            child: Text("Annulée(s)"),
                            value: "Annulée(s)",
                          ),
                          DropdownMenuItem(
                            child: Text("Livrée(s)"),
                            value: "Livrée(s)",
                          ),
                          DropdownMenuItem(
                            child: Text("Signalée(s)"),
                            value: "Signalée(s)",
                          )
                        ],
                        onChanged: (value) {
                          setState(() {
                            filter = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView(
                      cacheExtent: 2800,
                      children: data.map((e) {
                        var commandData = e.data();
                        Command command = Command(
                            id: e.id,
                            amount: commandData["amount"],
                            articleId: commandData["article id"],
                            buyerId: commandData["buyer id"],
                            colorIndex: commandData["color index"],
                            sellerId: commandData["seller id"],
                            sizeIndex: commandData["size index"],
                            status: commandData["status"],
                            time: commandData["time"]);

                        return CommandView(command: command);
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: manageHeight(context, 5))
                ],
              );
            }),
      ),
    );
  }
}
