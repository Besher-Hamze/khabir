import 'package:get/get.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/services/api_service.dart';
import 'offers_controller.dart';

class OffersBinding extends Bindings {
  @override
  void dependencies() {
    // Register API service if not already registered
    if (!Get.isRegistered<ApiService>()) {
      Get.lazyPut<ApiService>(() => ApiService());
    }

    // Register offers repository
    Get.lazyPut<OffersRepository>(
      () => OffersRepository(Get.find<ApiService>()),
    );

    // Register offers controller
    Get.lazyPut<OffersController>(
      () => OffersController(Get.find<OffersRepository>()),
    );
  }
}
