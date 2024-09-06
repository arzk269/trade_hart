import 'package:flutter/material.dart';

class FeedPovider extends ChangeNotifier {
  bool _eshop = true;
  bool get eshop => _eshop;

  void changeSelection() {
    _eshop = true;
    notifyListeners();
  }

  void changeSelection2() {
    _eshop = false;
    notifyListeners();
  }
}
