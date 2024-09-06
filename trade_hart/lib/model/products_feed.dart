import 'package:trade_hart/model/selllers.dart';

import 'identifyed_product.dart';

class ProductsFeed {
  List<IdentifyedProduct> getFeed() {
    List<IdentifyedProduct> identifiedProducts = [];

    for (var seller in sellers) {
      for (var product in seller.products) {
        identifiedProducts
            .add(IdentifyedProduct(product: product, seller: seller));
      }
    }

    return identifiedProducts;
  }
}

var identifyedProducts = ProductsFeed().getFeed();
