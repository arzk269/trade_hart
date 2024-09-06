import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/model/adress.dart';
import 'package:trade_hart/model/command.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/seller_command_view.dart';

class SellerCommandPage extends StatefulWidget {
  const SellerCommandPage({super.key});

  @override
  State<SellerCommandPage> createState() => _SellerCommandPageState();
}

class _SellerCommandPageState extends State<SellerCommandPage> {
  String filter = "Toutes";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
            title: "Mes commandes", size: manageWidth(context, 19)),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          manageWidth(context, 8.0),
          manageHeight(context, 8.0),
          manageWidth(context, 8.0),
          manageHeight(context, 8.0),
        ),
        child: StreamBuilder(
            stream: filter == "Toutes"
                ? FirebaseFirestore.instance
                    .collection('Commands')
                    .where(
                      'seller id',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                    )
                    .orderBy('time', descending: true)
                    .snapshots()
                : filter == "Signalée(s)"
                    ? FirebaseFirestore.instance
                        .collection('Commands')
                        .where(
                          'seller id',
                          isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                        )
                        .where('status', isEqualTo: 'Signalé')
                        .orderBy('time', descending: true)
                        .snapshots()
                    : filter == "Annulée(s)"
                        ? FirebaseFirestore.instance
                            .collection('Commands')
                            .where(
                              'seller id',
                              isEqualTo: FirebaseAuth.instance.currentUser!.uid,
                            )
                            .where('status', isEqualTo: 'Annulé')
                            .orderBy('time', descending: true)
                            .snapshots()
                        : filter == "En cours de traitement"
                            ? FirebaseFirestore.instance
                                .collection('Commands')
                                .where(
                                  'seller id',
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
                                      'seller id',
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
                                          'seller id',
                                          isEqualTo: FirebaseAuth
                                              .instance.currentUser!.uid,
                                        )
                                        .where('status', isEqualTo: "Expédié!")
                                        .orderBy('time', descending: true)
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('Commands')
                                        .where(
                                          'seller id',
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
                      title: "Aucune Commande", size: manageWidth(context, 19)),
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
                            time: commandData["time"],
                            adress: Adress(
                                adress: commandData["buyer adress"]["adress"],
                                city: commandData["buyer adress"]["city"],
                                codePostal: commandData["buyer adress"]
                                    ["code postal"]));

                        return SellerCommandView(command: command);
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: manageHeight(context, 5),
                  )
                ],
              );
            }),
      ),
    );
  }
}
