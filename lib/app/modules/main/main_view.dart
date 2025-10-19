import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:khabir/app/global_widgets/welcome_dialog.dart';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_appbar.dart';
import '../home/home_view.dart';
import '../bookings/my_bookings_view.dart';
import '../categories/categories_view.dart';
import '../offers/offers_view.dart';
import '../profile/profile_view.dart';
import 'main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments?['showWelcome'] == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WelcomeDialog.show();
      });
    }
    return Scaffold(
      appBar: HomeAppBar(
        notificationCount: controller.notificationCount,
        whatsAppNumber: controller.whatsAppNumber,
      ),
      body: Obx(
        () => IndexedStack(
          index: _getAdjustedIndex(controller.currentIndex.value),
          children: _buildBodyChildren(),
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _getBottomNavIndex(controller.currentIndex.value),
          onTap: controller.changePage,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textLight,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          elevation: 8,
          items: _buildBottomNavItems(),
        ),
      ),
    );
  }

  // Get adjusted index for visitors (skip bookings tab)
  int _getAdjustedIndex(int currentIndex) {
    final isVisitor = controller.isVisitorUser();
    if (isVisitor) {
      // For visitors: 0=Home, 1=Categories, 2=Offers
      // Map bottom nav index to body index
      switch (currentIndex) {
        case 0:
          return 0; // Home
        case 1:
          return 1; // Categories
        case 2:
          return 2; // Offers
        default:
          return 0;
      }
    }
    return currentIndex;
  }

  // Get bottom navigation index for visitors
  int _getBottomNavIndex(int currentIndex) {
    final isVisitor = controller.isVisitorUser();
    if (isVisitor) {
      // For visitors, return the same index since we only have 3 tabs
      return currentIndex;
    }
    return currentIndex;
  }

  // Build body children based on user type
  List<Widget> _buildBodyChildren() {
    final isVisitor = controller.isVisitorUser();

    if (isVisitor) {
      return [
        const HomeView(),
        const CategoriesView(showAppBar: false, showFilter: false),
        const OffersView(),
      ];
    } else {
      return [
        const HomeView(),
        const MyBookingsView(),
        const CategoriesView(showAppBar: false, showFilter: false),
        const OffersView(),
        const ProfileView(),
      ];
    }
  }

  // Build bottom navigation items based on user type
  List<BottomNavigationBarItem> _buildBottomNavItems() {
    final isVisitor = controller.isVisitorUser();
    final currentIndex = controller.currentIndex.value;

    final items = [
      BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            currentIndex == 0 ? Icons.home : Icons.home_outlined,
            size: 24,
          ),
        ),
        label: 'home'.tr,
      ),
      if (!isVisitor)
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              currentIndex == 1 ? Icons.bookmark : Icons.bookmark_border,
              size: 24,
            ),
          ),
          label: 'my_bookings'.tr,
        ),
      BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            (isVisitor ? currentIndex == 1 : currentIndex == 2)
                ? Icons.grid_view
                : Icons.grid_view_outlined,
            size: 24,
          ),
        ),
        label: 'categories'.tr,
      ),
      BottomNavigationBarItem(
        icon: Container(
          padding: const EdgeInsets.all(4),
          child: Icon(
            (isVisitor ? currentIndex == 2 : currentIndex == 3)
                ? Icons.local_offer
                : Icons.local_offer_outlined,
            size: 24,
          ),
        ),
        label: 'offers'.tr,
      ),
    ];

    // Only add profile tab if user is not a visitor
    if (!isVisitor) {
      items.add(
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              currentIndex == 4 ? Icons.person : Icons.person_outline,
              size: 24,
            ),
          ),
          label: 'profile'.tr,
        ),
      );
    }

    return items;
  }
}
