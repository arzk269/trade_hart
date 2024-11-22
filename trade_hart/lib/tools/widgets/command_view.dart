import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:trade_hart/constants.dart';
import 'package:trade_hart/model/article.dart';
import 'package:trade_hart/model/article_color.dart';
import 'package:trade_hart/model/command.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/seller_name_view.dart';
import 'package:trade_hart/views/main_page_components/pages/article_details_page.dart';
import 'package:trade_hart/views/main_page_components/pages/command_problem_page.dart';
import 'package:trade_hart/views/main_page_components/pages/command_rate_page.dart';
import 'package:trade_hart/views/main_page_components/pages/conversation_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CommandView extends StatefulWidget {
  final Command command;
  const CommandView({super.key, required this.command});

  @override
  State<CommandView> createState() => _CommandViewState();
}

class _CommandViewState extends State<CommandView> {
  void sendProblemMessage(String customerId, String problem) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var existingConversations1 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [currentUserId, widget.command.sellerId],
      ).get();

      var existingData1 = existingConversations1.docs;

      var existingConversations2 =
          await FirebaseFirestore.instance.collection('Conversations').where(
        'users',
        isEqualTo: [widget.command.sellerId, currentUserId],
      ).get();

      var existingData2 = existingConversations2.docs;

      if (existingData1.isNotEmpty || existingData2.isNotEmpty) {
        String conversationId = existingData1.isNotEmpty
            ? existingData1[0].id
            : existingData2[0].id;
        var moment = Timestamp.now();
        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .collection("Messages")
            .add({"sender": currentUserId, "content": problem, "date": moment});

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(conversationId)
            .update({
          "last time": moment,
          "last message": {"content": problem, "sender": currentUserId},
          "is all read": {"sender": true, "receiver": false}
        });

        var seller = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.command.sellerId)
            .get();
        sendNotification(
            token: seller.data()!["fcmtoken"],
            title: "Un problème sur une commande a été signalé",
            body: problem,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: conversationId,
            route: "/ConversationPage");
      } else {
        var moment = Timestamp.now();
        var newConversationRef =
            await FirebaseFirestore.instance.collection('Conversations').add({
          'users': [currentUserId, customerId],
          "last message": {"content": problem, "sender": currentUserId},
          'last time': moment,
          "is all read": {"sender": true, "receiver": false}
        });

        await FirebaseFirestore.instance
            .collection("Conversations")
            .doc(newConversationRef.id)
            .collection("Messages")
            .add({"sender": currentUserId, "content": problem, "date": moment});
        var seller = await FirebaseFirestore.instance
            .collection('Users')
            .doc(widget.command.sellerId)
            .get();
        sendNotification(
            token: seller.data()!["fcmtoken"],
            title: "Un problème sur une commande a été signalé",
            body: problem,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            conversationId: newConversationRef.id,
            route: "/ConversationPage");
      }
    } catch (error) {
      // Afficher une snackbar en cas d'échec
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Une erreur est survenue. Veuillez réessayer',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red));
    }

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
  }

  Future<void> createTransfer(double totalAmount, String sellerStripeId,
      DocumentReference<Map<String, dynamic>> ref) async {
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
      'totalAmount': double.parse(totalAmount.toStringAsFixed(2)),
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
      print('Transfer created successfully: ${responseData['transferId']}');
    } else {
      print('Failed to create transfer: ${response.body}');
      throw Exception('Failed to create transfer');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Articles')
          .doc(widget.command.articleId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.all(manageWidth(context, 8.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    height: manageHeight(context, 90),
                    width: manageWidth(context, 90),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                          BorderRadius.circular(manageWidth(context, 10)),
                    ),
                    margin: EdgeInsets.only(
                      right: manageWidth(context, 15),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: manageHeight(context, 5),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          left: manageWidth(context, 5),
                          right: manageWidth(context, 2),
                        ),
                        height: manageHeight(context, 10),
                        width: manageWidth(context, 75),
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: manageHeight(context, 5)),
                      Container(
                        margin: EdgeInsets.only(
                          left: manageWidth(context, 5),
                          right: manageWidth(context, 2),
                        ),
                        height: manageHeight(context, 10),
                        width: manageWidth(context, 60),
                        color: Colors.grey.shade300,
                      ),
                      SizedBox(height: manageHeight(context, 8)),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(
                              left: manageWidth(context, 0),
                              right: manageWidth(context, 0),
                            ),
                            height: manageHeight(context, 10),
                            color: Colors.grey.shade300,
                          ),
                          SizedBox(height: manageHeight(context, 15)),
                        ],
                      ),
                    ],
                  ),
                ]),
              ], // end Column children
            ),
          );
        }
        var articleData = snapshot.data!.data() as Map<String, dynamic>;
        List<NetworkArticleColor> colors = [];
        for (var color in articleData['colors']) {
          colors.add(NetworkArticleColor(
              color: color['name'],
              imageUrl: color['image url'],
              amount: color['amount'],
              sizes: color['sizes']));
        }
        Article article = Article(
          id: snapshot.data!.id,
          name: articleData['name'],
          price: articleData['price'] * 1.0,
          categories: articleData['category'],
          sellerId: articleData['sellerId'],
          amount: articleData['amount'],
          description: articleData['description'],
          averageRate: articleData['average rate'] * 1.0,
          totalPoints: articleData['total points'] * 1.0,
          ratesNumber: articleData['rates number'],
          date: (articleData['date'] as Timestamp).toDate(),
          status: articleData['status'],
          sellerName: articleData['seller name'],
          deliveryInformations: articleData['delivery informations'],
          images: articleData['images'],
          colors: colors,
        );
        return Padding(
          padding: EdgeInsets.all(manageWidth(context, 8.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ArticleDetailsPage(
                          articleId: widget.command.articleId,
                        ),
                      ),
                    ),
                    child: Container(
                      height: manageHeight(context, 90),
                      width: manageWidth(context, 90),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        // borderRadius:
                        //     BorderRadius.circular(manageWidth(context, 10)),
                        // image: DecorationImage(
                        //   image: NetworkImage(
                        //     article.colors[widget.command.colorIndex].imageUrl,
                        //   ),
                        //   fit: BoxFit.cover,
                        // ),
                      ),
                      margin: EdgeInsets.only(
                        right: manageWidth(context, 15),
                      ),
                      child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 10)),
                          child: Image.network(
                            article.colors[widget.command.colorIndex].imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                SizedBox(
                                    height: manageHeight(context, 150),
                                    width: manageWidth(context, 165),
                                    child: Column(
                                      children: [
                                        Icon(
                                          CupertinoIcons
                                              .exclamationmark_triangle_fill,
                                          size: manageWidth(context, 20),
                                        ),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    )),
                          )),
                    ),
                  ),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: manageHeight(context, 5),
                        ),
                        SizedBox(
                          width: manageWidth(context, 200),
                          child: Text(
                            article.name,
                            style: GoogleFonts.poppins(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.w500,
                              fontSize: manageWidth(context, 18),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(height: manageHeight(context, 5)),
                        Row(
                          children: [
                            SellerNameView(
                              name: article.sellerName,
                              fontSize: manageWidth(context, 15),
                              marginLeft: manageWidth(context, 0),
                            ),
                            GestureDetector(
                              onTap: () async {
                                String currentUserId =
                                    FirebaseAuth.instance.currentUser!.uid;
                                var existingConversations1 =
                                    await FirebaseFirestore.instance
                                        .collection('Conversations')
                                        .where(
                                  'users',
                                  isEqualTo: [
                                    currentUserId,
                                    widget.command.sellerId,
                                  ],
                                ).get();

                                var existingData1 = existingConversations1.docs;

                                var existingConversations2 =
                                    await FirebaseFirestore.instance
                                        .collection('Conversations')
                                        .where(
                                  'users',
                                  isEqualTo: [
                                    widget.command.sellerId,
                                    currentUserId,
                                  ],
                                ).get();

                                var existingData2 = existingConversations2.docs;

                                if (existingData1.isNotEmpty ||
                                    existingData2.isNotEmpty) {
                                  if (existingData1.isNotEmpty) {
                                    String conversationId = existingData1[0].id;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ConversationPage(
                                          conversationId: conversationId,
                                          memberId: widget.command.sellerId,
                                        ),
                                      ),
                                    );
                                  } else {
                                    String conversationId = existingData2[0].id;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ConversationPage(
                                          conversationId: conversationId,
                                          memberId: widget.command.sellerId,
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  DocumentReference newConversationRef =
                                      await FirebaseFirestore.instance
                                          .collection('Conversations')
                                          .add({
                                    'users': [
                                      currentUserId,
                                      widget.command.sellerId
                                    ],
                                    'last message': "",
                                    'last time': Timestamp.now(),
                                    "is all read": {
                                      "sender": true,
                                      "receiver": false
                                    }
                                  });
                                  String conversationId = newConversationRef.id;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ConversationPage(
                                        conversationId: conversationId,
                                        memberId: widget.command.sellerId,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Icon(
                                color: Colors.deepPurple,
                                CupertinoIcons.chat_bubble_text_fill,
                                size: manageWidth(context, 20),
                              ),
                            )
                          ],
                        ),
                      ]),
                ],
              ),
              SizedBox(
                height: manageHeight(context, 40),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    CircleAvatar(
                      radius: manageWidth(context, 11.5),
                      backgroundColor: Colors.deepPurple,
                      child: Icon(
                        CupertinoIcons.square_arrow_down,
                        size: manageWidth(context, 15),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: manageHeight(context, 10),
                        left: manageWidth(context, 5),
                      ),
                      child: Text(
                        widget.command.status == "En cours de traitement"
                            ? "En cours de traitement"
                            : "",
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: manageHeight(context, 19.5),
                        bottom: manageHeight(context, 19.5),
                        left: manageWidth(context, 5),
                        right: manageWidth(context, 2),
                      ),
                      height: manageHeight(context, 3),
                      width: manageWidth(context, 35),
                      color: Colors.grey,
                    ),
                    CircleAvatar(
                      radius: manageWidth(context, 11.5),
                      backgroundColor: widget.command.status == "Expédié!" ||
                              widget.command.status ==
                                  "En attente d'expédition" ||
                              widget.command.status == "Livré"
                          ? Colors.deepPurple
                          : Colors.grey.shade400,
                      child: Icon(
                        CupertinoIcons.clock,
                        size: manageWidth(context, 15),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: manageHeight(context, 10),
                        left: manageWidth(context, 5),
                      ),
                      child: Text(
                        widget.command.status == "En attente d'expédition"
                            ? "En attente d'expédition"
                            : "",
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: manageHeight(context, 19.5),
                        bottom: manageHeight(context, 19.5),
                        left: manageWidth(context, 5),
                        right: manageWidth(context, 2),
                      ),
                      height: manageHeight(context, 3),
                      width: manageWidth(context, 35),
                      color: Colors.grey,
                    ),
                    CircleAvatar(
                      radius: manageWidth(context, 11.5),
                      backgroundColor: widget.command.status == "Expédié!" ||
                              widget.command.status == "Livré"
                          ? Colors.deepPurple
                          : Colors.grey.shade400,
                      child: Icon(
                        Icons.local_shipping_outlined,
                        size: manageWidth(context, 15),
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: manageWidth(context, 5)),
                      child: Row(
                        children: [
                          Text(
                            widget.command.status == "Expédié!"
                                ? "Expédié!"
                                : widget.command.status == "Livré"
                                    ? "Livré"
                                    : widget.command.status == "Signalé"
                                        ? "Signalé"
                                        : "",
                            style: GoogleFonts.poppins(
                                color: widget.command.status == "Signalé"
                                    ? Colors.red
                                    : Colors.black),
                          ),
                          SizedBox(
                            width: manageWidth(context, 5),
                          ),
                          SizedBox(
                            child: widget.command.status == "Expédié!" ||
                                    widget.command.status == "Livré"
                                ? StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("CommandsPayments")
                                        .doc(widget.command.id)
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return SizedBox();
                                      }
                                      if (!snapshot.data!.exists) {
                                        return SizedBox();
                                      }

                                      if (snapshot.data!.data()![
                                          "buyer confirmation status"]) {
                                        return TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      CommandRatePage(
                                                    command: widget.command,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: Text("Evaluer"));
                                      }
                                      return TextButton(
                                        onPressed: () {
                                          showBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return BackdropFilter(
                                                filter: ImageFilter.blur(
                                                  sigmaX: 0.8,
                                                  sigmaY: 0.8,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                        manageWidth(
                                                            context, 20)),
                                                    topRight: Radius.circular(
                                                        manageWidth(
                                                            context, 20)),
                                                  ),
                                                  child: SizedBox(
                                                    height: manageHeight(
                                                        context, 350),
                                                    width: double.infinity,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: manageHeight(
                                                              context, 5),
                                                        ),
                                                        Center(
                                                          child: Container(
                                                            height:
                                                                manageHeight(
                                                                    context, 3),
                                                            width: manageWidth(
                                                                context, 45),
                                                            color: Colors
                                                                .grey.shade700,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: manageHeight(
                                                              context, 15),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                            manageWidth(
                                                                context, 15),
                                                          ),
                                                          child: Text(
                                                            "Si vous avez bien reçu votre colis, appuyez sur confirmer. Dans le cas où vous ne l'avez pas reçu dans les délais impartis avec le vendeur ou que le colis ne correspond pas à vos attentes, appuyez sur signaler un problème",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize:
                                                                  manageWidth(
                                                                      context,
                                                                      15),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Colors.grey
                                                                  .shade800,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                manageHeight(
                                                                    context,
                                                                    60)),
                                                        Row(
                                                          children: [
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                        builder:
                                                                            (context) =>
                                                                                CommandProblemPage(command: widget.command)));
                                                              },
                                                              child: Text(
                                                                "Signaler un problème",
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize:
                                                                      manageWidth(
                                                                          context,
                                                                          15),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  color: Colors
                                                                      .red,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  manageWidth(
                                                                      context,
                                                                      5),
                                                            ),
                                                            TextButton(
                                                              onPressed:
                                                                  () async {
                                                                var ref = FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        "CommandsPayments")
                                                                    .doc(widget
                                                                        .command
                                                                        .id);
                                                                ref.update({
                                                                  "buyer confirmation status":
                                                                      true
                                                                });

                                                                var refData =
                                                                    await ref
                                                                        .get();
                                                                var data =
                                                                    refData
                                                                        .data();

                                                                if ((data!["time"]
                                                                        as Timestamp)
                                                                    .toDate()
                                                                    .isBefore(DateTime
                                                                            .now()
                                                                        .subtract(const Duration(
                                                                            days:
                                                                                7)))) {
                                                                  // try {
                                                                  //   var amountInCents = (data["total amount"] *
                                                                  //           90 *
                                                                  //           0.97 as double)
                                                                  //       .round();

                                                                  //   // Créer le corps de la requête HTTP
                                                                  //   Map<String,
                                                                  //           dynamic>
                                                                  //       requestBody =
                                                                  //       {
                                                                  //     'amount':
                                                                  //         amountInCents
                                                                  //             .toString(),
                                                                  //     'currency':
                                                                  //         'eur',
                                                                  //     'destination':
                                                                  //         data[
                                                                  //             "seller stripe id"],
                                                                  //   };

                                                                  //   // Envoyer la requête HTTP à l'API Stripe
                                                                  //   final response =
                                                                  //       await http
                                                                  //           .post(
                                                                  //     Uri.parse(
                                                                  //         'https://api.stripe.com/v1/transfers'),
                                                                  //     headers: {
                                                                  //       'Authorization':
                                                                  //           'Bearer $SECRET_KEY',
                                                                  //       'Content-Type':
                                                                  //           'application/x-www-form-urlencoded',
                                                                  //     },
                                                                  //     body:
                                                                  //         requestBody,
                                                                  //   );

                                                                  //   // Vérifier si la requête HTTP a réussi
                                                                  //   if (response
                                                                  //           .statusCode ==
                                                                  //       200) {
                                                                  //     var transfertId =
                                                                  //         jsonDecode(
                                                                  //             response.body)["id"];
                                                                  //     await ref
                                                                  //         .update({
                                                                  //       "status":
                                                                  //           "Encaissé",
                                                                  //       "date encaissement":
                                                                  //           Timestamp.now(),
                                                                  //       "transfert id":
                                                                  //           transfertId
                                                                  //     });
                                                                  //     print(
                                                                  //         'Transfert réussi ${response.body}');
                                                                  //   } else {
                                                                  //     print(
                                                                  //         'Erreur lors du transfert: ${response.body}');
                                                                  //   }
                                                                  // } catch (e) {
                                                                  //   print(e
                                                                  //       .toString());
                                                                  // }

                                                                  createTransfer(
                                                                      (data["total amount"] *1.0/1.14 +
                                                                          data[
                                                                              "delivery fees"]*0.97),
                                                                      data[
                                                                          "seller stripe id"],
                                                                      ref);
                                                                }

                                                                Navigator.pop(
                                                                    context);
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            CommandRatePage(
                                                                      command:
                                                                          widget
                                                                              .command,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                "Confirmer",
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  fontSize:
                                                                      manageWidth(
                                                                          context,
                                                                          15),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Text("Colis reçu?"),
                                      );
                                    })
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
            ], // end Column children
          ),
        );
      },
    );
  }
}
