import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/services/storage_service.dart';
import '../../core/constants/app_constants.dart';

class LanguageController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // Observable for current language
  final RxString _currentLanguage = AppConstants.defaultLanguage.obs;

  // Getter for current language
  String get currentLanguage => _currentLanguage.value;

  // Getter for current locale
  Locale get currentLocale => Locale(_currentLanguage.value);

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
  }

  // Load saved language from storage
  void _loadSavedLanguage() {
    try {
      final savedLanguage = _storageService.getLanguage();
      _currentLanguage.value = savedLanguage;
      Get.updateLocale(Locale(savedLanguage));
      print('🌐 Loaded saved language: $savedLanguage');
    } catch (e) {
      print('❌ Error loading saved language: $e');
      _currentLanguage.value = AppConstants.defaultLanguage;
    }
  }

  // Change language and save to storage
  Future<void> changeLanguage(String languageCode) async {
    try {
      // Update the observable
      _currentLanguage.value = languageCode;

      // Save to storage
      await _storageService.saveLanguage(languageCode);

      // Update GetX locale
      Get.updateLocale(Locale(languageCode));

      print('🌐 Language changed to: $languageCode');

      // Show success message
      Get.snackbar(
        'success'.tr,
        'language_changed'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.language, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('❌ Error changing language: $e');

      // Show error message
      Get.snackbar(
        'error'.tr,
        'failed_to_change_language'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // Get available languages
  List<Map<String, String>> get availableLanguages => [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  ];

  // Get current language display name
  String get currentLanguageName {
    final language = availableLanguages.firstWhereOrNull(
      (lang) => lang['code'] == currentLanguage,
    );
    return language?['name'] ?? 'العربية';
  }

  // Get current language flag
  String get currentLanguageFlag {
    final language = availableLanguages.firstWhereOrNull(
      (lang) => lang['code'] == currentLanguage,
    );
    return language?['flag'] ?? '🇸🇦';
  }

  // Check if language is RTL
  bool get isRTL => currentLanguage == 'ar';

  // Check if language is LTR
  bool get isLTR => currentLanguage == 'en';
}
