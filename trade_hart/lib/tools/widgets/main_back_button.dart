import 'package:flutter/cupertino.dart';
import 'package:trade_hart/size_manager.dart';
// import 'package:trade_hart/views/main_page.dart';

class MainBackButton extends StatefulWidget {
  const MainBackButton({super.key});

  @override
  State<MainBackButton> createState() => _MainBackButtonState();
}

class _MainBackButtonState extends State<MainBackButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Icon(
        CupertinoIcons.clear_thick_circled,
        color: const Color.fromARGB(255, 141, 141, 141).withOpacity(0.8),
        size: manageWidth(context, 25),
      ),
    );
  }
}
