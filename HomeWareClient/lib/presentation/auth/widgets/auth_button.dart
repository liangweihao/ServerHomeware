import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 认证按钮变体
enum AuthButtonVariant {
  primary,
  outline,
  ghost,
}

/// 认证按钮
class AuthButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AuthButtonVariant variant;
  final bool isLoading;
  final bool enabled;
  final double? height;
  final double? width;
  final Widget? leftIcon;
  final Widget? rightIcon;

  const AuthButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AuthButtonVariant.primary,
    this.isLoading = false,
    this.enabled = true,
    this.height = 48,
    this.width,
    this.leftIcon,
    this.rightIcon,
  });

  /// 确定按钮是否可点击
  bool get _isEnabled => enabled && !isLoading && onPressed != null;

  /// 获取背景颜色
  Color _getBackgroundColor() {
    if (!_isEnabled) {
      return AppColors.gray300;
    }
    switch (variant) {
      case AuthButtonVariant.primary:
        return AppColors.primary;
      case AuthButtonVariant.outline:
      case AuthButtonVariant.ghost:
        return Colors.transparent;
    }
  }

  /// 获取文字颜色
  Color _getTextColor() {
    if (!_isEnabled) {
      return AppColors.gray400;
    }
    switch (variant) {
      case AuthButtonVariant.primary:
        return AppColors.white;
      case AuthButtonVariant.outline:
      case AuthButtonVariant.ghost:
        return AppColors.primary;
    }
  }

  /// 获取边框颜色
  Color? _getBorderColor() {
    if (!_isEnabled) {
      return AppColors.gray300;
    }
    switch (variant) {
      case AuthButtonVariant.primary:
      case AuthButtonVariant.ghost:
        return null;
      case AuthButtonVariant.outline:
        return AppColors.gray300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _isEnabled
          ? (_) {
              // 按下反馈
            }
          : null,
      onTapUp: _isEnabled
          ? (_) {
              // 松开反馈
            }
          : null,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(8),
          border: _getBorderColor() != null
              ? Border.all(color: _getBorderColor()!)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isEnabled ? onPressed : null,
            borderRadius: BorderRadius.circular(8),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getTextColor(),
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (leftIcon != null) ...[
                          leftIcon!,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _getTextColor(),
                          ),
                        ),
                        if (rightIcon != null) ...[
                          const SizedBox(width: 8),
                          rightIcon!,
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
