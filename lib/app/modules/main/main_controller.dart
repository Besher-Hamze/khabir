import 'package:get/get.dart';
import 'package:khabir/app/modules/orders/orders_controller.dart';
import 'package:khabir/app/modules/user/user_controller.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;
  Rx<int> notificationCount = 0.obs;
  Rx<String> whatsAppNumber = ''.obs;
  final OrdersController ordersController = Get.find();
  final UserController userController = Get.find();
  void changePage(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    // still listen for order changes using ever
    ever(ordersController.orders, (orders) {
      print('=====================orders: ${orders.length}');
      notificationCount.value = orders.length;
    });
    ever(userController.systemInfoModel, (systemInfo) {
      whatsAppNumber.value = systemInfo?.support.whatsappSupport ?? '';
    });
  }
}
