import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/services_repository.dart';
import '../../data/models/service_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/category_model.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class HomeController extends GetxController {
  final ServicesRepository _servicesRepository = Get.find<ServicesRepository>();

  var isLoading = false.obs;
  var categories = <CategoryModel>[].obs;
  var bestProviders = <ServiceProvider>[].obs;
  var selectedState = 'الرياض'.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    try {
      await Future.wait([loadCategories(), loadBestProviders()]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      final categoriesList = await _servicesRepository.getCategories();
      categories.value = categoriesList
          .take(10)
          .toList(); // Show first 10 categories
    } catch (e) {
      print('Error loading categories: $e');
      // Fallback to mock data
      categories.value = _getMockCategories();
    }
  }

  Future<void> loadBestProviders() async {
    try {
      final providersList = await _servicesRepository.getTopRatedProviders();
      bestProviders.value = providersList
          .take(5)
          .toList(); // Show first 5 providers
    } catch (e) {
      print('Error loading best providers: $e');
      // Fallback to mock data
      bestProviders.value = _getMockProviders();
    }
  }

  // Mock data fallback methods
  List<CategoryModel> _getMockCategories() {
    return [
      CategoryModel(
        id: 1,
        image: 'assets/icons/bag.png',
        titleAr: 'كهرباء',
        titleEn: 'Electricity',
        state: 'الرياض',
      ),
      CategoryModel(
        id: 2,
        image: 'assets/icons/bag.png',
        titleAr: 'سباكة',
        titleEn: 'Plumbing',
        state: 'الرياض',
      ),
      CategoryModel(
        id: 3,
        image: 'assets/icons/bag.png',
        titleAr: 'نجارة',
        titleEn: 'Carpentry',
        state: 'الرياض',
      ),
      CategoryModel(
        id: 4,
        image: 'assets/icons/bag.png',
        titleAr: 'تلفاز وستالايت',
        titleEn: 'TV & Satellite',
        state: 'الرياض',
      ),
      CategoryModel(
        id: 5,
        image: 'assets/icons/bag.png',
        titleAr: 'دهان',
        titleEn: 'Painting',
        state: 'الرياض',
      ),
    ];
  }

  List<ServiceProvider> _getMockProviders() {
    return [
      ServiceProvider(
        id: '1',
        name: 'أحمد محمد',
        phone: '+966501234567',
        state: 'الرياض',
        city: 'الرياض',
        rating: 4.8,
        reviewsCount: 25,
        status: ProviderStatus.online,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
      ),
      ServiceProvider(
        id: '2',
        name: 'محمد علي',
        phone: '+966502345678',
        state: 'الرياض',
        city: 'الرياض',
        rating: 4.6,
        reviewsCount: 18,
        status: ProviderStatus.online,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 200)),
      ),
      ServiceProvider(
        id: '3',
        name: 'فاطمة أحمد',
        phone: '+966503456789',
        state: 'الرياض',
        city: 'الرياض',
        rating: 4.9,
        reviewsCount: 42,
        status: ProviderStatus.busy,
        isVerified: true,
        createdAt: DateTime.now().subtract(const Duration(days: 300)),
      ),
    ];
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'good_morning'.tr;
    } else if (hour < 17) {
      return 'good_afternoon'.tr;
    } else {
      return 'good_evening'.tr;
    }
  }

  void openWhatsAppSupport() async {
    final url = '${AppConstants.whatsAppUrl}${AppConstants.supportWhatsApp}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void goToNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  void goToSearch() {
    Get.toNamed(AppRoutes.search);
  }

  void goToCategories() {
    Get.toNamed(AppRoutes.categories);
  }

  void goToCategory(CategoryModel category) {
    Get.toNamed(
      AppRoutes.services,
      arguments: {
        'categoryId': category.id,
        'categoryName': category.titleEn,
        'categoryImage': category.image,
        'categoryState': category.state,
      },
    );
  }

  void goToProvider(ServiceProvider provider) {
    // Get.to(const RequestServiceView());
  }

  void goToAllProviders() {
    Get.toNamed(AppRoutes.providers);
  }

  void selectState(String state) {
    selectedState.value = state;
    loadBestProviders();
  }

  void showStateSelectionDialog() {
    final states = [
      'الرياض',
      'جدة',
      'الدمام',
      'مكة المكرمة',
      'المدينة المنورة',
      'الطائف',
      'تبوك',
      'بريدة',
      'خميس مشيط',
      'الهفوف',
    ];

    Get.dialog(
      AlertDialog(
        title: Text('select_state'.tr),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: states.length,
            itemBuilder: (context, index) {
              final state = states[index];
              return ListTile(
                title: Text(state),
                trailing: selectedState.value == state
                    ? Icon(Icons.check, color: Get.theme.primaryColor)
                    : null,
                onTap: () {
                  selectState(state);
                  Get.back();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> refreshData() async {
    await loadHomeData();
  }
}
