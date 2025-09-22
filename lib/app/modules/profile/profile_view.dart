import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:khabir/app/routes/app_routes.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:khabir/app/core/utils/helpers.dart' as Helpers;

import '../../global_widgets/custom_drop_down.dart';
import '../user/user_controller.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/models/user_location_model.dart';
import '../../widgets/map_picker_widget.dart';
import '../../core/values/colors.dart';
import '../../core/constants/app_constants.dart';

class ProfileView extends GetView<UserController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshProfile,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            _buildProfileHeader(),
            const SizedBox(height: 24),

            // Menu Items
            _buildMenuItems(),
            const SizedBox(height: 40),

            // Social Media Section
            _buildSocialMediaSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      if (controller.isProfileLoading.value) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.hasProfileError.value) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: controller.refreshProfile,
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      final user = controller.userProfile.value;
      if (user == null) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(child: Text('no_profile_data'.tr)),
        );
      }

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            // Profile Picture and Edit Button
            Row(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.grey[200],
                      ),
                      child: user.image.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                Helpers.getImageUrl(user.image),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.grey[300],
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.grey[300],
                              ),
                              child: const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    // Edit badge on profile picture
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          LucideIcons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 16),

                // Name and Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name with edit icon
                      Row(
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _showEditNameDialog(user),
                            child: const Icon(
                              LucideIcons.edit,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // State
                      Text(
                        user.state,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // Edit Button
                GestureDetector(
                  onTap: () => _showEditProfileDialog(user),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Text(
                      'Edit',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          icon: LucideIcons.globe,
          iconColor: Colors.red,
          title: 'language'.tr,
          subtitle: Get.locale?.languageCode == 'ar' ? 'العربية' : 'English',
          hasArrow: true,
          onTap: () => _showLanguageDialog(),
        ),

        _buildMenuItem(
          icon: LucideIcons.mapPin,
          iconColor: Colors.red,
          title: 'my_locations'.tr,
          // subtitle: '${controller.userLocations.length} ${'saved'.tr}',
          hasArrow: false,
          onTap: () => _showLocationsDialog(),
        ),

        Obx(() {
          final systemInfo = controller.systemInfoModel.value;
          final isArabic = Get.locale?.languageCode == 'ar';
          final termsUrl = isArabic
              ? systemInfo?.legalDocuments.termsAr
              : systemInfo?.legalDocuments.termsEn;

          return _buildMenuItem(
            icon: LucideIcons.fileText,
            iconColor: Colors.red,
            title: 'terms_and_conditions'.tr,
            onTap: termsUrl != null && termsUrl.isNotEmpty
                ? () => _openDocument("${AppConstants.baseUrlImage}$termsUrl")
                : () => _showUnavailableDocument('Terms and Conditions'),
          );
        }),

        Obx(() {
          final systemInfo = controller.systemInfoModel.value;
          final isArabic = Get.locale?.languageCode == 'ar';
          final privacyUrl = isArabic
              ? systemInfo?.legalDocuments.privacyAr
              : systemInfo?.legalDocuments.privacyEn;

          return _buildMenuItem(
            icon: LucideIcons.shield,
            iconColor: Colors.red,
            title: 'privacy_policy'.tr,
            onTap: privacyUrl != null && privacyUrl.isNotEmpty
                ? () => _openDocument("${AppConstants.baseUrlImage}$privacyUrl")
                : () => _showUnavailableDocument('Privacy Policy'),
          );
        }),

        Obx(() {
          final systemInfo = controller.systemInfoModel.value;
          final supportUrl = systemInfo?.support.whatsappSupport;

          return _buildMenuItem(
            icon: LucideIcons.headphones,
            iconColor: Colors.red,
            title: 'support'.tr,
            onTap: supportUrl != null && supportUrl.isNotEmpty
                ? () => _openSupport(supportUrl)
                : () => _showUnavailableSupport(),
          );
        }),

        _buildMenuItem(
          icon: LucideIcons.trash2,
          iconColor: Colors.red,
          title: 'delete_account'.tr,
          onTap: () => _showDeleteAccountDialog(),
        ),

        _buildMenuItem(
          icon: LucideIcons.logOut,
          iconColor: Colors.red,
          title: 'log_out'.tr,
          onTap: () => _showLogoutDialog(),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    bool hasArrow = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),

                const SizedBox(width: 16),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // Subtitle and Arrow
                if (subtitle != null || hasArrow) ...[
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  if (hasArrow) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      LucideIcons.chevronRight,
                      size: 16,
                      color: Colors.black54,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Obx(() {
      final systemInfo = controller.systemInfoModel.value;
      if (systemInfo == null) {
        return const SizedBox.shrink();
      }

      final socialMedia = systemInfo.socialMedia;
      final socialIcons = <Widget>[];

      // WhatsApp
      if (socialMedia.whatsapp?.isNotEmpty == true) {
        socialIcons.add(
          _buildSocialIcon(
            icon: FontAwesomeIcons.whatsapp,
            color: Colors.green,
            onTap: () => _openSocialLink(socialMedia.whatsapp!),
          ),
        );
      }

      // Instagram
      if (socialMedia.instagram?.isNotEmpty == true) {
        socialIcons.add(
          _buildSocialIcon(
            icon: FontAwesomeIcons.instagram,
            color: Colors.pink,
            onTap: () => _openSocialLink(socialMedia.instagram!),
          ),
        );
      }

      // Snapchat
      if (socialMedia.snapchat?.isNotEmpty == true) {
        socialIcons.add(
          _buildSocialIcon(
            icon: FontAwesomeIcons.snapchat,
            color: Colors.yellow[600]!,
            onTap: () => _openSocialLink(socialMedia.snapchat!),
          ),
        );
      }

      // TikTok
      if (socialMedia.tiktok?.isNotEmpty == true) {
        socialIcons.add(
          _buildSocialIcon(
            icon: FontAwesomeIcons.tiktok,
            color: Colors.black,
            onTap: () => _openSocialLink(socialMedia.tiktok!),
          ),
        );
      }

      // Facebook (if available)
      if (socialMedia.facebook?.isNotEmpty == true) {
        socialIcons.add(
          _buildSocialIcon(
            icon: FontAwesomeIcons.facebook,
            color: Colors.blue[700]!,
            onTap: () => _openSocialLink(socialMedia.facebook!),
          ),
        );
      }

      if (socialIcons.isEmpty) {
        return const SizedBox.shrink();
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            socialIcons
                .map((icon) => [icon, const SizedBox(width: 24)])
                .expand((i) => i)
                .toList()
              ..removeLast(), // Remove the last SizedBox
      );
    });
  }

  Widget _buildSocialIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, size: 24, color: color),
      ),
    );
  }

  // Helper Methods
  void _openDocument(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open document');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open document: ${e.toString()}');
    }
  }

  void _openSupport(String supportUrl) async {
    try {
      if (await canLaunchUrl(Uri.parse(supportUrl))) {
        await launchUrl(
          Uri.parse(supportUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        Get.snackbar('Error', 'Could not open support link ${supportUrl}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open support: ${e.toString()}');
    }
  }

  void _openSocialLink(String url) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('Error', 'Could not open social media link');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open link: ${e.toString()}');
    }
  }

  void _showUnavailableDocument(String documentName) {
    Get.snackbar('Info', '$documentName is currently unavailable');
  }

  void _showUnavailableSupport() {
    Get.snackbar('Info', 'Support is currently unavailable');
  }

  // Existing methods remain the same...
  void _showLocationsDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.7,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'my_saved_locations'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Obx(() {
                  if (controller.isLocationsLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.hasLocationsError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'failed_to_load_locations'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),

                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: controller.refreshLocations,
                            child: Text('retry'.tr),
                          ),
                        ],
                      ),
                    );
                  }

                  if (controller.userLocations.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.location_off,
                              size: 40,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'no_locations_saved'.tr,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'add_first_location_message'.tr,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              _showAddLocationDialog();
                            },
                            icon: const Icon(Icons.add_location, size: 20),
                            label: Text('add_location'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: controller.userLocations.length,
                          itemBuilder: (context, index) {
                            final location = controller.userLocations[index];
                            return _buildLocationCard(location);
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Get.back();
                              _showAddLocationDialog();
                            },
                            icon: const Icon(Icons.add_location, size: 20),
                            label: Text('add_new_location'.tr),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard(UserLocationModel location) {
    final String status = _getLocationStatus(location);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          controller.selectLocation(location);
          Get.back();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: location.isDefault
                          ? Colors.amber.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      location.isDefault ? Icons.star : Icons.location_on,
                      color: location.isDefault
                          ? Colors.amber
                          : AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                location.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(status),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (location.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'default_location'.tr,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.amber[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.more_vert,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'set_default':
                          controller.setDefaultLocation(location.id);
                          break;
                        case 'edit':
                          Get.back();
                          _showEditLocationDialog(location);
                          break;
                        case 'delete':
                          _showDeleteLocationConfirmation(location);
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      if (!location.isDefault)
                        PopupMenuItem<String>(
                          value: 'set_default',
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_outline,
                                size: 16,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 8),
                              Text('set_as_default'.tr),
                            ],
                          ),
                        ),
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit_outlined,
                              size: 16,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8),
                            Text('edit'.tr),
                          ],
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'delete'.tr,
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // State and Address Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_city,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'state'.tr + ':',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getStateLabel(
                              location.address.split('|')[0],
                            ), // Extract state from address
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (location.address.contains('|') &&
                        location.address.split('|').length > 1) ...[
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.home, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            'address'.tr + ':',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location.address.split(
                                '|',
                              )[1], // Extract address details
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Description (if available)
              if (location.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.description, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        location.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 8),

              // Footer with last updated
              Row(
                children: [
                  Icon(Icons.access_time, size: 11, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    'Updated ${_formatDate(location.updatedAt)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'ID: ${location.id}',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        statusText = 'Active';
        break;
      case 'inactive':
        statusColor = Colors.orange;
        statusText = 'Inactive';
        break;
      case 'verified':
        statusColor = Colors.blue;
        statusText = 'Verified';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 9,
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getLocationStatus(UserLocationModel location) {
    if (location.isDefault) return 'active';

    final daysSinceUpdate = DateTime.now()
        .difference(location.updatedAt)
        .inDays;
    if (daysSinceUpdate > 30) return 'inactive';

    return 'active';
  }

  String _getStateLabel(String stateValue) {
    final state = AppConstants.OMAN_GOVERNORATES.firstWhere(
      (governorate) => governorate['value'] == stateValue,
      orElse: () => {'value': stateValue, 'label': stateValue},
    );
    return state['label']!;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _showAddLocationDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final addressDetailsController = TextEditingController();
    String selectedState = AppConstants.OMAN_GOVERNORATES[0]['value']!;
    double? selectedLatitude;
    double? selectedLongitude;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setDialogState) => Container(
            // Use setDialogState parameter
            width: Get.width * 0.95,
            height: Get.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.add_location,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'add_new_location'.tr,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location Title
                        Text(
                          'Location Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: titleController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Home, Work, Office',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            prefixIcon: Icon(
                              Icons.label_outline,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // State Dropdown
                        Text(
                          'State/Governorate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomGroupedDropdown(
                          hint: 'choose_state'.tr,
                          selectedValue: selectedState.isEmpty
                              ? null
                              : selectedState,
                          data: OmanStatesData.states,
                          onChanged: (String value, String label) {
                            selectedState = value;
                            setDialogState(
                              () {},
                            ); // Use the StatefulBuilder's setState
                          },
                          prefixIcon: const Icon(
                            Icons.public,
                            color: AppColors.textLight,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Address Details
                        Text(
                          'Address Details',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: addressDetailsController,
                          decoration: InputDecoration(
                            hintText:
                                'Street, building number, apartment, etc.',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            prefixIcon: Icon(
                              Icons.home_outlined,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                          maxLines: 2,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Description (Optional)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descriptionController,
                          decoration: InputDecoration(
                            hintText: 'Additional notes about this location',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            prefixIcon: Icon(
                              Icons.description_outlined,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                          maxLines: 2,
                        ),

                        const SizedBox(height: 16),

                        // Map Picker
                        Text(
                          'Pin Location on Map',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: MapPickerWidget(
                              onLocationSelected:
                                  (latitude, longitude, address) {
                                    selectedLatitude = latitude;
                                    selectedLongitude = longitude;
                                  },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('cancel'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (titleController.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please enter a location name',
                              );
                              return;
                            }
                            if (addressDetailsController.text.isEmpty) {
                              Get.snackbar(
                                'Error',
                                'Please enter address details',
                              );
                              return;
                            }
                            if (selectedLatitude == null ||
                                selectedLongitude == null) {
                              Get.snackbar(
                                'Error',
                                'Please select a location on the map',
                              );
                              return;
                            }

                            final fullAddress =
                                '$selectedState|${addressDetailsController.text.trim()}';

                            final request = CreateLocationRequest(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              latitude: selectedLatitude!,
                              longitude: selectedLongitude!,
                              address: fullAddress,
                              isDefault: controller.userLocations.isEmpty,
                            );

                            await controller.createLocation(request);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('save_location'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditLocationDialog(UserLocationModel location) {
    final addressParts = location.address.contains('|')
        ? location.address.split('|')
        : [location.address, ''];
    final titleController = TextEditingController(text: location.title);
    final descriptionController = TextEditingController(
      text: location.description,
    );
    final addressDetailsController = TextEditingController(
      text: addressParts.length > 1 ? addressParts[1] : '',
    );
    String selectedState = addressParts[0];
    double selectedLatitude = location.latitude;
    double selectedLongitude = location.longitude;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: Get.width * 0.95,
          height: Get.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_location,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'edit_location'.tr,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close, size: 24),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Title
                      Text(
                        'location_name'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          prefixIcon: Icon(
                            Icons.label_outline,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // State Dropdown
                      Text(
                        'state_governorate'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomGroupedDropdown(
                        hint: 'choose_state'.tr,
                        selectedValue: selectedState.isEmpty
                            ? null
                            : selectedState,
                        data: OmanStatesData.states,
                        onChanged: (String value, String label) {
                          selectedState = value;
                        },
                        prefixIcon: const Icon(
                          Icons.public,
                          color: AppColors.textLight,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Address Details
                      Text(
                        'address_details'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: addressDetailsController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          prefixIcon: Icon(
                            Icons.home_outlined,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Description
                      Text(
                        'description_optional'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          prefixIcon: Icon(
                            Icons.description_outlined,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ),
                        maxLines: 2,
                      ),

                      const SizedBox(height: 16),

                      // Map Picker
                      Text(
                        'pin_location_on_map'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: MapPickerWidget(
                            initialLatitude: location.latitude,
                            initialLongitude: location.longitude,
                            initialAddress: location.address,
                            onLocationSelected: (latitude, longitude, address) {
                              selectedLatitude = latitude;
                              selectedLongitude = longitude;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Get.back(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'please_enter_a_location_name'.tr,
                            );
                            return;
                          }
                          if (addressDetailsController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'please_enter_address_details'.tr,
                            );
                            return;
                          }

                          final fullAddress =
                              '$selectedState|${addressDetailsController.text.trim()}';

                          final request = UpdateLocationRequest(
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            latitude: selectedLatitude,
                            longitude: selectedLongitude,
                            address: fullAddress,
                          );

                          await controller.updateLocation(location.id, request);
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('update_location'.tr),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteLocationConfirmation(UserLocationModel location) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text('delete_location'.tr),
          ],
        ),
        content: Text(
          'are_you_sure_you_want_to_delete'.tr +
              ' "${location.title}"?' +
              'this_action_cannot_be_undone'.tr,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close confirmation dialog
              Get.back(); // Close locations dialog
              controller.deleteLocation(location.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(UserProfileModel user) {
    final nameController = TextEditingController(text: user.name);

    Get.dialog(
      AlertDialog(
        title: Text('edit_name'.tr),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'enter_your_name'.tr,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Name cannot be empty');
                return;
              }

              Get.back();
              await controller.updateProfile(
                UpdateProfileRequest(name: nameController.text.trim()),
              );
            },
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(UserProfileModel user) {
    final nameController = TextEditingController(text: user.name);
    String selectedState = user.state;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: StatefulBuilder(
          builder: (context, setDialogState) => Container(
            width: Get.width * 0.9,
            height: Get.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.close, size: 24),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          'Full Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            prefixIcon: Icon(
                              Icons.person_outline,
                              size: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // State
                        Text(
                          'State/Governorate',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        CustomGroupedDropdown(
                          hint: 'choose_state'.tr,
                          selectedValue: selectedState.isEmpty
                              ? null
                              : selectedState,
                          data: OmanStatesData.states,
                          onChanged: (String value, String label) {
                            selectedState = value;
                            setDialogState(
                              () {},
                            ); // Use StatefulBuilder's setState
                          },
                          prefixIcon: const Icon(
                            Icons.public,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Footer Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Get.back(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('cancel'.tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) {
                              Get.snackbar('Error', 'Name cannot be empty');
                              return;
                            }

                            final request = UpdateProfileRequest(
                              name: nameController.text.trim(),
                              state: selectedState,
                            );

                            try {
                              Get.back();
                              await controller.updateProfile(request);
                            } on Exception catch (e) {
                              print(e);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text('save_changes'.tr),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('select_language'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('english'.tr),
              trailing: Get.locale?.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () async {
                // Save to storage
                final storageService = Get.find<StorageService>();
                await storageService.saveLanguage('en');

                // Update locale
                Get.updateLocale(const Locale('en'));
                Get.back();

                // Show success message
                Get.snackbar(
                  'Success',
                  'Language changed to English',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text('arabic'.tr),
              trailing: Get.locale?.languageCode == 'ar'
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () async {
                // Save to storage
                final storageService = Get.find<StorageService>();
                await storageService.saveLanguage('ar');

                // Update locale
                Get.updateLocale(const Locale('ar'));
                Get.back();

                // Show success message
                Get.snackbar(
                  'نجح',
                  'تم تغيير اللغة إلى العربية',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 24),
            const SizedBox(width: 8),
            Text('delete_account'.tr),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              // Show loading
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );

              // Simulate API call delay
              await Future.delayed(const Duration(seconds: 2));

              Get.back(); // Close loading dialog

              // Show success message
              Get.snackbar(
                'Success',
                'Account deleted successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
                duration: const Duration(seconds: 2),
              );

              // Navigate to login screen after delay
              await Future.delayed(const Duration(seconds: 2));
              final storageService = Get.find<StorageService>();
              await storageService.removeToken();
              await storageService.removeUser();
              Get.offAllNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.orange, size: 24),
            const SizedBox(width: 8),
            Text('log_out'.tr),
          ],
        ),
        content: Text('log_out_confirmation'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          ElevatedButton(
            onPressed: () => controller.logout(),
            child: Text('log_out'.tr),
          ),
        ],
      ),
    );
  }
}
