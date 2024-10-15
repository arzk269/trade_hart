import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trade_hart/model/reservation.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
import 'package:trade_hart/views/main_page_components/pages/reservation_problem_page.dart';
import 'package:trade_hart/views/main_page_components/pages/reservation_rate_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_detail_page.dart';
import 'package:http/http.dart' as http;

class ReservationView extends StatefulWidget {
  final Reservation reservation;
  const ReservationView({super.key, required this.reservation});

  @override
  State<ReservationView> createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {
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

  Future<void> createTransfer(double totalAmount, String sellerStripeId,
      DocumentReference<Map<String, dynamic>> ref) async {
    // URL de votre Cloud Function
    final url = Uri.parse(
        'https://us-central1-tradehart-f5f44.cloudfunctions.net/createTransfer');

    // Obtenir le token d'authentification Firebase
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    String? idToken = await user.getIdToken();

    // Préparer les headers
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $idToken',
    };

    // Préparer le body de la requête
    final body = jsonEncode({
      'totalAmount': totalAmount,
      'sellerStripeId': sellerStripeId,
    });

    // Faire la requête POST
    final response = await http.post(url, headers: headers, body: body);

    // Gérer la réponse
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      var transfertId = responseData['transferId'];
      await ref.update({
        "status": "Encaissé",
        "date encaissement": Timestamp.now(),
        "transfert id": transfertId
      });
      print('Transfer created successfully: ${responseData['transferId']}');
    } else {
      print('Failed to create transfer: ${response.body}');
      throw Exception('Failed to create transfer');
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
                  Row(children: [
                    Container(
                      height: manageHeight(context, 90),
                      width: manageWidth(context, 90),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius:
                            BorderRadius.circular(manageWidth(context, 10)),
                      ),
                      margin: EdgeInsets.only(right: manageWidth(context, 15)),
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
                              right: manageWidth(context, 2)),
                          height: manageHeight(context, 10),
                          width: manageWidth(context, 75),
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: manageHeight(context, 5)),
                        Container(
                          margin: EdgeInsets.only(
                              left: manageWidth(context, 5),
                              right: manageWidth(context, 2)),
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
                                  right: manageWidth(context, 0)),
                              height: manageHeight(context, 10),
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: manageHeight(context, 15)),
                          ],
                        ),
                      ],
                    ),
                  ]),

                  // end SizedBox
                ], // end Column children
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ServiceDetailPage(
                                      serviceId: widget.reservation.serviceId,
                                    ))),
                        child: Container(
                          height: manageHeight(context, 90),
                          width: manageWidth(context, 90),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 10)),
                            // image: DecorationImage(
                            //     image: NetworkImage(
                            //         service.images[0]["image url"]),
                            //     fit: BoxFit.cover)
                          ),
                          margin:
                              EdgeInsets.only(right: manageWidth(context, 15)),
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 10)),
                              child: Image.network(
                                service.images[0]["image url"],
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
                                      widget.reservation.sellerId
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
                                      widget.reservation.sellerId,
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
                                                  memberId: widget
                                                      .reservation.buyerId,
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
                                                  memberId: widget
                                                      .reservation.sellerId,
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
                                        widget.reservation.sellerId
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
                                                conversationId: conversationId,
                                                memberId:
                                                    widget.reservation.sellerId,
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
                          SizedBox(height: manageHeight(context, 8)),
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
                          SizedBox(height: manageHeight(context, 15)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Date de réservation :",
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
                            widget.reservation.buyerAdres!.complement == null
                        ? manageHeight(context, 0.1)
                        : manageHeight(context, 20),
                    child: widget.reservation.buyerAdres == null ||
                            widget.reservation.buyerAdres!.complement == null
                        ? null
                        : ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              Text(
                                widget.reservation.buyerAdres == null
                                    ? widget.reservation.location
                                    : widget
                                        .reservation.buyerAdres!.complement!,
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
                    height: manageHeight(context, 5),
                  ),
                  Row(
                    children: widget.reservation.creneau == null
                        ? [const SizedBox()]
                        : [
                            Text(
                              "Créneau :",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: manageWidth(context, 16),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              width: manageWidth(context, 5),
                            ),
                            Text(
                              "${widget.reservation.creneau!.heure}h${widget.reservation.creneau!.minutes}",
                              style: GoogleFonts.poppins(
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w400,
                                fontSize: manageWidth(context, 15),
                              ),
                            )
                          ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 40),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        CircleAvatar(
                          radius: manageWidth(context, 11.5),
                          backgroundColor: widget.reservation.status == "Annulé"
                              ? Colors.grey.shade400
                              : Colors.deepPurple,
                          child: Icon(
                            CupertinoIcons.clock,
                            size: manageWidth(context, 15),
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: manageHeight(context, 10),
                              left: manageWidth(context, 5)),
                          child: Text(
                            widget.reservation.status ==
                                    "En cours de traitement"
                                ? "En cours de traitement"
                                : "",
                            style: GoogleFonts.poppins(),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              top: manageHeight(context, 19.5),
                              bottom: manageHeight(context, 19.5),
                              left: manageWidth(context, 5),
                              right: manageWidth(context, 2)),
                          height: manageHeight(context, 3),
                          width: manageWidth(context, 35),
                          color: Colors.grey,
                        ),
                        CircleAvatar(
                          radius: manageWidth(context, 11.5),
                          backgroundColor:
                              widget.reservation.status == "Terminé" ||
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
                          padding:
                              EdgeInsets.only(left: manageWidth(context, 5)),
                          child: Row(
                            children: [
                              Text(
                                widget.reservation.status == "Terminé"
                                    ? "Terminé!"
                                    : widget.reservation.status == "Confirmé"
                                        ? "Confirmé!"
                                        : widget.reservation.status == "Annulé"
                                            ? "Annulé":widget.reservation.status=="Signalé"?"Signalé"
                                            : "",
                                style: GoogleFonts.poppins(
                                    color: widget.reservation.status == "Annulé"
                                        ? Colors.red
                                        : null),
                              ),
                              SizedBox(
                                width: manageWidth(context, 5),
                              ),
                              SizedBox(
                                child:
                                    widget.reservation.buyerConfirmationStatus
                                        ? null
                                        : widget.reservation.status ==
                                                    "Confirmé" ||
                                                widget.reservation.status ==
                                                    "Terminé"
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
                                                                    const BorderRadius
                                                                        .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          20),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          20),
                                                                ),
                                                                child: SizedBox(
                                                                    height: manageHeight(
                                                                        context,
                                                                        350),
                                                                    width: manageWidth(
                                                                        context,
                                                                        double
                                                                            .infinity),
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
                                                                                EdgeInsets.all(manageWidth(context, 15.0)),
                                                                            child:
                                                                                Text(
                                                                              "En appuyant sur 'Confirmer', vous certifiez que la prestation s'est bien déroulée. Dans le cas contraire appuyez sur signaler un problème.",
                                                                              style: GoogleFonts.poppins(fontSize: manageWidth(context, 15), fontWeight: FontWeight.w500, color: Colors.grey.shade800),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              height: manageHeight(context, 60)),
                                                                          Row(
                                                                            children: [
                                                                              TextButton(
                                                                                  onPressed: () {
                                                                                    Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => ReservationProblemPage(
                                                                                                  reservation: widget.reservation,
                                                                                                )));
                                                                                  },
                                                                                  child: Text(
                                                                                    "Signaler un problème",
                                                                                    style: GoogleFonts.poppins(fontSize: manageWidth(context, 15), fontWeight: FontWeight.w500, color: Colors.red),
                                                                                  )),
                                                                              SizedBox(
                                                                                width: manageWidth(context, 5),
                                                                              ),
                                                                              TextButton(
                                                                                  onPressed: () async {
                                                                                    FirebaseFirestore.instance.collection('Reservations').doc(widget.reservation.id).update({
                                                                                      "status": "Terminé",
                                                                                      "buyer confirmation status": true
                                                                                    });
                                                                                    var ref = FirebaseFirestore.instance.collection("ReservationsPayments").doc(widget.reservation.id);
                                                                                    ref.update({
                                                                                      "buyer confirmation status": true
                                                                                    });

                                                                                    var refData = await ref.get();
                                                                                    var data = refData.data();

                                                                                    if ((data!["time"] as Timestamp).toDate().isBefore(DateTime.now().subtract(const Duration(days: 7)))) {
                                                                                      // try {
                                                                                      //   var amountInCents = (data["total amount"] *
                                                                                      //           90 *
                                                                                      //           0.97 as double)
                                                                                      //       .round();

                                                                                      //   // Créer le corps de la requête HTTP
                                                                                      //   Map<String,
                                                                                      //           dynamic>
                                                                                      //       requestBody =
                                                                                      //       {
                                                                                      //     'amount':
                                                                                      //         amountInCents
                                                                                      //             .toString(),
                                                                                      //     'currency':
                                                                                      //         'eur',
                                                                                      //     'destination':
                                                                                      //         data[
                                                                                      //             "seller stripe id"],
                                                                                      //   };

                                                                                      //   // Envoyer la requête HTTP à l'API Stripe
                                                                                      //   final response =
                                                                                      //       await http
                                                                                      //           .post(
                                                                                      //     Uri.parse(
                                                                                      //         'https://api.stripe.com/v1/transfers'),
                                                                                      //     headers: {
                                                                                      //       'Authorization':
                                                                                      //           'Bearer $SECRET_KEY',
                                                                                      //       'Content-Type':
                                                                                      //           'application/x-www-form-urlencoded',
                                                                                      //     },
                                                                                      //     body:
                                                                                      //         requestBody,
                                                                                      //   );

                                                                                      //   // Vérifier si la requête HTTP a réussi
                                                                                      //   if (response
                                                                                      //           .statusCode ==
                                                                                      //       200) {
                                                                                      //     var transfertId =
                                                                                      //         jsonDecode(
                                                                                      //             response.body)["id"];
                                                                                      //     await ref
                                                                                      //         .update({
                                                                                      //       "status":
                                                                                      //           "Encaissé",
                                                                                      //       "date encaissement":
                                                                                      //           Timestamp.now(),
                                                                                      //       "transfert id":
                                                                                      //           transfertId
                                                                                      //     });
                                                                                      //     print(
                                                                                      //         'Transfert réussi ${response.body}');
                                                                                      //   } else {
                                                                                      //     print(
                                                                                      //         'Erreur lors du transfert: ${response.body}');
                                                                                      //   }
                                                                                      // } catch (e) {
                                                                                      //   print(e
                                                                                      //       .toString());
                                                                                      // }

                                                                                      createTransfer(data["total amount"], data["seller stripe id"], ref);
                                                                                    }
                                                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ReservationRatePage(reservation: widget.reservation)));
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
              ));
        });
  }
}
