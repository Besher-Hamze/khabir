import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/provider_model.dart';
import 'package:khabir/app/data/models/service_model.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/user_location_model.dart';
import '../../data/repositories/providers_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../routes/app_routes.dart';

class RequestServiceController extends GetxController {
  final ProvidersRepository _providersRepository =
      Get.find<ProvidersRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  // Observable variables
  final RxList<ProviderServiceItem> services = <ProviderServiceItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting =
      false.obs; // Separate loading state for submission
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<int, int> serviceQuantities = <int, int>{}.obs;
  final RxString selectedDuration = 'Now'.obs;
  final Rx<UserLocationModel?> selectedLocation = Rx<UserLocationModel?>(null);
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);
  final RxString notes = ''.obs;
  final RxList<UserLocationModel> availableLocations =
      <UserLocationModel>[].obs;

  // Provider and category info
  ProviderApiModel? provider;
  int? serviceId;
  int? categoryId;

  @override
  void onInit() {
    super.onInit();
    // Get arguments passed from previous screen
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      provider = arguments['provider'] as ProviderApiModel?;
      serviceId = arguments['serviceId'] as int?;
      categoryId = arguments['categoryId'] as int?;

      if (provider != null && categoryId != null) {
        loadProviderServices(provider!.id, categoryId!);
      }
    }

    // Load user locations
    loadUserLocations();
  }

  // Load user locations
  Future<void> loadUserLocations() async {
    try {
      final response = await _userRepository.getUserLocations();
      availableLocations.value = response.locations;

      // Set default location if available
      if (availableLocations.isNotEmpty) {
        final defaultLocation = availableLocations.firstWhereOrNull(
          (loc) => loc.isDefault,
        );
        selectedLocation.value = defaultLocation ?? availableLocations.first;
      }
    } catch (e) {
      print('Error loading user locations: $e');
    }
  }

  // Load provider services
  Future<void> loadProviderServices(int providerId, int categoryId) async {
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';

      final Provider response = await _providersRepository.getProviderServices(
        providerId,
        categoryId,
      );

      services.value = response.services;

      // Initialize quantities to 0
      for (var service in response.services) {
        serviceQuantities[service.id] = 0;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
      print('Error loading provider services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Update service quantity
  void updateServiceQuantity(int serviceId, int quantity) {
    serviceQuantities[serviceId] = quantity;
  }

  // Get service quantity
  int getServiceQuantity(int serviceId) {
    return serviceQuantities[serviceId] ?? 0;
  }

  // Calculate total price for a specific service (price * quantity + commission)
  double getServiceTotalPrice(int serviceId) {
    final service = services.firstWhereOrNull((s) => s.id == serviceId);
    if (service == null) return 0.0;

    final quantity = getServiceQuantity(serviceId);
    final basePrice = service.price * quantity;
    final commission = service.commission ?? 0;

    return basePrice + commission;
  }

  // Calculate total price for all selected services
  double getTotalPrice() {
    double total = 0.0;
    for (var service in services) {
      final quantity = getServiceQuantity(service.id);
      if (quantity > 0) {
        total += getServiceTotalPrice(service.id);
      }
    }
    return total;
  }

  // Get selected services count
  int get selectedServicesCount {
    return serviceQuantities.values.where((quantity) => quantity > 0).length;
  }

  // Check if any services are selected
  bool get hasSelectedServices {
    return selectedServicesCount > 0;
  }

  // Set duration
  void setDuration(String duration) {
    selectedDuration.value = duration;
    if (duration != 'Calendar') {
      selectedDate.value = null;
    }
  }

  // Set date
  void setDate(DateTime date) {
    selectedDate.value = date;
    selectedDuration.value = 'Calendar';
  }

  // Set location
  void setLocation(UserLocationModel location) {
    selectedLocation.value = location;
  }

  // Submit service request
  Future<void> submitRequest() async {
    if (!hasSelectedServices) {
      Get.snackbar(
        'Error',
        'Please select at least one service',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      // Show submission loading state
      isSubmitting.value = true;

      // Prepare the request data according to the API structure
      final request = ServiceRequestRequest(
        providerId: provider?.id ?? 0,
        services: services
            .where((service) => getServiceQuantity(service.id) > 0)
            .map(
              (service) => ServiceRequestItem(
                serviceId: service.id,
                quantity: getServiceQuantity(service.id),
              ),
            )
            .toList(),
        scheduledDate: _getScheduledDate(),
        location: selectedLocation.value?.title ?? "Home",
        locationDetails:
            selectedLocation.value?.address ?? "No location selected",
        userLocation: UserLocation(
          latitude: selectedLocation.value?.latitude ?? 0.0,
          longitude: selectedLocation.value?.longitude ?? 0.0,
          address: selectedLocation.value?.address ?? "No address",
        ),
        notes: notes.value.isNotEmpty
            ? notes.value
            : 'Service request from mobile app',
      );

      // Send the request to the API
      final response = await _providersRepository.createServiceRequest(request);

      // Hide submission loading state
      isSubmitting.value = false;

      // Reset form state
      resetForm();

      // Navigate to success page with booking details
      Get.offAllNamed(
        AppRoutes.successPage,
        arguments: {
          'bookingId': response.id,
          'totalAmount': response.totalAmount.toString(),
          'scheduledDate': response.scheduledDate.toString(),
        },
      );
    } catch (e) {
      // Hide submission loading state
      isSubmitting.value = false;

      // Show error message
      String errorMsg = 'Failed to submit service request';
      if (e.toString().contains('Exception:')) {
        errorMsg = e.toString().split('Exception:').last.trim();
      } else if (e.toString().contains('Error:')) {
        errorMsg = e.toString().split('Error:').last.trim();
      } else {
        errorMsg = e.toString();
      }

      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        onTap: (_) {
          // If user taps the snackbar, dismiss it
          Get.closeCurrentSnackbar();
        },
      );

      print('Error submitting service request: $e');
    }
  }

  // Helper method to format the scheduled date
  String _getScheduledDate() {
    if (selectedDate.value != null) {
      return selectedDate.value!.toUtc().toIso8601String();
    } else if (selectedDuration.value == 'Tomorrow') {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        10,
        0,
      ).toUtc().toIso8601String();
    } else {
      // Now - schedule for next hour
      final nextHour = DateTime.now().add(const Duration(hours: 1));
      return nextHour.toUtc().toIso8601String();
    }
  }

  // Refresh services
  Future<void> refreshServices() async {
    if (provider != null && categoryId != null) {
      await loadProviderServices(provider!.id, categoryId!);
    }
  }

  // Reset form state after successful submission
  void resetForm() {
    serviceQuantities.clear();
    selectedDuration.value = 'Now';
    selectedDate.value = null;
    notes.value = '';

    // Reinitialize quantities to 0
    for (var service in services) {
      serviceQuantities[service.id] = 0;
    }
  }
}
