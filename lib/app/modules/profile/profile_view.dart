import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../global_widgets/custom_appbar.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildProfileHeader() {
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
                      image: const DecorationImage(
                        image: AssetImage('assets/images/profile_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
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
                        const Text(
                          'Samer Bakour',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showEditNameDialog(),
                          child: const Icon(
                            LucideIcons.edit,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Phone with edit icon
                    Row(
                      children: [
                        const Text(
                          '+9XXXXXXXXX',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _showEditPhoneDialog(),
                          child: const Icon(
                            LucideIcons.edit,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Edit Button
              GestureDetector(
                onTap: () => _showEditProfileDialog(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
  }

  Widget _buildMenuItems() {
    return Column(
      children: [
        _buildMenuItem(
          icon: LucideIcons.globe,
          iconColor: Colors.red,
          title: 'Language',
          subtitle: 'English',
          hasArrow: true,
          onTap: () => _showLanguageDialog(),
        ),

        _buildMenuItem(
          icon: LucideIcons.mapPin,
          iconColor: Colors.red,
          title: 'My address',
          subtitle: 'Add',
          hasArrow: true,
          onTap: () => _showAddAddressDialog(),
        ),

        _buildMenuItem(
          icon: LucideIcons.fileText,
          iconColor: Colors.red,
          title: 'Terms and Conditions',
          onTap: () => _openTermsAndConditions(),
        ),

        _buildMenuItem(
          icon: LucideIcons.shield,
          iconColor: Colors.red,
          title: 'Privacy Policy',
          onTap: () => _openPrivacyPolicy(),
        ),

        _buildMenuItem(
          icon: LucideIcons.headphones,
          iconColor: Colors.red,
          title: 'Support',
          onTap: () => _openSupport(),
        ),

        _buildMenuItem(
          icon: LucideIcons.trash2,
          iconColor: Colors.red,
          title: 'Delete Account',
          onTap: () => _showDeleteAccountDialog(),
        ),

        _buildMenuItem(
          icon: LucideIcons.logOut,
          iconColor: Colors.red,
          title: 'Log Out',
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
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor,
                  ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(
          icon: FontAwesomeIcons.whatsapp,
          color: Colors.green,
          onTap: () => _openWhatsApp(),
        ),

        const SizedBox(width: 24),

        _buildSocialIcon(
          icon: FontAwesomeIcons.instagram,
          color: Colors.pink,
          onTap: () => _openInstagram(),
        ),

        const SizedBox(width: 24),

        _buildSocialIcon(
          icon: FontAwesomeIcons.snapchat,
          color: Colors.yellow[600]!,
          onTap: () => _openSnapchat(),
        ),

        const SizedBox(width: 24),

        _buildSocialIcon(
          icon: FontAwesomeIcons.tiktok,
          color: Colors.black,
          onTap: () => _openTikTok(),
        ),
      ],
    );
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
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: color,
        ),
      ),
    );
  }

  // Dialog and Action Methods
  void _showEditNameDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Name'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Name updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Phone Number'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter your phone number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Phone number updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Profile updated successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              trailing: const Icon(Icons.check, color: Colors.green),
              onTap: () {
                Get.updateLocale(const Locale('en', 'US'));
                Get.back();
                Get.snackbar('Success', 'Language changed to English');
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('العربية'),
              onTap: () {
                Get.updateLocale(const Locale('ar', 'AE'));
                Get.back();
                Get.snackbar('نجح', 'تم تغيير اللغة إلى العربية');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddAddressDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Add Address'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter your address',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Success', 'Address added successfully');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openTermsAndConditions() {
    Get.snackbar('Info', 'Opening Terms and Conditions...');
    // You can navigate to a terms page or open a URL
  }

  void _openPrivacyPolicy() {
    Get.snackbar('Info', 'Opening Privacy Policy...');
    // You can navigate to a privacy page or open a URL
  }

  void _openSupport() {
    Get.snackbar('Support', 'Opening Support Center...');
    // You can navigate to a support page or open a chat
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar('Warning', 'Account deletion initiated');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Handle logout logic
              Get.snackbar('Info', 'Logged out successfully');
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // Social Media Methods
  void _openWhatsApp() async {
    const url = 'https://wa.me/96812345678';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openInstagram() async {
    const url = 'https://instagram.com/khabir_app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openSnapchat() async {
    const url = 'https://snapchat.com/add/khabir_app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openTikTok() async {
    const url = 'https://tiktok.com/@khabir_app';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
