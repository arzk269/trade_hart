import 'package:flutter/widgets.dart';

class SelectedArticle extends ChangeNotifier {
  List<bool> articleSelected = [];

  void getSelectedArticles(List<bool> selectedArticles) {
    articleSelected.addAll(selectedArticles);
    notifyListeners();
  }

  void changeSelection(int index) {
    articleSelected[index] = !articleSelected[index];
    notifyListeners();
  }

  void clearSelection() {
    articleSelected.clear();
    notifyListeners();
  }
}
