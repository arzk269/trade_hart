import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/model/reservation.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderReservationView extends StatefulWidget {
  final Reservation reservation;
  const ProviderReservationView({super.key, required this.reservation});

  @override
  State<ProviderReservationView> createState() =>
      _ProviderReservationViewState();
}

class _ProviderReservationViewState extends State<ProviderReservationView> {
  void sendAnnulationMessage(
      String customerId, Reservation reservation, Service service) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.reservation.buyerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.reservation.buyerId, currentUserId],
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
              "Bonjour, nous vous informons que votre réservation : ${service.name} ${formatTimestamp(reservation.date)} vient d'etre annulée. \n ${service.sellerName}",
          "date": moment
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {
            "content":
                "Bonjour, nous vous informons que votre réservation : ${service.name} ${formatTimestamp(reservation.date)} vient d'etre annulée. \n ${service.sellerName}",
            "sender": reservation.sellerId
          },
          "is all read": {"sender": true, "receiver": false}
        });

        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Réservation annulée",
            body:
                "Bonjour, nous vous informons que votre réservation : ${service.name} ${formatTimestamp(reservation.date)} vient d'etre annulée. \n ${service.sellerName}",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId,
            route: "/ConversationPage");
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {
            "content":
                " Bonjour, nous vous informons que votre réservation : ${service.name} ${formatTimestamp(reservation.date)} vient d'etre annulée. \n ${service.sellerName}",
            "sender": reservation.sellerId
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
              "Bonjour, nous vous informons que votre réservation : ${service.name} ${formatTimestamp(reservation.date)} vient d'etre annulée.\n ${service.sellerName}",
          "date": moment
        });
        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Réservation annulée",
            body:
                "Bonjour, nous vous informons que votre réservation : ${service.name} ${formatTimestamp(reservation.date)} vient d'etre annulée. \n ${service.sellerName}",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: "/ConversationPage");
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la confirmation de l\'annulation de cette réservation.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  void sendConfirmationMessage(
      String customerId, Reservation reservation, Service service) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.reservation.buyerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.reservation.buyerId, currentUserId],
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
              "Bonjour, nous avons le plaisir de confirmer votre réservation pour le service : ${service.name}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${service.sellerName}",
          "date": moment
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {
            "content":
                "Bonjour, nous avons le plaisir de confirmer votre réservation pour le service : ${service.name}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${service.sellerName}",
            "sender": reservation.sellerId
          },
          "is all read": {"sender": true, "receiver": false}
        });

        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Réservation confirmée",
            body:
                "Bonjour, nous avons le plaisir de confirmer votre réservation pour le service : ${service.name}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${service.sellerName}",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId,
            route: "/ConversationPage");
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {
            "content":
                "Bonjour, nous avons le plaisir de confirmer votre réservation pour le service : ${service.name}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${service.sellerName}",
            "sender": reservation.sellerId
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
              "Bonjour, nous avons le plaisir de confirmer votre réservation pour le service : ${service.name}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${service.sellerName}",
          "date": moment
        });

        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Réservation confirmée",
            body:
                "Bonjour, nous avons le plaisir de confirmer votre réservation pour le service : ${service.name}. Vous pouvez voir tous les détails sur 'Mes réservation'. \n ${service.sellerName}",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: "/ConversationPage");
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la confirmation de l\'annulation de cette réservation.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }
  }

  void sendConThanksMessage(
      String customerId, Reservation reservation, Service service) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.reservation.buyerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.reservation.buyerId, currentUserId],
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
              "Merci de nous avoir fait confiance. N'hésitez pas à appuyer sur 'Prestation terminée' et à nous laisser un avis.",
          "date": moment
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {
            "content":
                "Merci de nous avoir fait confiance. N'hésitez pas à appuyer sur 'Prestation terminée' et à nous laisser un avis.",
            "sender": reservation.sellerId
          },
          "is all read": {"sender": true, "receiver": false}
        });
        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Donnez un avis sur votre dernière expérience",
            body:
                "Merci de nous avoir fait confiance. N'hésitez pas à appuyer sur 'Prestation terminée' et à nous laisser un avis.",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId,
            route: "/ConversationPage");
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {
            "content":
                "Merci de nous avoir fait confiance. N'hésitez pas à appuyer sur 'Prestation terminée' et à nous laisser un avis.",
            "sender": reservation.sellerId
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
              "Merci de nous avoir fait confiance. N'hésitez pas à appuyer sur 'Prestation terminée' et à nous laisser un avis.",
          "date": moment
        });

        var customerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(customerId)
            .get();
        sendNotification(
            token: customerData.data()!["fcmtoken"],
            title: "Donnez un avis sur votre dernière expérience",
            body:
                "Merci de nous avoir fait confiance. N'hésitez pas à appuyer sur 'Prestation terminée' et à nous laisser un avis.",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: "/ConversationPage");
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la confirmation de la fin de cette réservation.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Services')
            .doc(widget.reservation.serviceId)
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
                  ),
                ],
              ),
            );
          }
          var serviceData = snapshot.data!.data() as Map<String, dynamic>;
          var service = Service(
              crenaux: serviceData['crenaux'],
              id: widget.reservation.serviceId,
              location: serviceData['location'],
              name: serviceData['name'],
              price: serviceData['price'] * 1.0,
              categories: serviceData['categories'],
              sellerId: serviceData['sellerId'],
              duration: serviceData['duration'],
              description: serviceData['description'],
              averageRate: serviceData['average rate'] * 1.0,
              date: (serviceData['date'] as Timestamp).toDate(),
              images: serviceData['images'],
              ratesNumber: serviceData['rates number'],
              sellerName: serviceData['seller name'],
              status: serviceData['status'],
              totalPoints: serviceData['total points'] * 1.0,
              creneauReservationStatus:
                  serviceData["creneau reservation status"]);
          return Padding(
            padding: EdgeInsets.all(manageWidth(context, 8.0)),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("Users")
                    .doc(widget.reservation.buyerId)
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ServiceDetailPage(
                                          serviceId:
                                              widget.reservation.serviceId,
                                        ))),
                            child: Container(
                                height: manageHeight(context, 90),
                                width: manageWidth(context, 90),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(10),
                                  // image: DecorationImage(
                                  //     image: NetworkImage(
                                  //         service.images[0]["image url"]),
                                  //     fit: BoxFit.cover)
                                ),
                                margin: EdgeInsets.only(
                                    right: manageWidth(context, 15)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        manageWidth(context, 10)),
                                    child: Image.network(
                                      service.images[0]["image url"],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          SizedBox(
                                              height:
                                                  manageHeight(context, 150),
                                              width: manageWidth(context, 165),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .exclamationmark_triangle_fill,
                                                    size: manageWidth(
                                                        context, 20),
                                                  ),
                                                ],
                                              )),
                                    ))),
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
                                  service.name,
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey.shade800,
                                    fontWeight: FontWeight.w500,
                                    fontSize: manageWidth(context, 18),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(height: manageHeight(context, 5)),
                              Row(
                                children: [
                                  SellerNameView(
                                    name: service.sellerName,
                                    fontSize: manageWidth(context, 15),
                                    marginLeft: 0,
                                  ),
                                ],
                              ),
                              SizedBox(height: manageHeight(context, 3)),
                              Row(
                                children: [
                                  Text(
                                    "${service.price}\$",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w400,
                                      fontSize: manageWidth(context, 15),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              Text(formatTimestamp(widget.reservation.time))
                            ],
                          ),
                        ],
                      ),
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
                        height: manageHeight(context, 20),
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
                                    widget.reservation.buyerId
                                  ],
                                ).get();

                                var existingData1 = existingConversations1.docs;

                                var existingConversations2 =
                                    await FirebaseFirestore.instance
                                        .collection('Conversations')
                                        .where(
                                  'users',
                                  isEqualTo: [
                                    widget.reservation.buyerId,
                                    currentUserId
                                  ],
                                ).get();

                                var existingData2 = existingConversations2.docs;

                                //Si une conversation existe, naviguer vers la page de conversation avec l'ID de la conversation
                                if (existingData1.isNotEmpty ||
                                    existingData2.isNotEmpty) {
                                  if (existingData1.isNotEmpty) {
                                    String conversationId = existingData1[0].id;
                                    //ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ConversationPage(
                                                conversationId: conversationId,
                                                memberId:
                                                    widget.reservation.buyerId,
                                              )),
                                    );
                                  } else {
                                    String conversationId = existingData2[0].id;
                                    //ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ConversationPage(
                                                conversationId: conversationId,
                                                memberId:
                                                    widget.reservation.buyerId,
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
                                      widget.reservation.buyerId
                                    ],
                                    'last message': "",
                                    'last time': Timestamp.now(),
                                    "is all read": {
                                      "sender": true,
                                      "receiver": false
                                    }
                                  });
                                  String conversationId = newConversationRef.id;
                                  //  ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConversationPage(
                                              conversationId: conversationId,
                                              memberId:
                                                  widget.reservation.buyerId,
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
                      Row(
                        children: [
                          Text(
                            "Date de la réservation :",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: manageWidth(context, 16),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            formatTimestamp(widget.reservation.time),
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w400,
                              fontSize: manageWidth(context, 15),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      SizedBox(
                        height: manageHeight(context, 5),
                      ),

                      Row(
                        children: [
                          Text(
                            "Lieu :",
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w600,
                              fontSize: manageWidth(context, 16),
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
                              widget.reservation.buyerAdres == null
                                  ? widget.reservation.location
                                  : "${widget.reservation.buyerAdres!.adress}, ${widget.reservation.buyerAdres!.codePostal}, ${widget.reservation.buyerAdres!.city}",
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
                        height: widget.reservation.buyerAdres == null ||
                                widget.reservation.buyerAdres!.complement ==
                                    null
                            ? 0.1
                            : manageHeight(context, 20),
                        child: widget.reservation.buyerAdres == null ||
                                widget.reservation.buyerAdres!.complement ==
                                    null
                            ? null
                            : ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      left: manageWidth(context, 0),
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.left,
                                      widget.reservation.buyerAdres == null
                                          ? widget.reservation.location
                                          : widget.reservation.buyerAdres!
                                              .complement!,
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w400,
                                        fontSize: manageWidth(context, 15),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      SizedBox(
                        height: manageHeight(context, 5),
                      ),
                      Row(
                        children: [
                          SizedBox(
                            child: widget.reservation.creneau == null
                                ? null
                                : Padding(
                                    padding: EdgeInsets.only(
                                      left: manageWidth(context, 0),
                                    ),
                                    child: Text(
                                      "Créneau :",
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade800,
                                        fontWeight: FontWeight.w600,
                                        fontSize: manageWidth(context, 16),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                          ),
                          SizedBox(
                            width: widget.reservation.creneau == null
                                ? 0
                                : manageWidth(context, 5),
                          ),
                          SizedBox(
                            child: widget.reservation.creneau == null
                                ? null
                                : Text(
                                    "${widget.reservation.creneau!.heure}h${widget.reservation.creneau!.minutes}",
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade800,
                                      fontWeight: FontWeight.w400,
                                      fontSize: manageWidth(context, 15),
                                    ),
                                  ),
                          ),
                          SizedBox(
                              child: widget.reservation.status ==
                                      "En cours de traitement"
                                  ? TextButton(
                                      onPressed: () {
                                        showBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return BackdropFilter(
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
                                                  height: manageHeight(
                                                      context, 320),
                                                  width: double.infinity,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
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
                                                          color: Colors
                                                              .grey.shade700,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: manageHeight(
                                                            context, 30),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.all(
                                                          manageWidth(
                                                              context, 15),
                                                        ),
                                                        child: Text(
                                                          "En appuyant sur 'Confirmer', vous annulez cette reservation. Appuyez sur 'Annuler' pour revenir en arrière. Un message sera envoyé à votre client qui sera remboursé aussi tot",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            fontSize:
                                                                manageWidth(
                                                                    context,
                                                                    15),
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .grey.shade800,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: manageHeight(
                                                            context, 60),
                                                      ),
                                                      Row(
                                                        children: [
                                                          SizedBox(
                                                            width: manageWidth(
                                                                context, 40),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              "Annuler",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize:
                                                                    manageWidth(
                                                                        context,
                                                                        16),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          TextButton(
                                                            onPressed: () {
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'Reservations')
                                                                  .doc(widget
                                                                      .reservation
                                                                      .id)
                                                                  .update({
                                                                "status":
                                                                    "Annulé"
                                                              });

                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'ReservationsPayments')
                                                                  .doc(widget
                                                                      .reservation
                                                                      .id)
                                                                  .update({
                                                                "status":
                                                                    "Annulé",
                                                                "annulation date":
                                                                    Timestamp
                                                                        .now()
                                                              });

                                                              sendAnnulationMessage(
                                                                  widget
                                                                      .reservation
                                                                      .buyerId,
                                                                  widget
                                                                      .reservation,
                                                                  service);

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text(
                                                              "Confirmer",
                                                              style: GoogleFonts
                                                                  .poppins(
                                                                fontSize:
                                                                    manageWidth(
                                                                        context,
                                                                        16),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                color:
                                                                    Colors.red,
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
                                          },
                                        );
                                      },
                                      child: Text(
                                        "Annuler",
                                        style: GoogleFonts.poppins(
                                          color: Colors.red,
                                          fontSize: manageWidth(context, 15),
                                        ),
                                      ),
                                    )
                                  : null),
                        ],
                      ),

                      SizedBox(
                        height: manageHeight(context, 40),
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            CircleAvatar(
                              radius: manageWidth(context, 11.5),
                              backgroundColor:
                                  widget.reservation.status != "Annulé"
                                      ? Colors.deepPurple
                                      : Colors.grey.shade400,
                              child: Icon(
                                CupertinoIcons.clock,
                                size: manageWidth(context, 15),
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(
                              child: widget.reservation.status !=
                                      "En cours de traitement"
                                  ? null
                                  : TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('Reservations')
                                            .doc(widget.reservation.id)
                                            .update({"status": "Confirmé"});
                                        sendConfirmationMessage(
                                            widget.reservation.buyerId,
                                            widget.reservation,
                                            service);
                                      },
                                      child: Text(
                                        widget.reservation.status ==
                                                "En cours de traitement"
                                            ? "Confirmer"
                                            : "",
                                        style: GoogleFonts.poppins(),
                                      ),
                                    ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: manageHeight(context, 19.5),
                                  bottom: manageHeight(context, 19.5),
                                  left: widget.reservation.status !=
                                          "En cours de traitement"
                                      ? manageWidth(context, 8)
                                      : 0,
                                  right: 2),
                              height: manageHeight(context, 3),
                              width: manageWidth(context, 35),
                              color: Colors.grey,
                            ),
                            CircleAvatar(
                              radius: manageWidth(context, 11.5),
                              backgroundColor: widget.reservation.status ==
                                          "Terminé" ||
                                      widget.reservation.status == "Confirmé"
                                  ? Colors.deepPurple
                                  : Colors.grey.shade400,
                              child: Icon(
                                Icons.check,
                                size: manageWidth(context, 15),
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: manageWidth(context, 5)),
                              child: Row(
                                children: [
                                  Text(
                                    widget.reservation.status == "Terminé"
                                        ? "Terminé!"
                                        : widget.reservation.status ==
                                                "Confirmé"
                                            ? "Confirmé!"
                                            : widget.reservation.status ==
                                                    "Annulé"
                                                ? "Annulé" : widget.reservation.status=="Signalé"?"Signalé"
                                                : "",
                                    style: GoogleFonts.poppins(
                                        color: widget.reservation.status ==
                                                "Annulé"
                                            ? Colors.red
                                            : null),
                                  ),
                                  SizedBox(
                                    width: manageWidth(context, 5),
                                  ),
                                  SizedBox(
                                    child:
                                        widget.reservation.status == "Confirmé"
                                            ? TextButton(
                                                onPressed: () {
                                                  showBottomSheet(
                                                      context: context,
                                                      builder: (context) {
                                                        return BackdropFilter(
                                                            filter: ImageFilter
                                                                .blur(
                                                                    sigmaX: 0.8,
                                                                    sigmaY:
                                                                        0.8), // Ajustez le flou selon vos préférences
                                                            child: ClipRRect(
                                                                // Couleur de fond avec opacité réduite
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .only(
                                                                  topLeft: Radius.circular(
                                                                      manageHeight(
                                                                          context,
                                                                          20)),
                                                                  topRight: Radius.circular(
                                                                      manageHeight(
                                                                          context,
                                                                          20)),
                                                                ),
                                                                child: SizedBox(
                                                                    height: manageHeight(
                                                                        context,
                                                                        350),
                                                                    width: double
                                                                        .infinity,
                                                                    child: Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: <Widget>[
                                                                          SizedBox(
                                                                            height:
                                                                                manageHeight(context, 5),
                                                                          ),
                                                                          Center(
                                                                            child:
                                                                                Container(
                                                                              height: manageHeight(context, 3),
                                                                              width: manageWidth(context, 45),
                                                                              color: Colors.grey.shade700,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            height:
                                                                                manageHeight(context, 15),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                EdgeInsets.all(manageWidth(context, 15)),
                                                                            child:
                                                                                Text(
                                                                              "En appuyant sur 'Confirmer', vous certifiez que la prestation s'est bien déroulée. Dans le cas contraire appuyez sur signaler un problème.",
                                                                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.grey.shade800),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: manageHeight(context, 60)),
                                                                          Row(
                                                                            children: [
                                                                              TextButton(
                                                                                  onPressed: () async {
                                                                                    final Uri params = Uri(
                                                                                      scheme: 'mailto',
                                                                                      path: 'contact.tradehart@gmail.com',
                                                                                      query: 'subject=Un problème à signaler ${widget.reservation.id} Ne pas changer l\'objet &body=Bonjour', // add subject and body here
                                                                                    );
                                                                                    final url = params.toString();
                                                                                    if (await canLaunchUrl(Uri.parse(url))) {
                                                                                      await launchUrl(Uri.parse(url));
                                                                                    } else {
                                                                                      print('Could not launch $url');
                                                                                    }
                                                                                  },
                                                                                  child: Text(
                                                                                    "Signaler un problème",
                                                                                    style: GoogleFonts.poppins(fontSize: manageWidth(context, 15), fontWeight: FontWeight.w500, color: Colors.red),
                                                                                  )),
                                                                              SizedBox(
                                                                                width: manageWidth(context, 5),
                                                                              ),
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    FirebaseFirestore.instance.collection('Reservations').doc(widget.reservation.id).update({
                                                                                      "status": "Terminé"
                                                                                    });
                                                                                    FirebaseFirestore.instance.collection("ReservationsPayments").doc(widget.reservation.id).update({
                                                                                      "seller confirmation status": true,
                                                                                      "seller confirmation date": Timestamp.now()
                                                                                    });
                                                                                    sendConThanksMessage(widget.reservation.buyerId, widget.reservation, service);
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text(
                                                                                    "Confirmer",
                                                                                    style: GoogleFonts.poppins(
                                                                                      fontSize: manageWidth(context, 15),
                                                                                      fontWeight: FontWeight.w500,
                                                                                    ),
                                                                                  )),
                                                                            ],
                                                                          )
                                                                        ]))));
                                                      });
                                                },
                                                child: const Text(
                                                    "Prestation terminée?"),
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
                  );
                }),
          );
        });
  }
}
