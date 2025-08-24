import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:khabir/app/data/models/booking_model.dart';
import 'package:khabir/app/data/models/provider_model.dart';
import 'package:khabir/app/data/models/service_model.dart';
import '../models/provider_model.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class ProvidersRepository {
  final ApiService _apiService = Get.find<ApiService>();

  // Get providers by service ID
  Future<ProviderResponse> getProvidersByService(int serviceId) async {
    try {
      print('Fetching providers for service ID: $serviceId');

      final path = AppConstants.providersByService.replaceAll(
        '{id}',
        serviceId.toString(),
      );

      final response = await _apiService.get(path);
      print('Providers by service API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.data == null) {
          print('Warning: Providers by service API returned null data');
          return ProviderResponse(
            providers: [],
            total: 0,
            serviceId: serviceId,
          );
        }

        print('Providers by service response: ${response.data}');

        // Handle the response structure
        final List<dynamic> providersData = response.data['providers'] ?? [];
        final int total = response.data['total'] ?? 0;
        final int responseServiceId = response.data['serviceId'] ?? serviceId;

        // Debug the structure before parsing
        if (providersData.isNotEmpty) {
          final firstProvider = providersData.first;
          print('First provider structure: $firstProvider');

          if (firstProvider['providerServices'] != null) {
            final firstService =
                (firstProvider['providerServices'] as List).first;
            print('First service structure: $firstService');
            print('Service has title: ${firstService.containsKey('title')}');
            print(
              'Service has nested service: ${firstService.containsKey('service')}',
            );
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
            print('Error parsing provider: $e');
            print('Provider data: $providerData');
            // Continue with other providers instead of failing completely
          }
        }

        print('Successfully parsed ${providers.length} providers from API');

        // Debug parsed providers
        _debugProvidersByService(providers);

        return ProviderResponse(
          providers: providers,
          total: total,
          serviceId: responseServiceId,
        );
      } else {
        throw Exception('Failed to load providers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error in getProvidersByService: ${e.message}');
      print('Error type: ${e.type}');
      print('Response data: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error in getProvidersByService: $e');
      print('Error stack trace: ${StackTrace.current}');
      throw Exception('Error fetching providers: $e');
    }
  }

  void _debugProvidersByService(List<Provider> providers) {
    print('=== PROVIDERS BY SERVICE DEBUG ===');
    for (var provider in providers) {
      print('Provider: ${provider.name} (ID: ${provider.id})');
      print('  - Active: ${provider.isActive}');
      print('  - Verified: ${provider.isVerified}');
      print('  - Services: ${provider.services.length}');

      for (var service in provider.services.take(3)) {
        print('    * Service: ${service.title}');
        print('      Price: ${service.price}');
        if (service.offerPrice != null) {
          print('      Offer Price: ${service.offerPrice}');
          print(
            '      Discount: ${service.discountPercentage.toStringAsFixed(1)}%',
          );
        }
        print('      Active: ${service.isActive}');
      }
      print('---');
    }
    print('=== END DEBUG ===');
  }

  Future<ProviderResponse> getTopProviders({String? state}) async {
    try {
      print('Fetching top providers for state: $state');

      // Build query parameters
      final Map<String, dynamic> queryParams = {};
      if (state != null) queryParams['state'] = state;

      final response = await _apiService.get(
        AppConstants.topProviders,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      print('Top providers API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        if (response.data == null) {
          print('Warning: Top providers API returned null data');
          return ProviderResponse(providers: [], total: 0, state: state);
        }

        print('Top providers response: ${response.data}');

        // Handle the response structure properly
        final List<dynamic> providersData = response.data['providers'] ?? [];
        final int total = response.data['total'] ?? 0;

        // Convert to Provider objects with proper type casting
        final List<Provider> providers = providersData
            .map((json) => Provider.fromJson(json as Map<String, dynamic>))
            .toList();

        print('Successfully parsed ${providers.length} providers from API');

        // Debug provider parsing
        _debugProviders(providers);

        return ProviderResponse(
          providers: providers,
          total: total,
          state: state,
        );
      } else {
        throw Exception('Failed to load top providers: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error in getTopProviders: ${e.message}');
      print('Error type: ${e.type}');
      print('Response data: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Unexpected error in getTopProviders: $e');
      throw Exception('Error fetching top providers: $e');
    }
  }

  // Get provider services
  Future<Provider> getProviderServices(int providerId, int categoryId) async {
    try {
      final path = AppConstants.providerServices
          .replaceAll('{providerId}', providerId.toString())
          .replaceAll('{categoryId}', categoryId.toString());

      final response = await _apiService.get(path);

      if (response.statusCode == 200) {
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
      throw Exception('Error creating service request: $e');
    }
  }

  // Get top providers

  void _debugProviders(List<Provider> providers) {
    print('=== PROVIDER PARSING DEBUG ===');
    for (var provider in providers) {
      print('Provider: ${provider.name} (ID: ${provider.id})');
      print('  - Services: ${provider.services.length}');
      print('  - Orders: ${provider.orders.length}');
      print('  - Tier: ${provider.tier.name}');
      print('  - Verified: ${provider.isVerified}');
      print('---');
    }
    print('=== END DEBUG ===');
  }

  // Get provider by ID
  Future<Provider> getProviderById(String providerId) async {
    final response = await _apiService.get(
      AppConstants.providerById.replaceAll('{id}', providerId),
    );
    print('Provider by ID: ${response.data}');
    return Provider.fromJson(response.data);
  }
}
