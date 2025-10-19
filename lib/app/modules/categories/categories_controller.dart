import 'package:get/get.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/categories_repository.dart';
import '../../routes/app_routes.dart';

class CategoriesController extends GetxController {
  final CategoriesRepository _categoriesRepository =
      Get.find<CategoriesRepository>();

  // Observable variables
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString selectedState = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  // Load all categories
  Future<void> loadCategories() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final List<CategoryModel> fetchedCategories = await _categoriesRepository
          .getCategories();

      categories.value = fetchedCategories;
    } catch (e) {
      hasError.value = true;
      print('Error loading categories: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load categories by state
  Future<void> loadCategoriesByState(String state) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      selectedState.value = state;

      final List<CategoryModel> fetchedCategories = await _categoriesRepository
          .getCategoriesByState(state);

      categories.value = fetchedCategories;
    } catch (e) {
      hasError.value = true;
      print('Error loading categories by state: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh categories
  Future<void> refreshCategories() async {
    if (selectedState.value.isNotEmpty) {
      await loadCategoriesByState(selectedState.value);
    } else {
      await loadCategories();
    }
  }

  // Get current language
  String get currentLanguage => Get.locale?.languageCode ?? 'en';

  // Get category title based on current language
  String getCategoryTitle(CategoryModel category) {
    return category.getTitle(currentLanguage);
  }

  // Get category image URL
  String getCategoryImageUrl(CategoryModel category) {
    return category.getImageUrl();
  }

  // Check if category has image
  bool categoryHasImage(CategoryModel category) {
    return category.hasImage;
  }

  // Get default icon for categories without images
  String getDefaultIcon() {
    return 'assets/icons/bag.png';
  }

  // Handle category selection
  void onCategorySelected(CategoryModel category) {
    Get.toNamed(
      AppRoutes.services,
      arguments: {
        'categoryId': category.id,
        'categoryName': getCategoryTitle(category),
        'categoryImage': category.image,
        'categoryState': category.state,
      },
    );
  }

  // Handle Khabir Category selection
  void onKhabirCategorySelected() {
    Get.toNamed(
      AppRoutes.services,
      arguments: {
        'categoryType': 'Khabir',
        'categoryName': 'Khabir Category',
        'categoryId': 0, // Special ID for Khabir Category
      },
    );
  }

  // Clear state filter
  void clearStateFilter() {
    selectedState.value = '';
    loadCategories();
  }

  // Get available states from categories
  List<String> get availableStates {
    final Set<String> states = categories
        .map((category) => category.state)
        .where((state) => state.isNotEmpty)
        .toSet();
    return states.toList()..sort();
  }
}
