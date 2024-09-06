import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/model/setting.dart';
import 'package:trade_hart/size_manager.dart';

class SettingView extends StatelessWidget {
  final Setting setting;
  const SettingView({super.key, required this.setting});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: manageHeight(context, 50),
      child: ListTile(
        leading: Icon(
          setting.icon,
          size: 15,
        ),
        title: Text(
          setting.title,
          style: TextStyle(fontSize: manageWidth(context, 14)),
        ),
        trailing: Icon(
          CupertinoIcons.forward,
          size: manageWidth(context, 15),
        ),
      ),
    );
  }
}
