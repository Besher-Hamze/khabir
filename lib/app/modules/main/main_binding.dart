import 'package:get/get.dart';
import 'package:khabir/app/modules/home/home_controller.dart';
import 'package:khabir/app/modules/offers/offers_controller.dart';
import 'package:khabir/app/data/repositories/services_repository.dart';
import 'package:khabir/app/data/repositories/providers_repository.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesRepository>(() => ServicesRepository());
    Get.lazyPut<ProvidersRepository>(() => ProvidersRepository());
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<OffersController>(() => OffersController());
  }
}
