import 'package:flutter/material.dart';

class CategoriesProvider extends ChangeNotifier {
  // article categories
  final Set<String> _articleCategories = {};
  Set<String> get articleCategories => _articleCategories;

  void getarticleCategories(List<dynamic> newarticleCategories) {
    for (var element in newarticleCategories) {
      articleCategories.add(element);
    }
    notifyListeners();
  }

  void addarticleCategory(String category) {
    articleCategories.add(category);
    notifyListeners();
  }

  void removearticleCategory(String category) {
    articleCategories.remove(category);
    notifyListeners();
  }

  void articleCategoriesclear() {
    articleCategories.clear();
    notifyListeners();
  }

  //SERVICE CATEGORIES

  final Set<String> _serviceCategories = {};
  Set<String> get serviceCategories => _serviceCategories;

  void addServiceCatgory(String category) {
    serviceCategories.add(category);
    notifyListeners();
  }

  void removeServiceCategory(String category) {
    serviceCategories.remove(category);
    notifyListeners();
  }

  void serviceCategoriesclear() {
    serviceCategories.clear();
    notifyListeners();
  }

  void getServiceCategories(List<dynamic> newServiceCategories) {
    for (var element in newServiceCategories) {
      serviceCategories.add(element);
    }
    notifyListeners();
  }
}
