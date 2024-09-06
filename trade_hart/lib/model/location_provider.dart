import 'package:flutter/cupertino.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class LocationProvider extends ChangeNotifier {
  String _location = "";
  String get location => _location;

  bool _isLocationFiltered = false;
  bool get isLocationFiltered => _isLocationFiltered;

  GeoFirePoint? _center;
  GeoFirePoint? get center => _center;

  double _radius = 5;
  double get radius => _radius;

  void updateRadius(double newRadius) {
    _radius = newRadius;
    notifyListeners();
  }

  void getCenter(double latitude, double longitude) {
    _center = GeoFlutterFire().point(latitude: latitude, longitude: longitude);
    notifyListeners();
  }

  void getlocation(String newLocation) {
    _location = newLocation;
    notifyListeners();
  }

  void updateLocationFilteredStatus() {
    _isLocationFiltered = !_isLocationFiltered;
    notifyListeners();
  }
}
