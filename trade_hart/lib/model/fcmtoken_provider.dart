import 'package:flutter/foundation.dart';
import 'package:trade_hart/model/notification_api.dart';

class FcmtokenProvider extends ChangeNotifier {
  String _fcmtoken = "";
  String get fcmtoken => _fcmtoken;

  getFcmToken() async {
    _fcmtoken = await FirebaseApi().requestPermission();
    print("voici le token $_fcmtoken");
    notifyListeners();
  }
}
