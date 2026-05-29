import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/providers/database_provider.dart';
import '../../core/services/item_service.dart';
import '../../core/services/upload_service.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_button.dart';
import 'item_form_controller.dart';
import 'item_form_view.dart';

/// 添加物品页（手动录入）
class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({super.key});

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  late final ItemFormController _form;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _form = ItemFormController();
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _notifyFormChanged() => setState(() {});

  Future<void> _saveAndExit() async {
    final saved = await _saveItem();
    if (saved && mounted) {
      context.pop();
    }
  }

  Future<void> _saveAndContinue() async {
    final saved = await _saveItem();
    if (saved && mounted) {
      _form.resetForNewEntry();
      _notifyFormChanged();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('保存成功！继续添加下一个')),
      );
    }
  }

  Future<bool> _saveItem() async {
    if (_isSaving) return false;
    if (!_form.validate()) {
      if (_form.selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请选择分类')),
        );
      }
      return false;
    }

    setState(() => _isSaving = true);

    try {
      // 1. 上传本地图片到服务端
      List<String> imageUrls = [];
      if (_form.imagePaths.isNotEmpty) {
        debugPrint('[AddItemPage] INFO: 开始上传 ${_form.imagePaths.length} 张图片');
        final uploadService = UploadService();
        imageUrls = await uploadService.uploadImages(_form.imagePaths);
        if (imageUrls.length != _form.imagePaths.length) {
          debugPrint('[AddItemPage] ERROR: 部分图片上传失败');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('图片上传失败，请重试')),
            );
          }
          return false;
        }
      }

      final body = _form.buildCreateApiBody(imageUrls: imageUrls);
      debugPrint('[AddItemPage] INFO: 创建物品 - ${body['name']}');

      final itemService = ItemService();
      final result = await itemService.createItem(body: body);

      if (result.code != 200 || result.data == null) {
        debugPrint('[AddItemPage] ERROR: 创建失败 - ${result.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result.message.isNotEmpty ? result.message : '保存失败',
              ),
            ),
          );
        }
        return false;
      }

      debugPrint('[AddItemPage] INFO: 服务端创建成功 id=${result.data!['id']}');
      await _saveItemLocally(result.data!);
      ref.invalidate(allItemsProvider);
      return true;
    } catch (e) {
      debugPrint('[AddItemPage] ERROR: 保存异常 - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveItemLocally(Map<String, dynamic> serverItem) async {
    final db = ref.read(databaseProvider);
    final serverIdRaw = serverItem['id'];
    final serverId = serverIdRaw is int
        ? serverIdRaw
        : int.tryParse(serverIdRaw?.toString() ?? '');

    // 从服务端响应提取图片 URL 写入本地
    final serverImages = serverItem['images'] as List<dynamic>?;
    final storedPaths = serverImages != null
        ? serverImages
            .map((e) => (e as Map<String, dynamic>)['url']?.toString() ?? '')
            .where((u) => u.isNotEmpty)
            .toList()
        : null;

    final companion = _form.buildInsertCompanion(
      serverId: serverId,
      imagePathsOverride: storedPaths,
    );
    final itemId = await db.insertItem(companion);

    await db.insertUsageRecord(
      UsageRecordsCompanion.insert(
        itemId: itemId,
        type: 0,
        quantity: _form.quantity,
        remainingQuantity: _form.quantity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加物品'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveAndExit,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('保存'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ItemFormView(
                  controller: _form,
                  onChanged: _notifyFormChanged,
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: AppButton(
                label: '保存入库',
                onPressed: _isSaving ? null : _saveAndExit,
                isFullWidth: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: '保存并继续',
                variant: ButtonVariant.secondary,
                onPressed: _isSaving ? null : _saveAndContinue,
                isFullWidth: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
