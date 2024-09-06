import 'package:flutter/material.dart';
import 'package:trade_hart/model/filters.dart';
import 'package:trade_hart/model/setting.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/main_page_components/pages/sub_category_page.dart';
import 'package:trade_hart/views/main_page_components/profile_page_components/setting_view.dart';

class CategoryPage extends StatefulWidget {
  final Map<Setting, List<String>> categories;
  const CategoryPage({super.key, required this.categories});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const MainBackButton(),
        title: const AppBarTitleText(
          title: "Catégories",
          size: 23,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: manageHeight(context, 1.5),
                      blurRadius: manageHeight(context, 5),
                      offset: const Offset(0, 2),
                    ),
                  ],
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 15))),
              margin: const EdgeInsets.all(10),
              height: manageHeight(context, 625),
              child: ListView.builder(
                itemCount: widget.categories.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: index == widget.categories.keys.length - 1
                        ? [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return SubCategoryPage(
                                        subcategory:
                                            widget.categories == articlesFilters
                                                ? 0
                                                : 1,
                                        filter: widget.categories.keys
                                            .toList()[index]
                                            .title,
                                        subFilters: widget.categories[widget
                                            .categories.keys
                                            .toList()[index]]!);
                                  },
                                ));
                              },
                              child: SettingView(
                                  setting:
                                      widget.categories.keys.toList()[index]),
                            ),
                          ]
                        : [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) {
                                    return SubCategoryPage(
                                        subcategory:
                                            widget.categories == articlesFilters
                                                ? 0
                                                : 1,
                                        filter: widget.categories.keys
                                            .toList()[index]
                                            .title,
                                        subFilters: widget.categories[widget
                                            .categories.keys
                                            .toList()[index]]!);
                                  },
                                ));
                              },
                              child: SettingView(
                                  setting:
                                      widget.categories.keys.toList()[index]),
                            ),
                            Container(
                              height: manageHeight(context, 1.5),
                              color: Colors.grey.withOpacity(0.2),
                              margin: const EdgeInsets.only(
                                left: 40,
                              ),
                            )
                          ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
