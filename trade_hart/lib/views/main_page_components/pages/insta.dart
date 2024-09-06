import 'package:flutter/material.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';

class Insta extends StatefulWidget {
  const Insta({super.key});

  @override
  State<Insta> createState() => _InstaState();
}

class _InstaState extends State<Insta> {
  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              setState(() {
                i++;
              });
            },
            child: Container(
              child: InstaImageViewer(
                child: Image(
                  image: Image.asset("images/suport_service.jpg",
                          fit: BoxFit.cover)
                      .image,
                ),
              ),
            ),
          ),
          Text(i.toString())
        ],
      ),
    ));
  }
}
