import 'package:flutter/material.dart';
import 'package:trade_hart/model/clothes_size.dart';
import 'package:trade_hart/model/other_article_size.dart';
import 'package:trade_hart/model/shoe_size.dart';

class ArticleSizeProvider extends ChangeNotifier {
  final Set<ClotheSize> _clotheSizes = {};
  Set<ClotheSize> get clotheSizes => _clotheSizes;

  final Set<ShoeSize> _shoeSizes = {};
  Set<ShoeSize> get shoeSizes => _shoeSizes;

  final Set<OtherArticleSize> _otherArticleizes = {};
  Set<OtherArticleSize> get otherArticleSize => _otherArticleizes;

  void addClotheSize(ClotheSize size) {
    clotheSizes.add(size);
    notifyListeners();
  }

  void addShoeSize(ShoeSize size) {
    shoeSizes.add(size);
    notifyListeners();
  }

  void addOtherArticleSize(ClotheSize size) {
    clotheSizes.add(size);
    notifyListeners();
  }
}
