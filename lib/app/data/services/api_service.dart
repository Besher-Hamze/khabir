import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:khabir/app/data/services/storage_service.dart';
import 'package:khabir/app/routes/app_routes.dart';

import '../../core/constants/app_constants.dart';

class ApiService extends GetxService {
  late Dio _dio;
  late StorageService _storageService;

  static ApiService get instance => Get.find<ApiService>();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: AppConstants.defaultTimeout,
        ),
        receiveTimeout: const Duration(
          milliseconds: AppConstants.defaultTimeout,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (log) => print('API: $log'),
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _getStoredToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          _handleError(error);
          handler.next(error);
        },
      ),
    );
  }

  Future<String?> _getStoredToken() async {
    try {
      _storageService = Get.find<StorageService>();
      return _storageService.getToken();
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Get.snackbar('خطأ', 'انتهت مهلة الاتصال');
        break;
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          // Handle unauthorized
          _handleUnauthorized();
        } else if (error.response?.statusCode == 400) {
          final responseData = error.response?.data;
          if (responseData is Map<String, dynamic>) {
            final message = responseData['message'] ?? 'data_error'.tr;
            // Get.snackbar('error'.tr, message);
          } else {
            // Get.snackbar('error'.tr, 'data_error'.tr);
          }
        } else if (error.response?.statusCode == 500) {
          // Get.snackbar('error'.tr, 'server_error_message'.tr);
        } else {
          Get.snackbar(
            'error'.tr,
            error.response?.data['message'] ?? 'data_error'.tr,
          );
        }
        break;
      case DioExceptionType.connectionError:
        // Get.snackbar('error'.tr, 'connection_failed'.tr);
        break;
      default:
      // Get.snackbar('error'.tr, 'unexpected_error'.tr);
    }
  }

  void _handleUnauthorized() async {
    try {
      // Clear token and redirect to login
      await _storageService.removeToken();
      await _storageService.removeUser();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      print('Error handling unauthorized: $e');
    }
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Upload file
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String? fileName,
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?data,
      });

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  void updateToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Helper method to replace path parameters
  String replacePathParams(String path, Map<String, String> params) {
    String result = path;
    params.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }
}
