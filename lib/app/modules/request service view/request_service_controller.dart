import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/provider_model.dart';
import '../../data/models/service_model.dart';
import '../../data/models/user_location_model.dart';
import '../../data/repositories/providers_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class RequestServiceController extends GetxController {
  final ProvidersRepository _providersRepository =
      Get.find<ProvidersRepository>();
  final UserRepository _userRepository = Get.find<UserRepository>();

  // Observable variables
  final RxList<ProviderServiceItem> services = <ProviderServiceItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool hasError = false.obs;
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
    _initializeFromArguments();
    loadUserLocations();
  }

  // Initialize controller with arguments from navigation
  void _initializeFromArguments() {
    final arguments = Get.arguments as Map<String, dynamic>?;
    if (arguments != null) {
      provider = arguments['provider'] as ProviderApiModel?;
      serviceId = arguments['serviceId'] as int?;
      categoryId = arguments['categoryId'] as int?;

      if (provider != null && categoryId != null) {
        loadProviderServices(provider!.id, categoryId!);
      }
    }
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
      // Don't show error to user for locations, just log it
    }
  }

  // Load provider services
  Future<void> loadProviderServices(int providerId, int categoryId) async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final Provider response = await _providersRepository.getProviderServices(
        providerId,
        categoryId,
      );

      services.value = response.services;
      _initializeServiceQuantities();
    } catch (e) {
      hasError.value = true;
      print('Error loading provider services: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Initialize service quantities to 0
  void _initializeServiceQuantities() {
    serviceQuantities.clear();
    for (var service in services) {
      serviceQuantities[service.id] = 0;
    }
  }

  // Update service quantity with validation
  void updateServiceQuantity(int serviceId, int quantity) {
    if (quantity < 0) return; // Don't allow negative quantities

    serviceQuantities[serviceId] = quantity;
    serviceQuantities.refresh(); // Force UI update
  }

  // Get service quantity
  int getServiceQuantity(int serviceId) {
    return serviceQuantities[serviceId] ?? 0;
  }

  // Calculate total price for a specific service (price * quantity) + (commission * quantity)
  double getServiceTotalPrice(int serviceId) {
    final service = services.firstWhereOrNull((s) => s.id == serviceId);
    if (service == null) return 0.0;

    final quantity = getServiceQuantity(serviceId);
    if (quantity == 0) return 0.0;

    final basePrice = service.offerPrice != null
        ? service.offerPrice! * quantity
        : service.price * quantity;
    final totalCommission = 0;

    return basePrice + totalCommission;
  }

  // Calculate total price for all selected services
  double getTotalPrice() {
    double total = 0.0;
    for (var service in services) {
      final quantity = getServiceQuantity(service.id);
      if (quantity > 0) {
        final servicePrice = (service.offerPrice ?? service.price) * quantity;
        total += servicePrice;
      }
    }
    return total;
  }

  // Get selected services count - make it reactive
  int get selectedServicesCount {
    return serviceQuantities.values.where((quantity) => quantity > 0).length;
  }

  // Check if any services are selected - make it reactive
  bool get hasSelectedServices {
    return serviceQuantities.values.any((quantity) => quantity > 0);
  }

  // Get list of selected services with their quantities
  List<Map<String, dynamic>> get selectedServicesDetails {
    final List<Map<String, dynamic>> selectedServices = [];

    for (var service in services) {
      final quantity = getServiceQuantity(service.id);
      if (quantity > 0) {
        selectedServices.add({
          'service': service,
          'quantity': quantity,
          'totalPrice': getServiceTotalPrice(service.id),
        });
      }
    }

    return selectedServices;
  }

  // Set duration with validation
  void setDuration(String duration) {
    final validDurations = ['Now', 'Tomorrow', 'Calendar'];
    if (!validDurations.contains(duration)) return;

    selectedDuration.value = duration;
    if (duration != 'Calendar') {
      selectedDate.value = null;
    }
  }

  // Set date with validation
  void setDate(DateTime date) {
    // Don't allow past dates
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return;
    }

    selectedDate.value = date;
    selectedDuration.value = 'Calendar';
  }

  // Set location
  void setLocation(UserLocationModel location) {
    selectedLocation.value = location;
  }

  // Validate request before submission
  bool _validateRequest() {
    if (!hasSelectedServices) {
      _showErrorSnackbar('Please select at least one service');
      return false;
    }

    if (selectedLocation.value == null) {
      _showErrorSnackbar('Please select a service location');
      return false;
    }

    if (selectedDuration.value == 'Calendar' && selectedDate.value == null) {
      _showErrorSnackbar('Please select a date for your service');
      return false;
    }

    return true;
  }

  // Submit service request
  Future<void> submitRequest() async {
    // Check if user is visitor and show registration popup
    if (_isVisitorUser()) {
      _showRegistrationPopup();
      return;
    }

    if (!_validateRequest()) return;

    try {
      isSubmitting.value = true;

      final request = _buildServiceRequest();
      final response = await _providersRepository.createServiceRequest(request);

      // Reset form state
      resetForm();

      // Navigate to success page
      Get.offAllNamed(
        AppRoutes.successPage,
        arguments: {
          'bookingId': response.id,
          'totalAmount': response.totalAmount.toString(),
          'scheduledDate': response.scheduledDate.toString(),
          'providerName': provider?.name ?? 'Provider',
          'servicesCount': selectedServicesCount,
        },
      );

      _showSuccessSnackbar('Service request submitted successfully');
    } catch (e) {
      _handleSubmissionError(e);
    } finally {
      isSubmitting.value = false;
    }
  }

  // Build service request object
  ServiceRequestRequest _buildServiceRequest() {
    return ServiceRequestRequest(
      providerId: provider?.id ?? 0,
      services: selectedServicesDetails
          .map(
            (serviceDetail) => ServiceRequestItem(
              serviceId: serviceDetail['service'].id,
              quantity: serviceDetail['quantity'],
            ),
          )
          .toList(),
      scheduledDate: _getScheduledDate(),
      location: selectedLocation.value?.title ?? "Selected Location",
      locationDetails: selectedLocation.value?.address ?? "No location details",
      userLocation: UserLocation(
        latitude: selectedLocation.value?.latitude ?? 0.0,
        longitude: selectedLocation.value?.longitude ?? 0.0,
        address: selectedLocation.value?.address ?? "No address",
      ),
      notes: notes.value.trim().isNotEmpty
          ? notes.value.trim()
          : 'Service request submitted from mobile app',
    );
  }

  // Get formatted scheduled date
  String _getScheduledDate() {
    if (selectedDate.value != null) {
      return selectedDate.value!.toUtc().toIso8601String();
    }

    switch (selectedDuration.value) {
      case 'Tomorrow':
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        return DateTime(
          tomorrow.year,
          tomorrow.month,
          tomorrow.day,
          10, // 10 AM default time
          0,
        ).toUtc().toIso8601String();

      case 'Now':
      default:
        // Schedule for next hour
        final nextHour = DateTime.now().add(const Duration(hours: 1));
        return nextHour.toUtc().toIso8601String();
    }
  }

  // Check if current user is a visitor
  bool _isVisitorUser() {
    try {
      final user = StorageService.instance.getUser();
      return user?.phoneNumber == '+96812345678' ||
          user?.name.toLowerCase().contains('visitor') == true;
    } catch (e) {
      return false;
    }
  }

  // Show registration popup for visitor users
  void _showRegistrationPopup() {
    Get.dialog(
      AlertDialog(
        title: Text('registration_required'.tr),
        content: Text('visitor_registration_message'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.signup);
            },
            child: Text('register_now'.tr),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  // Handle submission errors
  void _handleSubmissionError(dynamic error) {
    final String errorMsg = _extractErrorMessage(error.toString());

    Get.snackbar(
      'Submission Failed',
      errorMsg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      onTap: (_) => Get.closeCurrentSnackbar(),
    );

    print('Error submitting service request: $error');
  }

  // Extract clean error message
  String _extractErrorMessage(String error) {
    if (error.contains('Exception:')) {
      return error.split('Exception:').last.trim();
    } else if (error.contains('Error:')) {
      return error.split('Error:').last.trim();
    } else if (error.contains('SocketException')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (error.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.contains('FormatException')) {
      return 'Invalid data format. Please try again.';
    }

    return error.isNotEmpty ? error : 'An unexpected error occurred';
  }

  // Show error snackbar
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  // Show success snackbar
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
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
    _initializeServiceQuantities();
  }

  // Increment service quantity
  void incrementServiceQuantity(int serviceId) {
    final currentQuantity = getServiceQuantity(serviceId);
    updateServiceQuantity(serviceId, currentQuantity + 1);
  }

  // Decrement service quantity
  void decrementServiceQuantity(int serviceId) {
    final currentQuantity = getServiceQuantity(serviceId);
    if (currentQuantity > 0) {
      updateServiceQuantity(serviceId, currentQuantity - 1);
    }
  }

  // Clear all selected services
  void clearAllServices() {
    for (var service in services) {
      serviceQuantities[service.id] = 0;
    }
    serviceQuantities.refresh();
  }

  // Set notes with validation
  void setNotes(String value) {
    // Limit notes to reasonable length
    if (value.length <= 500) {
      notes.value = value;
    }
  }

  // Get formatted total price string
  String get formattedTotalPrice {
    return '${getTotalPrice().toStringAsFixed(2)} OMR';
  }

  // Get scheduled date display string
  String get scheduledDateDisplay {
    if (selectedDate.value != null) {
      final date = selectedDate.value!;
      return '${date.day}/${date.month}/${date.year}';
    }
    return selectedDuration.value;
  }

  // Check if service request can be submitted
  bool get canSubmitRequest {
    return hasSelectedServices &&
        selectedLocation.value != null &&
        !isSubmitting.value &&
        (selectedDuration.value != 'Calendar' || selectedDate.value != null);
  }

  @override
  void onClose() {
    // Clean up resources
    services.clear();
    serviceQuantities.clear();
    availableLocations.clear();
    super.onClose();
  }
}
