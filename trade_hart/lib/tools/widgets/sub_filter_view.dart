import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/search_filter_provider.dart';
import 'package:trade_hart/size_manager.dart';

class SubFilterView extends StatefulWidget {
  final int category;
  final String subCategory;
  const SubFilterView(
      {super.key, required this.subCategory, required this.category});

  @override
  State<SubFilterView> createState() => _SubFilterViewState();
}

class _SubFilterViewState extends State<SubFilterView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchFilterProvider>(
      builder: (context, value, child) => SizedBox(
        height: manageWidth(context, 58),
        width: manageWidth(context, 530),
        child: ListTile(
          leading: Checkbox(
              value: widget.category == 0
                  ? value.articlesFilters.contains(widget.subCategory)
                  : value.servicesFilters.contains(widget.subCategory),
              onChanged: (change) {
                if (change!) {
                  if (widget.category == 0) {
                    value.addToArticlesFilters(widget.subCategory);
                  } else {
                    value.addToServicesFilters(widget.subCategory);
                  }
                } else {
                  if (widget.category == 0) {
                    value.removeFromArticlesFilters(widget.subCategory);
                  } else {
                    value.removeFromServicesFilters(widget.subCategory);
                  }
                }
              }),
          title: Text(
            widget.subCategory,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ),
    );
  }
}
