import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

/// 手机号输入组件
class PhoneInput extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  
  const PhoneInput({
    super.key,
    required this.controller,
    this.hintText = '请输入手机号',
    this.errorText,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<PhoneInput> createState() => _PhoneInputState();
}

class _PhoneInputState extends State<PhoneInput> {
  final FocusNode _focusNode = FocusNode();
  bool _hasFocus = false;

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

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              // 区号
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: AppColors.gray300, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '🇨🇳',
                      style: TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '+86',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.enabled ? AppColors.gray900 : AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              // 输入框
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
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
