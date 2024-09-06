import 'package:flutter/cupertino.dart';

class AmountArticleCommandProvider extends ChangeNotifier {
  int _amount = 1;
  int get amount => _amount;
  void add() {
    _amount++;
    notifyListeners();
  }

  void reduce() {
    if (amount > 1) {
      _amount--;
    }
    notifyListeners();
  }
}
