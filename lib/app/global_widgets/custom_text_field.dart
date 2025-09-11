import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../core/values/colors.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          readOnly: widget.readOnly,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          enabled: widget.enabled,
          focusNode: _focusNode,
          textInputAction: widget.textInputAction,
          onFieldSubmitted: widget.onFieldSubmitted,
          textDirection: _getTextDirection(),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: AppColors.textLight,
              fontSize: 14,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.obscureText
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textLight,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled
                ? AppColors.surface
                : AppColors.surfaceVariant,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderLight),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  TextDirection _getTextDirection() {
    if (widget.keyboardType == TextInputType.phone ||
        widget.keyboardType == TextInputType.number) {
      return TextDirection.ltr;
    }
    return TextDirection.rtl; // Default to RTL for Arabic
  }
}

// Phone number text field
class PhoneTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PhoneTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  State<PhoneTextField> createState() => _PhoneTextFieldState();
}

class _PhoneTextFieldState extends State<PhoneTextField> {
  late TextEditingController _internalController;
  final String countryCode = '+968';

  @override
  void initState() {
    super.initState();
    _internalController = widget.controller ?? TextEditingController();

    // Initialize with country code if empty
    if (_internalController.text.isEmpty) {
      _internalController.text = countryCode + ' ';
    }

    // Add listener to maintain country code
    _internalController.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final text = _internalController.text;

    // Ensure country code is always present
    if (!text.startsWith(countryCode)) {
      final newText =
          countryCode + ' ' + text.replaceAll(countryCode, '').trim();
      _internalController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    // Call the original onChanged callback
    if (widget.onChanged != null) {
      widget.onChanged!(text);
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label ?? 'phone_number'.tr,
      hint: widget.hint ?? '+968 90 123 456',
      controller: _internalController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d+\-\s\(\)]')),
        LengthLimitingTextInputFormatter(17), // Adjusted for +968 prefix
        _OmanPhoneFormatter(), // Custom formatter to maintain +968
      ],
      validator: (value) {
        if (widget.validator != null) {
          return widget.validator!(value);
        }
        return null;
      },
      onChanged: null, // Handled internally
      // i want put the flag in suffix
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 12),
          const Text('🇴🇲', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
        ],
      ),
      prefixIcon: const Icon(Icons.phone, color: AppColors.textLight),
    );
  }
}

// Custom formatter to ensure +968 stays at the beginning
class _OmanPhoneFormatter extends TextInputFormatter {
  final String countryCode = '+968';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Don't allow deletion of country code
    if (!newValue.text.startsWith(countryCode)) {
      return oldValue;
    }

    // Ensure there's a space after country code
    if (newValue.text.length > countryCode.length &&
        !newValue.text.startsWith(countryCode + ' ')) {
      final remaining = newValue.text.substring(countryCode.length).trim();
      final formattedText = countryCode + ' ' + remaining;

      return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

    return newValue;
  }
}

// Password text field
class PasswordTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label ?? 'password'.tr,
      hint: hint ?? '••••••••',
      controller: controller,
      obscureText: true,
      validator: validator,
      onChanged: onChanged,
      prefixIcon: const Icon(Icons.lock, color: AppColors.textLight),
    );
  }
}

// Search text field
class SearchTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  const SearchTextField({
    Key? key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hint: hint ?? 'search'.tr,
      controller: controller,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
    );
  }
}
