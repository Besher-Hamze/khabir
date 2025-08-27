import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/services/storage_service.dart';
import 'package:khabir/app/routes/app_routes.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/user_location_model.dart';

class UserController extends GetxController {
  final UserRepository _userRepository = Get.find<UserRepository>();
  final StorageService _storageService = Get.find<StorageService>();
  // Profile observables
  final Rx<UserProfileModel?> userProfile = Rx<UserProfileModel?>(null);
  final Rx<SystemInfoModel?> systemInfoModel = Rx<SystemInfoModel?>(null);
  final RxBool isProfileLoading = false.obs;
  final RxBool hasProfileError = false.obs;
  final RxString profileErrorMessage = ''.obs;

  // Locations observables
  final RxList<UserLocationModel> userLocations = <UserLocationModel>[].obs;
  final RxBool isLocationsLoading = false.obs;
  final RxBool hasLocationsError = false.obs;
  final RxString locationsErrorMessage = ''.obs;

  // Location management observables
  final RxBool isLocationActionLoading = false.obs;
  final Rx<UserLocationModel?> selectedLocation = Rx<UserLocationModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadUserLocations();
  }

  // Profile Management
  Future<void> loadUserProfile() async {
    try {
      isProfileLoading.value = true;
      hasProfileError.value = false;
      profileErrorMessage.value = '';

      final response = await _userRepository.getUserProfile();
      userProfile.value = response.user;
      systemInfoModel.value = response.systemInfo;
    } catch (e) {
      hasProfileError.value = true;
      profileErrorMessage.value = e.toString();
      print('Error loading user profile: $e');
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  // Location Management
  Future<void> loadUserLocations() async {
    try {
      isLocationsLoading.value = true;
      hasLocationsError.value = false;
      locationsErrorMessage.value = '';

      final response = await _userRepository.getUserLocations();
      userLocations.value = response.locations;
    } catch (e) {
      hasLocationsError.value = true;
      locationsErrorMessage.value = e.toString();
      print('Error loading user locations: $e');
    } finally {
      isLocationsLoading.value = false;
    }
  }

  Future<void> refreshLocations() async {
    await loadUserLocations();
  }

  // Create new location
  Future<bool> createLocation(CreateLocationRequest request) async {
    try {
      isLocationActionLoading.value = true;

      final newLocation = await _userRepository.createUserLocation(request);
      userLocations.add(newLocation);

      // If this is the first location or marked as default, refresh the list
      if (userLocations.length == 1 || request.isDefault) {
        await loadUserLocations();
      }

      Get.snackbar(
        'success'.tr,
        'location_created'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_create_location'.tr + ': ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLocationActionLoading.value = false;
    }
  }

  // Update existing location
  Future<bool> updateLocation(
    int locationId,
    UpdateLocationRequest request,
  ) async {
    try {
      isLocationActionLoading.value = true;

      final updatedLocation = await _userRepository.updateUserLocation(
        locationId,
        request,
      );

      // Update the location in the list
      final index = userLocations.indexWhere((loc) => loc.id == locationId);
      if (index != -1) {
        userLocations[index] = updatedLocation;
      }

      Get.snackbar(
        'success'.tr,
        'location_updated'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_update_location'.tr + ': ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLocationActionLoading.value = false;
    }
  }

  // Set default location
  Future<bool> setDefaultLocation(int locationId) async {
    try {
      isLocationActionLoading.value = true;

      await _userRepository.setDefaultLocation(locationId);

      // Refresh locations to get updated default status
      await loadUserLocations();

      Get.snackbar(
        'success'.tr,
        'default_location_set'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_set_default_location'.tr + ': ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLocationActionLoading.value = false;
    }
  }

  // Delete location
  Future<bool> deleteLocation(int locationId) async {
    try {
      isLocationActionLoading.value = true;

      await _userRepository.deleteUserLocation(locationId);

      // Remove from the list
      userLocations.removeWhere((loc) => loc.id == locationId);

      Get.snackbar(
        'success'.tr,
        'location_deleted'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_delete_location'.tr + ': ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLocationActionLoading.value = false;
    }
  }

  // Select location for service request
  void selectLocation(UserLocationModel location) {
    selectedLocation.value = location;
  }

  // Get default location
  UserLocationModel? get defaultLocation {
    try {
      return userLocations.firstWhere((loc) => loc.isDefault);
    } catch (e) {
      return userLocations.isNotEmpty ? userLocations.first : null;
    }
  }

  // Check if user has locations
  bool get hasLocations => userLocations.isNotEmpty;

  // Get location by ID
  UserLocationModel? getLocationById(int id) {
    try {
      return userLocations.firstWhere((loc) => loc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Format location for display
  String formatLocation(UserLocationModel location) {
    return '${location.title} - ${location.address}';
  }

  // Get location coordinates for service request
  Map<String, double> getLocationCoordinates(UserLocationModel location) {
    return {'latitude': location.latitude, 'longitude': location.longitude};
  }

  // Update user profile
  Future<bool> updateProfile(UpdateProfileRequest request) async {
    try {
      if (userProfile.value == null) {
        Get.snackbar(
          'Error',
          'User profile not loaded',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      final updatedProfile = await _userRepository.updateUserProfile(
        userProfile.value!.id,
        request,
      );

      // Update the local profile
      userProfile.value = updatedProfile;

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _storageService.removeToken();
      await _storageService.removeUser();
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar('Success', 'Logged out successfully');
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
