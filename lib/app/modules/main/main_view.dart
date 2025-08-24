import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return Scaffold(
      appBar: const HomeAppBar(),
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            HomeView(),
            MyBookingsView(),
            CategoriesView(showAppBar: false, showFilter: false),
            OffersView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.currentIndex.value,
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
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  controller.currentIndex.value == 0
                      ? Icons.home
                      : Icons.home_outlined,
                  size: 24,
                ),
              ),
              label: 'home'.tr,
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  controller.currentIndex.value == 1
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  size: 24,
                ),
              ),
              label: 'my_bookings'.tr,
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  controller.currentIndex.value == 2
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
                  controller.currentIndex.value == 3
                      ? Icons.local_offer
                      : Icons.local_offer_outlined,
                  size: 24,
                ),
              ),
              label: 'offers'.tr,
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  controller.currentIndex.value == 4
                      ? Icons.person
                      : Icons.person_outline,
                  size: 24,
                ),
              ),
              label: 'profile'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
