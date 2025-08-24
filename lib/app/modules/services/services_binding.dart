import 'package:get/get.dart';
import 'services_controller.dart';
import '../../data/repositories/services_repository.dart';

class ServicesBinding extends Bindings {
  @override
  void dependencies() {
    // Register the repository
    Get.lazyPut<ServicesRepository>(() => ServicesRepository());

    // Register the controller
    Get.lazyPut<ServicesController>(() => ServicesController());
  }
}
