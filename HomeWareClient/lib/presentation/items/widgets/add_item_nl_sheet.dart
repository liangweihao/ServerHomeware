import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assistant/add_item_nl_parser.dart';
import '../../../core/config/space_skin_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/space_skin_provider.dart';
import '../item_add_nl_prefill_storage.dart';

/// M5 — 一句话添加入库输入 Sheet
class AddItemNlSheet {
  AddItemNlSheet._();

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (ctx) => const _AddItemNlSheetBody(),
    );
  }
}

class _AddItemNlSheetBody extends ConsumerStatefulWidget {
  const _AddItemNlSheetBody();

  @override
  ConsumerState<_AddItemNlSheetBody> createState() => _AddItemNlSheetBodyState();
}

class _AddItemNlSheetBodyState extends ConsumerState<_AddItemNlSheetBody> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    debugPrint('[AddItemNlSheet] INFO: 解析 $text');
    final parsed = AddItemNlParser.parse(text);
    if (!parsed.isAddIntent) {
      final skin = ref.read(spaceSkinProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(skin.addItemParseFailed)),
      );
      return;
    }

    ItemAddNlPrefillStorage.save(parsed);
    Navigator.pop(context);
    context.push('/items/add?nlPrefill=1');
  }

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(spaceSkinProvider);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '说话添物品',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '用一句话描述，管管帮你预填进向导',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            focusNode: _focus,
            maxLines: 2,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: '例如：添加2瓶牛奶在冰箱',
              filled: true,
              fillColor: AppColors.gray100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: skin.addItemExamples
                .map(
                  (e) => ActionChip(
                    label: Text(e, style: const TextStyle(fontSize: 12)),
                    onPressed: () {
                      _controller.text = e;
                      _submit();
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _submit,
            child: const Text('解析并进入向导'),
          ),
        ],
      ),
    );
  }
}
