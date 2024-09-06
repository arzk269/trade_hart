import 'dart:io';
import 'package:trade_hart/model/article_size.dart';

class ArticleColor {
  String color;
  File imageFile;
  int amount;
  List<ArticleSize> sizes;
  int articleGroupSizeValue;

  ArticleColor(
      {required this.color,
      required this.imageFile,
      required this.amount,
      required this.sizes,
      required this.articleGroupSizeValue});
}

class NetworkArticleColor {
  String color;
  String imageUrl;
  int amount;
  List<dynamic> sizes;

  NetworkArticleColor({
    required this.color,
    required this.imageUrl,
    required this.amount,
    required this.sizes,
  });
}
