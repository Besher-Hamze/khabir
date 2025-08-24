import 'package:get/get.dart';
import 'service_providers_controller.dart';
import '../../data/repositories/providers_repository.dart';

class ServiceProvidersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProvidersRepository>(() => ProvidersRepository());
    Get.lazyPut<ServiceProvidersController>(() => ServiceProvidersController());
  }
}
