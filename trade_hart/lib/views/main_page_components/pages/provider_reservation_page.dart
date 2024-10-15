import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/model/adress.dart';
import 'package:trade_hart/model/crenau.dart';
import 'package:trade_hart/model/reservation.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/provider_reservation_view.dart';

class ProviderReservationsPage extends StatefulWidget {
  const ProviderReservationsPage({super.key});

  @override
  State<ProviderReservationsPage> createState() =>
      _ProviderReservationsPageState();
}

class _ProviderReservationsPageState extends State<ProviderReservationsPage> {
  String filter = "Toutes";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitleText(
          title: "Mes réservations",
          size: manageWidth(context, 19),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          manageWidth(context, 8.0),
          manageHeight(context, 8.0),
          manageWidth(context, 8.0),
          manageHeight(context, 8.0),
        ),
        child: StreamBuilder(
          stream: filter != "Toutes"
              ? FirebaseFirestore.instance
                  .collection('Reservations')
                  .where('seller id',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .where("status", isEqualTo: filter)
                  .orderBy('date', descending: true)
                  .snapshots()
              : FirebaseFirestore.instance
                  .collection('Reservations')
                  .where('seller id',
                      isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                  .orderBy('date', descending: true)
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
                  title: "Aucune réservation",
                  size: manageWidth(context, 18),
                ),
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
                      items: const [
                        DropdownMenuItem(
                          value: "Toutes",
                          child: Text("Toutes"),
                        ),
                        DropdownMenuItem(
                          value: "En cours de traitement",
                          child: Text("En cours de traitement"),
                        ),
                        DropdownMenuItem(
                          value: "Confirmé",
                          child: Text("Confirmée(s)"),
                        ),
                        DropdownMenuItem(
                          value: "Terminé",
                          child: Text("Terminée(s)"),
                        ),
                        DropdownMenuItem(
                          value: "Annulé",
                          child: Text("Annulée(s)"),
                        ),
                        DropdownMenuItem(
                          value: "Signalé",
                          child: Text("Signalée(s)"),
                        ),
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
                    cacheExtent: manageHeight(context, 2800.0),
                    children: data.map((e) {
                      var reservationData = e.data();
                      Reservation reservation = Reservation(
                        sellerConfirmationStatus:
                            reservationData["seller confirmation status"] ??
                                false,
                        buyerConfirmationStatus:
                            reservationData["buyer confirmation status"] ??
                                false,
                        time: reservationData["time"],
                        buyerAdres: reservationData["buyer adress"] == null
                            ? null
                            : Adress(
                                adress: reservationData["buyer adress"]
                                    ["adress"],
                                city: reservationData["buyer adress"]["city"],
                                codePostal: reservationData["buyer adress"]
                                    ["code postal"],
                                complement: reservationData["buyer adress"]
                                    ["complement"],
                              ),
                        creneauReservationStatus:
                            reservationData["creneau reservation status"],
                        location: reservationData["location"],
                        serviceId: reservationData["service id"],
                        creneau: reservationData["creneau"] == null
                            ? null
                            : Crenau(
                                heure: reservationData["creneau"]["heure"],
                                minutes: reservationData["creneau"]["minutes"],
                                nombreDePlace: reservationData["creneau"]
                                    ["capacite"],
                              ),
                        id: e.id,
                        buyerId: reservationData["buyer id"],
                        sellerId: reservationData["seller id"],
                        status: reservationData["status"],
                        date: reservationData["date"],
                      );

                      return ProviderReservationView(reservation: reservation);
                    }).toList(),
                  ),
                ),
                SizedBox(
                  height: manageHeight(context, 5),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
