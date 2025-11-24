import 'package:chat_messenger/config/theme_config.dart';
import 'package:flutter/material.dart';

BoxDecoration getBubbleDecoration(bool isSender) {
  final double radius = PreferencesController.instance.customBubbleRadius.value;
  
  return BoxDecoration(
    color: isSender ? primaryColor.withOpacity(.2) : greyLight,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(!isSender ? 2 : radius),
      topRight: Radius.circular(radius),
      bottomLeft: Radius.circular(radius),
      bottomRight: Radius.circular(!isSender ? radius : 2),
    ),
  );
}
