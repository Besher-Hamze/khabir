import 'package:get/get.dart';
import 'request_service_controller.dart';

class RequestServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestServiceController>(() => RequestServiceController());
  }
}
