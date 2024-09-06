import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/categories_provider.dart';
import 'package:trade_hart/size_manager.dart';

class SubCategoryView extends StatefulWidget {
  final int category;
  final String subCategory;
  const SubCategoryView(
      {super.key, required this.subCategory, required this.category});

  @override
  State<SubCategoryView> createState() => _SubCategoryViewState();
}

class _SubCategoryViewState extends State<SubCategoryView> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CategoriesProvider>(
      builder: (context, value, child) => SizedBox(
        height: manageHeight(context, 58),
        width: manageWidth(context, 530),
        child: ListTile(
          leading: Checkbox(
              value: widget.category == 0
                  ? value.articleCategories.contains(widget.subCategory)
                  : value.serviceCategories.contains(widget.subCategory),
              onChanged: (change) {
                if (change!) {
                  if (widget.category == 0) {
                    context
                        .read<CategoriesProvider>()
                        .addarticleCategory(widget.subCategory);
                  } else {
                    value.addServiceCatgory(widget.subCategory);
                  }
                } else {
                  if (widget.category == 0) {
                    context
                        .read<CategoriesProvider>()
                        .removearticleCategory(widget.subCategory);
                  } else {
                    value.removeServiceCategory(widget.subCategory);
                  }
                }
              }),
          title: Text(
            widget.subCategory,
            style: TextStyle(fontSize: manageWidth(context, 14)),
          ),
        ),
      ),
    );
  }
}
