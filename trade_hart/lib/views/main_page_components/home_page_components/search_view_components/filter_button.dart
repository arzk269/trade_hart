import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/tools/colors.dart';

class FilterButton extends StatefulWidget {
  const FilterButton({super.key});

  @override
  State<FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<FilterButton> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
          manageWidth(context, 10),
          manageHeight(context, 4),
          manageWidth(context, 10),
          manageHeight(context, 0.5)),
      width: manageWidth(context, 50),
      height: manageWidth(context, 50),
      padding: EdgeInsets.only(top: manageWidth(context, 5)),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
          color: AppColors.mainColor,
          borderRadius: BorderRadius.circular(manageWidth(context, 26))),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.filter_list,
              color: Colors.white,
              size: manageWidth(context, 25),
            ),
            Text(
              "filtrer",
              style: TextStyle(
                  fontSize: manageWidth(context, 9), color: Colors.white),
            )
          ],
        ),
      ),
    );
  }
}
