import 'package:flutter/material.dart';

class ColorIndexProvider extends ChangeNotifier {
  int _currentColorIndex = 0;
  int get currenColortIndex => _currentColorIndex;

  void updateIndex(int index) {
    _currentColorIndex = index;
    notifyListeners();
  }

  void resetIndex() {
    _currentColorIndex = 0;
    notifyListeners();
  }
}
