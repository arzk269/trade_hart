import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  final List<String> messages;

  const Page2({super.key, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 2'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: messages.map((message) => Text(message)).toList(),
        ),
      ),
    );
  }
}
