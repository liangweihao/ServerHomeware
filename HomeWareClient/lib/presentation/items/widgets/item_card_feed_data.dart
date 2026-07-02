import 'package:flutter/material.dart';

import '../../../core/models/home_section.dart';
import '../../../core/utils/item_list_reason_helper.dart';
import '../../../data/database/app_database.dart';
import '../../../core/utils/item_image_storage.dart';

/// 物品 Feed 卡统一展示数据 — 首页分区 / 搜索推荐 / 列表网格共用
class ItemCardFeedData {
  const ItemCardFeedData({
    required this.id,
    required this.name,
    required this.tagLabel,
    required this.tagColor,
    required this.tagBackground,
    this.locationPath,
    this.previewImage,
    this.categoryIcon,
    this.categoryColorHex,
  });

  final int id;
  final String name;
  final String tagLabel;
  final Color tagColor;
  final Color tagBackground;
  final String? locationPath;
  final String? previewImage;
  final String? categoryIcon;
  final String? categoryColorHex;

  /// 从首页分区 API 模型解析
  factory ItemCardFeedData.fromHomeSection(HomeSectionItem item) {
    return ItemCardFeedData(
      id: item.id,
      name: item.name,
      tagLabel: item.tagLabel,
      tagColor: item.tagColor,
      tagBackground: item.tagBackground,
      locationPath: item.locationPath,
      previewImage: item.previewImage,
      categoryIcon: item.categoryIcon,
      categoryColorHex: item.categoryColorHex,
    );
  }

  /// 从本地 Item + 列表理由生成（网格 / 竖向列表）
  factory ItemCardFeedData.fromItem(
    Item item, {
    String? locationName,
    ItemListReason? reason,
    String? categoryIcon,
    String? categoryColorHex,
  }) {
    final listReason = reason ?? computeItemListReason(item);
    final sources = ItemImageStorage.resolveDisplaySources(item.images);
    final preview = sources.isNotEmpty ? sources.first : null;

    return ItemCardFeedData(
      id: item.id,
      name: item.name,
      tagLabel: listReason.label,
      tagColor: listReason.color,
      tagBackground: listReason.color.withValues(alpha: 0.12),
      locationPath: locationName,
      previewImage: preview,
      categoryIcon: categoryIcon,
      categoryColorHex: categoryColorHex,
    );
  }

  /// 占位图 emoji
  String get placeholderEmoji {
    final n = name;
    if (n.contains('食') || n.contains('饮') || n.contains('奶')) return '🍎';
    if (n.contains('药')) return '💊';
    if (n.contains('衣') || n.contains('服')) return '👕';
    return categoryIcon ?? '📦';
  }

  Color? get categoryColor {
    final hex = categoryColorHex;
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) return null;
    return Color(int.parse('FF$normalized', radix: 16));
  }
}
