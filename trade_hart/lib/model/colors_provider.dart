import 'dart:io';

import 'package:flutter/material.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/article_size.dart';

class ColorProvider extends ChangeNotifier {
  final Set<ArticleColor> _articleColors = {};
  Set<ArticleColor> get articleColors => _articleColors;

  final Set<NetworkArticleColor> _networkArticleColors = {};
  Set<NetworkArticleColor> get networkArticleColors => _networkArticleColors;

  void getNetworKColors(List<NetworkArticleColor> colors) {
    for (var color in colors) {
      networkArticleColors.add(color);
    }
    notifyListeners();
  }

  void deleteNetowrkColor(NetworkArticleColor color) {
    networkArticleColors.remove(color);
    notifyListeners();
  }

  void networkMinus(NetworkArticleColor color) {
    if (color.amount > 1) {
      networkArticleColors.firstWhere((element) => element == color).amount--;
      notifyListeners();
    } else {
      deleteNetowrkColor(color);
    }
  }

  void networkDeleteSize(NetworkArticleColor color, int index) {
    networkArticleColors
        .firstWhere((element) => element == color)
        .sizes
        .removeAt(index);
    notifyListeners();
  }

  void networkAdd(NetworkArticleColor color) {
    if (color.amount < 999) {
      networkArticleColors.firstWhere((element) => element == color).amount++;
      notifyListeners();
    }
  }

  void networkMinusSize(NetworkArticleColor color, int sizeIndex) {
    networkArticleColors
        .firstWhere((element) => element == color)
        .sizes[sizeIndex]['amount']--;
    notifyListeners();
  }

  void networkAddSize(NetworkArticleColor color, int sizeIndex) {
    networkArticleColors
        .firstWhere((element) => element == color)
        .sizes[sizeIndex]['amount']++;
    notifyListeners();
  }

  void networkAddColor(NetworkArticleColor color) {
    networkArticleColors.add(color);
    notifyListeners();
  }

  void networkAddColorSizes(List<ArticleSize> sizes, String color) {
    var selectedColor =
        networkArticleColors.firstWhere((element) => element.color == color);

    for (var size in sizes) {
      selectedColor.sizes.add({"amount": size.amount, "size": size.size});
    }
    notifyListeners();
  }

  //LOCAL

  void addColor(ArticleColor color) {
    articleColors.add(color);
    notifyListeners();
  }

  void removeColor(ArticleColor color) {
    articleColors.remove(color);
    notifyListeners();
  }

  void removeColorByFile(File file) {
    articleColors.removeWhere((element) {
      return element.imageFile.path == file.path;
    });
    notifyListeners();
  }

  void minus(ArticleColor color) {
    if (color.amount > 0) {
      articleColors.firstWhere((element) => element == color).amount--;
      notifyListeners();
    }
  }

  void add(ArticleColor color) {
    articleColors.firstWhere((element) => element == color).amount++;
    notifyListeners();
  }

  void minusSize(ArticleColor color, int sizeIndex) {
    articleColors
        .firstWhere((element) => element == color)
        .sizes[sizeIndex]
        .amount--;
    notifyListeners();
  }

  void addSize(ArticleColor color, int sizeIndex) {
    articleColors
        .firstWhere((element) => element == color)
        .sizes[sizeIndex]
        .amount++;
    notifyListeners();
  }

  void deleteSize(int index, int index2) {
    articleColors.toList()[index].sizes.removeAt(index2);
    notifyListeners();
  }

  void addColorSize(int index, List<ArticleSize> articleSizes) {
    for (var size in articleSizes) {
      articleColors.toList()[index].sizes.add(size);
    }
    notifyListeners();
  }

  void clear() {
    articleColors.clear();
    networkArticleColors.clear();
    notifyListeners();
  }
}
