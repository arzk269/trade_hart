import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/model/reservation.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/tools/widgets/app_bar_title_text.dart';

class ReservationRatePage extends StatefulWidget {
  final Reservation reservation;
  const ReservationRatePage({super.key, required this.reservation});

  @override
  State<ReservationRatePage> createState() => _ReservationRatePageState();
}

class _ReservationRatePageState extends State<ReservationRatePage> {
  TextEditingController commentController = TextEditingController();
  TextEditingController commentController2 = TextEditingController();
  int rate = 3;
  int rate2 = 3;

  void rateService(String comment, int serviceRate) async {
    var ref = FirebaseFirestore.instance
        .collection('Services')
        .doc(widget.reservation.serviceId);

    var article = await ref.get();
    var articleData = article.data();
    int totalPoints = articleData!['total points'] + serviceRate;
    int rateNumber = articleData['rates number'] + 1;

    double averageRate = totalPoints / rateNumber * 1.0;

    await ref.update({
      "average rate": averageRate,
      'total points': totalPoints,
      'rates number': rateNumber
    });
    await ref.collection("Avis").add({
      "buyer id": widget.reservation.buyerId,
      "seller id": widget.reservation.sellerId,
      "rate": serviceRate,
      "comment": comment,
      'date': Timestamp.now()
    });

    var sellerData = await FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.reservation.sellerId)
        .get();
    sendNotification(
        token: sellerData.data()!["fcmtoken"],
        title: "Nouvel avis sur un service",
        body: comment,
        route: '/ServiceRatesPage',
        senderId: FirebaseAuth.instance.currentUser!.uid,
        serviceId: widget.reservation.serviceId,
        receverId: widget.reservation.sellerId);
  }

  void rateSeller(String comment, int sellerRate) async {
    var ref = FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.reservation.sellerId);

    var seller = await ref.get();
    var sellerData = seller.data();
    int totalPoints = sellerData!['total points'] == null
        ? sellerRate
        : sellerData['total points'] + sellerRate;
    int rateNumber =
        sellerData['rates number'] == null ? 1 : sellerData['rates number'] + 1;

    double averageRate = totalPoints / rateNumber * 1.0;

    await ref.update({
      "average rate": averageRate,
      'total points': totalPoints,
      'rates number': rateNumber,
      'is all read': false
    });
    await ref.collection("Avis").add({
      "buyer id": widget.reservation.buyerId,
      "seller id": widget.reservation.sellerId,
      "rate": sellerRate,
      "comment": comment,
      'date': Timestamp.now()
    });

    sendNotification(
        token: sellerData["fcmtoken"],
        title: "Nouvel avis sur votre profil",
        body: comment,
        route: '/SellerRatesPage',
        senderId: FirebaseAuth.instance.currentUser!.uid,
        serviceId: widget.reservation.serviceId,
        receverId: widget.reservation.sellerId);
  }

  Widget ratingStars() {
    switch (rate) {
      case 1:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );

      case 2:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );
      case 3:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );
      case 4:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );

      case 5:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );
      default:
    }

    return const SizedBox();
  }

  Widget ratingStars2() {
    switch (rate2) {
      case 1:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );

      case 2:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );
      case 3:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );
      case 4:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.grey,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );

      case 5:
        return Container(
          margin: EdgeInsets.only(
            left: manageWidth(context, 0),
            right: manageWidth(context, 8),
            bottom: manageHeight(context, 4),
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 2;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 3;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 4;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: manageWidth(context, 18),
                ),
                onPressed: () {
                  setState(() {
                    rate2 = 5;
                  });
                },
              ),
              SizedBox(
                width: manageWidth(context, 2.5),
              ),
            ],
          ),
        );
      default:
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: AppBarTitleText(
          title: "Laisser un avi",
          size: manageWidth(context, 20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 25,
                ),
                Text(
                  "Prestataire",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: manageWidth(context, 19)),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Text(
                  rate == 1 ? "Note : $rate étoile" : "Note : $rate étoiles",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                      fontSize: manageWidth(context, 16)),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                ),
                ratingStars(),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Text(
                  "laisser votre commentaire",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                      fontSize: manageWidth(context, 16)),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                margin:
                    EdgeInsets.symmetric(horizontal: manageWidth(context, 20)),
                padding:
                    EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
                width: manageWidth(context, 335),
                // Ajuster la hauteur selon vos besoins
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 20)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(manageWidth(context, 8.0)),
                  child: TextField(
                    controller: commentController,
                    maxLines:
                        null, // Permet à TextField de s'ajuster dynamiquement en hauteur
                    maxLength: 250,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Ce prestataire est excellent!",
                        hintStyle:
                            TextStyle(fontSize: manageWidth(context, 15))),
                  ),
                )),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 25,
                ),
                Text(
                  "Service",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: manageWidth(context, 19)),
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Text(
                  rate2 == 1 ? "Note : $rate2 étoile" : "Note : $rate2 étoiles",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                      fontSize: manageWidth(context, 16)),
                ),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 16,
                ),
                ratingStars2(),
              ],
            ),
            Row(
              children: [
                const SizedBox(
                  width: 30,
                ),
                Text(
                  "laisser votre commentaire",
                  style: GoogleFonts.poppins(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w400,
                      fontSize: manageWidth(context, 16)),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
                margin:
                    EdgeInsets.symmetric(horizontal: manageWidth(context, 20)),
                padding:
                    EdgeInsets.symmetric(horizontal: manageWidth(context, 15)),
                width: manageWidth(context, 335),
                // Ajuster la hauteur selon vos besoins
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius:
                      BorderRadius.circular(manageHeight(context, 20)),
                ),
                child: Padding(
                  padding: EdgeInsets.all(manageWidth(context, 8.0)),
                  child: TextField(
                    controller: commentController2,
                    maxLines:
                        null, // Permet à TextField de s'ajuster dynamiquement en hauteur
                    maxLength: 250,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Je suis satisfait(e) du service!",
                        hintStyle:
                            TextStyle(fontSize: manageWidth(context, 15))),
                  ),
                )),
            GestureDetector(
              onTap: () {
                if (commentController.text.isEmpty ||
                    commentController2.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(
                      "Veuillez remplir les deux champs.",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                  ));
                } else {
                  rateService(commentController2.text, rate2);
                  rateSeller(commentController.text, rate);
                  Navigator.pop(context);
                }
              },
              child: Container(
                margin: EdgeInsets.only(top: manageHeight(context, 60)),
                width: manageWidth(context, 200),
                height: manageHeight(context, 50),
                padding: EdgeInsets.only(bottom: manageWidth(context, 2)),
                decoration: BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius:
                        BorderRadius.circular(manageHeight(context, 25))),
                child: Center(
                  child: Text("Terminer",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: manageWidth(context, 16))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
