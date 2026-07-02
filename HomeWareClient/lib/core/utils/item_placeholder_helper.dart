import 'package:flutter/material.dart';

/// 无图物品占位 — emoji / 颜色 / 名称首字解析
class ItemPlaceholderHelper {
  ItemPlaceholderHelper._();

  /// 暖色兜底 palette（无分类色时使用）
  static const _fallbackPalette = <Color>[
    Color(0xFF5A7A52),
    Color(0xFF8B6914),
    Color(0xFF4A6B8A),
    Color(0xFF8B4A42),
    Color(0xFF6B5B95),
    Color(0xFF4A8B7A),
  ];

  /// 解析占位 emoji：优先分类 icon，其次名称启发式
  static String resolveEmoji({
    String? categoryIcon,
    required String itemName,
  }) {
    if (categoryIcon != null && categoryIcon.trim().isNotEmpty) {
      return categoryIcon.trim();
    }
    return _emojiFromName(itemName);
  }

  /// 名称首字（用于右下角识别角标）
  static String nameInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return String.fromCharCode(trimmed.runes.first);
  }

  /// 解析分类色；无则按 itemId 取固定暖色
  static Color resolveAccentColor({
    String? categoryColorHex,
    int itemId = 0,
  }) {
    return parseHexColor(categoryColorHex) ??
        _fallbackPalette[itemId.abs() % _fallbackPalette.length];
  }

  /// 解析 #RRGGBB 十六进制颜色
  static Color? parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) return null;
    return Color(int.parse('FF$normalized', radix: 16));
  }

  /// 名称关键词 → emoji（与物品列表逻辑对齐）
  static String _emojiFromName(String name) {
    if (name.contains('食') || name.contains('饮') || name.contains('奶')) {
      return '🍎';
    }
    if (name.contains('药')) return '💊';
    if (name.contains('衣') || name.contains('服')) return '👕';
    return '📦';
  }
}
