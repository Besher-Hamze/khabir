import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/api_service.dart';
import '../../core/constants/app_constants.dart';

class AuthRepository {
  final StorageService _storageService = StorageService.instance;
  final ApiService _apiService = ApiService.instance;

  // Login with phone and password
  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await _apiService.post(
        AppConstants.authPhoneLogin,
        data: {'phoneNumber': phone, 'password': password},
      );

      if (response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);

        if (authResponse.success && authResponse.accessToken != null) {
          // Save user and token
          if (authResponse.user != null) {
            await _storageService.saveUser(authResponse.user!);
          }
          await _storageService.saveToken(authResponse.accessToken!);

          return {
            'success': true,
            'user': authResponse.user,
            'token': authResponse.accessToken,
            'message': authResponse.message,
          };
        } else {
          return {'success': false, 'message': authResponse.message};
        }
      } else {
        return {'success': false, 'message': 'فشل في تسجيل الدخول'};
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Register new user - Step 1 (Initiate)
  Future<Map<String, dynamic>> registerInitiate({
    required String name,
    required String phone,
    required String password,
    required String state,
    String? email,
    String? address,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.authRegisterInitiate,
        data: {
          'name': name,
          'phoneNumber': phone,
          'password': password,
          'role': 'USER',
          'state': state,
          'email': email,
          'address': address ?? '$state, Saudi Arabia',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'تم إرسال رمز التحقق إلى $phone'};
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في إنشاء الحساب',
        };
      }
    } catch (e) {
      print('Register initiate error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Register new user - Step 2 (Complete)
  Future<Map<String, dynamic>> registerComplete({
    required String name,
    required String phone,
    required String password,
    required String state,
    required String otp,
    String? email,
    String? address,
  }) async {
    try {
      final response = await _apiService.post(
        AppConstants.authRegisterComplete,
        data: {
          'name': name,
          'phoneNumber': phone,
          'password': password,
          'otp': otp,
          'role': 'USER',
          'state': state,
          'email': email,
          'address': address ?? '$state, Saudi Arabia',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);

        if (authResponse.success && authResponse.accessToken != null) {
          // Save user and token
          if (authResponse.user != null) {
            await _storageService.saveUser(authResponse.user!);
          }
          await _storageService.saveToken(authResponse.accessToken!);

          return {
            'success': true,
            'user': authResponse.user,
            'token': authResponse.accessToken,
            'message': authResponse.message,
          };
        } else {
          return {'success': false, 'message': authResponse.message};
        }
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في إكمال التسجيل',
        };
      }
    } catch (e) {
      print('Register complete error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Send OTP for phone verification
  Future<Map<String, dynamic>> sendOTP(String phone) async {
    try {
      final response = await _apiService.post(
        AppConstants.authPasswordResetSendOTP,
        data: {'phoneNumber': phone},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'تم إرسال رمز التحقق إلى $phone'};
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في إرسال رمز التحقق',
        };
      }
    } catch (e) {
      print('Send OTP error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOTP(
    User user,
    String otp,
    String password,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.authRegisterComplete,
        data: {...user.toJson(), 'otp': otp, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final authResponse = AuthResponse.fromJson(response.data);

        if (authResponse.success && authResponse.accessToken != null) {
          // Save user and token
          if (authResponse.user != null) {
            await _storageService.saveUser(authResponse.user!);
          }
          await _storageService.saveToken(authResponse.accessToken!);

          return {
            'success': true,
            'user': authResponse.user,
            'token': authResponse.accessToken,
            'message': authResponse.message,
          };
        } else {
          return {'success': false, 'message': authResponse.message};
        }
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'رمز التحقق غير صحيح',
        };
      }
    } catch (e) {
      print('Verify OTP error: $e');
      return {'success': false, 'message': 'خطأ في التحقق من الرمز'};
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword(
    String phone,
    String newPassword,
  ) async {
    try {
      final response = await _apiService.post(
        AppConstants.authPasswordReset,
        data: {
          'phoneNumber': phone,
          'otp': '123456', // This should be the OTP from the previous step
          'newPassword': newPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'تم تغيير كلمة المرور بنجاح'};
      } else {
        final responseData = response.data;
        return {
          'success': false,
          'message': responseData['message'] ?? 'فشل في تغيير كلمة المرور',
        };
      }
    } catch (e) {
      print('Reset password error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storageService.removeToken();
      await _storageService.removeUser();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _storageService.hasToken && _storageService.hasUser;

  // Get current user
  User? get currentUser => _storageService.getUser();

  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? email,
    String? state,
    String? profileImagePath,
  }) async {
    try {
      final response = await _apiService.put(
        AppConstants.userProfile,
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (state != null) 'state': state,
          if (profileImagePath != null) 'profileImage': profileImagePath,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['user'] != null) {
          final updatedUser = User.fromJson(responseData['user']);
          await _storageService.saveUser(updatedUser);

          return {
            'success': true,
            'user': updatedUser,
            'message': 'تم تحديث الملف الشخصي بنجاح',
          };
        }
      }

      return {'success': false, 'message': 'فشل في تحديث الملف الشخصي'};
    } catch (e) {
      print('Update profile error: $e');
      return {'success': false, 'message': 'خطأ في الاتصال بالخادم'};
    }
  }

  // Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      await logout();
      return {'success': true, 'message': 'تم حذف الحساب بنجاح'};
    } catch (e) {
      print('Delete account error: $e');
      return {'success': false, 'message': 'فشل في حذف الحساب'};
    }
  }
}
