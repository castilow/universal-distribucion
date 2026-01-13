import 'package:get/get.dart';
import 'package:chat_messenger/screens/home/controller/home_controller.dart';
import 'package:chat_messenger/controllers/assistant_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<HomeController>(HomeController(), permanent: true);
    Get.lazyPut<AssistantController>(() => AssistantController());
  }
}
