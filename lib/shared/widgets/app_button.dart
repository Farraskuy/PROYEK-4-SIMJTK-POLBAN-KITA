import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum AppButtonVariant {
  primary,
  navy,
  secondary,
  success,
  warning,
  danger,
  neutral,
  outline,
  ghost,
}

enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isDisabled = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isDisabled;
  final bool fullWidth;

  bool get _enabled => onPressed != null && !isDisabled && !isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = _ButtonColors.fromVariant(variant, enabled: _enabled);
    final metrics = _ButtonMetrics.fromSize(size);

    final button = SizedBox(
      width: fullWidth ? double.infinity : null,
      height: metrics.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(metrics.radius),
          border: Border.all(color: colors.border),
          boxShadow: variant == AppButtonVariant.primary && _enabled
              ? [
                  BoxShadow(
                    color: const Color(0xFFB26B00).withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: _enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            foregroundColor: colors.foreground,
            disabledForegroundColor: colors.foreground,
            padding: EdgeInsets.symmetric(
              horizontal: metrics.horizontalPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(metrics.radius),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: metrics.iconSize,
                  height: metrics.iconSize,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: colors.foreground,
                  ),
                )
              : Row(
                  mainAxisSize: fullWidth ? MainAxisSize.min : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(
                        leadingIcon,
                        color: colors.foreground,
                        size: metrics.iconSize,
                      ),
                      SizedBox(width: metrics.iconGap),
                    ],
                    Flexible(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          color: colors.foreground,
                          fontSize: metrics.fontSize,
                          fontWeight: FontWeight.w800,
                          height: metrics.lineHeight / metrics.fontSize,
                        ),
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      SizedBox(width: metrics.iconGap),
                      Icon(
                        trailingIcon,
                        color: colors.foreground,
                        size: metrics.iconSize,
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );

    return fullWidth ? button : IntrinsicWidth(child: button);
  }
}

class _ButtonColors {
  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;

  factory _ButtonColors.fromVariant(
    AppButtonVariant variant, {
    required bool enabled,
  }) {
    if (!enabled) {
      return const _ButtonColors(
        background: AppColors.disabled,
        foreground: AppColors.muted,
        border: AppColors.disabled,
      );
    }

    switch (variant) {
      case AppButtonVariant.primary:
        return const _ButtonColors(
          background: AppColors.primary,
          foreground: Colors.white,
          border: AppColors.primary,
        );
      case AppButtonVariant.navy:
        return const _ButtonColors(
          background: AppColors.navy,
          foreground: Colors.white,
          border: AppColors.navy,
        );
      case AppButtonVariant.secondary:
        return const _ButtonColors(
          background: AppColors.secondary,
          foreground: Colors.white,
          border: AppColors.secondary,
        );
      case AppButtonVariant.success:
        return const _ButtonColors(
          background: AppColors.success,
          foreground: Colors.white,
          border: AppColors.success,
        );
      case AppButtonVariant.warning:
        return const _ButtonColors(
          background: AppColors.warning,
          foreground: Colors.white,
          border: AppColors.warning,
        );
      case AppButtonVariant.danger:
        return const _ButtonColors(
          background: AppColors.danger,
          foreground: Colors.white,
          border: AppColors.danger,
        );
      case AppButtonVariant.neutral:
        return const _ButtonColors(
          background: AppColors.neutral,
          foreground: Colors.white,
          border: AppColors.neutral,
        );
      case AppButtonVariant.outline:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
          border: AppColors.primary,
        );
      case AppButtonVariant.ghost:
        return const _ButtonColors(
          background: Colors.transparent,
          foreground: AppColors.primary,
          border: Colors.transparent,
        );
    }
  }
}

class _ButtonMetrics {
  const _ButtonMetrics({
    required this.height,
    required this.fontSize,
    required this.lineHeight,
    required this.iconSize,
    required this.iconGap,
    required this.radius,
    required this.horizontalPadding,
  });

  final double height;
  final double fontSize;
  final double lineHeight;
  final double iconSize;
  final double iconGap;
  final double radius;
  final double horizontalPadding;

  factory _ButtonMetrics.fromSize(AppButtonSize size) {
    switch (size) {
      case AppButtonSize.small:
        return const _ButtonMetrics(
          height: 40,
          fontSize: 14,
          lineHeight: 20,
          iconSize: 18,
          iconGap: 8,
          radius: 8,
          horizontalPadding: 14,
        );
      case AppButtonSize.medium:
        return const _ButtonMetrics(
          height: 52,
          fontSize: 16,
          lineHeight: 24,
          iconSize: 20,
          iconGap: 10,
          radius: 8,
          horizontalPadding: 18,
        );
      case AppButtonSize.large:
        return const _ButtonMetrics(
          height: 68,
          fontSize: 18,
          lineHeight: 28,
          iconSize: 22,
          iconGap: 10,
          radius: 8,
          horizontalPadding: 22,
        );
    }
  }
}
