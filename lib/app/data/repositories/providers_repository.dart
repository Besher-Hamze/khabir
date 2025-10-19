import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/booking_model.dart';
import 'package:khabir/app/data/models/provider_model.dart';
import 'package:khabir/app/data/models/service_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ProvidersRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get all providers
  Future<List<Provider>> getAllProviders() async {
    try {
      final response = await _apiService.get('/providers');

      if (response.statusCode == 200) {
        if (response.data == null) {
          return [];
        }

        final List<dynamic> providersData = response.data ?? [];
        final List<Provider> providers = [];

        for (var providerData in providersData) {
          try {
            final provider = Provider.fromJson(
              providerData as Map<String, dynamic>,
            );
            providers.add(provider);
          } catch (e) {
            // Continue with other providers instead of failing completely
          }
        }

        return providers;
      } else {
        throw Exception('Failed to load all providers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching all providers: $e');
    }
  }

  // Get providers by service ID
  Future<ProviderResponse> getProvidersByService(int serviceId) async {
    try {
      final path = AppConstants.providersByService.replaceAll(
        '{id}',
        serviceId.toString(),
      );

      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        if (response.data == null) {
          return ProviderResponse(
            providers: [],
            total: 0,
            serviceId: serviceId,
          );
        }

        // Handle the response structure
        final List<dynamic> providersData = response.data['providers'] ?? [];
        final int total = response.data['total'] ?? 0;
        final int responseServiceId = response.data['serviceId'] ?? serviceId;

        // Debug the structure before parsing
        if (providersData.isNotEmpty) {
          final firstProvider = providersData.first;

          if (firstProvider['providerServices'] != null) {
            final firstService =
                (firstProvider['providerServices'] as List).first;
          }
        }

        // Convert to Provider objects with enhanced error handling
        final List<Provider> providers = [];

        for (var providerData in providersData) {
          try {
            final provider = Provider.fromJson(
              providerData as Map<String, dynamic>,
            );
            providers.add(provider);
          } catch (e) {
            // Continue with other providers instead of failing completely
          }
        }

        // Debug parsed providers

        return ProviderResponse(
          providers: providers,
          total: total,
          serviceId: responseServiceId,
        );
      } else {
        throw Exception('Failed to load providers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching providers: $e');
    }
  }

  Future<ProviderResponse> getTopProviders({String? state}) async {
    try {
      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (state != null) queryParams['state'] = state;

      final response = await _apiService.get(
        AppConstants.topProviders,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        if (response.data == null) {
          return ProviderResponse(providers: [], total: 0, state: state);
        }

        // Handle the response structure properly
        final List<dynamic> providersData = response.data['providers'] ?? [];
        final int total = response.data['total'] ?? 0;

        // Convert to Provider objects with proper type casting
        final List<Provider> providers = providersData
            .map((json) => Provider.fromJson(json as Map<String, dynamic>))
            .toList();

        return ProviderResponse(
          providers: providers,
          total: total,
          state: state,
        );
      } else {
        throw Exception('Failed to load top providers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching top providers: $e');
    }
  }

  // Get provider services
  Future<Provider> getProviderServices(int providerId, int categoryId) async {
    try {
      var path;
      if (true) {
        path = AppConstants.providerServicesAll.replaceAll(
          '{providerId}',
          providerId.toString(),
        );
      } else {
        path = AppConstants.providerServices
            .replaceAll('{providerId}', providerId.toString())
            .replaceAll('{categoryId}', categoryId.toString());
      }

      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        print('response.data: ${response.data['averageRating']}');
        return Provider.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to load provider services: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching provider services: $e');
    }
  }

  // Create service request
  Future<Order> createServiceRequest(ServiceRequestRequest request) async {
    try {
      print('request: ${request.toJson()}');
      final response = await _apiService.post(
        AppConstants.createServiceRequest,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Order.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to create service request: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error creating service request: $e');
      throw Exception('Error creating service request: $e');
    }
  }

  // Get top providers

  // Get provider by ID
  Future<Provider> getProviderById(String providerId) async {
    final response = await _apiService.get(
      AppConstants.providerById.replaceAll('{id}', providerId),
    );

    return Provider.fromJson(response.data);
  }

  // Rate a provider
  Future<Map<String, dynamic>> rateProvider({
    required int providerId,
    required int orderId,
    required double rating,
    String? comment,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.providerRatings,
        data: {
          'providerId': providerId,
          'orderId': orderId,
          'rating': rating,
          'comment': comment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Rating submitted successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to submit rating',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Error submitting rating: $e'};
    }
  }

  // Check if user has already rated a provider for a specific order
  Future<bool> hasUserRatedProvider(int orderId) async {
    try {
      final response = await _apiService.get(AppConstants.providerRatingsMy);

      if (response.statusCode == 200) {
        final List<dynamic> ratings = response.data ?? [];

        // Check if any rating exists for this order
        return ratings.any((rating) => rating['orderId'] == orderId);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get user's rating for a specific order
  Future<Map<String, dynamic>?> getUserRating(int orderId) async {
    try {
      final response = await _apiService.get(AppConstants.providerRatingsMy);

      if (response.statusCode == 200) {
        final List<dynamic> ratings = response.data ?? [];

        // Find rating for this specific order
        final rating = ratings.firstWhere(
          (rating) => rating['orderId'] == orderId,
          orElse: () => null,
        );

        return rating;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all user ratings
  Future<List<Map<String, dynamic>>> getAllUserRatings() async {
    try {
      final response = await _apiService.get(AppConstants.providerRatingsMy);

      if (response.statusCode == 200) {
        final List<dynamic> ratings = response.data ?? [];
        return ratings.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
