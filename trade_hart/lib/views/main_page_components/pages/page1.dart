import 'package:flutter/material.dart';

class Page1 extends StatelessWidget {
  final int intArgument;
  final String stringArgument;
  const Page1(
      {super.key, required this.intArgument, required this.stringArgument});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page1"),
      ),
      body: Center(
        child: Text("$intArgument $stringArgument"),
      ),
    );
  }
}
