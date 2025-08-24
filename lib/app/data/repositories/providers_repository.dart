import 'package:get/get.dart';
import '../models/provider_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ProvidersRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get providers by service ID
  Future<ProviderApiResponse> getProvidersByService(int serviceId) async {
    try {
      final path = AppConstants.providersByService.replaceAll(
        '{id}',
        serviceId.toString(),
      );
      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        return ProviderApiResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching providers: $e');
    }
  }

  // Get provider services
  Future<ProviderServicesResponse> getProviderServices(
    int providerId,
    int categoryId,
  ) async {
    try {
      final path = AppConstants.providerServices
          .replaceAll('{providerId}', providerId.toString())
          .replaceAll('{categoryId}', categoryId.toString());

      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
        return ProviderServicesResponse.fromJson(response.data);
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
  Future<ServiceRequestResponse> createServiceRequest(
    ServiceRequestRequest request,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.createServiceRequest,
        data: request.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceRequestResponse.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to create service request: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating service request: $e');
    }
  }

  // Get top providers
  Future<TopProvidersResponse> getTopProviders() async {
    try {
      final response = await _apiService.get(AppConstants.topProviders);

      if (response.statusCode == 200) {
        return TopProvidersResponse.fromJson(response.data);
      } else {
        throw Exception('Failed to load top providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top providers: $e');
    }
  }
}
