import 'package:get/get.dart';
import '../orders/orders_controller.dart';
import '../../data/repositories/orders_repository.dart';

class MyBookingsBinding extends Bindings {
  @override
  void dependencies() {
    print('MyBookingsBinding: Initializing dependencies...');
    // Put the repository and controller directly
    Get.lazyPut<OrdersRepository>(() {
      print('MyBookingsBinding: Creating OrdersRepository');
      return OrdersRepository();
    });
    Get.lazyPut<OrdersController>(() {
      print('MyBookingsBinding: Creating OrdersController');
      return OrdersController();
    });
    print('MyBookingsBinding: Dependencies initialized');
  }
}
