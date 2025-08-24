import 'package:get/get.dart';
import 'package:khabir/app/data/repositories/services_repository.dart';
import 'offers_controller.dart';

class OffersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesRepository>(() => ServicesRepository());
    Get.lazyPut<OffersController>(() => OffersController());
  }
}
