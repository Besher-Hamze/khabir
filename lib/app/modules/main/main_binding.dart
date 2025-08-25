import 'package:get/get.dart';
import 'package:khabir/app/data/repositories/banner_repository.dart';
import 'package:khabir/app/data/repositories/categories_repository.dart';
import 'package:khabir/app/data/repositories/offers_repository.dart';
import 'package:khabir/app/data/repositories/orders_repository.dart';
import 'package:khabir/app/data/services/api_service.dart';
import 'package:khabir/app/modules/categories/categories_controller.dart';
import 'package:khabir/app/modules/home/home_controller.dart';
import 'package:khabir/app/modules/offers/offers_controller.dart';
import 'package:khabir/app/data/repositories/services_repository.dart';
import 'package:khabir/app/data/repositories/providers_repository.dart';
import 'package:khabir/app/data/repositories/user_repository.dart';
import 'package:khabir/app/modules/orders/orders_controller.dart';
import 'package:khabir/app/modules/user/user_controller.dart';

import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServicesRepository>(() => ServicesRepository());
    Get.lazyPut<ProvidersRepository>(() => ProvidersRepository());
    Get.lazyPut<BannerRepository>(
      () => BannerRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<UserController>(() => UserController());
    Get.lazyPut<OrdersRepository>(() => OrdersRepository());
    Get.lazyPut<OrdersController>(() => OrdersController());
    // for category
    Get.lazyPut<CategoriesRepository>(() => CategoriesRepository());
    Get.lazyPut<CategoriesController>(() => CategoriesController());

    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<OffersRepository>(
      () => OffersRepository(Get.find<ApiService>()),
    );
    Get.lazyPut<OffersController>(
      () => OffersController(Get.find<OffersRepository>()),
    );
  }
}
