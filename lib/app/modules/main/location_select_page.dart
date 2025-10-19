import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/values/colors.dart';
import '../../global_widgets/custom_drop_down.dart';
import '../../data/services/storage_service.dart';
import '../../modules/user/user_controller.dart';
import '../../data/models/user_profile_model.dart';
import '../../modules/home/home_controller.dart';

class LocationSelectionPage extends StatefulWidget {
  const LocationSelectionPage({Key? key}) : super(key: key);

  @override
  State<LocationSelectionPage> createState() => _LocationSelectionPageState();
}

class _LocationSelectionPageState extends State<LocationSelectionPage> {
  String? selectedGovernorate;
  String? selectedState;
  List<StateData> availableStates = [];
  bool isLoading = false;

  final UserController userController = Get.find<UserController>();
  final StorageService storageService = Get.find<StorageService>();

  @override
  void initState() {
    super.initState();
    _initializeCurrentLocation();
  }

  void _initializeCurrentLocation() async {
    try {
      // Get fresh user data from the API
      final userData = userController.userProfile.value;
      if (userData?.state != null && userData!.state!.isNotEmpty) {
        print(
          'Initializing with current state from user data: ${userData.state}',
        );
        _findGovernorateByState(userData.state!);
      } else {
        print('No current state found in user data, starting fresh');
      }
    } catch (e) {
      print('Error fetching user data: $e');
      // Fallback to storage if API fails
      final currentUser = storageService.getUser();
      if (currentUser?.state != null && currentUser!.state!.isNotEmpty) {
        print('Fallback: Using stored state: ${currentUser.state}');
        _findGovernorateByState(currentUser.state!);
      }
    }
  }

  void _findGovernorateByState(String stateValue) {
    print('Looking for state value: $stateValue');
    for (var governorate in OmanStatesData.states) {
      for (var state in governorate.states) {
        print('Checking state: ${state.value}');
        if (state.value == stateValue) {
          print(
            'Found matching state! Setting governorate: ${governorate.governorate.en}',
          );
          setState(() {
            selectedGovernorate = Get.locale?.languageCode == 'ar'
                ? governorate.governorate.ar
                : governorate.governorate.en;
            selectedState = state.value;
            availableStates = governorate.states;
          });
          return;
        }
      }
    }
    print('No matching state found for: $stateValue');
  }

  void _onGovernorateChanged(String governorateValue) {
    // Find the governorate by matching the unique value format
    final governorate = OmanStatesData.states.firstWhere(
      (gov) =>
          '${gov.governorate.en}_${gov.governorate.ar}' == governorateValue,
    );

    final governorateLabel = Get.locale?.languageCode == 'ar'
        ? governorate.governorate.ar
        : governorate.governorate.en;

    setState(() {
      selectedGovernorate = governorateLabel;
      selectedState = null;
      availableStates = governorate.states;
    });
  }

  void _onStateChanged(String stateValue) {
    setState(() {
      selectedState = stateValue;
    });
  }

  Future<void> _saveLocation() async {
    if (selectedState == null) {
      // Get.snackbar(
      //   'Error',
      //   'Please select a state',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Use the existing updateProfile method from UserController
      await userController.updateProfile(
        UpdateProfileRequest(state: selectedState!),
      );

      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.selectedState.value = selectedState!;
        homeController.loadHomeData();
      }
      Get.back();
      Get.snackbar(
        'success'.tr,
        'location_updated_successfully'.tr,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Navigator.of(context).pop();
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_update_location'.tr,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(
            LucideIcons.chevronLeft,
            color: Colors.black87,
            size: 20,
          ),
        ),
        title: Text(
          'select_location'.tr,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Selection Section
                    Container(
                      width: double.infinity,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Governorate Dropdown
                          Text(
                            'governorate'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildGovernorateDropdown(),

                          const SizedBox(height: 20),

                          // State Dropdown
                          Text(
                            'state'.tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildStateDropdown(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Current Selection Display
                    if (selectedState != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  LucideIcons.checkCircle,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'selected_location'.tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _getSelectedLocationLabel(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || selectedState == null
                      ? null
                      : _saveLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'save_location'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGovernorateDropdown() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _getSelectedGovernorateValue(),
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'select_governorate'.tr,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              LucideIcons.chevronDown,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          items: OmanStatesData.states.map((governorate) {
            final label = Get.locale?.languageCode == 'ar'
                ? governorate.governorate.ar
                : governorate.governorate.en;
            // Use a unique key to avoid duplicates
            final uniqueValue =
                '${governorate.governorate.en}_${governorate.governorate.ar}';
            return DropdownMenuItem<String>(
              value: uniqueValue,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            );
          }).toList(),
          onChanged: (String? value) {
            if (value != null) {
              _onGovernorateChanged(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildStateDropdown() {
    if (selectedGovernorate == null) {
      return Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.location_city, color: Colors.grey),
              const SizedBox(width: 12),
              Text(
                'select_governorate_first'.tr,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedState,
          isExpanded: true,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'select_state'.tr,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ),
          icon: const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(
              LucideIcons.chevronDown,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          items: availableStates.map((state) {
            final label = Get.locale?.languageCode == 'ar'
                ? state.label.ar
                : state.label.en;
            return DropdownMenuItem<String>(
              value: state.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              _onStateChanged(value);
            }
          },
        ),
      ),
    );
  }

  String _getSelectedLocationLabel() {
    if (selectedState == null) return '';

    final state = availableStates.firstWhere((s) => s.value == selectedState);
    final isArabic = Get.locale?.languageCode == 'ar';

    return isArabic ? state.label.ar : state.label.en;
  }

  String? _getSelectedGovernorateValue() {
    if (selectedGovernorate == null) return null;

    // Find the governorate and return its unique value
    final governorate = OmanStatesData.states.firstWhereOrNull(
      (gov) =>
          (Get.locale?.languageCode == 'ar'
              ? gov.governorate.ar
              : gov.governorate.en) ==
          selectedGovernorate,
    );

    return governorate != null
        ? '${governorate.governorate.en}_${governorate.governorate.ar}'
        : null;
  }
}

// Add these to your translation files
class LocationTranslations {
  static Map<String, Map<String, String>> translations = {
    'en': {
      'select_location': 'Select Location',
      'choose_your_location': 'Choose Your Location',
      'select_your_governorate_and_state':
          'Select your governorate and state to continue',
      'governorate': 'Governorate',
      'state': 'State',
      'select_governorate': 'Select Governorate',
      'select_state': 'Select State',
      'select_governorate_first': 'Select governorate first',
      'selected_location': 'Selected Location',
      'save_location': 'Save Location',
    },
    'ar': {
      'select_location': 'اختيار الموقع',
      'choose_your_location': 'اختر موقعك',
      'select_your_governorate_and_state': 'اختر المحافظة والولاية للمتابعة',
      'governorate': 'المحافظة',
      'state': 'الولاية',
      'select_governorate': 'اختر المحافظة',
      'select_state': 'اختر الولاية',
      'select_governorate_first': 'اختر المحافظة أولاً',
      'selected_location': 'الموقع المحدد',
      'save_location': 'حفظ الموقع',
    },
  };
}
