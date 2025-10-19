import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/values/colors.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with language selector and skip button
            _buildHeader(),

            // Main content
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.goToPage,
                itemCount: controller.onboardingData.length,
                itemBuilder: (context, index) {
                  final data = controller.onboardingData[index];

                  switch (index) {
                    case 0:
                      return OnboardingPage1(
                        data: data,
                        onNext: controller.nextPage,
                      );
                    case 1:
                      return OnboardingPage2(
                        data: data,
                        onNext: controller.nextPage,
                        onBack: controller.previousPage,
                      );
                    case 2:
                      return OnboardingPage3(
                        data: data,
                        onSelectProvider: controller.selectServiceProvider,
                        onSelectUser: controller.selectUser,
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Center(child: _buildLanguageSelector()),
          Obx(
            () => Positioned(
              right: 0,
              top: 0,
              child: controller.currentPage.value < 2
                  ? TextButton(
                      onPressed: controller.skipOnboarding,
                      child: Text(
                        'skip'.tr,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey[300]!, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // English button
            _buildLanguageButton(
              language: 'en',
              displayText: 'EN',
              isSelected: Get.locale?.languageCode == 'en',
              isFirst: true,
              onTap: () {
                Get.updateLocale(const Locale('en'));
                controller.updateOnboardingData();
              },
            ),
            // Divider
            Container(width: 1, height: 30, color: Colors.grey[300]),
            // Arabic button
            _buildLanguageButton(
              language: 'ar',
              displayText: 'عربي',
              isSelected: Get.locale?.languageCode == 'ar',
              isFirst: false,
              onTap: () {
                Get.updateLocale(const Locale('ar'));
                controller.updateOnboardingData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton({
    required String language,
    required String displayText,
    required bool isSelected,
    required bool isFirst,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 25 : 0),
            bottomLeft: Radius.circular(isFirst ? 25 : 0),
            topRight: Radius.circular(!isFirst ? 25 : 0),
            bottomRight: Radius.circular(!isFirst ? 25 : 0),
          ),
        ),
        child: Text(
          displayText,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: language == 'en' ? 0.5 : 0,
          ),
        ),
      ),
    );
  }
}

// onboarding_page1.dart
class OnboardingPage1 extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onNext;

  const OnboardingPage1({Key? key, required this.data, required this.onNext})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Image
          SizedBox(
            height: Get.height * 0.45,
            width: Get.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data['image']!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
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
            ),
          ),

          const SizedBox(height: 20),

          // Dots indicator
          _buildDotsIndicator(0),

          const SizedBox(height: 40),

          // Title
          Text(
            data['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              data['description']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),

          const Spacer(flex: 2),

          // Next button only
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'next'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.borderLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// onboarding_page2.dart
class OnboardingPage2 extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const OnboardingPage2({
    Key? key,
    required this.data,
    required this.onNext,
    required this.onBack,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Image
          SizedBox(
            height: Get.height * 0.45,
            width: Get.width * 0.8,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data['image']!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
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
            ),
          ),

          const SizedBox(height: 20),

          // Dots indicator
          _buildDotsIndicator(1),

          const SizedBox(height: 40),

          // Title
          Text(
            data['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              data['description']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
            ),
          ),

          const Spacer(flex: 2),

          // Back and Next buttons
          Row(
            children: [
              // Back button
              Expanded(
                child: OutlinedButton(
                  onPressed: onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'back'.tr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Next button
              Expanded(
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'next'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.borderLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

// onboarding_page3.dart
class OnboardingPage3 extends StatelessWidget {
  final Map<String, String> data;
  final VoidCallback onSelectProvider;
  final VoidCallback onSelectUser;

  const OnboardingPage3({
    Key? key,
    required this.data,
    required this.onSelectProvider,
    required this.onSelectUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          // Image
          SizedBox(
            height: Get.height * 0.42,
            width: Get.width * 0.7,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  data['image']!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
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
            ),
          ),

          const SizedBox(height: 20),

          // Dots indicator
          _buildDotsIndicator(2),

          const SizedBox(height: 40),

          // Title
          Text(
            data['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 24),

          // Description (if available)
          if (data['description']!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                data['description']!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),

          if (data['description']!.isNotEmpty) const SizedBox(height: 20),

          const Spacer(flex: 2),

          // User and Provider buttons
          Row(
            children: [
              // User button
              Expanded(
                child: ElevatedButton(
                  onPressed: onSelectUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'user'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Service Provider button
              Expanded(
                child: ElevatedButton(
                  onPressed: onSelectProvider,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'service_provider'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDotsIndicator(int currentIndex) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.borderLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
