import 'package:get/get.dart';
import '../models/user_profile_model.dart';
import '../models/user_location_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class UserRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get user profile
  Future<UserProfileResponse> getUserProfile() async {
    try {
      final response = await _apiService.get(AppConstants.userProfile);

      if (response.statusCode == 200) {
        return UserProfileResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load user profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user profile: $e');
    }
  }

  // Get user locations
  Future<UserLocationResponse> getUserLocations() async {
    try {
      final response = await _apiService.get(AppConstants.userLocations);

      if (response.statusCode == 200) {
        return UserLocationResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load user locations: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching user locations: $e');
    }
  }

  // Create user location
  Future<UserLocationModel> createUserLocation(
    CreateLocationRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.userLocations,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserLocationModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating location: $e');
    }
  }

  // Update user location
  Future<UserLocationModel> updateUserLocation(
    int locationId,
    UpdateLocationRequest request,
  ) async {
    try {
      final path = AppConstants.userLocationById.replaceAll(
        '{id}',
        locationId.toString(),
      );
      final response = await _apiService.put(path, data: request.toJson());

      if (response.statusCode == 200) {
        return UserLocationModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating location: $e');
    }
  }

  // Set default location
  Future<void> setDefaultLocation(int locationId) async {
    try {
      final path = AppConstants.setDefaultLocation.replaceAll(
        '{id}',
        locationId.toString(),
      );
      final response = await _apiService.put(path);

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to set default location: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error setting default location: $e');
    }
  }

  // Delete user location
  Future<void> deleteUserLocation(int locationId) async {
    try {
      final path = AppConstants.userLocationById.replaceAll(
        '{id}',
        locationId.toString(),
      );
      final response = await _apiService.delete(path);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete location: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting location: $e');
    }
  }

  // Update user profile
  Future<UserProfileModel> updateUserProfile(
    int userId,
    UpdateProfileRequest request,
  ) async {
    try {
      final path = AppConstants.updateUserProfile.replaceAll(
        '{userId}',
        userId.toString(),
      );
      final response = await _apiService.put(path, data: request.toJson());

      if (response.statusCode == 200) {
        return UserProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating profile: $e');
    }
  }
}
