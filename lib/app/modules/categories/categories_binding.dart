import 'package:get/get.dart';
import 'categories_controller.dart';
import '../../data/repositories/categories_repository.dart';

class CategoriesBinding extends Bindings {
  @override
  void dependencies() {
    // Register the repository
    Get.lazyPut<CategoriesRepository>(() => CategoriesRepository());

    // Register the controller
    Get.lazyPut<CategoriesController>(() => CategoriesController());
  }
}
