import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/services/storage_service.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  var currentPage = 0.obs;
  var selectedRole = ''.obs;
  late PageController pageController;

  var onboardingData = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    updateOnboardingData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void updateOnboardingData() {
    onboardingData.value = [
      {
        'title': 'onboarding_title_1'.tr,
        'description': 'onboarding_desc_1'.tr,
        'image': 'assets/images/onboarding_1.png',
      },
      {
        'title': 'onboarding_title_2'.tr,
        'description': 'onboarding_desc_2'.tr,
        'image': 'assets/images/onboarding_2.png',
      },
      {
        'title': 'onboarding_title_3'.tr,
        'description': 'onboarding_desc_3'.tr,
        'image': 'assets/images/onboarding_3.png',
      },
    ];
  }

  void nextPage() {
    if (currentPage.value < onboardingData.length - 1) {
      currentPage.value++;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      currentPage.value--;
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    // Skip to the role selection page (page 2)
    currentPage.value = 2;
    pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void completeOnboarding() async {
    await _storageService.setOnboardingCompleted();
    // Don't navigate to role selection since it's integrated
  }

  void goToPage(int page) {
    currentPage.value = page;
  }

  void selectUser() async {
    selectedRole.value = 'user';
    await _storageService.setOnboardingCompleted();
    Get.offAllNamed(AppRoutes.login);
  }

  void selectServiceProvider() async {
    selectedRole.value = 'provider';
    await _storageService.setOnboardingCompleted();

    // Open Khabirs website
    const String url = 'https://khabirs.com/';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        // Fallback: show dialog with manual instructions
        Get.dialog(
          AlertDialog(
            title: Text('error'.tr),
            content: Text('cannot_open_website'.tr),
            actions: [
              TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'cannot_open_website'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // void selectServiceProvider() async {
  //   selectedRole.value = 'provider';
  //   await _storageService.setOnboardingCompleted();

  //   // Open store for provider app based on platform
  //   final String url = GetPlatform.isIOS
  //       ? AppConstants.providerAppStoreUrl
  //       : '${AppConstants.playStoreUrl}${AppConstants.providerAppId}';

  //   try {
  //     if (await canLaunchUrl(Uri.parse(url))) {
  //       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  //     } else {
  //       // Fallback: show dialog with manual instructions
  //       Get.dialog(
  //         AlertDialog(
  //           title: Text('download_provider_app'.tr),
  //           content: Text('download_provider_app_message'.tr),
  //           actions: [
  //             TextButton(onPressed: () => Get.back(), child: Text('ok'.tr)),
  //           ],
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'error'.tr,
  //       'cannot_open_store'.tr,
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }
}
