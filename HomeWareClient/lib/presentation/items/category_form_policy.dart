import '../../data/database/app_database.dart';
import 'item_form_controller.dart';

/// 录入页折叠分区
enum ItemFormSection {
  expiry,
  stock,
  purchase,
  locationDetail,
  more,
}

/// 分类 → 折叠展开策略与默认提醒（对齐 doc/design/add-item-redesign.md §四）
class CategoryFormPolicy {
  CategoryFormPolicy._();

  /// 首屏 Chip 固定展示的一级分类 ID
  static const pinnedTopLevelIds = [1, 2, 3, 4, 5, 7, 11];

  /// 包装级单位（首屏轻量露出「每 X 含」）
  static const packageLikeUnits = ['盒', '箱', '提', '板', '袋', '包', '瓶'];

  static const _expiryNames = {'宠物食品', '宠物药品', '奶粉/辅食'};
  static const _stockOnlyParentIds = {2, 3, 10, 11};
  static const _purchaseParentIds = {5, 9};
  static const _locationParentIds = {6, 7, 8, 12, 13, 14};

  /// 解析所属一级分类
  static Future<Category?> resolveTopLevel(Category category, AppDatabase db) async {
    var current = category;
    while (current.parentId != null) {
      final parent = await db.getCategoryById(current.parentId!);
      if (parent == null) break;
      current = parent;
    }
    return current;
  }

  /// 切换分类后应自动展开的主折叠；null 表示不自动展开
  static ItemFormSection? primarySection(Category category, Category topLevel) {
    if (_expiryNames.contains(category.name)) return ItemFormSection.expiry;
    if (category.name == '纸尿裤') return ItemFormSection.stock;

    switch (topLevel.id) {
      case 1:
      case 4:
        return ItemFormSection.expiry;
      case 2:
      case 3:
        return ItemFormSection.stock;
      case 5:
      case 9:
        return ItemFormSection.purchase;
      case 6:
      case 7:
      case 8:
      case 12:
      case 13:
      case 14:
        return ItemFormSection.locationDetail;
      case 10:
      case 11:
        return ItemFormSection.stock;
      case 15:
        return null;
      default:
        return null;
    }
  }

  /// 折叠显示顺序
  static List<ItemFormSection> sectionOrder(Category category, Category topLevel) {
    final primary = primarySection(category, topLevel);
    const all = ItemFormSection.values;

    if (primary == null) {
      return const [
        ItemFormSection.purchase,
        ItemFormSection.locationDetail,
        ItemFormSection.expiry,
        ItemFormSection.stock,
        ItemFormSection.more,
      ];
    }

    return [primary, ...all.where((s) => s != primary)];
  }

  /// 按分类写入默认提醒参数
  static void applyAlertDefaults(ItemFormController form, Category category, Category topLevel) {
    if (_expiryNames.contains(category.name) ||
        topLevel.id == 1 ||
        topLevel.id == 4) {
      form.expiryAlertDays = 7;
      form.safetyStock = 1;
      return;
    }
    if (_stockOnlyParentIds.contains(topLevel.id) || category.name == '纸尿裤') {
      form.expiryAlertDays = 3;
      form.safetyStock = 1;
      return;
    }
    if (_purchaseParentIds.contains(topLevel.id)) {
      form.expiryAlertDays = 3;
      form.safetyStock = 0;
      return;
    }
    form.expiryAlertDays = 3;
    form.safetyStock = 1;
  }

  static String sectionTitle(ItemFormSection section) {
    switch (section) {
      case ItemFormSection.expiry:
        return '保质期与过期';
      case ItemFormSection.stock:
        return '库存与补货';
      case ItemFormSection.purchase:
        return '购买记录';
      case ItemFormSection.locationDetail:
        return '存放详情';
      case ItemFormSection.more:
        return '更多';
    }
  }

  /// 折叠收起时的摘要文案
  static String sectionSummary(ItemFormSection section, ItemFormController c) {
    switch (section) {
      case ItemFormSection.expiry:
        if (c.expiryDate != null) {
          return '${c.formatApiDate(c.expiryDate!)} 到期';
        }
        return '未设置';
      case ItemFormSection.stock:
        return '低于 ${c.safetyStock.toStringAsFixed(0)} ${c.unit} 提醒';
      case ItemFormSection.purchase:
        final parts = <String>[];
        final price = double.tryParse(c.priceController.text);
        if (price != null) parts.add('¥${price.toStringAsFixed(1)}');
        if (c.purchaseChannel != null && c.purchaseChannel!.isNotEmpty) {
          parts.add(c.purchaseChannel!);
        }
        if (c.brandController.text.isNotEmpty) parts.add(c.brandController.text.trim());
        return parts.isEmpty ? '未填写' : parts.join(' · ');
      case ItemFormSection.locationDetail:
        if (c.containerName != null && c.containerName!.isNotEmpty) {
          return c.containerName!;
        }
        if (c.locationImagePaths.isNotEmpty) {
          return '已 ${c.locationImagePaths.length} 张位置照片';
        }
        return '未填写';
      case ItemFormSection.more:
        if (c.notesController.text.isNotEmpty) return c.notesController.text.trim();
        return '无备注';
    }
  }
}
