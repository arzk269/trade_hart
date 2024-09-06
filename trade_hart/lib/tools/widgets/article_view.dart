import 'package:flutter/material.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/price_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/product_image_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/product_name_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/rate_stars_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';

class ArticleView extends StatefulWidget {
  final Article article;
  const ArticleView({super.key, required this.article});

  @override
  State<ArticleView> createState() => _AtricleViewState();
}

class _AtricleViewState extends State<ArticleView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: manageWidth(context, 0),
        vertical: manageHeight(context, 0),
      ),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: manageWidth(context, 1.5),
            blurRadius: manageWidth(context, 5),
            offset: const Offset(0, 2),
          ),
        ],
        color: const Color.fromARGB(255, 246, 242, 242),
        borderRadius: BorderRadius.circular(manageWidth(context, 11)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageView(imagePath: widget.article.images[0]['image url']),
          SizedBox(height: manageHeight(context, 15)),
          ProductNameView(name: widget.article.name),
          RateStars(
            rate: widget.article.averageRate.round(),
            nbRates: widget.article.ratesNumber,
          ),
          PriceView(price: widget.article.price),
          SellerNameView(name: widget.article.sellerName),
        ],
      ),
    );
  }
}
