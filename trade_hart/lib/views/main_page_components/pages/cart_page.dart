// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/model/selected_articles_provider.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';
import 'package:trade_hart/tools/widgets/main_back_button.dart';
import 'package:trade_hart/views/main_page_components/cart_page_components/cart_product_view.dart';
import 'package:trade_hart/views/main_page_components/pages/adress_ading_page.dart';
import 'package:http/http.dart' as http;

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, dynamic>? selectedAdress;
  bool isAddingToCart = false;
  bool isPayed = false;
  double commandPrice = 0.0;
  Map<String, dynamic>? paymentIntent;
  String paymentId = "";

  Future<void> updateDatabase(data) async {
    for (var element in data) {
      if (element["isSelected"]) {
        var articleData = await FirebaseFirestore.instance
            .collection('Articles')
            .doc(element['article id'])
            .get();
        var article = articleData.data();
        var sellerData = await FirebaseFirestore.instance
            .collection('Users')
            .doc(article!["sellerId"])
            .get();
        var command =
            await FirebaseFirestore.instance.collection('Commands').add({
          'buyer id': userId,
          'seller id': element['seller id'],
          'article id': element['article id'],
          'color index': element['color index'],
          'size index': element['size index'],
          'amount': element['amount'],
          'time': Timestamp.now(),
          'status': 'En cours de traitement',
          'buyer adress': selectedAdress,
        });

        FirebaseFirestore.instance
            .collection('CommandsPayments')
            .doc(command.id)
            .set({
          'buyer confirmation status': false,
          'buyer id': FirebaseAuth.instance.currentUser!.uid,
          'command id': command.id,
          'number': element['amount'],
          'seller confirmation status': false,
          'seller id': element['seller id'],
          'seller stripe id': sellerData.data()!["stripe account id"],
          'status': 'En cours de traitement',
          'time': Timestamp.now(),
          'delivery fees': articleData.data()!['delivery informations']
                          ['delivery fees'] *
                      element['amount'] >
                  60.0
              ? 0
              : articleData.data()!['delivery informations']['delivery fees'] *
                          element['amount'] >
                      (element['amount'] * article["price"] * 15) / 100.0
                  ? ((element['amount'] * article["price"] * 15) / 100.0)
                      .round()
                  : articleData.data()!['delivery informations']
                          ['delivery fees'] *
                      element['amount'],
          'total amount': element['amount'] * article["price"],
          'article id': articleData.id,
          "payment id": paymentId
        });

        article['amount'] -= element['amount'];
        article['colors'][element['color index']]['amount'] -=
            element['amount'];
        article['colors'][element['color index']]['sizes']
            [element['size index']]['amount'] -= element['amount'];
        FirebaseFirestore.instance
            .collection('Articles')
            .doc(element['article id'])
            .update(article);

        sendNotification(
            token: sellerData.data()!["fcmtoken"],
            title: "Nouvelle Commande",
            body:
                "Une nouvelle commande vient d'etre effectuée dans votre boutique.",
            senderId: FirebaseAuth.instance.currentUser!.uid,
            route: "/CommandsSeller");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Commandes passées avec succès!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ));

        Navigator.pop(context);
      }
    }
  }

  deleteSelectedItems() async {
    var ref = FirebaseFirestore.instance
        .collection('Cart')
        .doc(userId)
        .collection('Items');
    QuerySnapshot itemsSnapshot =
        await ref.where("isSelected", isEqualTo: true).get();

    for (var element in itemsSnapshot.docs) {
      ref.doc(element.id).delete();
    }
  }

  Future<void> makePayment(double price, data) async {
    setState(() {});
    try {
      paymentIntent = await createPaymentIntent2(
        price.toString(),
        'EUR',
      );
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent!['client_secret'],
                  merchantDisplayName: 'TradeHart',
                  style: ThemeMode.light))
          .then((value) => null);
      await displayPaymentSheet(data);
    } catch (e) {
      print("error : $e");
    }
    // await Stripe.instance
    //     .initPaymentSheet(
    //         paymentSheetParameters: SetupPaymentSheetParameters(
    //             paymentIntentClientSecret: paymentIntent!['client_secret'],
    //             merchantDisplayName: 'TradeHart'))
    //     .then((value) => null);
  }

  displayPaymentSheet(data) async {
    try {
      paymentIntent = null;

      await Stripe.instance.presentPaymentSheet().then((value) async {
        showDialog(
          context: context,
          builder: (context) {
            return const AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      Text("Payment réussi!")
                    ],
                  )
                ],
              ),
            );
          },
        );
        await updateDatabase(data);
        await deleteSelectedItems();
      }).onError((error, stackTrace) {
        print("error : $error $stackTrace");
      });
    } on StripeException catch (e) {
      print('error $e');
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.clear,
                      color: Colors.red,
                    ),
                    Text("Le paiement n'a pu aboutir veuillez réessayer.")
                  ],
                )
              ],
            ),
          );
        },
      );
    }
  }

  createPaymentIntent2(String amount, String currency) async {
    Map<String, dynamic> body = {'amount': amount, 'currency': currency};
    var url = Uri.parse(
        'https://us-central1-tradehart-f5f44.cloudfunctions.net/createPayment');
    try {
      var response = await http.post(
        url,
        body: body,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      print(
          'Payment Intent created: ${jsonDecode(response.body)['client_secret']}');
      setState(() {
        paymentId = jsonDecode(response.body)["id"];
      });
      return jsonDecode(response.body);
      // Utilisez client_secret pour finaliser la transaction côté client
    } catch (e) {
      print('Error creating Payment Intent: $e');
    }
  }

  // createPaymentIntent(
  //     String amount, String currency, String applicationFeeAmount) async {
  //   try {
  //     Map<String, dynamic> body = {
  //       'amount': calculateAmount(amount),
  //       'currency': currency,
  //       'payment_method_types[]': 'card',
  //     };
  //     var response = await http.post(
  //         Uri.parse("https://api.stripe.com/v1/payment_intents"),
  //         body: body,
  //         headers: {
  //           'Authorization': 'Bearer $SECRET_KEY',
  //           'Content-Type': 'application/x-www-form-urlencoded'
  //         });

  //     print("Payment Intent Body->>> ${response.body.toString()}");
  //     setState(() {
  //       paymentId = jsonDecode(response.body)["id"];
  //     });
  //     return jsonDecode(response.body);
  //   } catch (e) {
  //     print("error : $e");
  //   }
  // }

  calculateAmount(String amount) {
    final calculatedAmount = int.parse(amount);
    return calculatedAmount.toString();
  }

  Widget buildBottomSheetContent(data) {
    return BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: 0.8, sigmaY: 0.8), // Ajustez le flou selon vos préférences
        child: ClipRRect(
          // Couleur de fond avec opacité réduite
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(manageHeight(context, 20)),
            topRight: Radius.circular(manageHeight(context, 20)),
          ),
          child: SizedBox(
            height: manageHeight(context, 570),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                    height: manageHeight(
                  context,
                  5,
                )),
                Center(
                  child: Container(
                    height: manageHeight(
                      context,
                      3,
                    ),
                    width: manageWidth(context, 45),
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(
                    height: manageHeight(
                  context,
                  5,
                )),
                Row(
                  children: [
                    SizedBox(
                      width: manageWidth(context, 25),
                    ),
                    Text("Adresse de livraison",
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: manageWidth(context, 16),
                        )),
                  ],
                ),
                Expanded(
                    child: StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return SizedBox(
                              height: manageHeight(context, 0.1),
                            );
                          }
                          var userdata = snapshot.data!.data();

                          if (userdata!['adress'] == null) {
                            return SizedBox(
                              height: manageHeight(context, 0.1),
                            );
                          }
                          List adress = userdata['adress'];
                          return ListView(
                            children: adress
                                .map((e) => Row(
                                      children: [
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        TextButton(
                                            onPressed: () async {
                                              try {
                                                setState(() {
                                                  selectedAdress = e;
                                                });
                                                await makePayment(
                                                    commandPrice, data);

                                                // ignore: empty_catches
                                              } catch (e) {}
                                            },
                                            child: Text(
                                                '${e['adress']}, ${e['code postal']}, ${e['city']}',
                                                style: TextStyle(
                                                  fontSize:
                                                      manageWidth(context, 16),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ))),
                                      ],
                                    ))
                                .toList(),
                          );
                        })),
                Row(
                  children: [
                    SizedBox(
                      width: manageWidth(context, 10),
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdressAddingPage()));
                        },
                        icon: const Icon(CupertinoIcons.add)),
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const AdressAddingPage()));
                        },
                        child: Text(
                          "Ajouter une addresse",
                          style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontSize: manageWidth(context, 15),
                              fontWeight: FontWeight.w500),
                        )),
                  ],
                )
              ],
            ),
          ),
        ));
  }

  String userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const MainBackButton(),
          title: AppBarTitleText(
            title: "Your cart",
            size: manageWidth(context, 22.5),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('Cart')
                    .doc(userId)
                    .collection('Items')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.docs.isEmpty) {
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        Center(
                            child: AppBarTitleText(
                          title: "Votre panier est vide",
                          size: manageWidth(context, 18),
                        )),
                      ],
                    );
                  }

                  var data = snapshot.data!.docs;

                  Future<Map<String, double>> getTotalPricce() async {
                    Map<String, double> priceData = {};
                    double totalPrice = 0.0;
                    double deliveryfees = 0.0;
                    for (var element in data) {
                      if (element["isSelected"]) {
                        var articleData = await FirebaseFirestore.instance
                            .collection('Articles')
                            .doc(element['article id'])
                            .get();

                        double artticlePrice =
                            articleData.data()!['price'] * 1.0;
                        double fees =
                            articleData.data()!['delivery informations']
                                    ['delivery fees'] *
                                1.0;
                        if (fees > (artticlePrice * 15) / 100.0) {
                          deliveryfees +=
                              ((element['amount'] * artticlePrice * 15) / 100.0)
                                  .round();
                        } else if (element['amount'] * artticlePrice > 60.0) {
                          totalPrice += 0;
                        } else {
                          deliveryfees += fees*element['amount'];
                        }
                        totalPrice += element['amount'] * artticlePrice;
                      }
                    }

                    commandPrice = totalPrice + deliveryfees;

                    priceData['total price'] = totalPrice + deliveryfees;
                    priceData['delivery fees'] = double.parse( deliveryfees.toStringAsFixed(2));

                    return priceData;
                  }

                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6895,
                        child: ListView.builder(
                          cacheExtent: 2000,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            var selectedArticles =
                                data.map((e) => true).toList();
                            context
                                .read<SelectedArticle>()
                                .getSelectedArticles(selectedArticles);
                            return Column(
                              children: [
                                Stack(
                                  children: [
                                    CartProductView(
                                      itemId: data[index].id,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          300, 0, 0, 0),
                                      child: Consumer<SelectedArticle>(
                                        builder: (context, value, child) =>
                                            Checkbox(
                                                value: data[index]
                                                    ["isSelected"],
                                                onChanged: (selection) {
                                                  FirebaseFirestore.instance
                                                      .collection('Cart')
                                                      .doc(userId)
                                                      .collection('Items')
                                                      .doc(data[index].id)
                                                      .update({
                                                    "isSelected": !data[index]
                                                        ["isSelected"]
                                                  });
                                                }),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                          height: manageHeight(
                        context,
                        10,
                      )),
                      FutureBuilder(
                        future: getTotalPricce(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return AppBarTitleText(
                                title: "Prix total :",
                                size: manageWidth(context, 17));
                          }
                          return Column(
                            children: [
                              AppBarTitleText(
                                  title:
                                      'Frais de livraison : ${snapshot.data!["delivery fees"]}\$',
                                  size: manageWidth(
                                    context,
                                    17,
                                  )),
                              AppBarTitleText(
                                  title:
                                      'Prix total : ${snapshot.data!["total price"]}\$',
                                  size: manageWidth(
                                    context,
                                    17,
                                  )),
                            ],
                          );
                        },
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return buildBottomSheetContent(data);
                              });
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                            top: manageHeight(context, 5),
                          ),
                          padding: EdgeInsets.fromLTRB(
                              manageWidth(context, 8),
                              manageWidth(context, 8),
                              manageWidth(context, 8),
                              manageWidth(context, 8)),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: const Offset(0, 0),
                                  blurRadius: 5,
                                  spreadRadius: 0.4)
                            ],
                            borderRadius: BorderRadius.circular(
                                manageHeight(context, 30)),
                            color: AppColors.mainColor,
                          ),
                          width: manageWidth(context, 200),
                          height: manageHeight(
                            context,
                            55,
                          ),
                          child: Center(
                            child: Text("passer la commande",
                                style: GoogleFonts.workSans(
                                  color: Colors.white,
                                  fontSize: manageWidth(context, 16.5),
                                )),
                          ),
                        ),
                      ),
                      // CircularProgressIndicator(
                      //   color: isAddingToCart
                      //       ? AppColors.mainColor
                      //       : Colors.transparent,
                      // )
                    ],
                  );
                }),
          ],
        ));
  }
}
