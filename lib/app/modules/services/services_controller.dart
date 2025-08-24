import 'package:get/get.dart';
import '../../data/models/service_model.dart';
import '../../data/repositories/services_repository.dart';
import '../../core/utils/app_translations.dart';
import '../../routes/app_routes.dart';

class ServicesController extends GetxController {
  final ServicesRepository _servicesRepository = Get.find<ServicesRepository>();

  // Observable variables
  final RxList<ServiceModel> services = <ServiceModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt currentCategoryId = 0.obs;
  final RxString currentCategoryName = ''.obs;
  final RxString currentCategoryState = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from previous screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      currentCategoryId.value = arguments['categoryId'] ?? 0;
      currentCategoryName.value = arguments['categoryName'] ?? '';
      currentCategoryState.value = arguments['categoryState'] ?? '';

      if (currentCategoryId.value > 0) {
        loadServicesByCategory(currentCategoryId.value);
      }
    }
  }

  // Load services by category ID
  Future<void> loadServicesByCategory(int categoryId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      currentCategoryId.value = categoryId;

      final List<ServiceModel> fetchedServices = await _servicesRepository
          .getServicesByCategory(categoryId);

      services.value = fetchedServices;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading services by category: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Load all services
  Future<void> loadAllServices() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final List<ServiceModel> fetchedServices = await _servicesRepository
          .getAllServices();

      services.value = fetchedServices;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading all services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh services
  Future<void> refreshServices() async {
    if (currentCategoryId.value > 0) {
      await loadServicesByCategory(currentCategoryId.value);
    } else {
      await loadAllServices();
    }
  }

  // Get current language
  String get currentLanguage => Get.locale?.languageCode ?? 'en';

  // Get service image URL
  String getServiceImageUrl(ServiceModel service) {
    return service.getImageUrl('http://31.97.71.187:3000');
  }

  // Check if service has image
  bool serviceHasImage(ServiceModel service) {
    return service.hasImage;
  }

  // Get default icon for services without images
  String getDefaultIcon() {
    return 'assets/icons/bag.png';
  }

  // Handle service selection
  void onServiceSelected(ServiceModel service) {
    Get.toNamed(
      AppRoutes.providers,
      arguments: {
        'serviceId': service.id,
        'serviceName': service.title,
        'serviceImage': service.image,
        'categoryId': service.categoryId,
        'categoryName': currentCategoryName.value,
        'categoryState': currentCategoryState.value,
      },
    );
  }

  // Handle WhatsApp contact
  void contactViaWhatsApp(ServiceModel service) {
    if (service.whatsapp.isNotEmpty) {
      final whatsappUrl =
          'https://wa.me/${service.whatsapp.replaceAll('+', '')}';
      // You can use url_launcher here to open WhatsApp
      print('Opening WhatsApp: $whatsappUrl');
      // Get.to(() => WhatsAppContactView(phoneNumber: service.whatsapp));
    }
  }

  // Get services count
  int get servicesCount => services.length;

  // Check if services are empty
  bool get hasServices => services.isNotEmpty;

  // Get category information
  String get categoryName => currentCategoryName.value;
  String get categoryState => currentCategoryState.value;
  int get categoryId => currentCategoryId.value;

  // Filter services by commission range
  List<ServiceModel> getServicesByCommissionRange(
    double minCommission,
    double maxCommission,
  ) {
    return services
        .where(
          (service) =>
              service.commission >= minCommission &&
              service.commission <= maxCommission,
        )
        .toList();
  }

  // Sort services by commission (low to high)
  List<ServiceModel> getServicesSortedByCommission() {
    final sortedServices = List<ServiceModel>.from(services);
    sortedServices.sort((a, b) => a.commission.compareTo(b.commission));
    return sortedServices;
  }

  // Sort services by commission (high to low)
  List<ServiceModel> getServicesSortedByCommissionDesc() {
    final sortedServices = List<ServiceModel>.from(services);
    sortedServices.sort((a, b) => b.commission.compareTo(a.commission));
    return sortedServices;
  }
}
