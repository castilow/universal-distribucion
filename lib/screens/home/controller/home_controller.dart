import 'package:chat_messenger/screens/contacts/controllers/contact_controller.dart';
import 'package:chat_messenger/tabs/chats/controllers/chat_controller.dart';
import 'package:chat_messenger/tabs/groups/controllers/group_controller.dart';
import 'package:chat_messenger/tabs/stories/controller/story_controller.dart';
import 'package:chat_messenger/tabs/calls/controller/call_history_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chat_messenger/tabs/chats/chats_screen.dart';
import 'package:chat_messenger/screens/contacts/contacts_screen.dart';
import 'package:chat_messenger/tabs/videos/videos_screen.dart';
import 'package:chat_messenger/tabs/calls/call_hsitory_screen.dart';
import 'package:chat_messenger/tabs/products/products_screen.dart';
import 'package:chat_messenger/tabs/profile/profile_screen.dart';
import 'package:chat_messenger/screens/dashboard/dashboard_screen.dart';
import 'package:chat_messenger/tabs/orders/orders_screen.dart';
import 'package:chat_messenger/controllers/order_controller.dart';
import 'package:chat_messenger/controllers/product_controller.dart';

class HomeController extends GetxController {
  // Vars
  final RxInt pageIndex = 0.obs;

  // List of tab pages (Chats, Contacts, Videos, Calls, Settings)
  final List<Widget> pages = [
    const DashboardScreen(), // Replaces ChatsScreen
    const OrdersScreen(),    // Replaces ContactsScreen (Index 1)
    const VideosScreen(),
    const ProductsScreen(), // Replaces CallHistoryScreen (Index 3)
    const ProfileScreen(),
  ];

  @override
  void onInit() {
    Get.put(ContactController(), permanent: true);
    Get.put(ChatController(), permanent: true);
    Get.put(ProductController(), permanent: true); // Product Manager
    Get.put(OrderController(), permanent: true); // Register Order Controller
    Get.put(GroupController(), permanent: true);
    Get.put(StoryController(), permanent: true); // Restaurado para historias en chats
    Get.put(CallHistoryController(), permanent: true);
    super.onInit();
  }
}
