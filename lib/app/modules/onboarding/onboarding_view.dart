import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_button.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() => Column(
          children: [
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildLanguageToggle(),
                  const Spacer(),
                  if (controller.currentPage < 2)
                    TextButton(
                      onPressed: controller.skipOnboarding,
                      child: Text(
                        "skip".tr,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.onboardingData.length,
                onPageChanged: controller.goToPage,
                itemBuilder: (context, index) {
                  final data = controller.onboardingData[index];

                  // Check if this is the role selection page (third page)
                  if (index == 2) {
                    return _buildRoleSelectionPage();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Container(
                          height: 300,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 40),
                          child: Image.asset(
                            data['image']!,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 300,
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.image,
                                  size: 80,
                                  color: AppColors.textLight,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.onboardingData.length,
                                (index) => _buildPageIndicator(index),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Title
                        Text(
                          data['title']!,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          data['description']!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Show navigation buttons only if not on role selection page
                  if (controller.currentPage.value < 2) ...[
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'back'.tr,
                            onPressed: controller.previousPage,
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CustomButton(
                            text: 'next'.tr,
                            onPressed: controller.nextPage,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }

  Widget _buildRoleSelectionPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const SizedBox(height: 40),

          // Image
          Container(
            height: 200,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 40),
            child: Image.asset(
              'assets/images/onboarding_3.png', // Use the third onboarding image
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.people,
                    size: 80,
                    color: AppColors.textLight,
                  ),
                );
              },
            ),
          ),

          // Page indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              controller.onboardingData.length,
                  (index) => _buildPageIndicator(index),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            'onboarding_title_3'.tr,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            'onboarding_desc_3'.tr,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // Role Selection Buttons
          Row(
            children: [
              Expanded(
                child: _buildRoleButton(
                  title: 'user'.tr,
                  onTap: controller.selectUser,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildRoleButton(
                  title: 'service_provider'.tr,
                  onTap: controller.selectServiceProvider,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageButton('EN', Get.locale?.languageCode == 'en', true),
          _buildLanguageButton('عربي', Get.locale?.languageCode == 'ar', false),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String text, bool isSelected, bool isLeft) {
    return GestureDetector(
      onTap: () {
        if (text == 'عربي' && Get.locale?.languageCode != 'ar') {
          Get.updateLocale(const Locale('ar'));
          controller.updateOnboardingData(); // Refresh the data
        } else if (text == 'EN' && Get.locale?.languageCode != 'en') {
          Get.updateLocale(const Locale('en'));
          controller.updateOnboardingData(); // Refresh the data
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(true ? 16 : 0),
            bottomLeft: Radius.circular(true ? 16 : 0),
            topRight: Radius.circular(true ? 0 : 16),
            bottomRight: Radius.circular(true ? 0 : 16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Obx(() => Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: controller.currentPage.value == index
            ? AppColors.primary
            : AppColors.borderLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
    ));
  }
}