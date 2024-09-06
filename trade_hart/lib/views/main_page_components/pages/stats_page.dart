// ignore_for_file: prefer__ructors, prefer__literals_to_create_immutables, sort_child_properties_last
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> generateAndAddPayments() async {
  CollectionReference payments =
      FirebaseFirestore.instance.collection('CommandsPayments');

  List<String> statuses = ['En cours de traitement', 'Annulé', 'Encaissé'];
  Random random = Random();

  DateTime now = DateTime.now();

  for (int monthOffset = 0; monthOffset < 12; monthOffset++) {
    DateTime monthStart = DateTime(now.year, now.month - monthOffset, 1);

    for (int i = 0; i < 5; i++) {
      String status = statuses[random.nextInt(statuses.length)];
      bool buyerConfirmationStatus = true;

      // Si le statut est "En cours de traitement", il y a une chance que le `buyerConfirmationStatus` soit false
      if (status == 'En cours de traitement' && random.nextBool()) {
        buyerConfirmationStatus = false;
      }

      Map<String, dynamic> payment = {
        'buyer confirmation status': buyerConfirmationStatus,
        'buyer id': 'zqhzzdz88dze8fezf',
        'command id': 'nazbdjzebdzed8edze',
        'number': random.nextInt(10) + 1, // Génère un nombre entre 1 et 10
        'seller confirmation status': true,
        'seller id': 'bdzjhbcebcqdjj55',
        'seller stripe id': 'aasazcazc7c8z8',
        'status': status,
        'time': Timestamp.fromDate(monthStart.add(Duration(
            days: random.nextInt(28),
            hours: random.nextInt(24),
            minutes: random.nextInt(60),
            seconds: random.nextInt(60)))),
        'total amount':
            (random.nextInt(5000) + 10), // Génère un montant entre 10 et 30000
      };

      await payments.add(payment);
    }
  }
}

class AppColors {
  static Color primary = contentColorCyan;
  static Color menuBackground = Color(0xFF090912);
  static Color itemsBackground = Color(0xFF1B2339);
  static Color pageBackground = Color(0xFF282E45);
  static Color mainTextColor1 = Colors.white;
  static Color mainTextColor2 = Colors.white70;
  static Color mainTextColor3 = Colors.white38;
  static Color mainGridLineColor = Colors.white10;
  static Color borderColor = Colors.white54;
  static Color gridLinesColor = Color(0x11FFFFFF);

  static Color contentColorBlack = Colors.black;
  static Color contentColorWhite = Colors.white;
  static Color contentColorBlue = Color(0xFF2196F3);
  static Color contentColorYellow = Color(0xFFFFC300);
  static Color contentColorOrange = Color(0xFFFF683B);
  static Color contentColorGreen = Color(0xFF3BFF49);
  static Color contentColorPurple = Color(0xFF6E1BFF);
  static Color contentColorPink = Color(0xFFFF3AF2);
  static Color contentColorRed = Color(0xFFE80054);
  static Color contentColorCyan = Color(0xFF50E4FF);
}

String getDayOfWeek(int dayIndex) {
  List<String> daysOfWeek = [
    'Lundi', // 0
    'Mardi', // 1
    'Mercredi', // 2
    'Jeudi', // 3
    'Vendredi', // 4
    'Samedi', // 5
    'Dimanche' // 6
  ];

  if (dayIndex < 0 || dayIndex > 6) {
    throw ArgumentError(
        'Le jour de la semaine doit être entre 0 et 6 inclusivement.');
  }

  return daysOfWeek[dayIndex];
}

String formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('dd MMMM', 'fr_FR');
  return formatter.format(date);
}

String getMonthOfYear(int monthIndex) {
  List<String> monthsOfYear = [
    'Janvier', // 1
    'Février', // 2
    'Mars', // 3
    'Avril', // 4
    'Mai', // 5
    'Juin', // 6
    'Juillet', // 7
    'Août', // 8
    'Septembre', // 9
    'Octobre', // 10
    'Novembre', // 11
    'Décembre' // 12
  ];

  if (monthIndex < 0 || monthIndex > 11) {
    throw ArgumentError(
        'Le mois de l\'année doit être entre 1 et 12 inclusivement.');
  }

  return monthsOfYear[monthIndex];
}

List<DateTime> get28LastDays() {
  DateTime now = DateTime.now();
  List<DateTime> last28Days = [];
  for (int i = 0; i < 28; i++) {
    last28Days.add(now.subtract(Duration(days: i)));
  }
  return last28Days.reversed.toList();
}

List<DateTime> getLastSixMonths() {
  DateTime now = DateTime.now();
  List<DateTime> lastSixMonths = [];

  for (int i = 0; i < 6; i++) {
    int year = now.year;
    int month = now.month - i;

    // Ajustement de l'année et du mois
    if (month <= 0) {
      month += 12;
      year -= 1;
    }

    lastSixMonths.add(DateTime(year, month, 1));
  }

  return lastSixMonths.reversed.toList();
}

