import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:khabir/app/modules/main/location_select_page.dart';
import 'package:khabir/app/routes/app_routes.dart';
import 'package:khabir/app/modules/bookings/my_bookings_view.dart';
import 'package:khabir/app/data/services/storage_service.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/values/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showTitle;
  final bool showAction;
  final Rx<int> notificationCount;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onWhatsAppTap;
  final StorageService storageService = Get.find<StorageService>();
  CustomAppBar({
    Key? key,
    this.title,
    this.showBackButton = false,
    this.showTitle = false,
    required this.notificationCount,
    this.onNotificationTap,
    this.onLocationTap,
    this.onWhatsAppTap,
    this.showAction = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 1),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              // Back button (if needed)
              if (showBackButton) ...[
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(
                      LucideIcons.chevronLeft,
                      color: Colors.black87,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Title (if needed)
              if (showTitle && title != null) ...[
                Expanded(
                  child: Text(
                    title!,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],

              if (showAction) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Notification Icon with Badge and Circle Background
                    if (storageService.getUser()?.role != 'VISTOR') ...[
                      GestureDetector(
                        onTap:
                            onNotificationTap ??
                            () {
                              print('Notification tapped');
                            },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  FontAwesomeIcons.bell,
                                  color: Color(0xFF6B7280),
                                  size: 20,
                                ),
                              ),
                              Obx(
                                () => notificationCount > 0
                                    ? Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 18,
                                            minHeight: 18,
                                          ),
                                          child: Center(
                                            child: Text(
                                              notificationCount > 99
                                                  ? '99+'
                                                  : notificationCount
                                                        .toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),
                    ],
                    if (storageService.getUser()?.role == 'VISTOR') ...[
                      // go to login screen if visitor
                      GestureDetector(
                        onTap: () {
                          storageService.removeUser();
                          storageService.removeToken();
                          Get.offAllNamed(AppRoutes.login);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              LucideIcons.logOut,
                              color: Color(0xFF6B7280),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],

                    // // Location Icon with Circle Background
                    GestureDetector(
                      onTap: () {
                        // Navigate to the new LocationSelectionPage
                        Get.to(() => const LocationSelectionPage());
                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            LucideIcons.mapPin,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // WhatsApp Icon with Circle Background
                    GestureDetector(
                      onTap:
                          onWhatsAppTap ??
                          () {
                            print('WhatsApp tapped');
                          },
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.whatsapp,
                            color: Color(0xFF6B7280),
                            size: 20,
                          ),
                        ),
                      ),
                    ),

                    // khabir Logo
                  ],
                ),
                Spacer(),
                Image.asset(
                  'assets/images/logo_white.png',
                  color: AppColors.primary,
                ),
              ],
              // Action Icons Row
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

// 1. Simple AppBar (for main pages like Home)
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Rx<int> notificationCount;
  final Rx<String> whatsAppNumber;

  const HomeAppBar({
    Key? key,
    required this.notificationCount,
    required this.whatsAppNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('=====================notificationCount: ${notificationCount.value}');
    return CustomAppBar(
      showBackButton: false,
      showTitle: false,
      showAction: true,
      notificationCount: notificationCount,
      onWhatsAppTap: () {
        launchUrl(Uri.parse(whatsAppNumber.value));
      },
      onNotificationTap: () {
        Get.to(MyBookingsView(showAppBar: true, title: 'notifications'.tr));
      },
      onLocationTap: () {},
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}

// 2. AppBar with title and back button (for detail pages)
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Rx<int> notificationCount;

  const DetailAppBar({
    Key? key,
    required this.title,
    required this.notificationCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showBackButton: true,
      showTitle: true,
      notificationCount: notificationCount,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
