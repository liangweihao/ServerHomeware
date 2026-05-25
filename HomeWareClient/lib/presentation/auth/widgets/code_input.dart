import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';

/// 验证码输入组件
class CodeInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final TextEditingController? controller;
  final String? errorText;
  final bool enabled;

  const CodeInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.controller,
    this.errorText,
    this.enabled = true,
  });

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  late final TextEditingController _controller;
  final List<FocusNode> _focusNodes = [];
  final List<String> _values = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
    
    for (int i = 0; i < widget.length; i++) {
      _focusNodes.add(FocusNode());
      _values.add('');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      for (int i = 0; i < widget.length; i++) {
        _values[i] = i < text.length ? text[i] : '';
      }
    });

    final currentIndex = text.length;
    if (currentIndex >= widget.length) {
      // 全部输入完成
      _focusNodes[widget.length - 1].unfocus();
      if (widget.onCompleted != null) {
        widget.onCompleted!(text);
      }
    } else if (currentIndex > 0 && currentIndex > _currentIndex) {
      // 向后输入，聚焦下一个
      _focusNodes[currentIndex].requestFocus();
    } else if (currentIndex < _currentIndex && currentIndex > 0) {
      // 向前删除，聚焦前一个
      _focusNodes[currentIndex - 1].requestFocus();
    }
    _currentIndex = currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // 隐藏的 TextField，用于处理输入
            Opacity(
              opacity: 0,
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                autofocus: true,
                enabled: widget.enabled,
              ),
            ),
            // 显示的输入框
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                widget.length,
                (index) => _CodeBox(
                  value: _values[index],
                  hasFocus: _currentIndex == index,
                  hasError: hasError,
                  enabled: widget.enabled,
                  onTap: () {
                    if (widget.enabled) {
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: _controller.text.length),
                      );
                      _focusNodes[index].requestFocus();
                    }
                  },
                  focusNode: _focusNodes[index],
                ),
              ),
            ),
          ],
        ),
        // 错误提示
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
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

/// 单个验证码输入框
class _CodeBox extends StatelessWidget {
  final String value;
  final bool hasFocus;
  final bool hasError;
  final bool enabled;
  final VoidCallback onTap;
  final FocusNode focusNode;

  const _CodeBox({
    required this.value,
    required this.hasFocus,
    required this.hasError,
    required this.enabled,
    required this.onTap,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? AppColors.white : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasError
                ? AppColors.danger
                : hasFocus
                ? AppColors.primary
                : AppColors.gray300,
            width: hasFocus || hasError ? 2 : 1,
          ),
          boxShadow: hasFocus
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.1),
                    blurRadius: 0,
                    spreadRadius: 3,
                  ),
                ]
              : [],
        ),
        child: Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: enabled ? AppColors.gray900 : AppColors.gray400,
          ),
        ),
      ),
    );
  }
}
