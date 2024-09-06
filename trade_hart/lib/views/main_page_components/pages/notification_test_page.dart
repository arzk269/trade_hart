// ignore_for_file: avoid_print

import 'package:flutter/material.dart';


import 'package:trade_hart/model/notification_api.dart';

class NotificationTestPage extends StatefulWidget {
  const NotificationTestPage({super.key});

  @override
  State<NotificationTestPage> createState() => _NotificationTestPageState();
}

class _NotificationTestPageState extends State<NotificationTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications Test"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              sendNotification(
                  token:
                      "dXS-2_Y4QK-Hd942SGk4r-:APA91bF_PFDJo_k75gVA6qVjy7mlwWTYMtqEe8XqjIVPYeyGPOXHfJja0x67t3ULLZIKjYnRd0brSs-sWGgXBKVHEfWYZ6nlOm7NutaExyJ2Z5Iaxbjp_gxKdnCioT0lM09RRdxCPDTf",
                  title: "hello",
                  body: "Comment ça va beau gosse?");
            },
            child: const Text("Send Notification")),
      ),
    );
  }
}
