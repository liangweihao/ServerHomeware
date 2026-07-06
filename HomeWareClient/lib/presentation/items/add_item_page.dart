import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/constants/app_colors.dart';
import '../../core/assistant/guanguan_copy.dart';
import '../../core/events/item_event_bus.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/barcode_service.dart';
import '../../core/services/item_id_resolver.dart';
import '../../core/services/item_service.dart';
import '../../core/services/upload_service.dart';
import '../../core/services/usage_record_sync_service.dart';
import '../../core/utils/item_image_storage.dart';
import '../../core/utils/usage_operator_helper.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_button.dart';
import '../common/widgets/warm_scaffold.dart';
import 'category_form_policy.dart';
import 'item_add_draft_storage.dart';
import 'add_item_nl_applier.dart';
import 'item_add_nl_prefill_storage.dart';
import 'item_form_controller.dart';
import 'widgets/add_item_wizard_view.dart';

/// 添加物品页 — 支持扫码预填与分步向导
class AddItemPage extends ConsumerStatefulWidget {
  const AddItemPage({
    super.key,
    this.initialBarcode,
    this.initialName,
    this.initialStep,
    this.resumeDraft = false,
    this.nlPrefill = false,
  });

  /// 路由 query `barcode` — 扫码跳转预填
  final String? initialBarcode;

  /// 路由 query `name` — 搜索无结果跳转预填物品名
  final String? initialName;

  /// 路由 query `step` — 指定起始向导步（如扫码后进 location）
  final AddItemWizardStep? initialStep;

  /// 路由 query `resumeDraft=1` — 直接恢复草稿
  final bool resumeDraft;

  /// 路由 query `nlPrefill=1` — M5 规则 NL 一句话预填
  final bool nlPrefill;

