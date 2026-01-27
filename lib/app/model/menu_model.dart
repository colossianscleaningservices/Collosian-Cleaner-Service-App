import 'package:flutter/cupertino.dart';

class MenuModel {
  MenuModel({
    required this.title,
    this.subtitle,
    this.icon,
    this.image,
    this.color,
    this.colors,
  });

  String? title, subtitle;
  IconData? icon;
  String? image;
  Color? color;
  List<Color>? colors;
}
