import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/tools/widgets/sub_filter_view.dart';

class SubFiltersPage extends StatefulWidget {
  final int subcategory;
  final String filter;
  final List<String> subFilters;
  const SubFiltersPage(
      {super.key,
      required this.filter,
      required this.subFilters,
      required this.subcategory});

  @override
  State<SubFiltersPage> createState() => _SubFiltersPageState();
}

class _SubFiltersPageState extends State<SubFiltersPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: const MainBackButton(),
            title: AppBarTitleText(
              title: widget.filter,
              size: manageWidth(context, 23),
            )),
        body: Column(children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: manageWidth(context, 1.5),
                  blurRadius: manageWidth(context, 5),
                  offset: Offset(0, manageHeight(context, 2)),
                ),
              ],
              color: Colors.white,
              borderRadius: BorderRadius.circular(manageWidth(context, 20)),
            ),
            margin: EdgeInsets.fromLTRB(
                manageWidth(context, 10),
                manageHeight(context, 10),
                manageWidth(context, 10),
                manageHeight(context, 10)),
            height: manageHeight(context, 610),
            child: ListView.builder(
              itemCount: widget.subFilters.length,
              itemBuilder: (context, index) {
                return Column(
                  children: index == widget.subFilters.length - 1
                      ? [
                          SubFilterView(
                            subCategory: widget.subFilters[index],
                            category: widget.subcategory,
                          ),
                        ]
                      : [
                          SubFilterView(
                            subCategory: widget.subFilters[index],
                            category: widget.subcategory,
                          ),
                          Container(
                            height: manageHeight(context, 1.5),
                            color: Colors.grey.withOpacity(0.2),
                            margin: EdgeInsets.only(
                              left: manageWidth(context, 40),
                            ),
                          ),
                        ],
                );
              },
            ),
          ),
        ]));
  }
}
