import 'package:get/get.dart';
import 'package:khabir/app/modules/orders/orders_controller.dart';
import 'package:khabir/app/modules/user/user_controller.dart';
import '../../data/services/storage_service.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;
  Rx<int> notificationCount = 0.obs;
  Rx<String> whatsAppNumber = ''.obs;
  final OrdersController ordersController = Get.find();
  final UserController userController = Get.find();
  void changePage(int index) {
    final isVisitor = isVisitorUser();

    if (isVisitor) {
      // For visitors, only allow indices 0, 1, 2 (Home, Categories, Offers)
      if (index >= 0 && index <= 2) {
        currentIndex.value = index;
      }
    } else {
      // For regular users, allow all indices
      currentIndex.value = index;
    }
  }

  // Check if current user is a visitor
  bool isVisitorUser() {
    try {
      final user = StorageService.instance.getUser();
      return user?.phoneNumber == '96812345678' ||
          user?.name.toLowerCase().contains('visitor') == true;
    } catch (e) {
      return false;
    }
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
      print(
        '=====================systemInfo: ${systemInfo?.support.whatsappSupport}',
      );

      whatsAppNumber.value =
          'https://wa.me/${systemInfo?.support.whatsappSupport ?? ''}';
    });
  }
}
