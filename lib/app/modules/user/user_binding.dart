import 'package:get/get.dart';
import 'user_controller.dart';
import '../../data/repositories/user_repository.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<UserController>(() => UserController());
  }
}
