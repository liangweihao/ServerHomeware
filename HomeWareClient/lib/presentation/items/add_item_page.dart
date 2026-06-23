import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants/app_colors.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/item_service.dart';
import '../../core/services/upload_service.dart';
import '../../core/utils/item_image_storage.dart';
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
  int _formResetKey = 0;

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
      setState(() => _formResetKey++);
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

    // 0. 检查是否存在同名物品
    final name = _form.nameController.text.trim();
    if (name.isNotEmpty) {
      final db = ref.read(databaseProvider);
      final allItems = await db.getAllItems();
      final existing = allItems.where((item) =>
          item.name.toLowerCase() == name.toLowerCase() &&
          item.status == 0 // 只匹配使用中的物品
      ).toList();

      if (existing.isNotEmpty && mounted) {
        setState(() => _isSaving = false); // 先释放状态等弹窗
        final shouldUpdate = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('发现同名物品'),
            content: Text(
              '已存在「${existing.first.name}」'
              '${existing.length > 1 ? '等多${existing.length}件' : ''}，'
              '是否更新已有物品而不是新增？',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('仍然新增', style: TextStyle(color: AppColors.textSecondary)),
              ),
              AppButton(
                label: '去更新',
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
        );
        if (shouldUpdate == true && mounted) {
          context.push('/items/${existing.first.id}/edit');
          return false;
        }
        // 用户选择仍然新增 → 重新设置 loading 继续
        setState(() => _isSaving = true);
      }
    }

    try {
      // 1. 上传本地图片到服务端（物品图片 + 位置照片）
      final uploadService = UploadService();
      final allLocalPaths = [
        ..._form.imagePaths,
        ..._form.locationImagePaths,
      ];
      List<String> allUploadedUrls = [];
      if (allLocalPaths.isNotEmpty) {
        debugPrint('[AddItemPage] INFO: 开始上传 ${allLocalPaths.length} 张图片'
            '（物品${_form.imagePaths.length} + 位置${_form.locationImagePaths.length}）');
        allUploadedUrls = await uploadService.uploadImages(allLocalPaths);
        if (allUploadedUrls.length != allLocalPaths.length) {
          debugPrint('[AddItemPage] ERROR: 部分图片上传失败');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('图片上传失败，请重试')),
            );
          }
          return false;
        }
      }
      // 分离物品图片和位置照片的 URL
      final imageUrls = allUploadedUrls.sublist(0, _form.imagePaths.length);
      final locationUrls = allUploadedUrls.sublist(_form.imagePaths.length);

      final body = _form.buildCreateApiBody(
        imageUrls: imageUrls,
        locationImageUrls: locationUrls,
      );
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
      // 仅保存本次上传的图片路径，避免服务端历史孤儿图片污染本地封面
      final storedImagePaths = <String>[
        ...imageUrls,
        for (final url in locationUrls) '${ItemImageStorage.locPrefix}$url',
      ];
      await _saveItemLocally(result.data!, storedImagePaths: storedImagePaths);
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

  Future<void> _saveItemLocally(
    Map<String, dynamic> serverItem, {
    List<String>? storedImagePaths,
  }) async {
    final db = ref.read(databaseProvider);
    final serverIdRaw = serverItem['id'];
    final serverId = serverIdRaw is int
        ? serverIdRaw
        : int.tryParse(serverIdRaw?.toString() ?? '');

    // 优先使用本次上传的图片路径；无则回退服务端响应（兼容旧逻辑）
    List<String>? paths = storedImagePaths;
    if (paths == null || paths.isEmpty) {
      final serverImages = serverItem['images'] as List<dynamic>?;
      paths = serverImages
          ?.map((e) => (e as Map<String, dynamic>)['url']?.toString() ?? '')
          .where((u) => u.isNotEmpty)
          .toList();
    }

    final companion = _form.buildInsertCompanion(
      serverId: serverId,
      imagePathsOverride: paths?.isNotEmpty == true ? paths : null,
    );
    final itemId = await db.insertItem(companion);

    // 通知事件总线：物品已创建
    ref.read(itemEventBusProvider.notifier).notifyCreated(itemId: itemId);

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
      body: ColoredBox(
        color: AppColors.gray50,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ItemFormView(
                    key: ValueKey(_formResetKey),
                    controller: _form,
                    onChanged: _notifyFormChanged,
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
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
