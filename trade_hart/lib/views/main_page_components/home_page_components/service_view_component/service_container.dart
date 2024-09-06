import 'package:flutter/material.dart';
import 'package:trade_hart/model/service.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/price_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/product_image_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/product_name_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/rate_stars_view.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';

class ServiceContainer extends StatefulWidget {
  final Service service;
  const ServiceContainer({super.key, required this.service});

  @override
  State<ServiceContainer> createState() => _ServiceContainerState();
}

class _ServiceContainerState extends State<ServiceContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1.5,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          color: const Color.fromARGB(255, 246, 242, 242),
          borderRadius: BorderRadius.circular(11)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProductImageView(imagePath: widget.service.images[0]["image url"]),
          SizedBox(height: manageWidth(context, 5)),
          ProductNameView(name: widget.service.name),
          RateStars(
              rate: widget.service.averageRate.round(),
              nbRates: widget.service.ratesNumber),
          PriceView(price: widget.service.price),
          SellerNameView(name: widget.service.sellerName)
        ],
      ),
    );
  }
}
