import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/values/colors.dart';

class CustomGroupedDropdown extends StatefulWidget {
  final String? hint;
  final String? selectedValue;
  final List<GovernorateData> data;
  final Function(String value, String label) onChanged;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final bool enabled;

  const CustomGroupedDropdown({
    Key? key,
    this.hint,
    this.selectedValue,
    required this.data,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<CustomGroupedDropdown> createState() => _CustomGroupedDropdownState();
}

class _CustomGroupedDropdownState extends State<CustomGroupedDropdown> {
  bool _isOpen = false;
  String? _selectedLabel;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null) {
      _selectedLabel = _findLabelByValue(widget.selectedValue!);
    }
  }

  @override
  void didUpdateWidget(CustomGroupedDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedValue != oldWidget.selectedValue) {
      _selectedLabel = widget.selectedValue != null
          ? _findLabelByValue(widget.selectedValue!)
          : null;
    }
  }

  String? _findLabelByValue(String value) {
    for (var governorate in widget.data) {
      for (var state in governorate.states) {
        if (state.value == value) {
          return Get.locale?.languageCode == 'ar'
              ? state.label.ar
              : state.label.en;
        }
      }
    }
    return null;
  }

  void _toggleDropdown() {
    if (!widget.enabled) return;

    if (_isOpen) {
      _closeDropdown();
    } else {
      _openDropdown();
    }
  }

  void _openDropdown() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isOpen = true);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() => _isOpen = false);
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 8.0,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'choose_state'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _closeDropdown,
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Scrollable list
                  Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: widget.data.length,
                      itemBuilder: (context, index) {
                        final governorate = widget.data[index];
                        return _buildGovernorateGroup(governorate);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGovernorateGroup(GovernorateData governorate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Governorate Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F5),
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Text(
            Get.locale?.languageCode == 'ar'
                ? governorate.governorate.ar
                : governorate.governorate.en,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        // States
        ...governorate.states.map((state) => _buildStateItem(state)).toList(),
      ],
    );
  }

  Widget _buildStateItem(StateData state) {
    final isSelected = widget.selectedValue == state.value;
    final label = Get.locale?.languageCode == 'ar'
        ? state.label.ar
        : state.label.en;

    return InkWell(
      onTap: () {
        widget.onChanged(state.value, label);
        setState(() => _selectedLabel = label);
        _closeDropdown();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: AppColors.borderLight),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: FormField<String>(
        initialValue: widget.selectedValue,
        validator: widget.validator,
        builder: (FormFieldState<String> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _toggleDropdown,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: widget.enabled
                        ? Colors.white
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: state.hasError
                          ? AppColors.error
                          : _isOpen
                          ? AppColors.primary
                          : AppColors.border,
                      width: _isOpen ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (widget.prefixIcon != null) ...[
                        const SizedBox(width: 16),
                        widget.prefixIcon!,
                        const SizedBox(width: 12),
                      ] else
                        const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _selectedLabel ?? widget.hint ?? 'Select...',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedLabel != null
                                ? AppColors.textPrimary
                                : AppColors.textLight,
                            fontWeight: _selectedLabel != null
                                ? FontWeight.normal
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      Icon(
                        _isOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
              if (state.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 16),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _closeDropdown();
    super.dispose();
  }
}

// Data Models
class GovernorateData {
  final LocalizedString governorate;
  final List<StateData> states;

  const GovernorateData({required this.governorate, required this.states});
}

class StateData {
  final String value;
  final LocalizedString label;

  const StateData({required this.value, required this.label});
}

class LocalizedString {
  final String en;
  final String ar;

  const LocalizedString({required this.en, required this.ar});
}

// Constants for Oman States Data
class OmanStatesData {
  static const List<GovernorateData> states = [
    GovernorateData(
      governorate: LocalizedString(en: 'Muscat Governorate', ar: 'محافظة مسقط'),
      states: [
        StateData(
          value: 'Muscat',
          label: LocalizedString(en: 'Muscat', ar: 'مسقط'),
        ),
        StateData(
          value: 'Muttrah',
          label: LocalizedString(en: 'Muttrah', ar: 'مطرح'),
        ),
        StateData(
          value: 'Al Amrat',
          label: LocalizedString(en: 'Al Amrat', ar: 'العامرات'),
        ),
        StateData(
          value: 'Bawshar',
          label: LocalizedString(en: 'Bawshar', ar: 'بوشر'),
        ),
        StateData(
          value: 'Al Seeb',
          label: LocalizedString(en: 'Al Seeb', ar: 'السيب'),
        ),
        StateData(
          value: 'Qurayyat',
          label: LocalizedString(en: 'Qurayyat', ar: 'القريات'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(en: 'Dhofar Governorate', ar: 'محافظة ظفار'),
      states: [
        StateData(
          value: 'Salalah',
          label: LocalizedString(en: 'Salalah', ar: 'صلالة'),
        ),
        StateData(
          value: 'Taqah',
          label: LocalizedString(en: 'Taqah', ar: 'طاقة'),
        ),
        StateData(
          value: 'Mirbat',
          label: LocalizedString(en: 'Mirbat', ar: 'مرباط'),
        ),
        StateData(
          value: 'Rakhyut',
          label: LocalizedString(en: 'Rakhyut', ar: 'رخيوت'),
        ),
        StateData(
          value: 'Thumrait',
          label: LocalizedString(en: 'Thumrait', ar: 'ثمريت'),
        ),
        StateData(
          value: 'Dhalkut',
          label: LocalizedString(en: 'Dhalkut', ar: 'ضلكوت'),
        ),
        StateData(
          value: 'Al Mazyunah',
          label: LocalizedString(en: 'Al Mazyunah', ar: 'المزيونة'),
        ),
        StateData(
          value: 'Maqshan',
          label: LocalizedString(en: 'Maqshan', ar: 'مقشن'),
        ),
        StateData(
          value: 'Shalim and the Hallaniyat Islands',
          label: LocalizedString(
            en: 'Shalim and the Hallaniyat Islands',
            ar: 'شليم وجزر الحلانيات',
          ),
        ),
        StateData(
          value: 'Sadah',
          label: LocalizedString(en: 'Sadah', ar: 'سدح'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'Musandam Governorate',
        ar: 'محافظة مسندم',
      ),
      states: [
        StateData(
          value: 'Khasab',
          label: LocalizedString(en: 'Khasab', ar: 'خصب'),
        ),
        StateData(
          value: 'Dibba',
          label: LocalizedString(en: 'Dibba', ar: 'دبا'),
        ),
        StateData(
          value: 'Bukha',
          label: LocalizedString(en: 'Bukha', ar: 'بخا'),
        ),
        StateData(
          value: 'Madha',
          label: LocalizedString(en: 'Madha', ar: 'مدحاء'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'Al Buraimi Governorate',
        ar: 'محافظة البريمي',
      ),
      states: [
        StateData(
          value: 'Al Buraimi',
          label: LocalizedString(en: 'Al Buraimi', ar: 'البريمي'),
        ),
        StateData(
          value: 'Mahdah',
          label: LocalizedString(en: 'Mahdah', ar: 'محضة'),
        ),
        StateData(
          value: 'Al Sinainah',
          label: LocalizedString(en: 'Al Sinainah', ar: 'السنينة'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'Ad Dakhiliyah Governorate',
        ar: 'محافظة الداخلية',
      ),
      states: [
        StateData(
          value: 'Nizwa',
          label: LocalizedString(en: 'Nizwa', ar: 'نزوى'),
        ),
        StateData(
          value: 'Bahla',
          label: LocalizedString(en: 'Bahla', ar: 'بهلا'),
        ),
        StateData(
          value: 'Manah',
          label: LocalizedString(en: 'Manah', ar: 'منح'),
        ),
        StateData(
          value: 'Al Hamra',
          label: LocalizedString(en: 'Al Hamra', ar: 'الحمراء'),
        ),
        StateData(
          value: 'Adam',
          label: LocalizedString(en: 'Adam', ar: 'أدم'),
        ),
        StateData(
          value: 'Izki',
          label: LocalizedString(en: 'Izki', ar: 'إزكي'),
        ),
        StateData(
          value: 'Samail',
          label: LocalizedString(en: 'Samail', ar: 'سمائل'),
        ),
        StateData(
          value: 'Bidbid',
          label: LocalizedString(en: 'Bidbid', ar: 'بدبد'),
        ),
        StateData(
          value: 'Al Jabal Al Akhdar',
          label: LocalizedString(en: 'Al Jabal Al Akhdar', ar: 'الجبل الأخضر'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'North Al Batinah Governorate',
        ar: 'محافظة شمال الباطنة',
      ),
      states: [
        StateData(
          value: 'Sohar',
          label: LocalizedString(en: 'Sohar', ar: 'صحار'),
        ),
        StateData(
          value: 'Liwa',
          label: LocalizedString(en: 'Liwa', ar: 'لوى'),
        ),
        StateData(
          value: 'Shinas',
          label: LocalizedString(en: 'Shinas', ar: 'شناص'),
        ),
        StateData(
          value: 'Saham',
          label: LocalizedString(en: 'Saham', ar: 'صحم'),
        ),
        StateData(
          value: 'Al Khaboura',
          label: LocalizedString(en: 'Al Khaboura', ar: 'الخابورة'),
        ),
        StateData(
          value: 'Al Suwaiq',
          label: LocalizedString(en: 'Al Suwaiq', ar: 'السويق'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'South Al Batinah Governorate',
        ar: 'محافظة جنوب الباطنة',
      ),
      states: [
        StateData(
          value: 'Rustaq',
          label: LocalizedString(en: 'Rustaq', ar: 'الرستاق'),
        ),
        StateData(
          value: 'Al Awabi',
          label: LocalizedString(en: 'Al Awabi', ar: 'العوابي'),
        ),
        StateData(
          value: 'Nakhal',
          label: LocalizedString(en: 'Nakhal', ar: 'نخل'),
        ),
        StateData(
          value: 'Wadi Al Maawil',
          label: LocalizedString(en: 'Wadi Al Maawil', ar: 'وادي المعاول'),
        ),
        StateData(
          value: 'Barka',
          label: LocalizedString(en: 'Barka', ar: 'بركاء'),
        ),
        StateData(
          value: 'Al Musannah',
          label: LocalizedString(en: 'Al Musannah', ar: 'المصنعة'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'South Ash Sharqiyah Governorate',
        ar: 'محافظة جنوب الشرقية',
      ),
      states: [
        StateData(
          value: 'Sur',
          label: LocalizedString(en: 'Sur', ar: 'صور'),
        ),
        StateData(
          value: 'Al Kamil Wal Wafi',
          label: LocalizedString(en: 'Al Kamil Wal Wafi', ar: 'الكامل والوافي'),
        ),
        StateData(
          value: 'Jaalan Bani Bu Hassan',
          label: LocalizedString(
            en: 'Jaalan Bani Bu Hassan',
            ar: 'جعلان بني بوحسن',
          ),
        ),
        StateData(
          value: 'Jaalan Bani Bu Ali',
          label: LocalizedString(
            en: 'Jaalan Bani Bu Ali',
            ar: 'جعلان بني بو علي',
          ),
        ),
        StateData(
          value: 'Masirah',
          label: LocalizedString(en: 'Masirah', ar: 'مصيرة'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'North Ash Sharqiyah Governorate',
        ar: 'محافظة شمال الشرقية',
      ),
      states: [
        StateData(
          value: 'Ibra',
          label: LocalizedString(en: 'Ibra', ar: 'إبراء'),
        ),
        StateData(
          value: 'Al Mudhaibi',
          label: LocalizedString(en: 'Al Mudhaibi', ar: 'المضيبي'),
        ),
        StateData(
          value: 'Bidiyah',
          label: LocalizedString(en: 'Bidiyah', ar: 'بدية'),
        ),
        StateData(
          value: 'Al Qabil',
          label: LocalizedString(en: 'Al Qabil', ar: 'القابل'),
        ),
        StateData(
          value: 'Wadi Bani Khalid',
          label: LocalizedString(en: 'Wadi Bani Khalid', ar: 'وادي بني خالد'),
        ),
        StateData(
          value: 'Dema Wa Thaieen',
          label: LocalizedString(en: 'Dema Wa Thaieen', ar: 'دماء الطائيين'),
        ),
        StateData(
          value: 'Sinaw',
          label: LocalizedString(en: 'Sinaw', ar: 'سناو'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'Ad Dhahirah Governorate',
        ar: 'محافظة الظاهرة',
      ),
      states: [
        StateData(
          value: 'Ibri',
          label: LocalizedString(en: 'Ibri', ar: 'عبري'),
        ),
        StateData(
          value: 'Yanqul',
          label: LocalizedString(en: 'Yanqul', ar: 'ينقل'),
        ),
        StateData(
          value: 'Dhank',
          label: LocalizedString(en: 'Dhank', ar: 'ضنك'),
        ),
      ],
    ),
    GovernorateData(
      governorate: LocalizedString(
        en: 'Al Wusta Governorate',
        ar: 'محافظة الوسطى',
      ),
      states: [
        StateData(
          value: 'Haima',
          label: LocalizedString(en: 'Haima', ar: 'هيما'),
        ),
        StateData(
          value: 'Mahout',
          label: LocalizedString(en: 'Mahout', ar: 'محوت'),
        ),
        StateData(
          value: 'Duqm',
          label: LocalizedString(en: 'Duqm', ar: 'الدقم'),
        ),
        StateData(
          value: 'Al Jazer',
          label: LocalizedString(en: 'Al Jazer', ar: 'الجازر'),
        ),
      ],
    ),
  ];
}
