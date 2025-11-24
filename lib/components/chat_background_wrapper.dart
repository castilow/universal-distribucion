import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/background_controller.dart';

class ChatBackgroundWrapper extends StatelessWidget {
  final Widget child;

  const ChatBackgroundWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final BackgroundController controller = Get.put(BackgroundController());

    return Obx(() => Container(
          decoration: controller.currentDecoration,
          child: child,
        ));
  }
}
