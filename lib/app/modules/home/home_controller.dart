import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/banner_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/repositories/services_repository.dart';
import '../../data/repositories/providers_repository.dart';
import '../../data/repositories/banner_repository.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/category_model.dart';
import '../../routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class HomeController extends GetxController {
  final ServicesRepository _servicesRepository = Get.find<ServicesRepository>();
  final ProvidersRepository _providersRepository =
      Get.find<ProvidersRepository>();
  final BannerRepository _bannerRepository = Get.find<BannerRepository>();

  var isLoading = false.obs;
  var isProvidersLoading = false.obs;
  var isBannersLoading = false.obs;
  var categories = <CategoryModel>[].obs;
  var bestProviders = <TopProviderModel>[].obs;
  var banners = <BannerModel>[].obs;
  var selectedState = 'الرياض'.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    isLoading.value = true;
    try {
      await Future.wait([loadCategories(), loadBestProviders(), loadBanners()]);
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

  Future<void> loadBanners() async {
    try {
      isBannersLoading.value = true;
      final bannersList = await _bannerRepository.getAdBanners();
      // Filter only active banners
      banners.value = bannersList.where((banner) => banner.isActive).toList();
      print('Loaded ${banners.length} active banners');
    } catch (e) {
      print('Error loading banners: $e');
      banners.value = [];
    } finally {
      isBannersLoading.value = false;
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
          activeProviders.sort((a, b) => a.rank.compareTo(b.rank ?? 0));
          bestProviders.value = activeProviders.take(5).toList();
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

  // FIXED: Better URL validation and error handling
  Future<void> openWhatsAppSupport() async {
    try {
      final url = '${AppConstants.whatsAppUrl}${AppConstants.supportWhatsApp}';

      // Validate URL format
      if (!_isValidUrl(url)) {
        print('Invalid WhatsApp URL: $url');
        _showErrorMessage('Invalid WhatsApp URL');
        return;
      }

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Cannot launch WhatsApp URL: $url');
        _showErrorMessage('WhatsApp is not installed or URL is invalid');
      }
    } catch (e) {
      print('Error opening WhatsApp support: $e');
      _showErrorMessage('Failed to open WhatsApp');
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
        'categoryName': category.getTitle(Get.locale?.languageCode ?? 'en'),
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

  // FIXED: Better URL validation and error handling for banners
  Future<void> onBannerTap(BannerModel banner) async {
    try {
      if (banner.linkType == 'external' && banner.externalLink != null) {
        final url = banner.externalLink!;

        // Validate URL format
        if (!_isValidUrl(url)) {
          print('Invalid external URL in banner: $url');
          _showErrorMessage('Invalid link URL');
          return;
        }

        final uri = Uri.parse(url);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          print('Cannot launch external URL: $url');
          _showErrorMessage('Cannot open this link');
        }
      } else if (banner.linkType == 'provider' && banner.providerId != null) {
        // get provider by id
        final provider = await _providersRepository.getProviderById(
          banner.providerId.toString(),
        );
        Get.toNamed(
          AppRoutes.requestService,
          arguments: {'provider': provider},
        );
      }
    } catch (e) {
      print('Error handling banner tap: $e');
      _showErrorMessage('Failed to open link');
    }
  }

  void selectState(String state) {
    selectedState.value = state;
    loadBestProviders();
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

  // ADDED: URL validation helper method
  bool _isValidUrl(String url) {
    if (url.isEmpty) return false;

    try {
      final uri = Uri.parse(url);

      // Check for placeholder text (common Lorem ipsum words)
      final placeholderWords = [
        'lorem',
        'ipsum',
        'dolor',
        'sit',
        'amet',
        'autem',
        'nostrum',
      ];
      final lowercaseUrl = url.toLowerCase();

      for (String word in placeholderWords) {
        if (lowercaseUrl.contains(word)) {
          print('URL contains placeholder text: $word');
          return false;
        }
      }

      // Must have a scheme
      if (uri.scheme.isEmpty) return false;

      // For web URLs, must have a host
      if ((uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      print('URL parsing error: $e');
      return false;
    }
  }

  // ADDED: Error message helper
  void _showErrorMessage(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      duration: Duration(seconds: 3),
    );
  }
}
