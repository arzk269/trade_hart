/*import 'package:flutter/cupertino.dart';
import 'package:trade_hart/tools/colors.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/views/main_page.dart';

class BottomNavigationAppBar extends StatefulWidget {
  const BottomNavigationAppBar({super.key});

  @override
  State<BottomNavigationAppBar> createState() => BottomNavigationAppBarState();
}

class BottomNavigationAppBarState extends State<BottomNavigationAppBar> {
  BottomNavigationBarItem buildCupertinoTabBarItem(
      IconData icon, String label, int index) {
    const selectedColor = AppColors.mainColor;
    const unselectedColor = Colors.black;

    return BottomNavigationBarItem(
      icon: Icon(
        icon,
        color: currentIndex == index ? selectedColor : unselectedColor,
        size: 25,
      ),
      label: label,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      items: [
        buildCupertinoTabBarItem(CupertinoIcons.home, "Home", 0),
        buildCupertinoTabBarItem(CupertinoIcons.chat_bubble, "Chat", 1),
        buildCupertinoTabBarItem(CupertinoIcons.heart, "Wish List", 2),
        buildCupertinoTabBarItem(CupertinoIcons.person, "Profile", 3),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        if (index != currentIndex) {}
        setState(() {
          currentIndex = index;
        });
      },
    );
  }
}*/
