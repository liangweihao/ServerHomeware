import 'package:flutter/foundation.dart';

import '../../../core/models/home_section.dart';
import '../../../core/utils/item_image_storage.dart';
import '../../../data/database/app_database.dart';

/// 首页分区物品数据补全 — 封面图 + 分类 icon/颜色（本地 Drift）
class HomeSectionImageEnricher {
  HomeSectionImageEnricher(this._db);

  final AppDatabase _db;

  /// 批量补全：API 缺字段时从本地库读取
  Future<List<HomeSectionItem>> enrichItems(List<HomeSectionItem> items) async {
    if (items.isEmpty) return items;

    final enriched = <HomeSectionItem>[];
    var imageFilled = 0;
    var categoryFilled = 0;

    for (final item in items) {
      enriched.add(await _enrichOne(item, onImageFilled: () => imageFilled++,
          onCategoryFilled: () => categoryFilled++));
    }

    if (imageFilled > 0 || categoryFilled > 0) {
      debugPrint(
        '[HomeSectionImageEnricher] INFO: 本地补全 封面=$imageFilled 分类=$categoryFilled/${items.length}',
      );
    }
    return enriched;
  }

  Future<HomeSectionItem> _enrichOne(
    HomeSectionItem item, {
    required VoidCallback onImageFilled,
    required VoidCallback onCategoryFilled,
  }) async {
    var updated = item;
    final local = await _db.getItemById(item.id);
    if (local == null) return updated;

    // 补全封面
    if (!_hasPreview(updated.previewImage)) {
      final sources = ItemImageStorage.resolveDisplaySources(local.images);
      if (sources.isNotEmpty) {
        updated = updated.copyWith(previewImage: sources.first);
        onImageFilled();
      }
    }

    // 补全分类 icon / 颜色（无图占位用）
    if (_needsCategoryMeta(updated)) {
      final cat = await _db.getCategoryById(local.categoryId);
      if (cat != null) {
        updated = updated.copyWith(
          categoryName: updated.categoryName ?? cat.name,
          categoryIcon: updated.categoryIcon ?? cat.icon,
          categoryColorHex: updated.categoryColorHex ?? cat.color,
        );
        onCategoryFilled();
      }
    }

    return updated;
  }

  bool _hasPreview(String? preview) =>
      preview != null && preview.trim().isNotEmpty;

  bool _needsCategoryMeta(HomeSectionItem item) =>
      item.categoryIcon == null ||
      item.categoryIcon!.isEmpty ||
      item.categoryColorHex == null ||
      item.categoryColorHex!.isEmpty;
}
