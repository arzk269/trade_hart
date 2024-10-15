import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/command.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/authentication_pages/widgets/auth_textfield.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:intl/intl.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerCommandView extends StatefulWidget {
  final Command command;
  const SellerCommandView({super.key, required this.command});

  @override
  State<SellerCommandView> createState() => _SellerCommandViewState();
}

class _SellerCommandViewState extends State<SellerCommandView> {
  void sendAnnulationMessage(
      String customerId, Command command, Article article) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.command.buyerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.command.buyerId, currentUserId],
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
            .add({
          "sender": currentUserId,
          "content":
              "Bonjour, nous vous informons que votre commande : ${article.name}, ${article.colors[command.colorIndex]}, ${article.colors[command.colorIndex].sizes[command.sizeIndex]["size"]} vient d'etre annulée. Rendez-vous sur 'Mes commandes pour plus de détails.' \n ${article.sellerName}",
          "date": moment
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {
            "content":
                "Bonjour, nous vous informons que votre commande : ${article.name}, ${article.colors[command.colorIndex]}, ${article.colors[command.colorIndex].sizes[command.sizeIndex]["size"]} vient d'etre annulée. Rendez-vous sur 'Mes commandes pour plus de détails.' \n ${article.sellerName}",
            "sender": command.sellerId
          },
          "is all read": {"sender": true, "receiver": false}
        });
        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Commande annulée",
            body:
                "Bonjour, nous vous informons que votre commande : ${article.name}, ${article.colors[command.colorIndex]}, ${article.colors[command.colorIndex].sizes[command.sizeIndex]["size"]} vient d'etre annulée. Rendez-vous sur 'Mes commandes annulées pour voir le statut de cette commande.'\n ${article.sellerName}",
            route: '/ConversationPage',
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId);
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {
            "content":
                " Bonjour, nous vous informons que votre commande : ${article.name}, ${article.colors[command.colorIndex]}, ${article.colors[command.colorIndex].sizes[command.sizeIndex]["size"]} vient d'etre annulée. Rendez-vous sur 'Mes commandes pour plus de détails.' \n ${article.sellerName}",
            "sender": command.sellerId
          },
          'last time': moment,
          "is all read": {"sender": true, "receiver": false}
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(newConversationRef.id)
            .collection("Messages")
            .add({
          "sender": currentUserId,
          "content":
              "Bonjour, nous vous informons que votre commande : ${article.name}, ${article.colors[command.colorIndex]}, ${article.colors[command.colorIndex].sizes[command.sizeIndex]["size"]} vient d'etre annulée. Rendez-vous sur 'Mes commandes pour voir le statut de cette commande.'\n ${article.sellerName}",
          "date": moment
        });
        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Commande annulée",
            body:
                "Bonjour, nous vous informons que votre commande : ${article.name}, ${article.colors[command.colorIndex]}, ${article.colors[command.colorIndex].sizes[command.sizeIndex]["size"]} vient d'etre annulée. Rendez-vous sur 'Mes commandes annulées pour voir le statut de cette commande.'\n ${article.sellerName}",
            route: '/ConversationPage',
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id);
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la confirmation de l\'annulation de cette commande.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void sendConfirmationMessage(
      String customerId, Command command, Article article) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.command.buyerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.command.buyerId, currentUserId],
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
            .add({
          "sender": currentUserId,
          "content":
              "Bonjour, nous avons le plaisir de confirmer votre commande: ${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${article.sellerName}",
          "date": moment
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {
            "content":
                "Bonjour, nous avons le plaisir de confirmer votre commande: ${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${article.sellerName}",
            "sender": command.sellerId
          },
          "is all read": {"sender": true, "receiver": false}
        });

        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
          token: customerData.data()!["fcmtoken"],
          title: "Commande confirmée ",
          body:
              "Bonjour, nous avons le plaisir de confirmer votre commande: ${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${article.sellerName}",
          senderId: FirebaseAuth.instance.currentUser!.uid,
          conversationId: conversationId,
          route: '/ConversationPage',
        );
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {
            "content":
                "Bonjour, nous avons le plaisir de confirmer votre commande pour le article : ${article.name}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${article.sellerName}",
            "sender": command.sellerId
          },
          'last time': moment,
          "is all read": {"sender": true, "receiver": false}
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(newConversationRef.id)
            .collection("Messages")
            .add({
          "sender": currentUserId,
          "content":
              "Bonjour, nous avons le plaisir de confirmer votre commande: ${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${article.sellerName}",
          "date": moment
        });
        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Commande confirmée ",
            body:
                "Bonjour, nous avons le plaisir de confirmer votre commande: ${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${article.sellerName}",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: '/ConversationPage');
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de l\'annulation de cette commande.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  TextEditingController trackingNumberController = TextEditingController();
  String formatTimestamp(Timestamp timestamp) {
    DateTime now = DateTime.now();
    DateTime dateTime = timestamp.toDate();
    DateTime yesterday = DateTime(now.year, now.month, now.day - 1);

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return "Aujourd'hui à ${DateFormat.Hm('fr').format(dateTime)}";
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return "Hier à ${DateFormat.Hm('fr').format(dateTime)}";
    } else {
      return DateFormat.yMMMMd('fr').add_Hm().format(dateTime);
    }
  }

  void sendExpeditionConfirmation(String customerId, String trackingNumber,
      Command command, Article article) async {
    try {
      var ref = FirebaseFirestore.instance
          .collection('Commands')
          .doc(widget.command.id);
      await ref.update({'status': 'Expédié!'});
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.command.buyerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.command.buyerId, currentUserId],
      ).get();

      var existingData2 = existingConversations2.docs;

      if (trackingNumber.isNotEmpty) {
        if (existingData1.isNotEmpty || existingData2.isNotEmpty) {
          String conversationId = existingData1.isNotEmpty
              ? existingData1[0].id
              : existingData2[0].id;
          var moment = Timestamp.now();
          await FirebaseFirestore.instance
              .collection("Conversations")
              .doc(conversationId)
              .collection("Messages")
              .add({
            "sender": currentUserId,
            "content":
                "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre expédiée. Elle vous sera livrée entre ${article.deliveryInformations['min delay']} et ${article.deliveryInformations['max delay']} jours par ${article.deliveryInformations['delivery provider']}. \n Vous pouvez suivre son évolution sur leur site avec ce numéro de suivi : $trackingNumber.\n Une fois votre colis receptionné, n'hésitez pas à appuyer sur la bouton 'Colis reçu?' pour confirmer et nous laisser un commentaire 😉.\n ${article.sellerName}",
            "date": moment
          });

          await FirebaseFirestore.instance
              .collection("Conversations")
              .doc(conversationId)
              .update({
            "last time": moment,
            "last message": {
              "content":
                  "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre expédiée. Elle vous sera livrée entre ${article.deliveryInformations['min delay']} et ${article.deliveryInformations['max delay']} jours par ${article.deliveryInformations['delivery provider']}. \n Vous pouvez suivre son évolution sur leur site avec ce numéro de suivi : $trackingNumber.\n Une fois votre colis receptionné, n'hésitez pas à appuyer sur la bouton 'Colis reçu?' pour confirmer et nous laisser un commentaire 😉.\n ${article.sellerName}",
              "sender": command.sellerId
            },
            "is all read": {"sender": true, "receiver": false}
          });
          var customerData = await FirebaseFirestore.instance
              .collection('Users')
              .doc(customerId)
              .get();
          sendNotification(
              token: customerData.data()!["fcmtoken"],
              title: "Commande expédiée ",
              body:
                  "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre expédiée. Elle vous sera livrée entre ${article.deliveryInformations['min delay']} et ${article.deliveryInformations['max delay']} jours par ${article.deliveryInformations['delivery provider']}. \n Vous pouvez suivre son évolution sur leur site avec ce numéro de suivi : $trackingNumber.\n Une fois votre colis receptionné, n'hésitez pas à appuyer sur la bouton 'Colis reçu?' pour confirmer et nous laisser un commentaire 😉.\n ${article.sellerName}",
              senderId: FirebaseAuth.instance.currentUser!.uid,
              conversationId: conversationId,
              route: '/ConversationPage');
        } else {
          var moment = Timestamp.now();
          var newConversationRef =
              await FirebaseFirestore.instance.collection('Conversations').add({
            'users': [currentUserId, customerId],
            'last message': {
              "content":
                  "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre expédiée. Elle vous sera livrée entre ${article.deliveryInformations['min delay']} et ${article.deliveryInformations['max delay']} jours par ${article.deliveryInformations['delivery provider']}. \n Vous pouvez suivre son évolution sur leur site avec ce numéro de suivi : $trackingNumber.\n Une fois votre colis receptionné, n'hésitez pas à appuyer sur la bouton 'Colis reçu?' pour confirmer et nous laisser un commentaire 😉.\n ${article.sellerName}",
              "sender": command.sellerId
            },
            'last time': moment,
            "is all read": {"sender": true, "receiver": false}
          });

          await FirebaseFirestore.instance
              .collection("Conversations")
              .doc(newConversationRef.id)
              .collection("Messages")
              .add({
            "sender": currentUserId,
            "content":
                "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre expédiée. Elle vous sera livrée entre ${article.deliveryInformations['min delay']} et ${article.deliveryInformations['max delay']} jours par ${article.deliveryInformations['delivery provider']}. \n Une fois votre colis receptionné, n'hésitez pas à appuyer sur la bouton 'Colis reçu?' pour confirmer et nous laisser un commentaire 😉.\n ${article.sellerName}",
            "date": moment
          });
          var customerData = await FirebaseFirestore.instance
              .collection('Users')
              .doc(customerId)
              .get();
          sendNotification(
              token: customerData.data()!["fcmtoken"],
              title: "Commande expédiée ",
              body:
                  "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre expédiée. Elle vous sera livrée entre ${article.deliveryInformations['min delay']} et ${article.deliveryInformations['max delay']} jours par ${article.deliveryInformations['delivery provider']}. \n Vous pouvez suivre son évolution sur leur site avec ce numéro de suivi : $trackingNumber.\n Une fois votre colis receptionné, n'hésitez pas à appuyer sur la bouton 'Colis reçu?' pour confirmer et nous laisser un commentaire 😉.\n ${article.sellerName}",
              senderId: FirebaseAuth.instance.currentUser!.uid,
              conversationId: newConversationRef.id,
              route: '/ConversationPage');
        }
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la confirmation de l\'expédition.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void sendLivraisonConfirmation(
      String customerId, Command command, Article article) async {
    try {
      var ref = FirebaseFirestore.instance
          .collection('Commands')
          .doc(widget.command.id);
      await ref.update({'status': 'Livré'});
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.command.buyerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.command.buyerId, currentUserId],
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
            .add({
          "sender": currentUserId,
          "content":
              "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre livrée à l'adresse : ${command.adress!.adress}, ${command.adress!.codePostal}, ${command.adress!.city} ${command.adress!.complement ?? ""}.\n Appuyez sur la bouton 'Colis reçu?' dans 'Mes commandes' pour confirmer et nous laisser un avis et un commentaire 😉.\n ${article.sellerName}",
          "date": moment
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {
            "content":
                "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre livrée à l'adresse : ${command.adress!.adress}, ${command.adress!.codePostal}, ${command.adress!.city} ${command.adress!.complement ?? ""}.\n Appuyez sur la bouton 'Colis reçu?' dans 'Mes commandes' pour confirmer et nous laisser un avis et un commentaire 😉.\n ${article.sellerName}",
            "sender": command.sellerId
          },
          "is all read": {"sender": true, "receiver": false}
        });
        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Commande livrée ",
            body:
                "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre livrée à l'adresse : ${command.adress!.adress}, ${command.adress!.codePostal}, ${command.adress!.city} ${command.adress!.complement ?? ""}.\n Appuyez sur la bouton 'Colis reçu?' dans 'Mes commandes' pour confirmer et nous laisser un avis et un commentaire 😉.\n ${article.sellerName}",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId,
            route: '/ConversationPage');
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {
            "content":
                "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre livrée à l'adresse : ${command.adress!.adress}, ${command.adress!.codePostal}, ${command.adress!.city} ${command.adress!.complement ?? ""}.\n Appuyez sur la bouton 'Colis reçu?' dans 'Mes commandes' pour confirmer et nous laisser un avis et un commentaire 😉.\n ${article.sellerName}",
            "sender": command.sellerId
          },
          'last time': moment,
          "is all read": {"sender": true, "receiver": false}
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(newConversationRef.id)
            .collection("Messages")
            .add({
          "sender": currentUserId,
          "content":
              "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre livrée à l'adresse : ${command.adress!.adress}, ${command.adress!.codePostal}, ${command.adress!.city} ${command.adress!.complement ?? ""}.\n Appuyez sur la bouton 'Colis reçu?' dans 'Mes commandes' pour confirmer et nous laisser un avis et un commentaire 😉.\n ${article.sellerName}",
          "date": moment
        });
        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Commande livrée ",
            body:
                "Hello! votre commande :${command.amount} x ${article.name}, ${article.colors[command.colorIndex].color}, taille: ${article.colors[command.colorIndex].sizes[command.sizeIndex]['size']}, vient d'etre livrée à l'adresse : ${command.adress!.adress}, ${command.adress!.codePostal}, ${command.adress!.city} ${command.adress!.complement ?? ""}.\n Appuyez sur la bouton 'Colis reçu?' dans 'Mes commandes' pour confirmer et nous laisser un avis et un commentaire 😉.\n ${article.sellerName}",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: '/ConversationPage');
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la confirmation de l\'expédition.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Articles')
            .doc(widget.command.articleId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(manageWidth(context, 8.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: manageHeight(context, 90),
                        width: manageWidth(context, 90),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 10)),
                        ),
                        margin: EdgeInsets.only(
                          right: manageWidth(context, 15),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: manageHeight(context, 5),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: manageWidth(context, 5),
                              right: manageWidth(context, 2),
                            ),
                            height: manageHeight(context, 10),
                            width: manageWidth(context, 75),
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: manageHeight(context, 5)),
                          Container(
                            margin: EdgeInsets.only(
                              left: manageWidth(context, 5),
                              right: manageWidth(context, 2),
                            ),
                            height: manageHeight(context, 10),
                            width: manageWidth(context, 60),
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: manageHeight(context, 8)),
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: manageWidth(context, 0),
                                  right: manageWidth(context, 0),
                                ),
                                height: manageHeight(context, 10),
                                color: Colors.grey.shade300,
                              ),
                              SizedBox(height: manageHeight(context, 15)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ), // end Row
                ], // end Column children
              ),
            );
          }
          var articleData = snapshot.data!.data() as Map<String, dynamic>;
          List<NetworkArticleColor> colors = [];
          for (var color in articleData['colors']) {
            colors.add(NetworkArticleColor(
                color: color['name'],
                imageUrl: color['image url'],
                amount: color['amount'],
                sizes: color['sizes']));
          }
          Article article = Article(
              id: snapshot.data!.id,
              name: articleData['name'],
              price: articleData['price'] * 1.0,
              categories: articleData['category'],
              sellerId: articleData['sellerId'],
              amount: articleData['amount'],
              description: articleData['description'],
              averageRate: articleData['average rate'] * 1.0,
              totalPoints: articleData['total points'] * 1.0,
              ratesNumber: articleData['rates number'],
              date: (articleData['date'] as Timestamp).toDate(),
              status: articleData['status'],
              sellerName: articleData['seller name'],
              deliveryInformations: articleData['delivery informations'],
              images: articleData['images'],
              colors: colors);
          return Padding(
            padding: EdgeInsets.all(manageWidth(context, 8.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ArticleDetailsPage(
                                  articleId: widget.command.articleId))),
                      child: Container(
                        height: manageHeight(context, 90),
                        width: manageWidth(context, 90),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(manageHeight(context, 10)),
                          // image: DecorationImage(
                          //     image: NetworkImage(article
                          //         .colors[widget.command.colorIndex]
                          //         .imageUrl),
                          //     fit: BoxFit.cover)
                        ),
                        margin:
                            EdgeInsets.only(right: manageWidth(context, 15)),
                        child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 10)),
                            child: Image.network(
                              article
                                  .colors[widget.command.colorIndex].imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  SizedBox(
                                      height: manageHeight(context, 150),
                                      width: manageWidth(context, 165),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons
                                                .exclamationmark_triangle_fill,
                                            size: manageWidth(context, 20),
                                          ),
                                        ],
                                      )),
                            )),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: manageHeight(context, 5),
                        ),
                        SizedBox(
                          width: manageWidth(context, 200),
                          child: Text(
                            article.name,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: manageHeight(context, 5)),
                        SellerNameView(
                          name: article.sellerName,
                          fontSize: 15,
                          marginLeft: 0,
                        ),
                        SizedBox(height: manageHeight(context, 8)),
                        Row(
                          children: [
                            Text(
                              "${article.price}\$ x${widget.command.amount} \t\t\t${article.colors[widget.command.colorIndex].color}, ${article.colors[widget.command.colorIndex].sizes[widget.command.sizeIndex]['size']}",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        SizedBox(height: manageHeight(context, 15)),
                      ],
                    ),
                  ],
                ),

                StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(widget.command.buyerId)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          margin: EdgeInsets.only(
                              left: manageWidth(context, 5),
                              right: manageWidth(context, 2)),
                          height: manageHeight(context, 10),
                          width: manageWidth(context, 75),
                          color: Colors.grey.shade300,
                        );
                      }

                      var buyerData = snapshot.data!.data();
                      return Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Infos client : ",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w800,
                                  fontSize: manageWidth(context, 15.5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: manageHeight(context, 25),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Text(
                                  "${buyerData!["first name"]} ${(buyerData["name"] as String).toUpperCase()}",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w400,
                                    fontSize: manageWidth(context, 15),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  width: manageWidth(context, 15),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    String currentUserId =
                                        FirebaseAuth.instance.currentUser!.uid;
                                    // Rechercher une conversation existante entre les deux utilisateurs
                                    var existingConversations1 =
                                        await FirebaseFirestore.instance
                                            .collection('Conversations')
                                            .where(
                                      'users',
                                      isEqualTo: [
                                        currentUserId,
                                        widget.command.buyerId
                                      ],
                                    ).get();

                                    var existingData1 =
                                        existingConversations1.docs;

                                    var existingConversations2 =
                                        await FirebaseFirestore.instance
                                            .collection('Conversations')
                                            .where(
                                      'users',
                                      isEqualTo: [
                                        widget.command.buyerId,
                                        currentUserId
                                      ],
                                    ).get();

                                    var existingData2 =
                                        existingConversations2.docs;

                                    //Si une conversation existe, naviguer vers la page de conversation avec l'ID de la conversation
                                    if (existingData1.isNotEmpty ||
                                        existingData2.isNotEmpty) {
                                      if (existingData1.isNotEmpty) {
                                        String conversationId =
                                            existingData1[0].id;
                                        //ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ConversationPage(
                                                    conversationId:
                                                        conversationId,
                                                    memberId:
                                                        widget.command.buyerId,
                                                  )),
                                        );
                                      } else {
                                        String conversationId =
                                            existingData2[0].id;
                                        //ignore: use_build_context_synchronously
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ConversationPage(
                                                    conversationId:
                                                        conversationId,
                                                    memberId:
                                                        widget.command.buyerId,
                                                  )),
                                        );
                                      }
                                    } else {
                                      // Si aucune conversation n'existe , créer une nouvelle conversation
                                      DocumentReference newConversationRef =
                                          await FirebaseFirestore.instance
                                              .collection('Conversations')
                                              .add({
                                        'users': [
                                          currentUserId,
                                          widget.command.buyerId
                                        ],
                                        'last message': "",
                                        'last time': Timestamp.now(),
                                        "is all read": {
                                          "sender": true,
                                          "receiver": false
                                        }
                                      });
                                      String conversationId =
                                          newConversationRef.id;
                                      //  ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ConversationPage(
                                                  conversationId:
                                                      conversationId,
                                                  memberId:
                                                      widget.command.buyerId,
                                                )),
                                      );
                                    }
                                  },
                                  child: Icon(
                                    color: Colors.deepPurple,
                                    CupertinoIcons.chat_bubble_text_fill,
                                    size: manageWidth(context, 20),
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: manageHeight(context, 8),
                          ),
                          Row(
                            children: [
                              Text(
                                "Adresse de livraison :",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w800,
                                  fontSize: manageWidth(context, 15.5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: manageHeight(context, 20),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Text(
                                  "${widget.command.adress!.adress}, ${widget.command.adress!.codePostal}, ${widget.command.adress!.city}  ",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w400,
                                    fontSize: manageWidth(context, 15),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: manageHeight(context, 8),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: [
                                Text(
                                  widget.command.adress!.complement ?? "",
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w400,
                                    fontSize: manageWidth(context, 15),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Date de la commande :",
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w800,
                                  fontSize: manageWidth(context, 15.5),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                formatTimestamp(widget.command.time),
                                style: GoogleFonts.poppins(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w400,
                                  fontSize: manageWidth(context, 15),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                Row(
                  children: [
                    SizedBox(
                      child: widget.command.status != "En cours de traitement"
                          ? null
                          : TextButton(
                              onPressed: () {
                                showBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 0.8,
                                            sigmaY:
                                                0.8), // Ajustez le flou selon vos préférences
                                        child: ClipRRect(
                                          // Couleur de fond avec opacité réduite
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          child: SizedBox(
                                            height: manageHeight(context, 320),
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 5),
                                                ),
                                                Center(
                                                  child: Container(
                                                    height: manageHeight(
                                                        context, 3),
                                                    width: manageWidth(
                                                        context, 45),
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 30),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: manageWidth(
                                                        context, 15),
                                                  ),
                                                  child: Text(
                                                    "En appuyant sur 'Confirmer', vous vous engagez à traiter cette commande conformément à la politique de confidentialité TradeHart. Aucune annulation ne sera possible.",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: manageWidth(
                                                          context, 15),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: manageHeight(
                                                        context, 60)),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: manageWidth(
                                                          context, 40),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Annuler",
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontSize:
                                                                    manageWidth(
                                                                        context,
                                                                        16),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors.red),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    TextButton(
                                                      onPressed: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Commands')
                                                            .doc(widget
                                                                .command.id)
                                                            .update({
                                                          "status":
                                                              "En attente d'expédition"
                                                        });

                                                        sendConfirmationMessage(
                                                            widget.command
                                                                .buyerId,
                                                            widget.command,
                                                            article);
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Confirmer",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: manageWidth(
                                                              context, 16),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: manageWidth(
                                                          context, 40),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Text(
                                "Confirmer",
                                style: GoogleFonts.poppins(
                                    fontSize: manageWidth(context, 15)),
                              ),
                            ),
                    ),
                    SizedBox(
                      child: widget.command.status != "En cours de traitement"
                          ? null
                          : TextButton(
                              onPressed: () {
                                showBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 0.8,
                                            sigmaY:
                                                0.8), // Ajustez le flou selon vos préférences
                                        child: ClipRRect(
                                          // Couleur de fond avec opacité réduite
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          child: SizedBox(
                                            height: manageHeight(context, 320),
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 5),
                                                ),
                                                Center(
                                                  child: Container(
                                                    height: manageHeight(
                                                        context, 3),
                                                    width: manageWidth(
                                                        context, 45),
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height:
                                                      manageHeight(context, 30),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: manageWidth(
                                                        context, 15),
                                                  ),
                                                  child: Text(
                                                    "En appuyant sur 'Confirmer', vous annulez cette commande. Appuyez sur 'Annuler' pour revenir en arrière. Un message sera envoyé à votre client qui sera remboursé aussi tot",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: manageWidth(
                                                          context, 15),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: manageHeight(
                                                        context, 60)),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: manageWidth(
                                                          context, 40),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text(
                                                        "Annuler",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: manageWidth(
                                                              context, 16),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const Spacer(),
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Commands')
                                                            .doc(widget
                                                                .command.id)
                                                            .update({
                                                          "status": "Annulé"
                                                        });
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'CommandsPayments')
                                                            .doc(widget
                                                                .command.id)
                                                            .update({
                                                          "status": "Annulé",
                                                          "annulation date":
                                                              Timestamp.now()
                                                        });
                                                        sendAnnulationMessage(
                                                            widget.command
                                                                .buyerId,
                                                            widget.command,
                                                            article);
                                                      },
                                                      child: Text(
                                                        "Confirmer",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          fontSize: manageWidth(
                                                              context, 16),
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: manageWidth(
                                                          context, 40),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: Text(
                                "Annuler",
                                style: GoogleFonts.poppins(
                                    color: Colors.red,
                                    fontSize: manageWidth(context, 15)),
                              ),
                            ),
                    ),
                  ],
                ),
                SizedBox(
                  height: manageHeight(context, 40),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      CircleAvatar(
                        radius: manageWidth(context, 11.5),
                        backgroundColor: widget.command.status == "Expédié!" ||
                                widget.command.status ==
                                    "En attente d'expédition" ||
                                widget.command.status == "Livré"
                            ? Colors.deepPurple
                            : Colors.grey.shade400,
                        child: Icon(
                          CupertinoIcons.clock,
                          size: manageWidth(context, 15),
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: manageHeight(context, 19.5),
                          bottom: manageHeight(context, 19.5),
                          left: manageWidth(context, 5),
                          right: manageWidth(context, 2),
                        ),
                        height: manageHeight(context, 3),
                        width: manageWidth(context, 30),
                        color: Colors.grey,
                      ),
                      CircleAvatar(
                        radius: manageWidth(context, 11.5),
                        backgroundColor: widget.command.status ==
                                    "En attente d'expédition" ||
                                widget.command.status == "Livré" ||
                                widget.command.status == "Expédié!"
                            ? Colors.deepPurple
                            : Colors.grey.shade400,
                        child: Icon(
                          CupertinoIcons.square_arrow_down,
                          size: manageWidth(context, 15),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        child: widget.command.status ==
                                "En attente d'expédition"
                            ? TextButton(
                                onPressed: () {
                                  showBottomSheet(
                                    backgroundColor: Colors.white,
                                    context: context,
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 0.8,
                                            sigmaY: 0.8,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  manageWidth(context, 20)),
                                              topRight: Radius.circular(
                                                  manageWidth(context, 20)),
                                            ),
                                            child: SizedBox(
                                              height:
                                                  manageHeight(context, 400),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: manageHeight(
                                                        context, 5),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      height: manageHeight(
                                                          context, 3),
                                                      width: manageWidth(
                                                          context, 45),
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: manageHeight(
                                                        context, 15),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      manageWidth(context, 8.0),
                                                    ),
                                                    child: AuthTextField(
                                                      color:
                                                          Colors.grey.shade200,
                                                      controller:
                                                          trackingNumberController,
                                                      hintText:
                                                          "Numéro de suivi",
                                                      obscuretext: false,
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      manageWidth(
                                                          context, 15.0),
                                                    ),
                                                    child: Text(
                                                      "En appuyant sur 'Confirmer', un message sera envoyé à votre client pour lui informer de l'expédition de son colis tout en précisant le article de livraison et son numéro de suivi que vous devez renseigner.",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: manageWidth(
                                                            context, 15),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: manageHeight(
                                                        context, 80),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      width: manageWidth(
                                                          context, 160),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.mainColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          manageWidth(
                                                              context, 40),
                                                        ),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          if (trackingNumberController
                                                              .text
                                                              .isNotEmpty) {
                                                            sendExpeditionConfirmation(
                                                              widget.command
                                                                  .buyerId,
                                                              trackingNumberController
                                                                  .text,
                                                              widget.command,
                                                              article,
                                                            );
                                                          }
                                                        },
                                                        child: Text(
                                                          "Confirmer",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize:
                                                                manageWidth(
                                                                    context,
                                                                    15),
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  "Confirmer l'expédition",
                                  style: GoogleFonts.poppins(),
                                ),
                              )
                            : null,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: manageHeight(context, 19.5),
                          bottom: manageHeight(context, 19.5),
                          left: manageWidth(context, 5),
                          right: manageWidth(context, 2),
                        ),
                        height: manageHeight(context, 3),
                        width: manageWidth(context, 30),
                        color: Colors.grey,
                      ),
                      CircleAvatar(
                        radius: manageWidth(context, 11.5),
                        backgroundColor: widget.command.status == "Expédié!" ||
                                widget.command.status == "Livré"
                            ? Colors.deepPurple
                            : Colors.grey.shade400,
                        child: Icon(
                          Icons.local_shipping_outlined,
                          size: manageWidth(context, 15),
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(
                        child: widget.command.status == "Expédié!"
                            ? TextButton(
                                onPressed: () {
                                  showBottomSheet(
                                    backgroundColor: Colors.white,
                                    context: context,
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 0.8,
                                            sigmaY: 0.8,
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(
                                                  manageWidth(context, 20)),
                                              topRight: Radius.circular(
                                                  manageWidth(context, 20)),
                                            ),
                                            child: SizedBox(
                                              height:
                                                  manageHeight(context, 350),
                                              width: double.infinity,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedBox(
                                                    height: manageHeight(
                                                        context, 5),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      height: manageHeight(
                                                          context, 3),
                                                      width: manageWidth(
                                                          context, 45),
                                                      color:
                                                          Colors.grey.shade700,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: manageHeight(
                                                        context, 15),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.all(
                                                      manageWidth(
                                                          context, 15.0),
                                                    ),
                                                    child: Text(
                                                      "En appuyant sur 'Confirmer', un message sera envoyé à votre client pour lui informer de la livraison de son colis. Par ailleurs il lui sera demandé de confirmer la réception de sa commande et de laisser un avis.",
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: manageWidth(
                                                            context, 15),
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: manageHeight(
                                                        context, 80),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      width: manageWidth(
                                                          context, 160),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.mainColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                          manageWidth(
                                                              context, 40),
                                                        ),
                                                      ),
                                                      child: TextButton(
                                                        onPressed: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  "CommandsPayments")
                                                              .doc(widget
                                                                  .command.id)
                                                              .update({
                                                            "seller confirmation status":
                                                                true,
                                                            "seller confirmation date":
                                                                Timestamp.now()
                                                          });
                                                          sendLivraisonConfirmation(
                                                            widget.command
                                                                .buyerId,
                                                            widget.command,
                                                            article,
                                                          );
                                                        },
                                                        child: Text(
                                                          "Confirmer",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize:
                                                                manageWidth(
                                                                    context,
                                                                    15),
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Text(
                                  "Confirmer la livraison",
                                  style: GoogleFonts.poppins(),
                                ),
                              )
                            : null,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: manageHeight(context, 19.5),
                          bottom: manageHeight(context, 19.5),
                          left: manageWidth(context, 5),
                          right: manageWidth(context, 2),
                        ),
                        height: manageHeight(context, 3),
                        width: manageWidth(context, 30),
                        color: Colors.grey,
                      ),
                      CircleAvatar(
                        radius: manageWidth(context, 11.5),
                        backgroundColor: widget.command.status == "Livré"
                            ? Colors.deepPurple
                            : Colors.grey.shade400,
                        child: Icon(
                          Icons.check,
                          size: manageWidth(context, 15),
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: manageWidth(context, 5)),
                        child: Row(
                          children: [
                            Text(
                              widget.command.status == "Expédié!"
                                  ? "Expédié!"
                                  : widget.command.status == "Livré"
                                      ? "Livré"
                                      : widget.command.status == "Signalé"
                                          ? "Signalé"
                                          : "",
                              style: GoogleFonts.poppins(
                                  color: widget.command.status == "Signalé"
                                      ? Colors.red
                                      : Colors.black),
                            ),
                            SizedBox(
                              child: widget.command.status == "Livré"
                                  ? TextButton(
                                      onPressed: () async {
                                        final Uri params = Uri(
                                          scheme: 'mailto',
                                          path: 'contact.tradehart@gmail.com',
                                          query:
                                              'subject=Un problème à signaer&body=Bonjour', // add subject and body here
                                        );
                                        final url = params.toString();
                                        if (await canLaunchUrl(
                                            Uri.parse(url))) {
                                          await launchUrl(Uri.parse(url));
                                        } else {
                                          print('Could not launch $url');
                                        }
                                      },
                                      child: const Text("Un problème?"),
                                    )
                                  : null,
                            )
                          ],
                        ),
                      ),
                    ], // end ListView children
                  ),
                ),
                const Divider() // end SizedBox
              ], // end Column children
            ),
          );
        });
  }
}
