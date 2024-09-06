import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/price_filter_provider.dart';
import 'package:trade_hart/size_manager.dart';

class AuthTextField extends StatefulWidget {
  final bool obscuretext;
  final String hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final double? width;
  final Color? color;
  final bool forPriceFilter;
  final bool? forArticlePriceFilter;
  final bool? forMaxPrice;

  final bool forProviderInformations;

  const AuthTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      required this.obscuretext,
      this.keyboardType = TextInputType.text,
      this.width,
      this.color,
      this.forPriceFilter = false,
      this.forArticlePriceFilter,
      this.forMaxPrice,
      this.forProviderInformations = true});

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  final FocusNode focusNode = FocusNode();
  Timer? timer;

  void startTimer() {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 2), () {
      focusNode.unfocus();
    });
  }

  void onTextChanged(String text) {
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
        width: widget.width ?? manageWidth(context, 355),
        height: manageHeight(context, 60),
        decoration: BoxDecoration(
            color: widget.color ?? Colors.grey.shade100,
            borderRadius: BorderRadius.circular(manageHeight(context, 20))),
        child: Padding(
            padding: EdgeInsets.all(manageWidth(context, 8)),
            child: Consumer<PriceFilterProvider>(
              builder: (context, value, child) => TextField(
                onChanged: widget.forPriceFilter
                    ? (price) {
                        if (widget.forArticlePriceFilter!) {
                          if (widget.forMaxPrice!) {
                            value.getMaxArticlePrice(
                                double.tryParse(price) ?? 0);
                          } else {
                            value.getMinArticlePrice(
                                double.tryParse(price) ?? 0);
                          }
                        } else if (!widget.forArticlePriceFilter!) {
                          if (widget.forMaxPrice!) {
                            value.getMaxServicePrice(
                                double.tryParse(price) ?? 0);
                          } else {
                            value.getMinServicePrice(
                                double.tryParse(price) ?? 0);
                          }
                        }
                      }
                    : widget.forProviderInformations
                        ? onTextChanged
                        : (price) {},
                keyboardType: widget.keyboardType,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.hintText,
                ),
                obscureText: widget.obscuretext,
                controller: widget.controller,
                focusNode: widget.forProviderInformations ? focusNode : null,
              ),
            )));
  }
}
