import 'package:get/get.dart';
import '../home/home_controller.dart';
import '../home/home_binding.dart';

class AllProvidersBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure HomeController is available
    if (!Get.isRegistered<HomeController>()) {
      HomeBinding().dependencies();
    }
  }
}
