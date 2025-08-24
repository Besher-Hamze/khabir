import 'package:dio/dio.dart';
import '../models/provider_model.dart';
import '../../core/constants/app_constants.dart';
import '../services/api_service.dart';

class OffersRepository {
  final ApiService _apiService;

  OffersRepository(this._apiService);

  /// Get all available offers
  Future<List<OfferModel>> getAvailableOffers() async {
    try {
      final response = await _apiService.get(AppConstants.availableOffers);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => OfferModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load offers: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
