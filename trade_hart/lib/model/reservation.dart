import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_hart/model/adress.dart';
import 'package:trade_hart/model/crenau.dart';

class Reservation {
  final String id;
  final String buyerId;
  final Crenau? creneau;

  final bool creneauReservationStatus;
  final Timestamp date;
  final Timestamp time;

  final String location;

  final String sellerId;
  final String serviceId;
  final String status;
  final Adress? buyerAdres;
  final bool buyerConfirmationStatus;
  final bool sellerConfirmationStatus;

  Reservation(
      {required this.buyerId,
      required this.creneau,
      required this.creneauReservationStatus,
      required this.date,
      required this.location,
      required this.sellerId,
      required this.serviceId,
      required this.status,
      required this.buyerAdres,
      required this.id,
      required this.time,
      required this.buyerConfirmationStatus,
      required this.sellerConfirmationStatus});
}
