import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:khabir/app/data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ImagePicker _imagePicker = ImagePicker();

  // Observable variables
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isConfirmPasswordVisible = false.obs;
  var agreedToTerms = false.obs;
  var selectedState = ''.obs;
  var profileImagePath = ''.obs;
  var otpCode = ''.obs;
  var phoneNumber = ''.obs;

  // Text controllers
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();

  // Form keys
  final loginFormKey = GlobalKey<FormState>();
  final signupFormKey = GlobalKey<FormState>();
  final forgotPasswordFormKey = GlobalKey<FormState>();
  final resetPasswordFormKey = GlobalKey<FormState>();

  // States list
  final states = [
    'الرياض',
    'جدة',
    'الدمام',
    'مكة المكرمة',
    'المدينة المنورة',
    'الطائف',
    'تبوك',
    'بريدة',
    'خميس مشيط',
    'الهفوف',
    'حفر الباطن',
    'الجبيل',
    'ضباء',
    'رفحاء',
    'القطيف',
  ];

  @override
  void onClose() {
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    usernameController.dispose();
    emailController.dispose();
    newPasswordController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  // Toggle terms agreement
  void toggleTermsAgreement() {
    agreedToTerms.value = !agreedToTerms.value;
  }

  // Select state
  void selectState(String state) {
    selectedState.value = state;
  }

  // Pick profile image
  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        profileImagePath.value = image.path;
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'image_pick_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Login
  Future<void> login() async {
    // if (!loginFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final result = await _authRepository.login(
        phoneController.text.trim(),
        passwordController.text,
      );
      print("result is equal to: $result");
      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'login_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Guest login
  void loginAsGuest() {
    Get.offAllNamed(AppRoutes.main);
  }

  // Sign up
  Future<void> signUp() async {
    if (!signupFormKey.currentState!.validate()) return;

    if (!agreedToTerms.value) {
      Get.snackbar(
        'error'.tr,
        'agree_terms_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (selectedState.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'select_state_required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Step 1: Initiate registration
      final initiateResult = await _authRepository.registerInitiate(
        name: usernameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        state: selectedState.value,
        email: emailController.text.isNotEmpty
            ? emailController.text.trim()
            : null,
        address: selectedState.value.isNotEmpty
            ? '$selectedState.value, Saudi Arabia'
            : null,
      );

      if (initiateResult['success']) {
        phoneNumber.value = phoneController.text.trim();
        Get.snackbar(
          'success'.tr,
          initiateResult['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.toNamed(AppRoutes.verifyPhone);
      } else {
        Get.snackbar(
          'error'.tr,
          initiateResult['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'signup_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Send OTP for forgot password
  Future<void> sendOTP() async {
    if (!forgotPasswordFormKey.currentState!.validate()) return;
    isLoading.value = true;
    try {
      final result = await _authRepository.sendOTP(phoneController.text.trim());

      if (result['success']) {
        phoneNumber.value = phoneController.text.trim();
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.toNamed(AppRoutes.verifyPhone);
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'send_otp_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Verify OTP
  Future<void> verifyOTP() async {
    if (otpCode.value.length != 4) {
      Get.snackbar(
        'error'.tr,
        'enter_valid_otp'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    final User user = User(
      name: usernameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      role: 'USER',
      state: selectedState.value,
      isVerified: false,
      createdAt: DateTime.now(),
      id: '',

      address: selectedState.value.isNotEmpty
          ? '${selectedState.value}, Saudi Arabia'
          : null,
    );
    try {
      final result = await _authRepository.verifyOTP(
        user,
        otpCode.value,
        passwordController.text,
      );

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Check if this is from forgot password flow
        if (Get.previousRoute == AppRoutes.forgotPassword) {
          Get.toNamed(AppRoutes.resetPassword);
        } else {
          // This is from signup flow - complete registration
          await _completeRegistration();
        }
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'verify_otp_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Complete registration after OTP verification
  Future<void> _completeRegistration() async {
    try {
      final result = await _authRepository.registerComplete(
        name: usernameController.text.trim(),
        phone: phoneController.text.trim(),
        password: passwordController.text,
        state: selectedState.value,
        otp: otpCode.value,
        email: emailController.text.isNotEmpty
            ? emailController.text.trim()
            : null,
        address: selectedState.value.isNotEmpty
            ? '$selectedState.value, Saudi Arabia'
            : null,
      );

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.main);
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'signup_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    await sendOTP();
  }

  // Reset password
  Future<void> resetPassword() async {
    if (!resetPasswordFormKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      final result = await _authRepository.resetPassword(
        phoneNumber.value,
        newPasswordController.text,
      );

      if (result['success']) {
        Get.snackbar(
          'success'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        Get.snackbar(
          'error'.tr,
          result['message'],
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'reset_password_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Validators
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }

    // Remove all spaces, dashes, parentheses, and other formatting
    String cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');

    // Check if it contains only digits
    if (!RegExp(r'^\d+$').hasMatch(cleanedPhone)) {
      return 'invalid_phone'.tr;
    }

    // Check minimum and maximum length (international standards)
    // Most phone numbers are between 7-15 digits
    if (cleanedPhone.length < 7 || cleanedPhone.length > 15) {
      return 'invalid_phone_length'.tr;
    }

    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (value.length < 6) {
      return 'password_too_short'.tr;
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (value != passwordController.text) {
      return 'passwords_not_match'.tr;
    }
    return null;
  }

  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'field_required'.tr;
    }
    if (value.length < 3) {
      return 'username_too_short'.tr;
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return 'invalid_email'.tr;
      }
    }
    return null;
  }

  // Navigation methods
  void goToSignup() {
    Get.toNamed(AppRoutes.signup);
  }

  void goToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.forgotPassword);
  }

  void goToTermsAndConditions() {
    Get.toNamed(AppRoutes.termsConditions);
  }

  void goToPrivacyPolicy() {
    Get.toNamed(AppRoutes.privacyPolicy);
  }

  RxInt timerSeconds = 120.obs; // 2 minutes timer
  Timer? _timer;
  void startTimer() {
    timerSeconds.value = 120;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }
}