  @override
  ConsumerState<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends ConsumerState<AddItemPage> {
  late final ItemFormController _form;
  bool _isSaving = false;
  bool _isLookingUpBarcode = false;
  bool _savedSuccessfully = false;
  String? _prefillHint;
  int _formResetKey = 0;
  AddItemWizardStep _currentStep = AddItemWizardStep.category;
  /// 扫码预填成功时，指示器将此前步骤标记为已完成
  AddItemWizardStep? _completedThroughStep;

  static const _steps = AddItemWizardStep.values;

  @override
  void initState() {
    super.initState();
    _form = ItemFormController();
    _applyInitialName();
    if (widget.initialStep != null) {
      _currentStep = widget.initialStep!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.nlPrefill) {
        await _applyNlPrefill();
      } else if (widget.resumeDraft) {
        await _restoreDraft(force: true);
      } else if (widget.initialBarcode?.trim().isNotEmpty == true) {
        await _handleBarcodeDraftConflict();
      } else {
        await _offerRestoreDraft();
      }
      if (mounted && !widget.nlPrefill) {
        await _handleInitialBarcode();
      }
    });
  }

  /// M5 — 应用规则 NL 预填并跳到合适向导步
  Future<void> _applyNlPrefill() async {
    final parsed = ItemAddNlPrefillStorage.take();
    if (parsed == null || !parsed.isAddIntent) {
      debugPrint('[AddItemPage] WARN: nlPrefill 无有效数据');
      if (mounted) {
        setState(() => _prefillHint = GuanguanCopy.addItemParseFailed);
      }
      return;
    }

    final db = ref.read(databaseProvider);
    final outcome = await applyAddItemNlPrefill(
      parsed: parsed,
      form: _form,
      db: db,
    );

    if (!mounted) return;
    setState(() {
      _prefillHint = outcome.hintMessage;
      _currentStep = outcome.startStep;
      _completedThroughStep = outcome.completedThroughStep;
      _formResetKey++;
    });
    debugPrint(
      '[AddItemPage] INFO: NL 预填 step=${outcome.startStep} '
      'applied=${outcome.appliedFields}',
    );
  }

  /// 搜索无结果跳转时预填物品名称
  void _applyInitialName() {
    final name = widget.initialName?.trim();
    if (name == null || name.isEmpty) return;
    _form.nameController.text = name;
    debugPrint('[AddItemPage] INFO: 预填物品名称 name=$name');
  }

  /// 扫码进入时若存在草稿，提示是否覆盖
  Future<void> _handleBarcodeDraftConflict() async {
    if (!await ItemAddDraftStorage.hasDraft() || !mounted) return;
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('发现未完成录入'),
        content: const Text('继续扫码将覆盖上次草稿，是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'draft'),
            child: const Text('恢复草稿'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'scan'),
            child: const Text('继续扫码'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'draft') {
      await _restoreDraft(force: true);
    } else if (action == 'scan') {
      await ItemAddDraftStorage.clear();
    }
  }

  /// 进入时询问是否恢复草稿
  Future<void> _offerRestoreDraft() async {
    if (!await ItemAddDraftStorage.hasDraft() || !mounted) return;
    final restore = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('发现未完成录入'),
        content: const Text('是否继续上次的添加入库？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('重新开始'),
          ),
          AppButton(
            label: '继续录入',
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (restore == true) {
      await _restoreDraft(force: true);
    } else {
      await ItemAddDraftStorage.clear();
    }
  }

  Future<void> _restoreDraft({required bool force}) async {
    final map = await ItemAddDraftStorage.load();
    if (map == null || !mounted) return;
    final db = ref.read(databaseProvider);
    await _form.applyDraftMap(map, db);
    final stepIndex = (map['wizardStep'] as int?) ?? 0;
    setState(() {
      _currentStep = AddItemWizardStep.values[
          stepIndex.clamp(0, AddItemWizardStep.values.length - 1)];
      _prefillHint = '已恢复未完成录入';
      _formResetKey++;
    });
    debugPrint('[AddItemPage] INFO: 恢复草稿 step=$_currentStep');
  }

  Future<void> _saveDraftIfNeeded() async {
    if (_savedSuccessfully || !_form.hasDraftContent) return;
    await ItemAddDraftStorage.save(
      _form.toDraftMap(wizardStepIndex: _currentStep.index),
    );
  }

  /// 扫码进入：查询条码并预填，尽量跳到「位置」步（10 秒录入）
  Future<void> _handleInitialBarcode() async {
    final code = widget.initialBarcode?.trim();
    if (code == null || code.isEmpty || !mounted) return;
    if (_prefillHint == '已恢复未完成录入') return;

    setState(() => _isLookingUpBarcode = true);
    debugPrint('[AddItemPage] INFO: 扫码预填 barcode=$code');

    try {
      // 本地条码命中优先
      final db = ref.read(databaseProvider);
      final localItems = await db.getAllItems();
      final localHit = localItems
          .where((i) => i.barcode == code && i.status == 0)
          .toList();
      if (localHit.isNotEmpty && mounted) {
        await _showExistingBarcodeDialog(localHit.first.id, localHit.first.name);
        return;
      }

      final result = await BarcodeService().lookup(code);
      if (!mounted) return;

      if (result.alreadyExists && result.existingItemId != null) {
        await _showExistingBarcodeDialog(
          result.existingItemId!,
          result.existingItemName ?? '该物品',
        );
        return;
      }

      _form.barcode = code;

      if (result.hasProductHint) {
        _form.nameController.text = result.productName!.trim();
        if (result.brand != null && result.brand!.isNotEmpty) {
          _form.brandController.text = result.brand!.trim();
        }
        if (result.imageUrl != null && result.imageUrl!.startsWith('http')) {
          _form.imagePaths = [result.imageUrl!];
        }
        await _applyDefaultFoodCategory();
        setState(() {
          _prefillHint = result.source == 'open_food_facts'
              ? '已识别商品信息，请确认位置与过期日'
              : '已预填商品信息';
          _currentStep = AddItemWizardStep.location;
          _completedThroughStep = AddItemWizardStep.basic;
        });
      } else {
        setState(() {
          _prefillHint = '未识别该条码，请手动填写名称';
          _currentStep = AddItemWizardStep.basic;
          _completedThroughStep = null;
        });
      }
    } catch (e) {
      debugPrint('[AddItemPage] ERROR: 条码查询失败 $e');
      if (mounted) {
        _form.barcode = code;
        setState(() {
          _prefillHint = '条码查询失败，请手动填写';
          _currentStep = AddItemWizardStep.basic;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLookingUpBarcode = false);
      }
    }
  }

  Future<void> _applyDefaultFoodCategory() async {
    final db = ref.read(databaseProvider);
    final tops = await db.getTopLevelCategories();
    final food = tops.where((c) => c.name == '食品饮料').firstOrNull ??
        tops.where((c) => c.id == 1).firstOrNull;
    if (food == null) return;
    _form.selectedCategory = food;
    CategoryFormPolicy.applyAlertDefaults(_form, food, food);
  }

  Future<void> _showExistingBarcodeDialog(int itemId, String name) async {
    if (!mounted) return;
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('家里已有该条码'),
        content: Text('「$name」已入库，要查看还是再记一件？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'add'),
            child: const Text('再记一件'),
          ),
          AppButton(
            label: '查看物品',
            onPressed: () => Navigator.pop(ctx, 'view'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'view') {
      context.pop();
      context.push('/items/$itemId');
      return;
    }
    // 再记一件：沿用同款信息，只需确认位置与数量
    final db = ref.read(databaseProvider);
    final item = await db.getItemById(itemId);
    if (item != null) {
      final category = await db.getCategoryById(item.categoryId);
      final location =
          item.locationId != null ? await db.getLocationById(item.locationId!) : null;
      _form.loadFromItem(item: item, category: category, location: location);
      _form.barcode = widget.initialBarcode ?? item.barcode;
      _form.quantity = 1;
      _form.editCurrentQuantity = null;
    } else {
      _form.barcode = widget.initialBarcode;
    }
    if (!mounted) return;
    setState(() {
      _prefillHint = '为同款商品新增一件，请确认位置';
      _currentStep = AddItemWizardStep.location;
      _completedThroughStep = AddItemWizardStep.basic;
    });
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  void _notifyFormChanged() => setState(() {});

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case AddItemWizardStep.category:
        if (_form.selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请选择分类')),
          );
          return false;
        }
        return true;
      case AddItemWizardStep.basic:
        if (_form.nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('请输入物品名称')),
          );
          return false;
        }
        return true;
      case AddItemWizardStep.location:
      case AddItemWizardStep.expiry:
        return true;
    }
  }

  void _goNextStep() {
    if (!_validateCurrentStep()) return;
    final idx = _currentStep.index;
    if (idx < _steps.length - 1) {
      setState(() => _currentStep = _steps[idx + 1]);
      debugPrint('[AddItemPage] INFO: 进入步骤 ${_currentStep.name}');
    }
  }

  void _goPrevStep() {
    final idx = _currentStep.index;
    if (idx > 0) {
      setState(() => _currentStep = _steps[idx - 1]);
    }
  }

  bool _validateAllStepsForSave() {
    if (_form.selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择分类')),
      );
      // 扫码跳过 Step1 时，回到「信息」步选分类
      setState(() {
        _currentStep = _completedThroughStep != null
            ? AddItemWizardStep.basic
            : AddItemWizardStep.category;
      });
      return false;
    }
    if (_form.nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入物品名称')),
      );
      setState(() => _currentStep = AddItemWizardStep.basic);
      return false;
    }
    return true;
  }

  Future<void> _saveAndExit() async {
    if (!_validateAllStepsForSave()) return;
    final saved = await _saveItem();
    if (saved && mounted) {
      await _navigateAfterSuccessfulSave(continueAdding: false);
    }
  }

  Future<void> _saveAndContinue() async {
    if (!_validateAllStepsForSave()) return;
    final saved = await _saveItem();
    if (saved && mounted) {
      await _navigateAfterSuccessfulSave(continueAdding: true);
    }
  }

  /// 保存成功后的反馈与导航（扫码 go 进入时 pop 无效，需 fallback）
  Future<void> _navigateAfterSuccessfulSave({
    required bool continueAdding,
  }) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          continueAdding ? '保存成功！继续添加下一个' : '保存成功',
        ),
      ),
    );

    if (continueAdding) {
      _form.resetForNewEntry();
      setState(() {
        _formResetKey++;
        _currentStep = AddItemWizardStep.category;
        _completedThroughStep = null;
        _prefillHint = null;
      });
      _notifyFormChanged();
      debugPrint('[AddItemPage] INFO: 保存成功，继续添加下一件');
      return;
    }

    // 扫码等场景用 go 进入，栈上无可 pop 路由
    if (context.canPop()) {
      debugPrint('[AddItemPage] INFO: 保存成功，返回上一页');
      context.pop();
      return;
    }

    debugPrint('[AddItemPage] INFO: 保存成功，跳转物品列表');
    context.go('/items');
  }

  Future<bool> _saveItem() async {
    if (_isSaving) return false;
    if (!_validateAllStepsForSave()) return false;

    setState(() => _isSaving = true);

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
      await ItemAddDraftStorage.clear();
      _savedSuccessfully = true;
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

    // 若 WS 已抢先同步写入同 id，改为更新避免 UNIQUE 冲突
    if (serverId != null) {
      final synced = await db.getItemById(serverId);
      if (synced != null) {
        debugPrint(
          '[AddItemPage] INFO: WS 已同步物品 id=$serverId，合并表单数据',
        );
        if (paths != null && paths.isNotEmpty) {
          _form.imagePaths = paths
              .where((p) => !p.startsWith(ItemImageStorage.locPrefix))
              .toList();
          _form.locationImagePaths = paths
              .where((p) => p.startsWith(ItemImageStorage.locPrefix))
              .map((p) => p.substring(ItemImageStorage.locPrefix.length))
              .toList();
        }
        final updated = _form.applyToExistingItem(synced);
        await db.updateItem(updated);
        await ItemIdResolver(db).bind(
          localItemId: serverId,
          serverItemId: serverId,
        );
        ref.read(itemEventBusProvider.notifier).notifyUpdated(itemId: serverId);
        final usages = await db.getUsageRecordsByItem(serverId, limit: 1);
        if (usages.isEmpty) {
          final operator = resolveUsageOperatorName(ref);
          await UsageRecordSyncService(db).recordAndSync(
            itemId: serverId,
            type: 0,
            quantity: _form.quantity,
            remainingQuantity: _form.quantity,
            operatorName: operator,
            notes: '入库',
          );
        }
        return;
      }
    }

    final companion = _form.buildInsertCompanion(
      serverId: serverId,
      imagePathsOverride: paths?.isNotEmpty == true ? paths : null,
    );
    final itemId = await db.insertItem(companion);
    if (serverId != null) {
      await ItemIdResolver(db).bind(
        localItemId: itemId,
        serverItemId: serverId,
      );
    }

    // 通知事件总线：物品已创建
    ref.read(itemEventBusProvider.notifier).notifyCreated(itemId: itemId);

    final operator = resolveUsageOperatorName(ref);
    await UsageRecordSyncService(db).recordAndSync(
      itemId: itemId,
      type: 0,
      quantity: _form.quantity,
      remainingQuantity: _form.quantity,
      operatorName: operator,
      notes: '入库',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == AddItemWizardStep.expiry;
    final isFirstStep = _currentStep == AddItemWizardStep.category;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _saveDraftIfNeeded();
        if (context.mounted) context.pop();
      },
      child: WarmScaffold(
      title: '添加入库',
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                if (_prefillHint != null) _buildPrefillBanner(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: AppCard(
                      child: AddItemWizardView(
                        key: ValueKey(_formResetKey),
                        controller: _form,
                        currentStep: _currentStep,
                        completedThroughStep: _completedThroughStep,
                        onChanged: _notifyFormChanged,
                      ),
                    ),
                  ),
                ),
                _buildWizardNav(isFirstStep, isLastStep),
              ],
            ),
          ),
          if (_isLookingUpBarcode)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.2),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      '正在保存…',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }

  Widget _buildPrefillBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.infoBannerBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.homeDivider),
      ),
      child: Row(
        children: [
          CandyIcon(
            widget.nlPrefill ? Icons.mic_none_outlined : Icons.qr_code_2,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _prefillHint!,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWizardNav(bool isFirstStep, bool isLastStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
          if (!isFirstStep)
            Expanded(
              child: AppButton(
                label: '上一步',
                variant: ButtonVariant.outline,
                onPressed: _isSaving ? null : _goPrevStep,
                isFullWidth: true,
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: AppButton(
              label: isLastStep ? '保存入库' : '下一步',
              onPressed: _isSaving
                  ? null
                  : () {
                      if (isLastStep) {
                        _saveAndExit();
                      } else {
                        _goNextStep();
                      }
                    },
              isFullWidth: true,
            ),
          ),
          if (isLastStep) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: _isSaving ? null : _saveAndContinue,
              child: const Text('继续添加'),
            ),
          ],
        ],
      ),
    );
  }
}
