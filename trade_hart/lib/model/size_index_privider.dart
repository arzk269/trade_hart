import 'package:flutter/cupertino.dart';

class SizeIndexProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentSizeIndex => _currentIndex;
  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
