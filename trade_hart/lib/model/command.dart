import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trade_hart/model/adress.dart';

class Command {
  final int amount;
  final String articleId;
  final String buyerId;
  final int colorIndex;
  final String sellerId;
  final int sizeIndex;
  final String status;
  final Timestamp time;
  final Adress? adress;
  final String id;

  Command(
      {required this.amount,
      required this.articleId,
      required this.buyerId,
      required this.colorIndex,
      required this.sellerId,
      required this.sizeIndex,
      required this.status,
      required this.time,
      this.adress,
      required this.id});
}
