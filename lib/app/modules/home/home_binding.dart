import 'package:get/get.dart';
import 'package:khabir/app/data/repositories/services_repository.dart';
import 'home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ServicesRepository>(() => ServicesRepository());
  }
}
