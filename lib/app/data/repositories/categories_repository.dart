import 'package:get/get.dart';
import '../models/category_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class CategoriesRepository extends GetxService {
  final ApiService _apiService = Get.find<ApiService>();

  // Get all categories
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

  // Get categories by state
  Future<List<CategoryModel>> getCategoriesByState(String state) async {
    try {
      final response = await _apiService.get(
        AppConstants.categories,
        queryParameters: {'state': state},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> categoriesData = response.data;
        return categoriesData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load categories for state: $state');
      }
    } catch (e) {
      print('Error fetching categories by state: $e');
      rethrow;
    }
  }

  // Get category by ID
  Future<CategoryModel?> getCategoryById(int id) async {
    try {
      final response = await _apiService.get('${AppConstants.categories}/$id');

      if (response.statusCode == 200 && response.data != null) {
        return CategoryModel.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching category by ID: $e');
      return null;
    }
  }
}
