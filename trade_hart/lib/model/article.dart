import 'package:trade_hart/model/article_color.dart';

class Article {
  String? id;
  String name;
  double price;
  List<dynamic> categories;
  String sellerId;
  int amount;
  String description;
  double averageRate;
  double totalPoints;
  int ratesNumber;
  DateTime date;
  bool status;
  String sellerName;
  Map<String, dynamic> deliveryInformations;
  List<dynamic> images;
  List<NetworkArticleColor> colors;
  Article(
      {this.id,
      required this.name,
      required this.price,
      required this.categories,
      required this.sellerId,
      required this.amount,
      required this.description,
      required this.averageRate,
      required this.totalPoints,
      required this.ratesNumber,
      required this.date,
      required this.status,
      required this.sellerName,
      required this.deliveryInformations,
      required this.images,
      required this.colors});
}
