import 'package:flutter/cupertino.dart';
import 'package:trade_hart/model/crenau.dart';
import 'package:trade_hart/model/day_with_crenau.dart';

class ServiceReservationMethodProvider extends ChangeNotifier {
  final List<DayWithCrenau> _daysWithCrenau = [
    DayWithCrenau(day: "Lundi", crenaux: {}),
    DayWithCrenau(day: "Mardi", crenaux: {}),
    DayWithCrenau(day: "Mercredi", crenaux: {}),
    DayWithCrenau(day: "Jeudi", crenaux: {}),
    DayWithCrenau(day: "Vendredi", crenaux: {}),
    DayWithCrenau(day: "Samedi", crenaux: {}),
    DayWithCrenau(day: "Dimanche", crenaux: {})
  ];

  List<DayWithCrenau> get daysWithCrenau => _daysWithCrenau;

  void addCrenau(String day, Crenau crenau) {
    daysWithCrenau
        .firstWhere((element) => element.day == day)
        .crenaux
        .add(crenau);
    notifyListeners();
  }

  void remouveCrenau(String day, String hour, String minutes, int capacity) {
    daysWithCrenau.firstWhere((element) => element.day == day).crenaux.remove(
        daysWithCrenau
            .firstWhere((element) => element.day == day)
            .crenaux
            .firstWhere((element) =>
                element.heure == hour &&
                element.minutes == minutes &&
                element.nombreDePlace == capacity));

    notifyListeners();
  }

  void addPlace(String day, String hour, String minutes) {
    daysWithCrenau
        .firstWhere((element) => element.day == day)
        .crenaux
        .firstWhere(
            (element) => element.heure == hour && element.minutes == minutes)
        .nombreDePlace++;
    notifyListeners();
  }

  void reducePlace(String day, String hour, String minutes) {
    daysWithCrenau
        .firstWhere((element) => element.day == day)
        .crenaux
        .firstWhere(
            (element) => element.heure == hour && element.minutes == minutes)
        .nombreDePlace--;
    notifyListeners();
  }

  void clearDayCreneau(String day) {
    daysWithCrenau.firstWhere((element) => element.day == day).crenaux.clear();
    notifyListeners();
  }

  void clearAllCrenau() {
    for (var element in daysWithCrenau) {
      clearDayCreneau(element.day);
    }
    notifyListeners();
  }

  void getCreneaux(List<dynamic> newDaysWithCreneaux) {
    for (var dayWithCreneau in newDaysWithCreneaux) {
      daysWithCrenau
          .firstWhere((element) => element.day == dayWithCreneau["jour"])
          .crenaux
          .addAll((dayWithCreneau["horaires"] as List<dynamic>).map((e) =>
              Crenau(
                  heure: e["heure"],
                  minutes: e["minutes"],
                  nombreDePlace: e["capacite"])));
    }

    notifyListeners();
  }

  int _reservationType = 1;
  int get reservationType => _reservationType;
  void changeReservationType(int newType) {
    _reservationType = newType;
    notifyListeners();
  }
}
