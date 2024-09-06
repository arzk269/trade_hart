import 'package:flutter/material.dart';

class FiltersProvider extends ChangeNotifier {
  String _search = "";
  String get search => _search;

  void updateSearch(String newValue) {
    _search = newValue;
    notifyListeners();
  }
}
