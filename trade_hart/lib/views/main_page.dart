import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:trade_hart/model/link_provider_service.dart';
import 'package:trade_hart/model/notification_api.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:trade_hart/views/authentication_pages/login_page.dart';
import 'package:trade_hart/views/main_page_components/app_bar_view.dart';
import 'package:trade_hart/views/main_page_components/pages/home_page.dart';
import 'package:trade_hart/views/main_page_components/pages/main_chat_page.dart';
import 'package:trade_hart/views/main_page_components/pages/profile_page.dart';
import 'package:trade_hart/views/main_page_components/pages/wish_list_page.dart';

bool eshopSelection = true;

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MainProvider(),
      child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (snapshot.hasData && snapshot.data != null) {
              print(snapshot.data!.email);
              return const MainPageContent();
            }

            return const LoginPage();
          }),
    );
  }
}

class MainPageContent extends StatefulWidget {
  const MainPageContent({super.key});

  @override
  State<MainPageContent> createState() => _MainPageContentState();
}

class _MainPageContentState extends State<MainPageContent> {
  final auth = FirebaseAuth.instance.currentUser;
  bool hasInternet = true;
  Future<bool> checkInternetConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == [ConnectivityResult.mobile] ||
        connectivityResult == [ConnectivityResult.wifi]) {
      return true;
    } else {
      return false;
    }
  }

  final FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin =
      kIsWeb ? null : FlutterLocalNotificationsPlugin();
  Future<void> _showNotification(RemoteMessage message) async {
    int uniqueId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'TradeHart', 'TradeHart',
        importance: Importance.high, priority: Priority.high);
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin!.show(
      uniqueId,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: json.encode(message.data),
    );
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null) {
      var data = json.decode(notificationResponse.payload!);
      if ((data['route'] as String).isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context)
              .pushNamed((data['route'] as String), arguments: data);
        });
      }
    }
  }

  Future<void> listenForMessages() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('@mipmap/launcher_icon');
    var initializationSettingsIOS = const DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // FirebaseMessaging.instance
    //     .getInitialMessage()
    //     .then((RemoteMessage? message) {
    //   if (message != null) {
    //     var data = message.data;
    //     WidgetsBinding.instance.addPostFrameCallback((_) {
    //       Navigator.of(context)
    //           .pushNamed((data['route'] as String), arguments: data);
    //     });
    //     _showNotification(message);
    //   }
    // });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });

    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    //   var data = message.data;
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     Navigator.of(context)
    //         .pushNamed((data['route'] as String), arguments: data);
    //   });
    // });
  }

  late StreamSubscription<List<ConnectivityResult>> connectivitySubscription;
  @override
  void initState() {
    super.initState();
    LinkProviderService().listenDynamicLinks(context);

    var user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      getNewToken(user.uid);
    }
    if (!kIsWeb) {
      listenForMessages();
    }

    checkInternetConnection().then((hasInternet) {
      setState(() {
        this.hasInternet = hasInternet;
      });
    });
    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        hasInternet = result != [ConnectivityResult.none];
      });
    });
  }

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pages = [
      const HomePage(),
      MainChatPage(),
      WishListPage(),
      const ProfilePage(),
    ];
    List<String> titles = const ["TradHart", "Chat", "Wish List", "Profil"];

    BottomNavigationBarItem buildCupertinoTabBarItem(
      IconData icon,
      String label,
      int index,
    ) {
      const selectedColor = AppColors.mainColor;
      const unselectedColor = Colors.black;
      return BottomNavigationBarItem(
        icon: index == 1
            ? Stack(
                alignment: Alignment.topCenter,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: Icon(
                      icon,
                      color: Provider.of<MainProvider>(context).currentIndex ==
                              index
                          ? selectedColor
                          : unselectedColor,
                      size: manageWidth(context, 25),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:35),
                    child: Text(
                      label,
                      style: TextStyle(
                          fontSize: manageWidth(context, 10),
                          color:
                              Provider.of<MainProvider>(context).currentIndex ==
                                      index
                                  ? selectedColor
                                  : unselectedColor),
                    ),
                  ),
                  StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('Conversations')
                          .where('users', arrayContains: auth!.uid)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            !snapshot.hasData ||
                            snapshot.hasError) {
                          return const SizedBox(
                            height: 0.1,
                          );
                        }

                        var data = snapshot.data!.docs
                            .where((element) => element["last message"] != "");
                        var unReads = data.any(
                          (element) {
                            return element["last message"]["sender"] !=
                                    auth!.uid &&
                                element["is all read"]["receiver"] == false;
                          },
                        );
                        return Padding(
                          padding: EdgeInsets.only(
                            top: 7, right: manageWidth(context, 10.0)),
                          child: CircleAvatar(
                            radius: manageWidth(context, 5),
                            backgroundColor:
                                unReads ? Colors.red : Colors.transparent,
                          ),
                        );
                      })
                ],
              )
            : index == 3
                ? Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Icon(
                          icon,
                          color:
                              Provider.of<MainProvider>(context).currentIndex ==
                                      index
                                  ? selectedColor
                                  : unselectedColor,
                          size: manageWidth(context, 25),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 35),
                        child: Text(
                          label,
                          style: TextStyle(
                              fontSize: manageWidth(context, 10),
                              color: Provider.of<MainProvider>(context)
                                          .currentIndex ==
                                      index
                                  ? selectedColor
                                  : unselectedColor),
                        ),
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData ||
                                snapshot.hasError) {
                              return const SizedBox(
                                height: 0.1,
                              );
                            }
                            var data = snapshot.data!;
                            var user = data.data();

                            if (user!["user type"] == "buyer") {
                              return const SizedBox(
                                height: 0.1,
                              );
                            }
                            var isAllCommentsRead =
                                user['is all comments read'] ?? true;
                            return StreamBuilder(
                                stream: user["user type"] == "seller"
                                    ? FirebaseFirestore.instance
                                        .collection('Commands')
                                        .where('seller id',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .where("status", isNotEqualTo: "Livré")
                                        .snapshots()
                                    : FirebaseFirestore.instance
                                        .collection('Reservations')
                                        .where('seller id',
                                            isEqualTo: FirebaseAuth
                                                .instance.currentUser!.uid)
                                        .where("status",
                                            isNotEqualTo: "Terminé")
                                        .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                  }
                                  bool alldone = snapshot.data!.docs.isEmpty;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: 7,
                                        right: manageWidth(context, 10.0)),
                                    child: CircleAvatar(
                                      radius: 3.5,
                                      backgroundColor:
                                          !isAllCommentsRead || !alldone
                                              ? Colors.red
                                              : Colors.transparent,
                                    ),
                                  );
                                });
                          }),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('Commands')
                              .where('buyer id',
                                  isEqualTo:
                                      FirebaseAuth.instance.currentUser!.uid)
                              .where("status", isNotEqualTo: "Livré")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox();
                            }

                            var isAllDelivered = snapshot.data!.docs.isEmpty;
                            return StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('Reservations')
                                    .where('buyer id',
                                        isEqualTo: FirebaseAuth
                                            .instance.currentUser!.uid)
                                    .where("status", isNotEqualTo: "Terminé")
                                    .snapshots(),
                                builder: (context, snapshot2) {
                                  if (snapshot2.connectionState ==
                                      ConnectionState.waiting) {
                                    return const SizedBox();
                                  }

                                  var isAllFinisehd =
                                      snapshot2.data!.docs.isEmpty;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: 7,
                                        right: manageWidth(context, 10.0)),
                                    child: CircleAvatar(
                                      radius: manageWidth(context, 3.5),
                                      backgroundColor:
                                          !isAllFinisehd || !isAllDelivered
                                              ? Colors.red
                                              : Colors.transparent,
                                    ),
                                  );
                                });
                          })
                    ],
                  )
                : Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Icon(
                          icon,
                          color:
                              Provider.of<MainProvider>(context).currentIndex ==
                                      index
                                  ? selectedColor
                                  : unselectedColor,
                          size: manageWidth(context, 25),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(top: 35),
                          child: Text(
                            label,
                            style: TextStyle(
                                fontSize: manageWidth(context, 10),
                                color: Provider.of<MainProvider>(context)
                                            .currentIndex ==
                                        index
                                    ? selectedColor
                                    : unselectedColor),
                          ))
                    ],
                  ),
      );
    }


    return Scaffold(
      appBar: AppBarView(
              title: titles[Provider.of<MainProvider>(context).currentIndex])
          .appBarsetter(context),
      body: IndexedStack(
        index: Provider.of<MainProvider>(context).currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CupertinoTabBar(
        items: [
          buildCupertinoTabBarItem(CupertinoIcons.home, "Home", 0),
          buildCupertinoTabBarItem(CupertinoIcons.chat_bubble, "Chat", 1),
          buildCupertinoTabBarItem(CupertinoIcons.heart, "Wish List", 2),
          buildCupertinoTabBarItem(CupertinoIcons.person, "Profil", 3),
        ],height:50,
        currentIndex: Provider.of<MainProvider>(context).currentIndex,
        onTap: (index) {
          // Utilisation de Provider pour mettre à jour l'état global
          Provider.of<MainProvider>(context, listen: false)
              .updateCurrentIndex(index);
        },
      ),
    );
  }
}

class MainProvider with ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
