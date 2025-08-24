import 'package:get/get.dart';
import 'package:flutter/scheduler.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    print('🚀 SplashController initialized');
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    print('⏱️ Starting 2-second delay...');

    // Show splash for exactly 2 seconds
    await Future.delayed(const Duration(seconds: 2));

    print('⏰ 2 seconds completed, navigating...');
    _navigateToNextScreen();
    // Wait for the next frame to ensure the widget tree is ready

  }

  void _navigateToNextScreen() {
    try {
      print('🔄 Starting navigation logic...');

      // Try to get storage service
      StorageService? storageService;
      try {
        storageService = Get.find<StorageService>();
        print('✅ Storage service found');
      } catch (e) {
        print('❌ Storage service not found: $e');
        // If storage service is not available, go to onboarding
        print('🔄 No storage service, navigating to onboarding');
        _performNavigation(AppRoutes.onboarding);
        return;
      }

      if (storageService != null) {
        // Check if user is logged in
        final hasToken = storageService.hasToken;
        final hasUser = storageService.hasUser;

        print('🔍 Has token: $hasToken, Has user: $hasUser');

        if (hasToken && hasUser) {
          print('✅ User is logged in, navigating to main screen');
          _performNavigation(AppRoutes.main);
          return;
        }

        // Check if onboarding is completed
        final isOnboardingCompleted = storageService.isOnboardingCompleted;
        print('🔍 Onboarding completed: $isOnboardingCompleted');

        if (isOnboardingCompleted) {
          print('✅ Onboarding completed, navigating to login');
          _performNavigation(AppRoutes.login);
          return;
        }
      }

      // Default: First time user - show onboarding
      print('✅ Navigating to onboarding (default)');
      _performNavigation(AppRoutes.onboarding);
    } catch (e) {
      print('❌ Error in navigation: $e');
      // Fallback navigation
      print('🔄 Fallback: navigating to onboarding');
      _performNavigation(AppRoutes.onboarding);
    }
  }

  void _performNavigation(String route) {
    try {
      print('🎯 Attempting to navigate to: $route');

      // Use Get.offAllNamed with a small delay to ensure proper navigation
      Future.delayed(const Duration(milliseconds: 100), () {
        Get.offAllNamed(route);
        print('✅ Navigation completed to: $route');
      });
    } catch (e) {
      print('❌ Navigation failed: $e');
      // Last resort fallback
      Get.offAllNamed('/onboarding'); // Use string route as absolute fallback
    }
  }
}
