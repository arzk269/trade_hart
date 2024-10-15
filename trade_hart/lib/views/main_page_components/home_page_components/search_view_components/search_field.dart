import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/pages/history_page.dart';
import 'package:trade_hart/views/main_page_components/pages/search_page.dart';

class SearchField extends StatefulWidget {
  final double? height;
  const SearchField({super.key, this.height});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const SearchPage()));
      },
      child: Container(
        margin: EdgeInsets.only(
          left: manageWidth(context, 10),
          top: manageHeight(context, 3),
        ),
        width: manageWidth(context, 275),
        height: widget.height ?? manageHeight(context, 52),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(manageWidth(context, 27.5)),
          border: Border.all(
            color: Colors.grey,
            width: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.23),
              spreadRadius: manageWidth(context, 1.5),
              blurRadius: manageWidth(context, 8),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: manageWidth(context, 15)),
            Icon(
              Icons.search,
              size: manageWidth(context, 20),
            ),
            SizedBox(
              width: manageWidth(context, 15),
            ),
            Text(
              "Search...",
              style: TextStyle(
                color: const Color.fromARGB(255, 128, 128, 128),
                fontSize: manageWidth(context, 16),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: ((context) => const HistoryPage())));
                },
                icon: Icon(
                  Icons.history_sharp,
                  size: manageWidth(context, 20),
                ))
          ],
        ),
      ),
    );
  }
}

class RealSearchField extends StatefulWidget {
  final double? height;
  final TextEditingController controller;
  const RealSearchField({super.key, this.height, required this.controller});

  @override
  State<RealSearchField> createState() => _RealSearchFieldState();
}

class _RealSearchFieldState extends State<RealSearchField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: manageWidth(context, 10),
        top: manageHeight(context, 3),
      ),
      width: manageWidth(context, 275),
      height: widget.height ?? manageHeight(context, 52),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(manageWidth(context, 27.5)),
        border: Border.all(
          color: Colors.grey,
          width: 0.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.23),
            spreadRadius: 1.5,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(width: manageWidth(context, 15)),
          Icon(
            Icons.search,
            size: manageWidth(context, 20),
          ),
          SizedBox(
            width: manageWidth(context, 225),
            height: manageHeight(context, 50),
            child: TextField(
              autofocus: true,
              controller: widget.controller,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search...',
                contentPadding: EdgeInsets.all(manageWidth(context, 15.5)),
                hintStyle: TextStyle(
                  color: const Color.fromARGB(255, 128, 128, 128),
                  fontSize: manageWidth(context, 16),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
