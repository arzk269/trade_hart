import 'package:flutter/material.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/search_view_components/filter_button.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/search_view_components/search_field.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [SearchField(), FilterButton()],
    );
  }
}
