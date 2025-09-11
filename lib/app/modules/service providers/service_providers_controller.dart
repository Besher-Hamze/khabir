import 'package:get/get.dart';
import 'package:khabir/app/data/services/storage_service.dart';
import 'package:khabir/app/global_widgets/login_required_dialog.dart';
import '../../data/models/provider_model.dart';
import '../../data/repositories/providers_repository.dart';
import '../../routes/app_routes.dart';

class ServiceProvidersController extends GetxController {
  final ProvidersRepository _providersRepository =
      Get.find<ProvidersRepository>();

  // Observable variables
  final RxList<ProviderApiModel> providers = <ProviderApiModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentServiceId = 0.obs;
  final RxString currentServiceName = ''.obs;
  final RxString currentCategoryName = ''.obs;
  final RxString currentCategoryState = ''.obs;
  final RxInt currentCategoryId = 0.obs;
  final RxInt totalProviders = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from previous screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      currentServiceId.value = arguments['serviceId'] ?? 0;
      currentServiceName.value = arguments['serviceName'] ?? '';
      currentCategoryName.value = arguments['categoryName'] ?? '';
      currentCategoryState.value = arguments['categoryState'] ?? '';
      currentCategoryId.value = arguments['categoryId'] ?? 0;

      if (currentServiceId.value > 0) {
        loadProvidersByService(currentServiceId.value);
      }
    }
  }

  // Load providers by service ID
  Future<void> loadProvidersByService(int serviceId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      currentServiceId.value = serviceId;

      final ProviderApiResponse response = await _providersRepository
          .getProvidersByService(serviceId);

      providers.value = response.providers;
      totalProviders.value = response.total;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading providers by service: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh providers
  Future<void> refreshProviders() async {
    await loadProvidersByService(currentServiceId.value);
  }

  // Get provider image URL
  String getProviderImageUrl(ProviderApiModel provider) {
    if (provider.image.isNotEmpty) {
      return provider.image;
    }
    return 'assets/images/logo-04.png'; // Default image
  }

  // Check if provider has image
  bool providerHasImage(ProviderApiModel provider) {
    return provider.image.isNotEmpty;
  }

  // Get provider price
  double getProviderPrice(ProviderApiModel provider) {
    if (provider.services.isNotEmpty) {
      return provider.services.first.price;
    }
    return 0.0;
  }

  double? getProviderOfferPrice(ProviderApiModel provider) {
    if (provider.services.isNotEmpty) {
      return provider.services.first.offerPrice;
    }
    return null;
  }

  // Handle provider selection
  void onProviderSelected(ProviderApiModel provider) {
    if (Get.find<StorageService>().getUser()?.role == 'VISTOR') {
      Get.dialog(const LoginRequiredDialog());
      return;
    }
    Get.toNamed(
      AppRoutes.requestService,
      arguments: {
        'provider': provider,
        'serviceId': currentServiceId.value,
        'serviceName': currentServiceName.value,
        'categoryName': currentCategoryName.value,
        'categoryState': currentCategoryState.value,
        'categoryId': currentCategoryId.value,
      },
    );
  }

  // Get providers count
  int get providersCount => providers.length;

  // Check if providers are empty
  bool get hasProviders => providers.isNotEmpty;

  // Get service information
  String get serviceName => currentServiceName.value;
  String get categoryName => currentCategoryName.value;
  String get categoryState => currentCategoryState.value;
  int get serviceId => currentServiceId.value;
}
