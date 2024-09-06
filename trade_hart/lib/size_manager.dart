import 'package:flutter/material.dart';

manageHeight(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.height / 725.0;
}

manageWidth(BuildContext context, double size) {
  return size * MediaQuery.of(context).size.width / 360.0;
}