List<DateTime> getLastTwelveMonths() {
  DateTime now = DateTime.now();
  List<DateTime> lastTwelveMonths = [];

  for (int i = 0; i < 12; i++) {
    int year = now.year;
    int month = now.month - i;

    // Ajustement de l'année et du mois
    if (month <= 0) {
      month += 12;
      year -= 1;
    }

    lastTwelveMonths.add(DateTime(year, month, 1));
  }

  return lastTwelveMonths.reversed.toList();
}

List<DateTime> getSevenLastDays() {
  DateTime now = DateTime.now();
  List<DateTime> lastSevenDays = [];
  for (int i = 0; i < 7; i++) {
    lastSevenDays.add(now.subtract(Duration(days: i)));
  }
  return lastSevenDays.reversed.toList();
}

class StatsPage extends StatefulWidget {
  StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  bool isTransferLoading = false;
  String filtre = "Date";
  initController(WebViewController controller) async {
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(
          Uri.parse("https://dashboard.stripe.com/test/connect/accounts"));
  }

  Future<void> createTransfer(double totalAmount, String sellerStripeId,
      DocumentReference<Map<String, dynamic>> ref) async {
    if (!isTransferLoading) {
      setState(() {
        isTransferLoading = true;
      });
      // URL de votre Cloud Function
      final url = Uri.parse(
          'https://us-central1-tradehart-f5f44.cloudfunctions.net/createTransfer');

      // Obtenir le token d'authentification Firebase
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }
      String? idToken = await user.getIdToken();

      // Préparer les headers
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      };

      // Préparer le body de la requête
      final body = jsonEncode({
        'totalAmount': totalAmount,
        'sellerStripeId': sellerStripeId,
      });

      // Faire la requête POST
      final response = await http.post(url, headers: headers, body: body);

      // Gérer la réponse
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        var transfertId = responseData['transferId'];
        await ref.update({
          "status": "Encaissé",
          "date encaissement": Timestamp.now(),
          "transfert id": transfertId
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Transaction effectuée avec succès!",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
        ));

