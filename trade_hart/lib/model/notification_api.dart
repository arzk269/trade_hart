// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:googleapis_auth/auth_io.dart';
import 'package:trade_hart/main.dart';
import 'package:http/http.dart' as http;
// import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

Future<void> handleBackgroundMessage(RemoteMessage? message) async {
  if (message == null) {
    return;
  } else {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState != null) {
        var data = message.data;
        navigatorKey.currentState!.pushNamed(data["route"], arguments: data);
      } else {
        Future.delayed(const Duration(microseconds: 100), () {
          handleBackgroundMessage(message);
        });
      }
    });
  }
}

Future initNotification() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  FirebaseMessaging.instance.getInitialMessage().then(handleBackgroundMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleBackgroundMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}

class FirebaseApi {
  final firebaseMessaging = FirebaseMessaging.instance;
  Future<String> requestPermission() async {
    await firebaseMessaging.requestPermission();
    final fcmtoken = await firebaseMessaging.getToken();
    print("token: $fcmtoken");
    initNotification();
    return fcmtoken ?? "";
  }
}

void getNewToken(String uid) async {
  var newToken = await FirebaseMessaging.instance.getToken();

  if (newToken != null) {
    var user =
        await FirebaseFirestore.instance.collection('Users').doc(uid).get();
    if (user.exists) {
      if (user.data()!.containsKey("fcmtoken")) {
        var savedToken = user.data()!["fcmtoken"];
      if (savedToken != newToken) {
        FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .update({"fcmtoken": newToken});
      }
      }

      else{
        FirebaseFirestore.instance
            .collection('Users')
            .doc(uid)
            .update({"fcmtoken": newToken});
      }
      
    }
  }
}
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _showNotification(RemoteMessage message) async {
//   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'TradeHart', 'TradeHart',
//       importance: Importance.high, priority: Priority.high);
//   var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     message.notification?.title,
//     message.notification?.body,
//     platformChannelSpecifics,
//     payload: json.encode(message.data),
//   );
// }

// void onDidReceiveNotificationResponse(
//     NotificationResponse notificationResponse) {
//   if (notificationResponse.payload != null) {
//     var data = json.decode(notificationResponse.payload!);
//     if ((data['route'] as String).isNotEmpty) {
//       if (navigatorKey.currentState == null) {
//         // Créez une nouvelle GlobalKey et utilisez-la pour naviguer vers la nouvelle page
//         final newNavigatorKey = GlobalKey<NavigatorState>();
//         newNavigatorKey.currentState
//             ?.pushNamed((data['route'] as String), arguments: data);
//       } else {
//         // Utilisez la GlobalKey existante pour naviguer vers la nouvelle page
//         navigatorKey.currentState
//             ?.pushNamed((data['route'] as String), arguments: data);
//       }
//     }
//   }
// }

// Future<void> listenForMessages() async {
//   var initializationSettingsAndroid =
//       const AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettingsIOS = const DarwinInitializationSettings();
//   var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//   );

//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     if (message != null) {
//       var data = message.data;
//       if ((data['route'] as String).isNotEmpty) {
//         if (navigatorKey.currentState == null) {
//           // Créez une nouvelle GlobalKey et utilisez-la pour naviguer vers la nouvelle page
//           final newNavigatorKey = GlobalKey<NavigatorState>();
//           newNavigatorKey.currentState
//               ?.pushNamed((data['route'] as String), arguments: data);
//         } else {
//           // Utilisez la GlobalKey existante pour naviguer vers la nouvelle page
//           navigatorKey.currentState
//               ?.pushNamed((data['route'] as String), arguments: data);
//         }
//       }
//       _showNotification(message);
//     }
//   });

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     _showNotification(message);
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     _showNotification(message);
//   });
// }
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// Future<void> _showNotification(RemoteMessage message) async {
//   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'TradeHart', 'TradeHart',
//       importance: Importance.high, priority: Priority.high);
//   var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
//   var platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     message.notification?.title,
//     message.notification?.body,
//     platformChannelSpecifics,
//     payload: json.encode(message.data),
//   );
// }

// void onDidReceiveNotificationResponse(
//     NotificationResponse notificationResponse) {
//   if (notificationResponse.payload != null) {
//     var data = json.decode(notificationResponse.payload!);
//     if ((data['route'] as String).isNotEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         navigatorKey.currentState
//             ?.pushNamed((data['route'] as String), arguments: data);
//       });
//     }
//   }
// }

// Future<void> listenForMessages() async {
//   var initializationSettingsAndroid =
//       const AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettingsIOS = const DarwinInitializationSettings();
//   var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
//   );

//   // FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//   //   if (message != null) {
//   //     var data = message.data;
//   //     WidgetsBinding.instance.addPostFrameCallback((_) {
//   //       navigatorKey.currentState
//   //           ?.pushNamed((data['route'] as String), arguments: data);
//   //     });
//   //     _showNotification(message);
//   //   }
//   // });

//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     _showNotification(message);
//   });

//   // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//   //   var data = message.data;
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     navigatorKey.currentState
//   //         ?.pushNamed((data['route'] as String), arguments: data);
//   //   });
//   // });
// }

Future<void> sendNotification({
  required String token,
  required String title,
  required String body,
  String? senderId,
  String? receverId,
  String? articleId,
  String? serviceId,
  String? commandId,
  String? resrvationId,
  String? route,
  String? conversationId,
}) async {
  // URL Cloud Function
  final url = Uri.parse(
      'https://us-central1-tradehart-f5f44.cloudfunctions.net/sendNotification');

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
  final requestBody = jsonEncode({
    'token': token,
    'title': title,
    'body': body,
    'senderId': senderId,
    'receverId': receverId,
    'articleId': articleId,
    'serviceId': serviceId,
    'commandId': commandId,
    'resrvationId': resrvationId,
    'route': route,
    'conversationId': conversationId,
  });

  // Faire la requête POST
  final response = await http.post(url, headers: headers, body: requestBody);

  // Gérer la réponse
  if (response.statusCode == 200) {
    print('Notification sent successfully');
  } else {
    print('Failed to send notification: ${response.body}');
    throw Exception('Failed to send notification');
  }
}

class NotificationRouter {
  static void handleNotification(RemoteMessage message) {
    final data = message.data;
    final route = data['route'];

    switch (route) {
      case 'article_details':
        Get.toNamed('/article_details', arguments: data);
        break;
      case 'conversation':
        Get.toNamed('/conversation', arguments: data);
        break;
      // ...
      default:
        Get.toNamed('/main');
    }
  }
}
// import 'dart:convert';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:trade_hart/main.dart';

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

// class FirebaseApi {
//   Future<void> requestPermission() async {
//     await firebaseMessaging.requestPermission();
//     final fcmToken = await firebaseMessaging.getToken();
//     print("token: $fcmToken");
//   }
// }

// Future<void> _showNotification(RemoteMessage message) async {
//   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'TradeHart', 'TradeHart',
//       importance: Importance.high, priority: Priority.high);
//   var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
//   var platformChannelSpecifics =  rNotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iOSPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin.show(
//     0,
//     message.notification?.title,
//     message.notification?.body,
//     platformChannelSpecifics,
//     payload: json.encode(message.data),
//   );
// }
// void handleMessage(RemoteMessage? message) {
//   if (message == null) {
//     return;
//   }
//   navigatorKey.currentState?.pushNamed(
//     '/notification_screen',
//     arguments: message,
//   );
//   FirebaseMessaging.instance.sendMessage();
// }

// Future initNotification() async {
//   FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//   //
//   FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
// }

// Future<void> listenForMessages() async {
//   var initializationSettingsAndroid =
//       const AndroidInitializationSettings('@mipmap/ic_launcher');
//   var initializationSettingsIOS = const DarwinInitializationSettings();
//   var initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
//     if (message != null) {
//       String? route = message.data['route'];
//       if (route == '/page1') {
//         Map<String, dynamic> arguments = {
//           'intValue': int.parse(message.data['intValue']),
//           'stringValue': message.data['stringValue'] as String,
//         };
//         navigatorKey.currentState?.pushNamed('/page1', arguments: arguments);
//       } else if (route == '/page2') {
//         List<String> arguments = List<String>.from(message.data['stringList']);
//         navigatorKey.currentState?.pushNamed('/page2', arguments: arguments);
//       }
//     }
//   });
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     String? route = message.data['route'];
//     if (route == '/page1') {
//       Map<String, dynamic> arguments = {
//         'intValue': int.parse(message.data['intValue']),
//         'stringValue': message.data['stringValue'] as String,
//       };
//       navigatorKey.currentState?.pushNamed('/page1', arguments: arguments);
//     } else if (route == '/page2') {
//       List<String> arguments = List<String>.from(message.data['stringList']);
//       navigatorKey.currentState?.pushNamed('/page2', arguments: arguments);
//     }
//     _showNotification(message);
//   });

//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     String? route = message.data['route'];
//     if (route == '/page1') {
//       Map<String, dynamic> arguments = {
//         'intValue': int.parse(message.data['intValue']),
//         'stringValue': message.data['stringValue'] as String,
//       };
//       navigatorKey.currentState?.pushNamed('/page1', arguments: arguments);
//     } else if (route == '/page2') {
//       List<String> arguments = List<String>.from(message.data['stringList']);
//       navigatorKey.currentState?.pushNamed('/page2', arguments: arguments);
//     }
//     listenForMessages();
//   });
// }
// // Future initNotification() async {
// //   FirebaseMessaging.instance.getInitialMessage().then(l);
// //   //
// //   FirebaseMessaging.onMessageOpenedApp.listen(listenForMessages);
// // }


// // class FirebaseApi {
// //   final firebaseMessageing = FirebaseMessaging.instance;
// //   Future<void> requestPermission() async {
// //     await firebaseMessageing.requestPermission();
// //     final fcmtoken = await firebaseMessageing.getToken();
// //     print("token: $fcmtoken");
// //   }
// // }

// // void handleMessage(RemoteMessage? message) {
// //   if (message == null) {
// //     return;
// //   }
// //   navigatorKey.currentState?.pushNamed(
// //     '/notification_screen',
// //     arguments: message,
// //   );
// // }

// String? route = message.data['route'];
    // if (route == '/page1') {
    //   Map<String, dynamic> arguments = {
    //     'intValue': message.data['intValue'] as int,
    //     'stringValue': message.data['stringValue'] as String,
    //   };
    //   navigatorKey.currentState?.pushNamed('/page1', arguments: arguments);
    // } else if (route == '/page2') {
    //   List<String> arguments = List<String>.from(message.data['stringList']);
    //   navigatorKey.currentState?.pushNamed('/page2', arguments: arguments);
    // }
    // var data = message.data;
    // if ((data['route'] as String).isNotEmpty) {
    //   navigatorKey.currentState
    //       ?.pushNamed((data['route'] as String), arguments: data);
    // }

    // String? route = message.data['route'];
    // if (route == '/page1') {
    //   Map<String, dynamic> arguments = {
    //     'intValue': message.data['intValue'] as int,
    //     'stringValue': message.data['stringValue'] as String,
    //   };
    //   navigatorKey.currentState?.pushNamed('/page1', arguments: arguments);
    // } else if (route == '/page2') {
    //   List<String> arguments = List<String>.from(message.data['stringList']);
    //   navigatorKey.currentState?.pushNamed('/page2', arguments: arguments);
    // }

    // var data = message.data;
    // if ((data['route'] as String).isNotEmpty) {
    //   navigatorKey.currentState
    //       ?.pushNamed((data['route'] as String), arguments: data);
    // }

      // if (message != null) {
    //   // String? route = message.data['route'];
    //   // if (route == '/page1') {
    //   //   Map<String, dynamic> arguments = {
    //   //     'intValue': message.data['intValue'] as int,
    //   //     'stringValue': message.data['stringValue'] as String,
    //   //   };
    //   //   navigatorKey.currentState?.pushNamed('/page1', arguments: arguments);
    //   // } else if (route == '/page2') {
    //   //   List<String> arguments = List<String>.from(message.data['stringList']);
    //   //   navigatorKey.currentState?.pushNamed('/page2', arguments: arguments);
    //   // }

    //   var data = message.data;
    //   if ((data['route'] as String).isNotEmpty) {
    //     navigatorKey.currentState
    //         ?.pushNamed((data['route'] as String), arguments: data);
    //   }
    // }