import 'dart:convert';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_page_view_indicator/flutter_page_view_indicator.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/detail_article_index_provider.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/views/authentication_pages/login_page.dart';
import 'package:trade_hart/views/main_page.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/rate_stars_view.dart';
import 'package:trade_hart/views/main_page_components/pages/adress_ading_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_provider_page.dart';
import 'package:trade_hart/views/main_page_components/pages/service_rates_page.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:http/http.dart' as http;

class ServiceDetailPage extends StatefulWidget {
  final String? serviceId;
  const ServiceDetailPage({super.key, this.serviceId});

  @override
  State<ServiceDetailPage> createState() => _ServiceDetailPageState();
}

class _ServiceDetailPageState extends State<ServiceDetailPage> {
  var currentUser = FirebaseAuth.instance.currentUser;
  String paymentId = "";
  var customerId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, dynamic>? paymentIntent;
  Future<void> makePayment(double price) async {
    setState(() {});
    try {
      paymentIntent = await createPaymentIntent2(
        price.round().toString(),
        'EUR',
      );
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  merchantDisplayName: 'TradeHart',
                  style: ThemeMode.light))
          .then((value) => null);
      await displayPaymentSheet();
    } catch (e) {
      print("error : $e");
    }
  }

  displayPaymentSheet() async {
    try {
      paymentIntent = null;

      await Stripe.instance.presentPaymentSheet().then((value) async {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      Text("Payment réussi!")
                    ],
                  )
                ],
              ),
            );
          },
        );
      }).onError((error, stackTrace) {
        print("error : $error $stackTrace");
      });
    } on StripeException catch (e) {
      print('error $e');
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                    Text("Le paiement n'a pu aboutir veuillez réessayer.")
                  ],
                )
              ],
            ),
          );
        },
      );
    }
  }

  createPaymentIntent2(String amount, String currency) async {
    Map<String, dynamic> body = {'amount': amount, 'currency': currency};
    var url = Uri.parse(
        'https://us-central1-tradehart-f5f44.cloudfunctions.net/createPayment');
    try {
      var response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print(
          'Payment Intent created: ${jsonDecode(response.body)['client_secret']}');
      setState(() {
        paymentId = jsonDecode(response.body)["id"];
      });
      return jsonDecode(response.body);
      // Utilisez client_secret pour finaliser la transaction côté client
    } catch (e) {
      print('Error creating Payment Intent: $e');
    }
  }

  void sendReservationMessage(String customerId, Service service) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, service.sellerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [service.sellerId, currentUserId],
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
              "Bonjour je vous infome que je viens de faire une réservation pour votre service : ${service.name}",
          "date": moment
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {
            "content":
                "Bonjour je vous infome que je viens de faire une réservation pour votre service ${service.name}",
            "sender": currentUserId
          },
          "is all read": {"sender": true, "receiver": false}
        });

        var sellerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(service.sellerId)
            .get();
        sendNotification(
            token: sellerData.data()!["fcmtoken"],
            title: "Nouvelle Réservation",
            body:
                "Une nouvelle réservation pour le service ${service.name} vient d'etre effectuée.",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId,
            route: "/ProviderReservations");
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [service.sellerId, customerId],
          "last message": {
            "content":
                " Bonjour je vous infome que je viens de faire une réservation pour votre service ${service.name}",
            "sender": currentUserId
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
              "Bonjour je vous infome que je viens de faire une réservation pour votre service ${service.name}",
          "date": moment
        });
        var sellerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(service.sellerId)
            .get();
        sendNotification(
            token: sellerData.data()!["fcmtoken"],
            title: "Nouvelle Réservation",
            body:
                "Une nouvelle réservation pour le service ${service.name} vient d'etre effectuée.",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: "/ProviderReservations");
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Une erreur est survenue lors de la confirmation de cette réservation.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }

    // ignore: use_build_context_synchronously
  }

  CarouselSliderController carouselController = CarouselSliderController();
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  String userId = FirebaseAuth.instance.currentUser!.uid;
  Widget buildBottomSheetContent(DateTime pickedDate, TimeOfDay? pickedTime,
      Service service, dynamic creneau, String? day) {
    return BackdropFilter(
      filter: ImageFilter.blur(
          sigmaX: 0.8, sigmaY: 0.8), // Ajustez le flou selon vos préférences
      child: ClipRRect(
        // Couleur de fond avec opacité réduite
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(manageWidth(context, 20)),
          topRight: Radius.circular(manageWidth(context, 20)),
        ),
        child: SizedBox(
          height: manageHeight(context, 400),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: manageHeight(context, 5),
              ),
              Center(
                child: Container(
                  height: manageHeight(context, 3),
                  width: manageWidth(context, 45),
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(
                height: manageHeight(context, 5),
              ),
              Row(
                children: [
                  SizedBox(
                    width: manageWidth(context, 25),
                  ),
                  Text(
                    "Choisir une adresse",
                    style: GoogleFonts.poppins(
                        color: Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: manageWidth(context, 16)),
                  ),
                ],
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('Users')
                      .doc(userId)
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
                    return Expanded(
                      child: ListView(
                        children: adress
                            .map((e) => Row(
                                  children: [
                                    SizedBox(
                                      width: manageWidth(context, 15),
                                    ),
                                    TextButton(
                                        onPressed: () async {
                                          // Ajoutez la date et l'heure sélectionnées à la collection "Reservations" dans Firestore
                                          DateTime selectedDateTime =
                                              pickedTime != null
                                                  ? DateTime(
                                                      pickedDate.year,
                                                      pickedDate.month,
                                                      pickedDate.day,
                                                      pickedTime.hour,
                                                      pickedTime.minute,
                                                    )
                                                  : DateTime(
                                                      pickedDate.year,
                                                      pickedDate.month,
                                                      pickedDate.day,
                                                    );

                                          if (creneau != null && day != null) {
                                            setState(() {});
                                            try {
                                              paymentIntent =
                                                  await createPaymentIntent2(
                                                service.price
                                                    .round()
                                                    .toString(),
                                                'EUR',
                                              );
                                              await Stripe.instance
                                                  .initPaymentSheet(
                                                      paymentSheetParameters:
                                                          SetupPaymentSheetParameters(
                                                              paymentIntentClientSecret:
                                                                  paymentIntent![
                                                                      'client_secret'],
                                                              merchantDisplayName:
                                                                  'TradeHart',
                                                              style: ThemeMode
                                                                  .light))
                                                  .then((value) => null);

                                              try {
                                                paymentIntent = null;

                                                await Stripe.instance
                                                    .presentPaymentSheet()
                                                    .then((value) async {
                                                  // ignore: use_build_context_synchronously

                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const AlertDialog(
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                Text(
                                                                    "Payment réussi!")
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );

                                                  var reservation =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'Reservations')
                                                          .add({
                                                    'buyer id': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'date': Timestamp.fromDate(
                                                        selectedDateTime),
                                                    'creneau reservation status':
                                                        service
                                                            .creneauReservationStatus,
                                                    'seller id':
                                                        service.sellerId,
                                                    'reservation date':
                                                        Timestamp.now(),
                                                    'status':
                                                        'En cours de traitement',
                                                    'service id': service.id,
                                                    'location':
                                                        service.location,
                                                    'buyer adress': e,
                                                    'jour': day,
                                                    'creneau': creneau,
                                                    'time': Timestamp.now()

                                                    // Ajoutez d'autres champs de réservation si nécessaire
                                                  });
                                                  var seller =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("Users")
                                                          .doc(service.sellerId)
                                                          .get();
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'ReservationsPayments')
                                                      .doc(reservation.id)
                                                      .set({
                                                    'buyer confirmation status':
                                                        false,
                                                    'buyer id': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'reservation id':
                                                        reservation.id,
                                                    'number': 1,
                                                    'seller confirmation status':
                                                        false,
                                                    'seller id':
                                                        service.sellerId,
                                                    'seller stripe id': seller
                                                            .data()![
                                                        "stripe account id"],
                                                    'status':
                                                        'En cours de traitement',
                                                    'time': Timestamp.now(),
                                                    'total amount':
                                                        service.price,
                                                    'service id': service.id,
                                                    "payment id": paymentId
                                                  });

                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Réservation ajoutée avec succès.'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );

                                                  sendReservationMessage(
                                                      customerId, service);
                                                }).onError((error, stackTrace) {
                                                  print(
                                                      "error : $error $stackTrace");
                                                });
                                              } on StripeException catch (e) {
                                                print('error $e');
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const AlertDialog(
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.clear,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              Text(
                                                                  "Le paiement n'a pu aboutir veuillez réessayer.")
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            } catch (e) {
                                              print("error : $e");
                                            }
                                          } else {
                                            try {
                                              paymentIntent =
                                                  await createPaymentIntent2(
                                                service.price
                                                    .round()
                                                    .toString(),
                                                'EUR',
                                              );
                                              await Stripe.instance
                                                  .initPaymentSheet(
                                                      paymentSheetParameters:
                                                          SetupPaymentSheetParameters(
                                                              paymentIntentClientSecret:
                                                                  paymentIntent![
                                                                      'client_secret'],
                                                              merchantDisplayName:
                                                                  'TradeHart',
                                                              style: ThemeMode
                                                                  .light))
                                                  .then((value) => null);

                                              try {
                                                paymentIntent = null;

                                                await Stripe.instance
                                                    .presentPaymentSheet()
                                                    .then((value) async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const AlertDialog(
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                Text(
                                                                    "Payment réussi!")
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );

                                                  var reservation =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'Reservations')
                                                          .add({
                                                    'buyer id': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'date': Timestamp.fromDate(
                                                        selectedDateTime),
                                                    'creneau reservation status':
                                                        service
                                                            .creneauReservationStatus,
                                                    'seller id':
                                                        service.sellerId,
                                                    'reservation date':
                                                        Timestamp.now(),
                                                    'status':
                                                        'En cours de traitement',
                                                    'service id': service.id,
                                                    'location':
                                                        service.location,
                                                    'buyer adress': e,
                                                    'time': Timestamp.now()

                                                    // Ajoutez d'autres champs de réservation si nécessaire
                                                  });

                                                  var seller =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("Users")
                                                          .doc(service.sellerId)
                                                          .get();
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'ReservationsPayments')
                                                      .doc(reservation.id)
                                                      .set({
                                                    'buyer confirmation status':
                                                        false,
                                                    'buyer id': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'reservation id':
                                                        reservation.id,
                                                    'number': 1,
                                                    'seller confirmation status':
                                                        false,
                                                    'seller id':
                                                        service.sellerId,
                                                    'seller stripe id': seller
                                                            .data()![
                                                        "stripe account id"],
                                                    'status':
                                                        'En cours de traitement',
                                                    'time': Timestamp.now(),
                                                    'total amount':
                                                        service.price,
                                                    'service id': service.id,
                                                    "payment id": paymentId
                                                  });
                                                  // ignore: use_build_context_synchronously
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Réservation ajoutée avec succès.'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                  sendReservationMessage(
                                                      customerId, service);
                                                }).onError((error, stackTrace) {
                                                  print(
                                                      "error : $error $stackTrace");
                                                });
                                              } on StripeException catch (e) {
                                                print('error $e');
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const AlertDialog(
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.clear,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              Text(
                                                                  "Le paiement n'a pu aboutir veuillez réessayer.")
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            } catch (e) {
                                              print("error : $e");
                                            }
                                          }
                                        },
                                        child: Text(
                                          '${e['adress']}, ${e['code postal']}, ${e['city']}',
                                          style: TextStyle(
                                              fontSize:
                                                  manageWidth(context, 16)),
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ],
                                ))
                            .toList(),
                      ),
                    );
                  }),
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
          ),
        ),
      ),
    );
  }

  Future<void> selectDateAndTime(BuildContext context2, Service service) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('fr'),
      helpText: 'Selectionnez une date',
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // 1 an à partir de la date d'aujourd'hui
    );
    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? pickedTime = await showTimePicker(
        helpText: 'A quelle heure?',
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });

        try {
          paymentIntent = await createPaymentIntent2(
            service.price.round().toString(),
            'EUR',
          );
          await Stripe.instance
              .initPaymentSheet(
                  paymentSheetParameters: SetupPaymentSheetParameters(
                      paymentIntentClientSecret:
                          paymentIntent!['client_secret'],
                      merchantDisplayName: 'TradeHart',
                      style: ThemeMode.light))
              .then((value) => null);

          try {
            paymentIntent = null;

            await Stripe.instance.presentPaymentSheet().then((value) async {
              showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                            Text("Payment réussi!")
                          ],
                        )
                      ],
                    ),
                  );
                },
              );

              DateTime selectedDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              var reservation = await FirebaseFirestore.instance
                  .collection('Reservations')
                  .add({
                'buyer id': FirebaseAuth.instance.currentUser!.uid,
                'date': Timestamp.fromDate(selectedDateTime),
                'creneau reservation status': service.creneauReservationStatus,
                'seller id': service.sellerId,
                'reservation date': Timestamp.now(),
                'status': 'En cours de traitement',
                'service id': service.id,
                'location': service.location,
                'time': Timestamp.now()
              });
              var seller = await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(service.sellerId)
                  .get();
              FirebaseFirestore.instance
                  .collection('ReservationsPayments')
                  .doc(reservation.id)
                  .set({
                'buyer confirmation status': false,
                'buyer id': FirebaseAuth.instance.currentUser!.uid,
                'reservation id': reservation.id,
                'number': 1,
                'seller confirmation status': false,
                'seller id': service.sellerId,
                'seller stripe id': seller.data()!["stripe account id"],
                'status': 'En cours de traitement',
                'time': Timestamp.now(),
                'total amount': service.price,
                'service id': service.id,
                "payment id": paymentId
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Réservation ajoutée avec succès.'),
                  backgroundColor: Colors.green,
                ),
              );
              // ignore: use_build_context_synchronously
              Navigator.pop(context);

              sendReservationMessage(customerId, service);
            }).onError((error, stackTrace) {
              print("error : $error $stackTrace");
            });
          } on StripeException catch (e) {
            print('error $e');
            showDialog(
              context: context,
              builder: (context) {
                return const AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                          Text("Le paiement n'a pu aboutir veuillez réessayer.")
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          }
        } catch (e) {
          print("error : $e");
        }

        // Ajoutez la date et l'heure sélectionnées à la collection "Reservations" dans Firestore

        // ignore: use_build_context_synchronously
      }
    }
  }

  Future<void> selectDateAndCreneau(
      BuildContext context2, Service service) async {
    List<String> jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('fr'),
      helpText: 'Selectionnez une date',
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // 1 an à partir de la date d'aujourd'hui
    );
    if (pickedDate != null) {
      // ignore: use_build_context_synchronously

      // ignore: use_build_context_synchronously
      showBottomSheet(
        context: context2,
        builder: (context2) => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 0.8,
            sigmaY: 0.8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(manageWidth(context2, 20)),
              topRight: Radius.circular(manageWidth(context2, 20)),
            ),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Reservations')
                  .where('service id', isEqualTo: service.id)
                  .where('creneau reservation status', isEqualTo: true)
                  .where('date',
                      isEqualTo: Timestamp.fromDate(DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                      )))
                  .snapshots(),
              builder: (context2, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var reservations = snapshot.data!.docs;
                var creneaux = reservations.isEmpty
                    ? []
                    : reservations.map((e) => e['creneau']).toList();
                return SizedBox(
                  height: manageHeight(context2, 400),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: manageHeight(context2, 5),
                      ),
                      Center(
                        child: Container(
                          height: manageHeight(context2, 3),
                          width: manageWidth(context2, 45),
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        "Créneaux",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context2, 16),
                        ),
                      ),
                      SizedBox(
                        height: manageHeight(context2, 10),
                      ),
                      Expanded(
                        child: ListView(
                          children: !(service.crenaux!.any((element) =>
                                  (element['jour'] as String).toLowerCase() ==
                                  jours[pickedDate.weekday - 1].toLowerCase()))
                              ? [
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: manageHeight(context2, 100),
                                      ),
                                      Center(
                                        child: Text(
                                          "Le service n'est pas disponible le ${jours[pickedDate.weekday - 1].toLowerCase()}. \n Pour plus d'informations, veuillez contacter le prestataire.",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: manageWidth(context2, 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ]
                              : (service.crenaux!.firstWhere((element) =>
                                              (element['jour'] as String).toLowerCase() ==
                                              jours[pickedDate.weekday - 1]
                                                  .toLowerCase())['horaires']
                                          as List)
                                      .where((creneau) =>
                                          creneau['capacite'] >
                                          creneaux
                                              .where((element) =>
                                                  element['heure'] == creneau['heure'] && element['minutes'] == creneau['minutes'])
                                              .length)
                                      .isEmpty
                                  ? [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: manageHeight(context2, 150),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(
                                              manageWidth(context2, 8.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                "Aucun créneau disponible pour cette date.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey.shade800,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      manageWidth(context2, 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]
                                  : (service.crenaux!.firstWhere((element) => (element['jour'] as String).toLowerCase() == jours[pickedDate.weekday - 1].toLowerCase())['horaires'] as List)
                                      .where((creneau) => creneau['capacite'] > creneaux.where((element) => element['heure'] == creneau['heure'] && element['minutes'] == creneau['minutes']).length)
                                      .map(
                                        (e) => TextButton(
                                          child: Text(
                                            '${e['heure']} : ${e['minutes']}',
                                            style: TextStyle(
                                              fontSize:
                                                  manageWidth(context2, 18),
                                            ),
                                          ),
                                          onPressed: () async {
                                            // Ajoutez la date et l'heure sélectionnées à la collection "Reservations" dans Firestore
                                            DateTime selectedDateTime =
                                                DateTime(
                                              pickedDate.year,
                                              pickedDate.month,
                                              pickedDate.day,
                                            );

                                            try {
                                              paymentIntent =
                                                  await createPaymentIntent2(
                                                service.price
                                                    .round()
                                                    .toString(),
                                                'EUR',
                                              );
                                              await Stripe.instance
                                                  .initPaymentSheet(
                                                      paymentSheetParameters:
                                                          SetupPaymentSheetParameters(
                                                              paymentIntentClientSecret:
                                                                  paymentIntent![
                                                                      'client_secret'],
                                                              merchantDisplayName:
                                                                  'TradeHart',
                                                              style: ThemeMode
                                                                  .light))
                                                  .then((value) => null);

                                              try {
                                                paymentIntent = null;

                                                await Stripe.instance
                                                    .presentPaymentSheet()
                                                    .then((value) async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return const AlertDialog(
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .green,
                                                                ),
                                                                Text(
                                                                    "Payment réussi!")
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  var reservation =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(
                                                              'Reservations')
                                                          .add({
                                                    'buyer id': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'date': Timestamp.fromDate(
                                                      selectedDateTime,
                                                    ),
                                                    'creneau reservation status':
                                                        service
                                                            .creneauReservationStatus,
                                                    'seller id':
                                                        service.sellerId,
                                                    'reservation date':
                                                        Timestamp.now(),
                                                    'status':
                                                        'En cours de traitement',
                                                    'service id': service.id,
                                                    'location':
                                                        service.location,
                                                    'creneau': e,
                                                    'jour': jours[
                                                        pickedDate.weekday - 1],
                                                    'time': Timestamp.now(),
                                                    // Ajoutez d'autres champs de réservation si nécessaire
                                                  });
                                                  var seller =
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection("Users")
                                                          .doc(service.sellerId)
                                                          .get();
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'ReservationsPayments')
                                                      .doc(reservation.id)
                                                      .set({
                                                    'buyer confirmation status':
                                                        false,
                                                    'buyer id': FirebaseAuth
                                                        .instance
                                                        .currentUser!
                                                        .uid,
                                                    'reservation id':
                                                        reservation.id,
                                                    'number': 1,
                                                    'seller confirmation status':
                                                        false,
                                                    'seller id':
                                                        service.sellerId,
                                                    'seller stripe id': seller
                                                            .data()![
                                                        "stripe account id"],
                                                    'status':
                                                        'En cours de traitement',
                                                    'time': Timestamp.now(),
                                                    'total amount':
                                                        service.price,
                                                    'service id': service.id,
                                                    "payment id": paymentId
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Réservation ajoutée avec succès.'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                  // ignore: use_build_context_synchronously
                                                  Navigator.pop(context);
                                                  sendReservationMessage(
                                                      customerId, service);
                                                  sendReservationMessage(
                                                      customerId, service);
                                                }).onError((error, stackTrace) {
                                                  print(
                                                      "error : $error $stackTrace");
                                                });
                                              } on StripeException catch (e) {
                                                print('error $e');
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return const AlertDialog(
                                                      content: Column(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Icon(
                                                                Icons.clear,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              Text(
                                                                  "Le paiement n'a pu aboutir veuillez réessayer.")
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                );
                                              }
                                            } catch (e) {
                                              print("error : $e");
                                            }
                                          },
                                        ),
                                      )
                                      .toList(),
                        ),
                      ),
                      SizedBox(
                        height: manageHeight(context2, 5),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  Future<void> selectDateAndCreneauAndAdress(
      BuildContext context2, Service service) async {
    List<String> jours = [
      'Lundi',
      'Mardi',
      'Mercredi',
      'Jeudi',
      'Vendredi',
      'Samedi',
      'Dimanche',
    ];
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('fr'),
      helpText: 'Selectionnez une date',
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // 1 an à partir de la date d'aujourd'hui
    );
    if (pickedDate != null) {
      // ignore: use_build_context_synchronously

      // ignore: use_build_context_synchronously
      showBottomSheet(
        context: context2,
        builder: (context2) => BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 0.8,
            sigmaY: 0.8,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(manageWidth(context, 20)),
              topRight: Radius.circular(manageWidth(context, 20)),
            ),
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Reservations')
                  .where('service id', isEqualTo: service.id)
                  .where('creneau reservation status', isEqualTo: true)
                  .where('date',
                      isEqualTo: Timestamp.fromDate(DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                      )))
                  .snapshots(),
              builder: (context2, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                var reservations = snapshot.data!.docs;
                var creneaux = reservations.isEmpty
                    ? []
                    : reservations.map((e) => e['creneau']).toList();
                return SizedBox(
                  height: manageHeight(context, 400),
                  width: double.infinity,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: manageHeight(context, 5),
                      ),
                      Center(
                        child: Container(
                          height: manageHeight(context, 3),
                          width: manageWidth(context, 45),
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        "Créneaux",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16),
                        ),
                      ),
                      SizedBox(
                        height: manageHeight(context, 10),
                      ),
                      Expanded(
                        child: ListView(
                          children: !(service.crenaux!.any((element) =>
                                  (element['jour'] as String).toLowerCase() ==
                                  jours[pickedDate.weekday - 1].toLowerCase()))
                              ? [
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: manageHeight(context, 100),
                                      ),
                                      Center(
                                        child: Text(
                                          "Le service n'est pas disponible le ${jours[pickedDate.weekday - 1].toLowerCase()}. \n Pour plus d'informations, veuillez contacter le prestataire.",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey.shade800,
                                            fontWeight: FontWeight.bold,
                                            fontSize: manageWidth(context, 16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ]
                              : (service.crenaux!.firstWhere((element) =>
                                              (element['jour'] as String).toLowerCase() ==
                                              jours[pickedDate.weekday - 1]
                                                  .toLowerCase())['horaires']
                                          as List)
                                      .where((creneau) =>
                                          creneau['capacite'] >
                                          creneaux
                                              .where((element) =>
                                                  element['heure'] == creneau['heure'] && element['minutes'] == creneau['minutes'])
                                              .length)
                                      .isEmpty
                                  ? [
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: manageHeight(context, 150),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(
                                                manageWidth(context, 8.0)),
                                            child: Center(
                                              child: Text(
                                                "Aucun créneau disponible pour cette date.",
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey.shade800,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      manageWidth(context, 16),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ]
                                  : (service.crenaux!.firstWhere((element) => (element['jour'] as String).toLowerCase() == jours[pickedDate.weekday - 1].toLowerCase())['horaires'] as List)
                                      .where((creneau) => creneau['capacite'] > creneaux.where((element) => element['heure'] == creneau['heure'] && element['minutes'] == creneau['minutes']).length)
                                      .map(
                                        (e) => TextButton(
                                          child: Text(
                                            '${e['heure']} : ${e['minutes']}',
                                            style: TextStyle(
                                                fontSize:
                                                    manageWidth(context, 18)),
                                          ),
                                          onPressed: () {
                                            showBottomSheet(
                                              context: context2,
                                              builder: (context2) =>
                                                  buildBottomSheetContent(
                                                pickedDate,
                                                null,
                                                service,
                                                e,
                                                jours[pickedDate.weekday - 1],
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      .toList(),
                        ),
                      ),
                      SizedBox(
                        height: manageHeight(context, 5),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    }
  }

  Future<void> selectDateAndTimeAndAdress(
      BuildContext context2, Service service) async {
    final DateTime? pickedDate = await showDatePicker(
      locale: const Locale('fr'),
      helpText: 'Selectionnez une date',
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now()
          .add(const Duration(days: 365)), // 1 an à partir de la date d'aujourd'hui
    );
    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      final TimeOfDay? pickedTime = await showTimePicker(
        helpText: 'A quelle heure?',
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          selectedDate = pickedDate;
          selectedTime = pickedTime;
        });

        // ignore: use_build_context_synchronously
        showBottomSheet(
            context: context2,
            builder: (context2) => buildBottomSheetContent(
                pickedDate, pickedTime, service, null, null));
      }
    }
  }

  @override
  void initState() {
    if (context.read<DetailsIndexProvider>().index != 0) {
      context.read<DetailsIndexProvider>().reset();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments;
    String? serviceId;
    if (message != null) {
      serviceId = (message as Map)["serviceId"];
    }
    return Scaffold(
        appBar: AppBar(
          title: AppBarTitleText(
              title: "TradeHart", size: manageWidth(context, 20)),
          leading: GestureDetector(
            onTap: () {
              if (widget.serviceId == null) {
                Navigator.pushAndRemoveUntil(
                    (context),
                    MaterialPageRoute(builder: (context) => const MainPage()),
                    (Route<dynamic> route) => false);
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(
              CupertinoIcons.clear_thick_circled,
              color: const Color.fromARGB(255, 141, 141, 141).withOpacity(0.8),
              size: manageWidth(context, 25),
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Services')
              .doc(widget.serviceId ?? serviceId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: AppColors.mainColor,
              ));
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Service not found'));
            }
            var serviceData = snapshot.data!.data() as Map<String, dynamic>;
            var service = Service(
                crenaux: serviceData['crenaux'],
                id: widget.serviceId ?? serviceId,
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

            return SingleChildScrollView(
                child: Consumer<DetailsIndexProvider>(
              builder: (context, value, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CarouselSlider(
                    carouselController: carouselController,
                    items: service.images
                        .map(
                          (image) => Container(
                            width: MediaQuery.of(context).size.width * 0.95,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 15)),
                              color: Colors.grey.shade300,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  manageWidth(context, 15)),
                              child: InstaImageViewer(
                                imageUrl: image['image url'],
                                child: Image.network(image['image url'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                  return SizedBox(
                                      height: manageHeight(context, 150),
                                      width: manageWidth(context, 165),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            CupertinoIcons
                                                .exclamationmark_triangle,
                                            size: manageWidth(context, 30),
                                          ),
                                          SizedBox(
                                            height: manageHeight(context, 3),
                                          ),
                                          const Text(
                                            "Erreur lors du chargement",
                                            style: TextStyle(color: Colors.red),
                                            textAlign: TextAlign.center,
                                          )
                                        ],
                                      ));
                                }),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    options: CarouselOptions(
                      onPageChanged: (index, reason) {
                        context.read<DetailsIndexProvider>().upDateIndex(index);
                      },
                      enableInfiniteScroll: false,
                      enlargeCenterPage: true,
                      aspectRatio: 11.8 / 10,
                      viewportFraction: 0.98,
                      initialPage: context.read<DetailsIndexProvider>().index,
                      autoPlay: false,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: service.images.length *
                          1.2 *
                          manageWidth(context, 15),
                      margin: EdgeInsets.only(
                        top: manageHeight(context, 5),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius:
                            BorderRadius.circular(manageWidth(context, 10)),
                      ),
                      child: PageViewIndicator(
                        length: service.images.length,
                        currentIndex: value.index,
                        currentSize: manageWidth(context, 8),
                        otherSize: manageWidth(context, 6),
                        margin: EdgeInsets.all(manageWidth(context, 2.5)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: manageHeight(context, 10),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        padding:
                            EdgeInsets.only(right: manageWidth(context, 15)),
                        child: Text(
                          service.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: manageWidth(context, 18),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '\$${service.price}',
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 18),
                        ),
                      ),
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: manageWidth(context, 15),
                      right: manageWidth(context, 10),
                    ),
                    child: Text(
                      service.location,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 155, 89, 69),
                        fontSize: manageWidth(context, 14.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: manageHeight(context, 5),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 7),
                      ),
                      RateStars(
                        rate: service.averageRate.round(),
                        nbRates: service.ratesNumber,
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceRatePage(service: service),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "voir tous les avis",
                          style: GoogleFonts.poppins(
                            fontSize: manageWidth(context, 14),
                            fontWeight: FontWeight.w500,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 5),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                      Text(
                        "Proposé par : ${service.sellerName}",
                        style: GoogleFonts.poppins(
                          fontSize: manageWidth(context, 14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(
                        width: manageWidth(context, 5),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ServiceProviderPage(id: service.sellerId),
                              ),
                            );
                          }
                        },
                        child: Text(
                          "voir le profil",
                          style: GoogleFonts.poppins(
                            fontSize: manageWidth(context, 14),
                            color: Colors.blueAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: manageWidth(context, 5),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 5),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: manageWidth(context, 15),
                      right: manageWidth(context, 10),
                    ),
                    child: Text(
                      service.description,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: manageWidth(context, 15.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: manageWidth(context, 15),
                      right: manageWidth(context, 10),
                      top: manageHeight(context, 10),
                    ),
                    child: Text(
                      'Durée moyenne: ${service.duration}',
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color.fromARGB(255, 155, 89, 69),
                        fontSize: manageWidth(context, 14.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        LinkProviderService().shareLink(
                            service.name,
                            "${service.description}.\n Reservez sur tradeHart chez ${service.sellerName}",
                            null,
                            service.id,
                            null,
                            service.sellerId,
                            '/ServiceDetailsPage',
                            service.images.first["image url"]);
                      },
                      child: const Text("Partager")),
                  SizedBox(
                    height: manageHeight(context, 120),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: manageWidth(context, 15),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (currentUser == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginPage()));
                          } else {
                            if (service.creneauReservationStatus) {
                              if (service.location == 'Service à dommicile') {
                                selectDateAndCreneauAndAdress(context, service);
                              } else {
                                selectDateAndCreneau(context, service);
                              }
                            } else if (service.location ==
                                'Service à dommicile') {
                              selectDateAndTimeAndAdress(context, service);
                            } else {
                              selectDateAndTime(context, service);
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(manageWidth(context, 8)),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                offset: const Offset(0, 0),
                                blurRadius: manageWidth(context, 5),
                                spreadRadius: manageWidth(context, 0.4),
                              )
                            ],
                            borderRadius:
                                BorderRadius.circular(manageWidth(context, 30)),
                            color: const Color.fromARGB(255, 250, 102, 92),
                          ),
                          width: manageWidth(context, 200),
                          height: manageHeight(context, 55),
                          child: Center(
                            child: Text(
                              "Buy now",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: manageWidth(context, 16.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.all(manageWidth(context, 8)),
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: const Offset(0, 0),
                              blurRadius: manageWidth(context, 5),
                              spreadRadius: manageWidth(context, 0.4),
                            )
                          ],
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 30)),
                          color: const Color.fromARGB(255, 119, 101, 172)
                              .withOpacity(0.4),
                        ),
                        width: manageWidth(context, 80),
                        height: manageHeight(context, 55),
                        child: Icon(
                          CupertinoIcons.heart,
                          color: const Color.fromARGB(255, 255, 111, 101),
                          size: manageWidth(context, 32),
                        ),
                      ),
                      SizedBox(
                        width: manageWidth(context, 15),
                      )
                    ],
                  ),
                  SizedBox(
                    height: manageHeight(context, 15),
                  )
                ],
              ),
            ));
          },
        ));
  }
}