        setState(() {
          isTransferLoading = false;
        });
        print('Transfer created successfully: ${responseData['transferId']}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Une erreur s'est produite! Veuillez réessayer",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ));
        setState(() {
          isTransferLoading = false;
        });
        print('Failed to create transfer: ${response.body}');
        throw Exception('Failed to create transfer');
      }
    }
  }

  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse("https://dashboard.stripe.com/test/dashboard"));
  int navIndex = 0;
  int timeArea = 0;
  String status = "Toutes";
  ScrollController scrollController = ScrollController();
  ScrollController navScrollController = ScrollController();

  Query<Map<String, dynamic>> getPaymentsStream(String status, int timeArea) {
    DateTime now = DateTime.now();
    DateTime startDate = timeArea == 0
        ? now.subtract(Duration(days: 7))
        : timeArea == 1
            ? now.subtract(Duration(days: 28))
            : timeArea == 2
                ? DateTime(now.year, now.month - 6, now.day)
                : DateTime(now.year, now.month - 12, now.day);

    Timestamp startTimestamp = Timestamp.fromDate(startDate);
    Timestamp nowTimestamp = Timestamp.fromDate(now);

    return (navIndex == 0
            ? (status == "Toutes"
                ? FirebaseFirestore.instance
                    .collection("CommandsPayments")
                    .where("status", isNotEqualTo: "Annulé")
                : status == "Encaissées"
                    ? FirebaseFirestore.instance
                        .collection("CommandsPayments")
                        .where("status", isEqualTo: "Encaissé")
                        .orderBy("date encaissement", descending: true)
                    : status == "Annulées"
                        ? FirebaseFirestore.instance
                            .collection("CommandsPayments")
                            .where("status", isEqualTo: "Annulé")
                        : FirebaseFirestore.instance
                            .collection("CommandsPayments")
                            .where("status",
                                isEqualTo: "En cours de traitement"))
            : (status == "Toutes"
                ? FirebaseFirestore.instance.collection("CommandsPayments")
                : status == "Encaissées"
                    ? FirebaseFirestore.instance
                        .collection("CommandsPayments")
                        .where("status", isEqualTo: "Encaissé")
                    : status == "Annulées"
                        ? FirebaseFirestore.instance
                            .collection("CommandsPayments")
                            .where("status", isEqualTo: "Annulé")
                        : FirebaseFirestore.instance
                            .collection("CommandsPayments")
                            .where("status",
                                isEqualTo: "En cours de traitement")))
        .where("time", isGreaterThanOrEqualTo: startTimestamp)
        .where("time", isLessThanOrEqualTo: nowTimestamp)
        .where("seller id", isEqualTo: FirebaseAuth.instance.currentUser!.uid);
  }

  List<Color> gradientColors = [
    AppColors.contentColorCyan,
    AppColors.contentColorBlue,
  ];

  List<Color> gradientColors2 = [
    Color.fromARGB(255, 80, 255, 168),
    AppColors.contentColorGreen,
  ];

  List<Color> gradientColorsAnnule = [
    Color.fromARGB(69, 255, 105, 59),
    Color.fromARGB(45, 232, 0, 85)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: manageWidth(context, 10),
              ),
              MainBackButton()
            ],
          ),
          SizedBox(
            height: manageHeight(context, 20),
          ),
          SizedBox(
            height: manageHeight(context, 60),
            child: ListView(
              controller: navScrollController,
              scrollDirection: Axis.horizontal,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          navIndex = 0;
                        });
                        navScrollController.animateTo(
                          navScrollController.position.minScrollExtent,
                          duration: Duration(milliseconds: 100),
                          curve: Curves.decelerate,
                        );
                      },
                      child: Text(
                        "Activité financière",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: manageWidth(context, 17),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: manageWidth(context, 15)),
                      width: manageWidth(context, 120),
                      height: manageHeight(context, 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: navIndex != 0
                              ? Colors.transparent
                              : Color.fromARGB(200, 87, 199, 197)),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          navIndex = 1;
                        });
                        navScrollController.animateTo(
                          navScrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        "Toutes les transactions",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: manageWidth(context, 17),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: manageWidth(context, 15)),
                      width: manageWidth(context, 160),
                      height: manageHeight(context, 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: navIndex != 1
                              ? Colors.transparent
                              : Color.fromARGB(200, 87, 199, 197)),
                    )
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          navIndex = 2;
                        });
                        navScrollController.animateTo(
                          navScrollController.position.maxScrollExtent,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        "Stripe",
                        style: GoogleFonts.poppins(
                            color: Colors.grey.shade800,
                            fontSize: manageWidth(context, 17),
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: manageWidth(context, 15)),
                      width: manageWidth(context, 35),
                      height: manageHeight(context, 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2.5),
                          color: navIndex != 2
                              ? Colors.transparent
                              : Color.fromARGB(200, 87, 199, 197)),
                    )
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            height: navIndex == 2 ? 0 : manageHeight(context, 40),
            child: navIndex == 2
                ? null
                : ListView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              timeArea = 0;
                            });
                            scrollController.animateTo(
                              scrollController.position.minScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "cette Semaine",
                            style: GoogleFonts.poppins(
                                color: timeArea == 0
                                    ? Colors.deepPurple
                                    : Colors.grey.shade800,
                                fontSize: manageWidth(context, 14.5),
                                fontWeight: FontWeight.w500),
                          )),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              timeArea = 1;
                            });
                            scrollController.animateTo(
                              scrollController.position.minScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "4 dernières semaines",
                            style: GoogleFonts.poppins(
                                color: timeArea == 1
                                    ? Colors.deepPurple
                                    : Colors.grey.shade800,
                                fontSize: manageWidth(context, 14.5),
                                fontWeight: FontWeight.w500),
                          )),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              timeArea = 2;
                            });

                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "6 derniers mois",
                            style: GoogleFonts.poppins(
                                color: timeArea == 2
                                    ? Colors.deepPurple
                                    : Colors.grey.shade800,
                                fontSize: manageWidth(context, 14.5),
                                fontWeight: FontWeight.w500),
                          )),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              timeArea = 3;
                            });
                            scrollController.animateTo(
                              scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            "cette année",
                            style: GoogleFonts.poppins(
                                color: timeArea == 3
                                    ? Colors.deepPurple
                                    : Colors.grey.shade800,
                                fontSize: manageWidth(context, 14.5),
                                fontWeight: FontWeight.w500),
                          ))
                    ],
                  ),
          ),
          Expanded(
            child: navIndex == 2
                ? WebViewWidget(controller: controller)
                : StreamBuilder(
                    stream: navIndex == 1
                        ? (getPaymentsStream(status, timeArea)
                            .orderBy(filtre == "Montant"
                                ? "total amount"
                                : (status == "Encaissées"
                                    ? "date encaissement"
                                    : "time"))
                            .snapshots())
                        : getPaymentsStream(status, timeArea).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: [
                            SizedBox(
                              height: manageHeight(context, 350),
                            ),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                    width: manageWidth(
                                  context,
                                  15,
                                )),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: manageWidth(context, 40)),
                                  child: DropdownButton(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("Toutes"),
                                        value: "Toutes",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("En cours de traitement"),
                                        value: "En cours de traitement",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Disponibles"),
                                        value: "Disponibles",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Encaissées"),
                                        value: "Encaissées",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Annulées"),
                                        value: "Annulées",
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        status = value!;
                                      });
                                    },
                                    hint: Text(status),
                                  ),
                                ),
                                Text(
                                  "Transactions",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade800,
                                      fontSize: manageWidth(context, 15),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: manageHeight(context, 50),
                            ),
                            Center(
                                child: AppBarTitleText(
                                    title:
                                        "Nous n'avons pas trouvé de transactions ",
                                    size: manageWidth(context, 15))),
                            Center(
                                child: AppBarTitleText(
                                    title: timeArea == 0
                                        ? "${status.toLowerCase()} cette semaine"
                                        : timeArea == 1
                                            ? "${status.toLowerCase()} ces 4 dernières semaines"
                                            : timeArea == 2
                                                ? "${status.toLowerCase()} ces 6 derniers mois"
                                                : "${status.toLowerCase()} cette année",
                                    size: manageWidth(context, 14.5)))
                          ],
                        );
                      }

                      var days = timeArea == 0
                          ? getSevenLastDays()
                          : timeArea == 1
                              ? get28LastDays()
                              : timeArea == 2
                                  ? getLastSixMonths()
                                  : getLastTwelveMonths();

                      var data = status == "Disponibles"
                          ? snapshot.data!.docs
                              .where((element) =>
                                  (element.data()["buyer confirmation status"] &&
                                      element.data()[
                                          "seller confirmation status"] &&
                                      (element.data()["time"] as Timestamp)
                                          .toDate()
                                          .isBefore(DateTime.now()
                                              .subtract(Duration(days: 7)))) ||
                                  (!element.data()["buyer confirmation status"] &&
                                      element.data()[
                                          "seller confirmation status"] &&
                                      (element.data()["time"] as Timestamp)
                                          .toDate()
                                          .isBefore(DateTime.now()
                                              .subtract(Duration(days: 11))) &&
                                      (element.data()["seller confirmation date"] as Timestamp)
                                          .toDate()
                                          .isBefore(DateTime.now().subtract(Duration(days: 3)))))
                              .toList()
                          : status == "En cours de traitement"
                              ? snapshot.data!.docs.where((element) => (element.data()["time"] as Timestamp).toDate().isAfter(DateTime.now().subtract(Duration(days: 7))) || !((element.data()["buyer confirmation status"] && element.data()["seller confirmation status"] && (element.data()["time"] as Timestamp).toDate().isBefore(DateTime.now().subtract(Duration(days: 7)))) || (!element.data()["buyer confirmation status"] && element.data()["seller confirmation status"] && (element.data()["time"] as Timestamp).toDate().isBefore(DateTime.now().subtract(Duration(days: 11)))))).toList()
                              : snapshot.data!.docs;

                      List<double> results = days.map((e) => 0.0).toList();
                      List<int> sells = days.map((e) => 0).toList();
                      double totalResult = 0;
                      double totalSells = 0;

                      for (int i = 0; i < data.length; i++) {
                        if (!(data[i]["status"] == "Annulé" &&
                            status == "Toutes")) {
                          totalResult += data[i].data()["total amount"];
                        }

                        totalSells += data[i].data()["number"];
                        for (int j = 0; j < days.length; j++) {
                          if (timeArea == 0 || timeArea == 1) {
                            if ((data[i]["time"] as Timestamp).toDate().day ==
                                    days[j].day &&
                                (data[i]["time"] as Timestamp).toDate().month ==
                                    days[j].month) {
                              results[j] +=
                                  data[i].data()["total amount"] * 1.0;
                              sells[j] += data[i].data()["number"] as int;
                            }
                          } else {
                            if ((data[i]["time"] as Timestamp).toDate().month ==
                                days[j].month) {
                              results[j] +=
                                  data[i].data()["total amount"] * 1.0;
                              sells[j] += data[i].data()["number"] as int;
                            }
                          }
                        }
                      }

                      var maxResults = results.reduce(max);
                      var maxSells = sells.reduce(max);

                      List<FlSpot> resultSpots = [];
                      for (var i = 0; i < results.length; i++) {
                        resultSpots.add(FlSpot(i * 1.0, results[i]));
                      }

                      List<FlSpot> sellSpots = [];

                      for (var i = 0; i < sells.length; i++) {
                        sellSpots.add(FlSpot(i * 1.0, sells[i] * 1.0));
                      }

                      print(results);
                      print(sells);
                      if (!results.any((element) => element != 0)) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                    width: manageWidth(
                                  context,
                                  15,
                                )),
                                Padding(
                                  padding: EdgeInsets.only(
                                      right: manageWidth(context, 40)),
                                  child: DropdownButton(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("Toutes"),
                                        value: "Toutes",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("En cours de traitement"),
                                        value: "En cours de traitement",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Disponibles"),
                                        value: "Disponibles",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Encaissées"),
                                        value: "Encaissées",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Annulées"),
                                        value: "Annulées",
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        status = value!;
                                      });
                                    },
                                    hint: Text(status),
                                  ),
                                ),
                                Text(
                                  "Transactions",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade800,
                                      fontSize: manageWidth(context, 15),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: manageHeight(context, 50),
                            ),
                            Center(
                                child: AppBarTitleText(
                                    title:
                                        "Nous n'avons pas trouvé de transactions ",
                                    size: manageWidth(context, 15))),
                            Center(
                                child: AppBarTitleText(
                                    title: timeArea == 0
                                        ? "${status.toLowerCase()} cette semaine"
                                        : timeArea == 1
                                            ? "${status.toLowerCase()} ces 4 dernières semaines"
                                            : timeArea == 2
                                                ? "${status.toLowerCase()} ces 6 derniers mois"
                                                : "${status.toLowerCase()} cette année",
                                    size: manageWidth(context, 14.5)))
                          ],
                        );
                      } else if (navIndex == 1) {
                        return Column(
                          children: <Widget>[
                            Row(
                              children: [
                                SizedBox(
                                    width: manageWidth(
                                  context,
                                  15,
                                )),
                                Padding(
                                  padding: EdgeInsets.only(right: 40),
                                  child: DropdownButton(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("Toutes"),
                                        value: "Toutes",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("En cours de traitement"),
                                        value: "En cours de traitement",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Disponibles"),
                                        value: "Disponibles",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Encaissées"),
                                        value: "Encaissées",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Annulées"),
                                        value: "Annulées",
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        status = value!;
                                      });
                                    },
                                    hint: Text(status),
                                  ),
                                ),
                                Text(
                                  "Transactions",
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey.shade800,
                                      fontSize: manageWidth(context, 15),
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: manageHeight(context, 30),
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [SizedBox(width: manageWidth(context, 10),),
                                  Padding(
                                    padding: EdgeInsets.all(manageWidth(context, 5)),
                                    child: Text(
                                      "Total : $totalResult \$",
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey.shade800,
                                          fontSize: manageWidth(context, 15),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(width: manageWidth(context, 80)),
                                  Padding(
                                    padding:  EdgeInsets.all(manageWidth(context, 5)),
                                    child: Text(
                                      "Filtre",
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey.shade800,
                                          fontSize: manageWidth(context, 15),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  SizedBox(
                                      width: manageWidth(
                                    context,
                                    15,
                                  )),
                                  DropdownButton(
                                    items: [
                                      DropdownMenuItem(
                                        child: Text("Date"),
                                        value: "Date",
                                      ),
                                      DropdownMenuItem(
                                        child: Text("Montant"),
                                        value: "Montant",
                                      )
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        filtre = value!;
                                      });
                                    },
                                    hint: Text(filtre),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                                child: ListView(
                              children: data
                                  .map((element) => Container(
                                        padding: EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                    "${element.data()["total amount"]} \$",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontSize: manageWidth(
                                                            context, 17),
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                SizedBox(
                                                    width: manageWidth(
                                                  context,
                                                  20,
                                                )),
                                                Text(
                                                    (element.data()["status"] ==
                                                                "En cours de traitement") &&
                                                            ((element.data()["buyer confirmation status"] &&
                                                                    element.data()[
                                                                        "seller confirmation status"] &&
                                                                    (element.data()["time"] as Timestamp).toDate().isBefore(DateTime.now().subtract(Duration(
                                                                        days:
                                                                            7)))) ||
                                                                (!element.data()["buyer confirmation status"] &&
                                                                    element.data()[
                                                                        "seller confirmation status"] &&
                                                                    (element.data()["time"] as Timestamp)
                                                                        .toDate()
                                                                        .isBefore(DateTime.now().subtract(Duration(days: 11))) &&
                                                                    (element.data()["seller confirmation date"] as Timestamp).toDate().isBefore(DateTime.now().subtract(Duration(days: 3)))))
                                                        ? "Disponible"
                                                        : element.data()["status"],
                                                    style: GoogleFonts.poppins(color: element.data()["status"] == "Annulé" ? Colors.red : Colors.grey.shade800, fontSize: manageWidth(context, 14), fontWeight: FontWeight.w500)),
                                                SizedBox(
                                                    child: element.data()["status"] ==
                                                            "Annulé"
                                                        ? null
                                                        : ((element.data()["status"] ==
                                                                    "En cours de traitement") &&
                                                                ((element.data()["buyer confirmation status"] &&
                                                                        element.data()[
                                                                            "seller confirmation status"] &&
                                                                        (element.data()["time"] as Timestamp).toDate().isBefore(DateTime.now().subtract(Duration(
                                                                            days:
                                                                                7)))) ||
                                                                    (!element.data()["buyer confirmation status"] &&
                                                                        element.data()["seller confirmation status"] &&
                                                                        (element.data()["time"] as Timestamp).toDate().isBefore(DateTime.now().subtract(Duration(days: 11))) &&
                                                                        (element.data()["seller confirmation date"] as Timestamp).toDate().isBefore(DateTime.now().subtract(Duration(days: 3)))))
                                                            ? TextButton(
                                                                onPressed: () {
                                                                  createTransfer(
                                                                      element.data()[
                                                                              "total amount"] +
                                                                          element.data()[
                                                                              "delivery fees"],
                                                                      element[
                                                                          "seller stripe id"],
                                                                      element
                                                                          .reference);
                                                                },
                                                                child: Text("Récupérer",
                                                                    style: GoogleFonts.poppins(
                                                                      fontSize: manageWidth(
                                                                          context,
                                                                          14),
                                                                    )))
                                                            : Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        left:
                                                                            15),
                                                                child:
                                                                    CircleAvatar(
                                                                  radius: 12,
                                                                  backgroundColor: element.data()[
                                                                              "status"] ==
                                                                          "Encaissé"
                                                                      ? Colors
                                                                          .green
                                                                      : Colors
                                                                          .deepPurple,
                                                                  child: Icon(
                                                                      element.data()["status"] ==
                                                                              "Encaissé"
                                                                          ? Icons
                                                                              .check
                                                                          : CupertinoIcons
                                                                              .clock,
                                                                      color: Colors
                                                                          .white,
                                                                      size: manageWidth(
                                                                          context,
                                                                          13)),
                                                                ),
                                                              )))
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                    "${formatDate((element.data()["time"] as Timestamp).toDate())} ${(element.data()["time"] as Timestamp).toDate().year} ",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontSize: manageWidth(
                                                            context, 14),
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    manageHeight(context, 6)),
                                            Row(
                                              children: [
                                                Text(
                                                    "Nombre de ventes :${element.data()["number"]}",
                                                    style: GoogleFonts.poppins(
                                                        color: Colors
                                                            .grey.shade800,
                                                        fontSize: manageWidth(
                                                            context, 14),
                                                        fontWeight:
                                                            FontWeight.w400)),
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    manageHeight(context, 6)),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ArticleDetailsPage(
                                                                    articleId: element
                                                                            .data()[
                                                                        "article id"])));
                                                  },
                                                  child: Text("Voir l'article",
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: Colors
                                                                  .deepPurple,
                                                              fontSize:
                                                                  manageWidth(
                                                                      context,
                                                                      14),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400)),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        margin: EdgeInsets.all(
                                            manageWidth(context, 15)),
                                        height: manageHeight(context, 150),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.grey.shade200,
                                                  blurRadius: 1.5)
                                            ]),
                                      ))
                                  .toList(),
                            )),
                          ],
                        );
                      }

                      return ListView(
                        children: <Widget>[
                          Row(
                            children: [
                              SizedBox(
                                  width: manageWidth(
                                context,
                                15,
                              )),
                              Padding(
                                padding: EdgeInsets.only(right: 40),
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text("Toutes"),
                                      value: "Toutes",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("En cours de traitement"),
                                      value: "En cours de traitement",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Disponibles"),
                                      value: "Disponibles",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Encaissées"),
                                      value: "Encaissées",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Annulées"),
                                      value: "Annulées",
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      status = value!;
                                    });
                                  },
                                  hint: Text(status),
                                ),
                              ),
                              Text(
                                "Transactions",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade800,
                                    fontSize: manageWidth(context, 15),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              "Total : $totalResult \$",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey.shade800,
                                  fontSize: manageWidth(context, 15),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: manageHeight(context, 15),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            height: manageHeight(context, 300),
                            width: manageWidth(context, 350),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 2,
                                      color: Colors.grey.shade300)
                                ],
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(15)),
                            child: AspectRatio(
                              aspectRatio: 1.1,
                              child: LineChart(
                                LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval:
                                          maxResults / results.length,
                                      verticalInterval: 1,
                                      getDrawingHorizontalLine: (value) {
                                        return FlLine(
                                          color: Color.fromARGB(45, 44, 37, 37),
                                          strokeWidth:
                                              manageWidth(context, 0.5),
                                        );
                                      },
                                    ),
                                    titlesData: FlTitlesData(
                                      show: true,
                                      rightTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      topTitles: AxisTitles(
                                        sideTitles:
                                            SideTitles(showTitles: false),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize:
                                              manageWidth(context, 30),
                                          interval: 1,
                                          getTitlesWidget: bottomTitleWidgets,
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                            showTitles: true,
                                            interval: maxResults * 1.0 / 4,
                                            getTitlesWidget:
                                                (double value, TitleMeta meta) {
                                              var style = TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize:
                                                    manageWidth(context, 9),
                                              );
                                              String text;
                                              if (value == maxResults) {
                                                text = "${maxResults.toInt()}";
                                                return Text(text,
                                                    style: style,
                                                    textAlign: TextAlign.left);
                                              } else if (value ==
                                                  (maxResults * (3.0 / 4))) {
                                                text = maxResults * (3.0 / 4) <
                                                        1
                                                    ? ""
                                                    : "${(maxResults * (3.0 / 4)).round()}";
                                                return Text(text,
                                                    style: style,
                                                    textAlign: TextAlign.left);
                                              } else if (value ==
                                                  (maxResults * (1.0 / 2))) {
                                                text = maxResults * (1.0 / 2) <
                                                        1
                                                    ? ""
                                                    : "${(maxResults * (1.0 / 2)).round()}";
                                                return Text(text,
                                                    style: style,
                                                    textAlign: TextAlign.left);
                                              } else if (value ==
                                                  (maxResults * (1.0 / 4))) {
                                                text = value < 1
                                                    ? ""
                                                    : "${(maxResults * (1.0 / 4)).round()}";
                                                return Text(text,
                                                    style: style,
                                                    textAlign: TextAlign.left);
                                              }

                                              return SizedBox();
                                            },
                                            reservedSize:
                                                manageWidth(context, 30)),
                                      ),
                                    ),
                                    borderData: FlBorderData(
                                      show: false,
                                      border:
                                          Border.all(color: Color(0xff37434d)),
                                    ),
                                    minX: 0.0,
                                    maxX: days.length * 1.0 - 1,
                                    minY: 0.0,
                                    maxY: maxResults,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: resultSpots,
                                        isCurved: false,
                                        gradient: status == "Annulées"
                                            ? LinearGradient(
                                                colors: gradientColorsAnnule,
                                              )
                                            : LinearGradient(
                                                colors: gradientColors,
                                              ),
                                        barWidth: manageWidth(context, 1.5),
                                        isStrokeCapRound: true,
                                        dotData: FlDotData(
                                          show: false,
                                        ),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          gradient: status == "Annulées"
                                              ? LinearGradient(
                                                  colors: gradientColorsAnnule,
                                                )
                                              : LinearGradient(
                                                  colors: gradientColors
                                                      .map((color) => color
                                                          .withOpacity(0.3))
                                                      .toList(),
                                                ),
                                        ),
                                      ),
                                    ],
                                    lineTouchData: LineTouchData(
                                      touchTooltipData: LineTouchTooltipData(
                                        getTooltipColor: (touchedSpot) =>
                                            Colors.blueGrey,
                                        getTooltipItems:
                                            (List<LineBarSpot> touchedSpots) {
                                          return touchedSpots.map((spot) {
                                            var date = timeArea == 0
                                                ? getSevenLastDays()[
                                                    spot.x.toInt()]
                                                : timeArea == 1
                                                    ? get28LastDays()[
                                                        spot.x.toInt()]
                                                    : timeArea == 2
                                                        ? getLastSixMonths()[
                                                            spot.x.toInt()]
                                                        : getLastTwelveMonths()[
                                                            spot.x.toInt()];
                                            return LineTooltipItem(
                                              timeArea > 1
                                                  ? '${getMonthOfYear(date.month)} ${date.year}\n${spot.y} \$'
                                                  : '${formatDate(date)} ${date.year}\n${spot.y} \$',
                                              TextStyle(color: Colors.white),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    )),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: manageHeight(context, 20),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                  width: manageWidth(
                                context,
                                15,
                              )),
                              Padding(
                                padding: EdgeInsets.only(right: 40),
                                child: DropdownButton(
                                  items: [
                                    DropdownMenuItem(
                                      child: Text("Toutes"),
                                      value: "Toutes",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("En cours de traitement"),
                                      value: "En cours de traitement",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Achevées"),
                                      value: "Disponibles",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Encaissées"),
                                      value: "Encaissées",
                                    ),
                                    DropdownMenuItem(
                                      child: Text("Annulées"),
                                      value: "Annulées",
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      status = value!;
                                    });
                                  },
                                  hint: Text(status == "Disponibles"
                                      ? "Achevées"
                                      : status),
                                ),
                              ),
                              Text(
                                "Ventes",
                                style: GoogleFonts.poppins(
                                    color: Colors.grey.shade800,
                                    fontSize: manageWidth(context, 15),
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Text(
                              totalSells > 1
                                  ? "Total : ${totalSells.toInt()} ventes"
                                  : "Total : ${totalSells.toInt()} vente",
                              style: GoogleFonts.poppins(
                                  color: Colors.grey.shade800,
                                  fontSize: manageWidth(context, 15),
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: manageHeight(context, 15),
                          ),
                          Container(
                            padding: EdgeInsets.all(10),
                            height: manageHeight(context, 300),
                            width: manageWidth(context, 350),
                            margin: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                      blurRadius: 2,
                                      color: Colors.grey.shade300)
                                ],
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(15)),
                            child: AspectRatio(
                              aspectRatio: 1.1,
                              child: LineChart(LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval:
                                        maxSells * 1.0 / sells.length,
                                    verticalInterval: 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Color.fromARGB(45, 44, 37, 37),
                                        strokeWidth: manageWidth(context, 0.5),
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: manageWidth(context, 30),
                                        interval: 1,
                                        getTitlesWidget: bottomTitleWidgets,
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: maxSells * 1.0 / 4,
                                        getTitlesWidget:
                                            (double value, TitleMeta meta) {
                                          var style = TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: manageWidth(
                                                context,
                                                9,
                                              ));
                                          String text;
                                          if (value == maxSells.toDouble()) {
                                            text = "${maxSells.toInt()}";
                                            return Text(text,
                                                style: style,
                                                textAlign: TextAlign.left);
                                          } else if (value ==
                                              (maxSells * (3.0 / 4))) {
                                            text = value < 1
                                                ? ""
                                                : "${(maxSells * (3.0 / 4)).round()}";
                                            return Text(text,
                                                style: style,
                                                textAlign: TextAlign.left);
                                          } else if (value ==
                                              (maxSells * (1.0 / 2))) {
                                            text = value < 1
                                                ? ""
                                                : "${(maxSells * (1.0 / 2)).round()}";
                                            return Text(text,
                                                style: style,
                                                textAlign: TextAlign.left);
                                          } else if (value ==
                                              (maxSells * (1.0 / 4))) {
                                            text = value < 1
                                                ? ""
                                                : "${(maxSells * (1.0 / 4)).round()}";
                                            return Text(text,
                                                style: style,
                                                textAlign: TextAlign.left);
                                          }

                                          return SizedBox();
                                        },
                                        reservedSize: manageWidth(context, 30),
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: false,
                                    border:
                                        Border.all(color: Color(0xff37434d)),
                                  ),
                                  minX: 0.0,
                                  maxX: sells.length * 1.0 - 1,
                                  minY: 0.0,
                                  maxY: maxSells * 1.0,
                                  lineBarsData: [
                                    LineChartBarData(
                                      spots: sellSpots,
                                      isCurved: false,
                                      gradient: status == "Annulées"
                                          ? LinearGradient(
                                              colors: gradientColorsAnnule,
                                            )
                                          : LinearGradient(
                                              colors: gradientColors2,
                                            ),
                                      barWidth: manageWidth(context, 1.5),
                                      isStrokeCapRound: true,
                                      dotData: FlDotData(
                                        show: false,
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        gradient: status == "Annulées"
                                            ? LinearGradient(
                                                colors: gradientColorsAnnule,
                                              )
                                            : LinearGradient(
                                                colors: gradientColors2
                                                    .map((color) =>
                                                        color.withOpacity(0.3))
                                                    .toList(),
                                              ),
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipColor: (touchedSpot) =>
                                          Colors.blueGrey,
                                      getTooltipItems:
                                          (List<LineBarSpot> touchedSpots) {
                                        return touchedSpots.map((spot) {
                                          var date = timeArea == 0
                                              ? getSevenLastDays()[
                                                  spot.x.toInt()]
                                              : timeArea == 1
                                                  ? get28LastDays()[
                                                      spot.x.toInt()]
                                                  : timeArea == 2
                                                      ? getLastSixMonths()[
                                                          spot.x.toInt()]
                                                      : getLastTwelveMonths()[
                                                          spot.x.toInt()];
                                          return LineTooltipItem(
                                            timeArea > 1
                                                ? '${getMonthOfYear(date.month)} ${date.year}\n${spot.y.toInt()} ventes'
                                                : '${formatDate(date)} ${date.year}\n${spot.y.toInt()} ventes',
                                            TextStyle(color: Colors.white),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ))),
                            ),
                          ),
                        ],
                      );
                    }),
          ),
        ],
      ),
    ));
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: manageWidth(
          context,
          9,
        ));

    switch (timeArea) {
      case 0:
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: Text(value.toInt() == 6
              ? "Auj"
              : value.toInt() == 5
                  ? "Hier"
                  : getDayOfWeek(getSevenLastDays()[value.toInt()].weekday - 1)
                      .substring(0, 3)),
        );
      case 1:
        return SideTitleWidget(
          axisSide: meta.axisSide,
          child: value.toInt() % 4 == 3
              ? Text(
                  value.toInt() == 27
                      ? "Auj"
                      : formatDate(
                          get28LastDays()[value.toInt()],
                        ),
                  style: style,
                )
              : SizedBox(),
        );

      case 2:
        return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              getMonthOfYear(getLastSixMonths()[value.toInt()].month - 1),
              style: style,
            ));
      case 3:
        return SideTitleWidget(
            axisSide: meta.axisSide,
            child: Text(
              getMonthOfYear(getLastTwelveMonths()[value.toInt()].month - 1)
                  .substring(0, 3),
              style: style,
            ));
      default:
    }

    return Container();
  }
}
