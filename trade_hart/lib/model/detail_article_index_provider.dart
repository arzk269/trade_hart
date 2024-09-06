import 'package:flutter/material.dart';

class DetailsIndexProvider extends ChangeNotifier {
  int _index = 0;
  int get index => _index;
  void upDateIndex(int newIndex) {
    _index = newIndex;
    notifyListeners();
  }

  void reset() {
    _index = 0;
    notifyListeners();
  }
}
