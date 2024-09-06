import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';

class SelectionDivider extends StatelessWidget {
  const SelectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: manageHeight(context, 30),
      width: 2,
      color: Colors.grey.withOpacity(0.7),
    );
  }
}
