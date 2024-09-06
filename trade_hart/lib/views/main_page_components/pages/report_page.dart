import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';

class ReportPage extends StatefulWidget {
  final String memberId;
  const ReportPage({super.key, required this.memberId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  TextEditingController reportController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitleText(title: "Signaler", size: 20),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: manageHeight(context, 52),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: manageWidth(context, 15),
              ),
              width: manageWidth(context, 335),
              height: manageHeight(context, 200),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: EdgeInsets.all(manageWidth(context, 15)),
                child: TextField(
                  controller: reportController,
                  maxLines: null,
                  maxLength: 250,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText:
                        "Signalez nous votre problème avec cet utilisateur",
                    hintStyle: TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: manageHeight(context, 30),
            ),
            GestureDetector(
              onTap: () {
                if (reportController.text.isNotEmpty) {
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('Reports')
                      .add({
                    "reportId": widget.memberId,
                    "time": Timestamp.now(),
                    "description": reportController.text
                  });
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Veuillez signalez votre problème",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ));
                }
              },
              child: Container(
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                    color: Colors.red, borderRadius: BorderRadius.circular(25)),
                child: Center(
                  child: Text("Envoyer",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16))),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
