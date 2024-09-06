import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trade_hart/size_manager.dart';
import 'package:trade_hart/views/main_page_components/home_page_components/product_view_components/product_name_view.dart';

class ChatView extends StatelessWidget {
  final bool isAllRead;
  final String? profilImage;
  final String name;
  final String message;
  final String time;

  const ChatView(
      {super.key,
      this.profilImage,
      required this.name,
      required this.message,
      required this.time,
      required this.isAllRead});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor:
                      !isAllRead ? Colors.blueAccent : Colors.transparent,
                  radius: manageWidth(context, 5),
                ),
                SizedBox(
                  width: manageWidth(context, 5),
                ),
                CircleAvatar(
                  radius: manageWidth(context, 25),
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  child: profilImage == null
                      ? Icon(CupertinoIcons.person)
                      : ClipRRect(
                          borderRadius:
                              BorderRadius.circular(manageWidth(context, 25)),
                          child: SizedBox(
                            height: manageWidth(context, 50),
                            width: manageWidth(context, 50),
                            child: Image.network(
                              profilImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  SizedBox(
                                      height: manageHeight(context, 150),
                                      width: manageWidth(context, 165),
                                      child: Column(
                                        children: [
                                          Icon(
                                            CupertinoIcons.person,
                                            size: manageWidth(context, 25),
                                          ),
                                        ],
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                      )),
                            ),
                          ),
                        ),
                ),
              ],
            ),
            title: Row(
              children: [
                ProductNameView(name: name, size: manageWidth(context, 16)),
                Spacer(),
                ProductNameView(
                  name: time,
                  size: manageWidth(context, 14.5),
                ),
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(
                left: manageWidth(context, 8),
              ),
              child: Text(
                message,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(),
              ),
            ),
          ),
        ),
        Container(
          height: manageHeight(context, 1.5),
          color: Colors.grey.withOpacity(0.2),
          margin: EdgeInsets.only(
              left: manageWidth(context, 80), top: manageHeight(context, 10)),
        ),
      ],
    );
  }
}
