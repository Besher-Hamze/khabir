import 'package:get/get.dart';
import '../models/service_model.dart';
import '../models/provider_model.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ServicesRepository extends GetxService {
  ApiService get _apiService => Get.find<ApiService>();

  // Get services by category ID
  Future<List<ServiceModel>> getServicesByCategory(int categoryId) async {
    try {
      final response = await _apiService.get(
        AppConstants.servicesByCategory.replaceAll(
          '{id}',
          categoryId.toString(),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> servicesData = response.data;
        return servicesData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services for category: $categoryId');
      }
    } catch (e) {
      print('Error fetching services by category: $e');
      rethrow;
    }
  }

  Future<List<ServiceModel>> getKhabirServices() async {
    try {
      final response = await _apiService.get(AppConstants.servicesKhabir);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> servicesData = response.data;
        return servicesData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load khabir services');
      }
    } catch (e) {
      print('Error fetching khabir services: $e');
      rethrow;
    }
  }

  // Get all services
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _apiService.get(AppConstants.services);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> servicesData = response.data;
        return servicesData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load services');
      }
    } catch (e) {
      print('Error fetching all services: $e');
      rethrow;
    }
  }

  // Get service by ID
  Future<ServiceModel?> getServiceById(int id) async {
    try {
      final response = await _apiService.get('${AppConstants.services}/$id');

      if (response.statusCode == 200 && response.data != null) {
        return ServiceModel.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching service by ID: $e');
      return null;
    }
  }

  // Get trending services
  Future<List<ServiceModel>> getTrendingServices() async {
    try {
      final response = await _apiService.get(AppConstants.searchTrending);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> servicesData = response.data;
        return servicesData.map((json) => ServiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending services');
      }
    } catch (e) {
      print('Error fetching trending services: $e');
      rethrow;
    }
  }

  // Get active offers
  Future<List<Offer>> getActiveOffers() async {
    try {
      final response = await _apiService.get(AppConstants.offersActive);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> offersData = response.data;
        return offersData.map((json) => Offer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load active offers');
      }
    } catch (e) {
      print('Error fetching active offers: $e');
      rethrow;
    }
  }

  // Get top rated providers
  Future<List<ServiceProvider>> getTopRatedProviders() async {
    try {
      final response = await _apiService.get(
        AppConstants.providerRatingsTopRated,
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> providersData = response.data;
        return providersData
            .map((json) => ServiceProvider.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load top rated providers');
      }
    } catch (e) {
      print('Error fetching top rated providers: $e');
      rethrow;
    }
  }

  // Get categories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _apiService.get(AppConstants.categories);

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> categoriesData = response.data;
        return categoriesData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      rethrow;
    }
  }
}
