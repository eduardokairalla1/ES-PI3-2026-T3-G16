// --- AppButton ---
//
// One button component to rule them all. Used everywhere we need a textual
// action: page CTAs, dialog confirms, retry actions, sign-out, etc.
//
// Chips, stepper +/-, menu rows, icon-only buttons and bottom-nav items are
// intentionally NOT covered — they have very different semantics.

// --- IMPORTS ---
import 'package:flutter/material.dart';
import 'package:mesclainvest/shared/styles/app_colors.dart';

// --- TYPES ---

/// Visual + semantic variant of the button.
enum AppButtonVariant {
  /// Main call to action. Black fill, white text.
  primary,

  /// Alternate action. White fill with subtle border, black text.
  secondary,

  /// Inline link. Transparent, black text.
  text,

  /// Destructive / negative action. White fill with subtle border, danger-red text.
  destructive,
}

/// Touch-target / typographic size.
enum AppButtonSize {
  /// 58px height — primary auth/home CTAs.
  large,

  /// 52px height — page-level actions (save, confirm).
  medium,

  /// 44px height — inline retry, dialog actions, compact rows.
  small,
}

// --- CODE ---

/// Shared textual button used by forms, dialogs and page-level actions.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;
  bool _isThrottled = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  void _handleTap() {
    if (!_enabled || _isThrottled) return;
    _isThrottled = true;
    widget.onPressed!();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _isThrottled = false;
      }
    });
  }

  double get _height => switch (widget.size) {
    AppButtonSize.large => 58,
    AppButtonSize.medium => 52,
    AppButtonSize.small => 44,
  };

  double get _fontSize => switch (widget.size) {
    AppButtonSize.large => 16,
    AppButtonSize.medium => 15,
    AppButtonSize.small => 14,
  };

  EdgeInsets get _padding => switch (widget.size) {
    AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24),
    AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 20),
    AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 16),
  };

  _ButtonColors get _colors {
    if (!_enabled && !widget.isLoading) {
      // disabled state shared by all variants
      return const _ButtonColors(
        background: AppColors.buttonDisabledBg,
        foreground: AppColors.buttonDisabledFg,
        border: Colors.transparent,
      );
    }

    return switch (widget.variant) {
      AppButtonVariant.primary => const _ButtonColors(
        background: AppColors.buttonPrimaryBg,
        foreground: AppColors.buttonPrimaryFg,
        border: Colors.transparent,
      ),
      AppButtonVariant.secondary => const _ButtonColors(
        background: AppColors.buttonSecondaryBg,
        foreground: AppColors.buttonSecondaryFg,
        border: AppColors.buttonSecondaryBorder,
      ),
      AppButtonVariant.text => const _ButtonColors(
        background: Colors.transparent,
        foreground: AppColors.buttonTextFg,
        border: Colors.transparent,
      ),
      AppButtonVariant.destructive => const _ButtonColors(
        background: AppColors.buttonSecondaryBg,
        foreground: AppColors.buttonDestructiveFg,
        border: AppColors.buttonSecondaryBorder,
      ),
    };
  }

  void _setPressed(bool value) {
    if (!_enabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;
    final isTextOnly = widget.variant == AppButtonVariant.text;

    final content = widget.isLoading
        ? SizedBox(
            height: _fontSize + 4,
            width: _fontSize + 4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: _fontSize + 4,
                  color: colors.foreground,
                ),
                const SizedBox(width: 10),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          );

    final body = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: _height,
      width: widget.fullWidth ? double.infinity : null,
      padding: _padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(isTextOnly ? 8 : 20),
        border: colors.border == Colors.transparent
            ? null
            : Border.all(color: colors.border, width: 1),
      ),
      child: content,
    );

    final scaled = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 80),
      child: body,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: _enabled ? _handleTap : null,
      child: scaled,
    );
  }
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
