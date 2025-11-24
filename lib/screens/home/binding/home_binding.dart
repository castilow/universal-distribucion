import 'package:get/get.dart';
import 'package:chat_messenger/screens/home/controller/home_controller.dart';
import 'package:chat_messenger/controllers/assistant_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AssistantController>(() => AssistantController());
  }
}
