import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

/// 密码强度级别
enum PasswordStrength {
  weak,
  medium,
  strong,
}

/// 密码输入组件
class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool showStrength;
  final bool enabled;

  const PasswordInput({
    super.key,
    required this.controller,
    this.hintText = '请输入密码',
    this.errorText,
    this.onChanged,
    this.showStrength = false,
    this.enabled = true,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _hasFocus = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  /// 计算密码强度
  PasswordStrength _calculateStrength(String password) {
    if (password.isEmpty) return PasswordStrength.weak;
    
    bool hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    bool hasDigit = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    
    if (hasLetter && hasDigit && (hasSpecial || password.length >= 10)) {
      return PasswordStrength.strong;
    } else if (hasLetter && hasDigit) {
      return PasswordStrength.medium;
    } else {
      return PasswordStrength.weak;
    }
  }

  /// 获取强度颜色
  Color _getStrengthColor(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return AppColors.danger;
      case PasswordStrength.medium:
        return AppColors.warning;
      case PasswordStrength.strong:
        return AppColors.success;
    }
  }

  /// 获取强度文本
  String _getStrengthText(PasswordStrength strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return '弱';
      case PasswordStrength.medium:
        return '中';
      case PasswordStrength.strong:
        return '强';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final strength = _calculateStrength(widget.controller.text);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 输入框
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: widget.enabled ? AppColors.white : AppColors.gray100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: hasError
                  ? AppColors.danger
                  : _hasFocus
                  ? AppColors.primary
                  : AppColors.gray300,
              width: _hasFocus || hasError ? 2 : 1,
            ),
            boxShadow: _hasFocus
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: AppColors.gray400,
                      fontSize: 16,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.enabled ? AppColors.gray900 : AppColors.gray400,
                  ),
                  onChanged: widget.onChanged,
                ),
              ),
              // 密码可见性切换
              GestureDetector(
                onTap: widget.enabled
                    ? () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: widget.enabled ? AppColors.gray500 : AppColors.gray400,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 密码强度指示
        if (widget.showStrength && widget.controller.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 强度条
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: strength == PasswordStrength.weak
                              ? 0.33
                              : strength == PasswordStrength.medium
                              ? 0.66
                              : 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: _getStrengthColor(strength),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getStrengthText(strength),
                      style: TextStyle(
                        color: _getStrengthColor(strength),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        // 错误提示
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              widget.errorText!,
              style: TextStyle(
                color: AppColors.danger,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
