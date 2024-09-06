import 'package:flutter/material.dart';

class PriceFilterProvider extends ChangeNotifier {
  bool _isArticlesFiltered = false;
  bool get isArticlesFiltered => _isArticlesFiltered;
  double _minArticlePrice = 0.0;
  double get minArticlePrice => _minArticlePrice;
  double _maxArticlePrice = 0.0;
  double get maxArticlePrice => _maxArticlePrice;

  void getMinArticlePrice(double price) {
    _minArticlePrice = price;
    notifyListeners();
  }

  void getMaxArticlePrice(double price) {
    _maxArticlePrice = price;
    notifyListeners();
  }

  void changeArticleFilteredStatus() {
    _isArticlesFiltered = !_isArticlesFiltered;
    notifyListeners();
  }

  bool _isServicesFiltered = false;
  bool get isServicesFiltered => _isServicesFiltered;
  double _minServicePrice = 0.0;
  double get minServicePrice => _minServicePrice;
  double _maxServicePrice = 0.0;
  double get maxServicePrice => _maxServicePrice;

  void getMinServicePrice(double price) {
    _minServicePrice = price;
    notifyListeners();
  }

  void getMaxServicePrice(double price) {
    _maxServicePrice = price;
    notifyListeners();
  }

  void changeServiceFilteredStatus() {
    _isServicesFiltered = !_isServicesFiltered;
    notifyListeners();
  }
}
