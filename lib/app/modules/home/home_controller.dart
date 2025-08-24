import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/services_repository.dart';
import '../../data/repositories/providers_repository.dart';
import '../../data/models/service_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/category_model.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class HomeController extends GetxController {
  final ServicesRepository _servicesRepository = Get.find<ServicesRepository>();
  final ProvidersRepository _providersRepository =
      Get.find<ProvidersRepository>();

  var isLoading = false.obs;
  var isProvidersLoading = false.obs;
  var categories = <CategoryModel>[].obs;
  var bestProviders = <TopProviderModel>[].obs;
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
      categories.value = [];
    }
  }

  Future<void> loadBestProviders() async {
    try {
      isProvidersLoading.value = true;
      print('Loading best providers...');

      final response = await _providersRepository.getTopProviders();
      print('API Response: ${response.providers.length} providers received');

      if (response.providers.isNotEmpty) {
        // Filter active providers and sort by rank/score
        final activeProviders = response.providers
            .where((provider) => provider.isActive)
            .toList();

        if (activeProviders.isNotEmpty) {
          // Sort by rank (lower is better) and take top 5
          activeProviders.sort((a, b) => a.rank.compareTo(b.rank));
          bestProviders.value = activeProviders.take(5).toList();

          print(
            'Successfully loaded ${bestProviders.length} active providers from API',
          );
          print('Providers sorted by rank:');

          // Debug: Print provider details
          for (var provider in bestProviders) {
            print(
              'Provider: ${provider.name} - Rating: ${provider.averageRating} - Tier: ${provider.tier} - Rank: ${provider.rank}',
            );
          }
        } else {
          print('No active providers found in API response');
          bestProviders.value = [];
        }
      } else {
        print('No providers returned from API');
        bestProviders.value = [];
      }
    } catch (e) {
      print('Error loading best providers: $e');
      print('Error details: ${e.toString()}');
      bestProviders.value = [];
    } finally {
      isProvidersLoading.value = false;
    }
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

  void goToProvider(TopProviderModel provider) {
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

  Future<void> refreshProviders() async {
    await loadBestProviders();
  }

  Future<void> forceRefreshProviders() async {
    print('Force refreshing providers...');
    bestProviders.clear(); // Clear existing data
    await loadBestProviders(); // Reload from API
  }

  bool get hasProviders => bestProviders.isNotEmpty;

  int get providersCount => bestProviders.length;

  bool get needsRefresh => bestProviders.isEmpty && !isProvidersLoading.value;

  String get providersStatus {
    if (isProvidersLoading.value) return 'Loading...';
    if (bestProviders.isEmpty) return 'No providers available';
    return '${bestProviders.length} providers loaded';
  }
}
