import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/item_enrich_service.dart';
import '../item_form_controller.dart';

/// 备注输入框 + 魔法按钮（根据已填信息生成备注与检索别名）
class NotesMagicField extends StatefulWidget {
  const NotesMagicField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.maxLines = 3,
    this.labelText = '备注（可选）',
    this.hintText = '例如：超市促销购入、开封后需冷藏',
  });

  final ItemFormController controller;
  final VoidCallback onChanged;
  final int maxLines;
  final String labelText;
  final String hintText;

  @override
  State<NotesMagicField> createState() => _NotesMagicFieldState();
}

class _NotesMagicFieldState extends State<NotesMagicField> {
  bool _loading = false;

  Future<void> _onMagicTap() async {
    final c = widget.controller;
    final name = c.nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先填写物品名称，再使用魔法备注')),
      );
      return;
    }
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final result = await const ItemEnrichService().enrichDraft(
        name: name,
        brand: c.brandController.text,
        categoryName: c.selectedCategory?.name,
        existingNotes: c.notesController.text,
      );
      if (!mounted) return;
      if (result == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('魔法备注生成失败，请稍后再试')),
        );
        return;
      }
      c.notesController.text = result.notes;
      c.searchAliases = result.searchAliases;
      widget.onChanged();
      final aliasHint = result.searchAliases.isEmpty
          ? ''
          : '，并准备了检索词：${result.searchAliases.take(3).join('、')}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已生成备注$aliasHint')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller.notesController,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        alignLabelWithHint: true,
        suffixIcon: IconButton(
          tooltip: '魔法备注：根据已填信息生成',
          onPressed: _loading ? null : _onMagicTap,
          icon: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : CandyIcon(
                  Icons.auto_awesome,
                  size: 22,
                  color: AppColors.primary,
                ),
        ),
      ),
      onChanged: (_) => widget.onChanged(),
    );
  }
}
