import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';

class UserProfileView extends StatefulWidget {
  final String username;
  final bool withRow;
  final double? radius;
  const UserProfileView(
      {super.key, required this.username, this.withRow = true, this.radius});

  @override
  State<UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<UserProfileView> {
  List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.teal,
    Colors.pink,
    Colors.cyan,
    Colors.amber,
    Colors.indigo,
    Colors.lime,
    Colors.brown,
    Colors.grey,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.amberAccent,
  ];
  @override
  Widget build(BuildContext context) {
    if (!widget.withRow) {
      return CircleAvatar(
          radius: widget.radius ?? manageWidth(context, 24),
          backgroundColor: colors[widget.username.length % colors.length],
          child: Text(
            widget.username[0].toUpperCase(),
            style: TextStyle(
                color: Colors.white,
                fontSize: widget.radius == null
                    ? manageWidth(context, 24)
                    : manageWidth(context, widget.radius! * 23 / 24)),
          ));
    }
    return Row(
      children: [
        SizedBox(
          width: manageWidth(context, 15),
        ),
        CircleAvatar(
            radius: manageWidth(context, 24),
            backgroundColor: colors[widget.username.length % colors.length],
            child: Text(
              widget.username[0].toUpperCase(),
              style: TextStyle(
                  color: Colors.white, fontSize: manageWidth(context, 23)),
            )),
        SizedBox(
          width: manageWidth(context, 15),
        ),
        Text(
          widget.username,
          style: TextStyle(
              fontSize: manageWidth(context, 21), fontWeight: FontWeight.w400),
        ),
        const Spacer(),
      ],
    );
  }
}
