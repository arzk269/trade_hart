import 'package:flutter/material.dart';

class SearchFilterProvider extends ChangeNotifier {
  final List<String> _arcticlesFilters = [];
  List<String> get articlesFilters => _arcticlesFilters;
  final List<String> _servicesFilters = [];
  List<String> get servicesFilters => _servicesFilters;

  void addToArticlesFilters(String filter) {
    articlesFilters.add(filter);
    notifyListeners();
  }

  void removeFromArticlesFilters(String filter) {
    articlesFilters.remove(filter);
    notifyListeners();
  }

  void addToServicesFilters(String filter) {
    servicesFilters.add(filter);
    notifyListeners();
  }

  void removeFromServicesFilters(String filter) {
    servicesFilters.remove(filter);
    notifyListeners();
  }
}
