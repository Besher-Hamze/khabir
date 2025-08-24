import 'package:dio/dio.dart';
import '../models/provider_model.dart';
import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';

class BannerRepository {
  final ApiService _apiService;

  BannerRepository(this._apiService);

  /// Get all active ad banners
  Future<List<BannerModel>> getAdBanners() async {
    try {
      final response = await _apiService.get(AppConstants.adBanners);
      print('Banners: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BannerModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load banners: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
