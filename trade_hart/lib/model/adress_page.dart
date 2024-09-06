import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/pages/adress_ading_page.dart';

class AdressPage extends StatefulWidget {
  const AdressPage({super.key});

  @override
  State<AdressPage> createState() => _AdressPageState();
}

class _AdressPageState extends State<AdressPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Adresse de livraison",
            style: GoogleFonts.poppins(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
              fontSize: manageWidth(context, 20),
            )),
      ),
      body: SafeArea(
          child: Column(
        children: [
          Expanded(
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        height: manageHeight(context, 0.1),
                      );
                    }
                    var userdata = snapshot.data!.data();

                    if (userdata!['adress'] == null) {
                      return SizedBox(
                        height: manageHeight(context, 0.1),
                      );
                    }
                    List adress = userdata['adress'];
                    return ListView(
                      children: adress
                          .map((e) => Row(
                                children: [
                                  SizedBox(
                                    width: manageWidth(context, 15),
                                  ),
                                  Text(
                                      '${e['adress']}, ${e['code postal']}, ${e['city']}',
                                      style: TextStyle(
                                        fontSize: manageWidth(context, 16),
                                        overflow: TextOverflow.ellipsis,
                                      )),
                                  const Spacer(),
                                  IconButton(
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('Users')
                                            .doc(FirebaseAuth
                                                .instance.currentUser!.uid)
                                            .update({
                                          'adress': FieldValue.arrayRemove([e])
                                        });
                                      },
                                      icon: Icon(
                                        CupertinoIcons.clear,
                                        color: Colors.grey,
                                        size: manageWidth(context, 15),
                                      ))
                                ],
                              ))
                          .toList(),
                    );
                  })),
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 10),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdressAddingPage()));
                  },
                  icon: const Icon(CupertinoIcons.add)),
              TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AdressAddingPage()));
                  },
                  child: Text(
                    "Ajouter une addresse",
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade800,
                        fontSize: manageWidth(context, 15),
                        fontWeight: FontWeight.w500),
                  )),
            ],
          )
        ],
      )),
    );
  }
}
