import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/model/command.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:url_launcher/url_launcher.dart';

class CommandProblemPage extends StatefulWidget {
  final Command command;
  const CommandProblemPage({super.key, required this.command});

  @override
  State<CommandProblemPage> createState() => _CommandProblemPageState();
}

class _CommandProblemPageState extends State<CommandProblemPage> {
  var commentController = TextEditingController();
  void sendProblemMessage(String customerId, String problem) async {
    var ref = FirebaseFirestore.instance
        .collection('Commands')
        .doc(widget.command.id);
    await ref.update({'status': 'Signalé'});
    await FirebaseFirestore.instance
        .collection('CommandsPayments')
        .doc(widget.command.id)
        .update({'status': 'Signalé'});
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.command.sellerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.command.sellerId, currentUserId],
      ).get();

      var existingData2 = existingConversations2.docs;

      if (existingData1.isNotEmpty || existingData2.isNotEmpty) {
        String conversationId = existingData1.isNotEmpty
            ? existingData1[0].id
            : existingData2[0].id;
        var moment = Timestamp.now();

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .collection("Messages")
            .add({"sender": currentUserId, "content": problem, "date": moment});

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {"content": problem, "sender": currentUserId},
          "is all read": {"sender": true, "receiver": false}
        });

        var seller = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.command.sellerId)
            .get();
        sendNotification(
            token: seller.data()!["fcmtoken"],
            title: "Un problème sur une commande a été signalé",
            body: problem,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId,
            route: "/ConversationPage");
        final Uri params = Uri(
          scheme: 'mailto',
          path: 'contact.tradehart@gmail.com',
          query:
              'subject=Un problème à signaler ${widget.command.id} Ne pas changer l\'objet &body=$problem', // add subject and body here
        );
        final url = params.toString();
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          print('Could not launch $url');
        }
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {"content": problem, "sender": currentUserId},
          'last time': moment,
          "is all read": {"sender": true, "receiver": false}
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(newConversationRef.id)
            .collection("Messages")
            .add({"sender": currentUserId, "content": problem, "date": moment});
        var seller = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.command.sellerId)
            .get();

        sendNotification(
            token: seller.data()!["fcmtoken"],
            title: "Un problème sur une commande a été signalé",
            body: problem,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: "/ConversationPage");
      }
      final Uri params = Uri(
        scheme: 'mailto',
        path: 'contact.tradehart@gmail.com',
        query:
            'subject=Un problème à signaer&body=$problem', // add subject and body here
      );
      final url = params.toString();
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        print('Could not launch $url');
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppBarTitleText(title: "Signalement d'un problème", size: 17.5),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                    width: manageWidth(
                  context,
                  30,
                )),
                Text(
                  "laisser votre commentaire",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                      fontSize: manageWidth(context, 16)),
                ),
              ],
            ),
            SizedBox(
              height: manageHeight(context, 50),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: manageWidth(context, 335),
                // Ajuster la hauteur selon vos besoins
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 20)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: commentController,
                    maxLines:
                        null, // Permet à TextField de s'ajuster dynamiquement en hauteur
                    maxLength: 250,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "J'ai un problème avec ma commande.",
                        hintStyle:
                            TextStyle(fontSize: manageWidth(context, 15))),
                  ),
                )),
            GestureDetector(
              onTap: () async {
                if (commentController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Veuillez écrire votre message",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ));
                } else {
                  sendProblemMessage(FirebaseAuth.instance.currentUser!.uid,
                      commentController.text);
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: manageHeight(context, 60)),
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageHeight(context, 2)),
                decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 25))),
                child: Center(
                  child: Text("Envoyer",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
