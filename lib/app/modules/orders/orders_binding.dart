import 'package:get/get.dart';
import 'orders_controller.dart';
import '../../data/repositories/orders_repository.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrdersRepository>(() => OrdersRepository());
    Get.lazyPut<OrdersController>(() => OrdersController());
  }
}
