import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/theme/cartoon_motion.dart';

enum ButtonVariant { primary, secondary, outline, ghost, danger }
enum ButtonSize { large48, medium40, small32 }

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium40,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final height = switch (widget.size) {
      ButtonSize.large48 => 48.0,
      ButtonSize.medium40 => 40.0,
      ButtonSize.small32 => 32.0,
    };

    final padding = switch (widget.size) {
      ButtonSize.large48 => const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ButtonSize.medium40 => const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ButtonSize.small32 => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    };

    final textStyle = switch (widget.size) {
      ButtonSize.large48 => Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ButtonSize.medium40 => Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
      ButtonSize.small32 => Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
    };

    final backgroundColor = switch (widget.variant) {
      ButtonVariant.primary => AppColors.primary,
      ButtonVariant.secondary => AppColors.primary.withOpacity( 0.1),
      ButtonVariant.outline => Colors.transparent,
      ButtonVariant.ghost => Colors.transparent,
      ButtonVariant.danger => AppColors.danger,
    };

    final foregroundColor = switch (widget.variant) {
      ButtonVariant.primary => Colors.white,
      ButtonVariant.secondary => AppColors.primary,
      ButtonVariant.outline => AppColors.textPrimary,
      ButtonVariant.ghost => AppColors.primary,
      ButtonVariant.danger => Colors.white,
    };

    const borderRadius = AppRadius.xl;

    final borderSide = switch (widget.variant) {
      ButtonVariant.outline => BorderSide(
          color: AppColors.border,
          width: 1.5,
        ),
      _ => BorderSide.none,
    };

    final isDisabled = widget.onPressed == null || widget.isLoading;

    Widget content;
    if (widget.isLoading) {
      content = SizedBox(
        width: height * 0.5,
        height: height * 0.5,
        child: CircularProgressIndicator(
          color: foregroundColor,
          strokeWidth: 2.5,
        ),
      );
    } else {
      final children = <Widget>[];
      if (widget.leadingIcon != null) {
        children.add(IconTheme(
          data: IconThemeData(color: foregroundColor, size: widget.size == ButtonSize.small32 ? 18 : 22),
          child: widget.leadingIcon ?? const SizedBox.shrink(),
        ));
        children.add(const SizedBox(width: 8));
      }
      children.add(Text(widget.label, style: textStyle?.copyWith(color: foregroundColor)));
      if (widget.trailingIcon != null) {
        children.add(const SizedBox(width: 8));
        children.add(IconTheme(
          data: IconThemeData(color: foregroundColor, size: widget.size == ButtonSize.small32 ? 18 : 22),
          child: widget.trailingIcon ?? const SizedBox.shrink(),
        ));
      }
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    Widget buttonWidget = ElevatedButton(
      onPressed: isDisabled ? null : widget.onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        disabledBackgroundColor: AppColors.disabled.withOpacity( 0.3),
        disabledForegroundColor: AppColors.disabled,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderSide,
        ),
        elevation: 0,
        padding: padding,
        minimumSize: Size(widget.isFullWidth ? double.infinity : 0, height),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: content,
    );

    if (widget.isFullWidth) {
      buttonWidget = SizedBox(width: double.infinity, child: buttonWidget);
    }

    const pressScale = CartoonMotion.pressScale;
    const pressDuration = CartoonMotion.pressDownDuration;
    const releaseDuration = CartoonMotion.pressUpDuration;
    const pressCurve = CartoonMotion.pressDownCurve;
    const releaseCurve = CartoonMotion.pressUpCurve;

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapUp: isDisabled ? null : (_) => setState(() => _isPressed = false),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? pressScale : 1.0,
        duration: _isPressed ? pressDuration : releaseDuration,
        curve: _isPressed ? pressCurve : releaseCurve,
        child: buttonWidget,
      ),
    );
  }
}
