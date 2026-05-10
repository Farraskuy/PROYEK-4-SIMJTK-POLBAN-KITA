import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import 'app_field_label.dart';

enum AppTextFieldVariant { filled, outlined, underline }

enum AppTextFieldState { normal, success, error }

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.variant = AppTextFieldVariant.filled,
    this.state = AppTextFieldState.normal,
    this.required = false,
    this.helperText,
    this.errorText,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final AppTextFieldVariant variant;
  final AppTextFieldState state;
  final bool required;
  final String? helperText;
  final String? errorText;
  final int maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final borderRadius = variant == AppTextFieldVariant.underline ? 0.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: AppFieldLabel(text: label, required: required),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          onChanged: onChanged,
          style: GoogleFonts.poppins(
            color: AppColors.title,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            filled: variant == AppTextFieldVariant.filled,
            fillColor: enabled ? AppColors.field : AppColors.disabled,
            hintText: hintText,
            hintStyle: GoogleFonts.poppins(
              color: AppColors.fieldText.withValues(alpha: 0.34),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.body, size: 22),
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: _border(
              color: _borderColor(enabled: enabled),
              radius: borderRadius,
              width: 1,
              variant: variant,
            ),
            enabledBorder: _border(
              color: _borderColor(enabled: enabled),
              radius: borderRadius,
              width: 1,
              variant: variant,
            ),
            disabledBorder: _border(
              color: AppColors.disabled,
              radius: borderRadius,
              width: 1,
              variant: variant,
            ),
            focusedBorder: _border(
              color: _focusedColor(),
              radius: borderRadius,
              width: 1.6,
              variant: variant,
            ),
            errorBorder: _border(
              color: AppColors.danger,
              radius: borderRadius,
              width: 1.2,
              variant: variant,
            ),
            focusedErrorBorder: _border(
              color: AppColors.danger,
              radius: borderRadius,
              width: 1.6,
              variant: variant,
            ),
          ),
        ),
        if (_supportingText != null) ...[
          const SizedBox(height: 6),
          Text(
            _supportingText!,
            style: GoogleFonts.poppins(
              color: _supportingColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 16 / 12,
            ),
          ),
        ],
      ],
    );
  }

  String? get _supportingText {
    if (state == AppTextFieldState.error) return errorText;
    return helperText;
  }

  Color get _supportingColor {
    switch (state) {
      case AppTextFieldState.success:
        return AppColors.success;
      case AppTextFieldState.error:
        return AppColors.danger;
      case AppTextFieldState.normal:
        return AppColors.muted;
    }
  }

  Color _borderColor({required bool enabled}) {
    if (!enabled) return AppColors.disabled;
    switch (state) {
      case AppTextFieldState.success:
        return AppColors.success;
      case AppTextFieldState.error:
        return AppColors.danger;
      case AppTextFieldState.normal:
        return variant == AppTextFieldVariant.filled
            ? Colors.transparent
            : AppColors.border;
    }
  }

  Color _focusedColor() {
    switch (state) {
      case AppTextFieldState.success:
        return AppColors.success;
      case AppTextFieldState.error:
        return AppColors.danger;
      case AppTextFieldState.normal:
        return AppColors.primary;
    }
  }

  InputBorder _border({
    required Color color,
    required double radius,
    required double width,
    required AppTextFieldVariant variant,
  }) {
    if (variant == AppTextFieldVariant.underline) {
      return UnderlineInputBorder(
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
