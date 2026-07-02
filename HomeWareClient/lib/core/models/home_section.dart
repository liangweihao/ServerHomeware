import 'package:flutter/material.dart';

/// 首页横向分区类型
enum HomeSectionType {
  /// 已过期
  expired,
  /// 临期（7 天内）
  expiringSoon,
  /// 库存不足
  lowStock,
  /// 全部 — 按最近入库排序
  recentAll,
}

/// 首页分区展示配置
class HomeSectionConfig {
  const HomeSectionConfig({
    required this.type,
    required this.title,
    required this.routeSection,
    required this.icon,
    required this.accentColor,
    required this.subtitle,
  });

  final HomeSectionType type;
  final String title;

  /// 查看全部路由 segment：/home/section/:routeSection
  final String routeSection;

  /// 分区标题左侧图标
  final IconData icon;

  /// 图标容器强调色
  final Color accentColor;

  /// 标题下方固定副文案（统一头部高度）
  final String subtitle;

  static const configs = <HomeSectionConfig>[
    HomeSectionConfig(
      type: HomeSectionType.expired,
      title: '已过期',
      routeSection: 'expired',
      icon: Icons.event_busy_outlined,
      accentColor: Color(0xFF8B4A42),
      subtitle: '需尽快处理',
    ),
    HomeSectionConfig(
      type: HomeSectionType.expiringSoon,
      title: '临期',
      routeSection: 'expiring',
      icon: Icons.schedule_outlined,
      accentColor: Color(0xFF8B6914),
      subtitle: '7 天内到期',
    ),
    HomeSectionConfig(
      type: HomeSectionType.lowStock,
      title: '库存不足',
      routeSection: 'low_stock',
      icon: Icons.inventory_2_outlined,
      accentColor: Color(0xFF4A6B8A),
      subtitle: '需要补货',
    ),
    HomeSectionConfig(
      type: HomeSectionType.recentAll,
      title: '全部',
      routeSection: 'all',
      icon: Icons.apps_outlined,
      accentColor: Color(0xFF5A7A52),
      subtitle: '最近入库',
    ),
  ];
}

/// 首页横向卡片数据（来自 API）
class HomeSectionItem {
  const HomeSectionItem({
    required this.id,
    required this.name,
    required this.tagLabel,
    required this.tagColor,
    required this.tagBackground,
    this.previewImage,
    this.categoryName,
    this.categoryIcon,
    this.categoryColorHex,
    this.locationPath,
  });

  final int id;
  final String name;
  final String tagLabel;
  final Color tagColor;
  final Color tagBackground;
  final String? previewImage;
  final String? categoryName;

  /// 分类 emoji（无图占位用）
  final String? categoryIcon;

  /// 分类色 #RRGGBB（无图占位用）
  final String? categoryColorHex;

  final String? locationPath;

  /// 从过期接口 JSON 解析
  factory HomeSectionItem.fromExpiredJson(Map<String, dynamic> json) {
    final days = json['days_overdue'] as int? ?? 0;
    return HomeSectionItem(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      tagLabel: days > 0 ? '已过期 $days 天' : '已过期',
      tagColor: const Color(0xFF8B4A42),
      tagBackground: const Color(0xFFF5E8E6),
      previewImage: json['preview_image']?.toString(),
      categoryName: json['category_name']?.toString(),
      locationPath: json['location_path']?.toString(),
    );
  }

  /// 从临期接口 JSON 解析
  factory HomeSectionItem.fromExpiringJson(Map<String, dynamic> json) {
    final days = json['days_until_expiry'] as int? ?? 0;
    final label = days == 0 ? '今天过期' : '还剩 $days 天';
    return HomeSectionItem(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      tagLabel: label,
      tagColor: const Color(0xFF8B6914),
      tagBackground: const Color(0xFFF5F0E0),
      previewImage: json['preview_image']?.toString(),
      categoryName: json['category_name']?.toString(),
      locationPath: json['location_path']?.toString(),
    );
  }

  /// 从库存不足接口 JSON 解析
  factory HomeSectionItem.fromLowStockJson(Map<String, dynamic> json) {
    final qty = json['current_quantity'];
    final unit = json['unit']?.toString() ?? '件';
    return HomeSectionItem(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      tagLabel: '剩余 $qty $unit',
      tagColor: const Color(0xFF4A6B8A),
      tagBackground: const Color(0xFFE6EDF5),
      previewImage: json['preview_image']?.toString(),
      categoryName: json['category_name']?.toString(),
      locationPath: json['location_path']?.toString(),
    );
  }

  /// 从物品列表接口 JSON 解析（最近入库）
  factory HomeSectionItem.fromItemJson(Map<String, dynamic> json) {
    final category = json['category_name']?.toString();
    return HomeSectionItem(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      tagLabel: category != null && category.isNotEmpty ? category : '新入库',
      tagColor: const Color(0xFF5A7A52),
      tagBackground: const Color(0xFFE8F0E6),
      previewImage: json['preview_image']?.toString(),
      categoryName: category,
      locationPath: json['location_full_path']?.toString(),
    );
  }

  /// 复制并替换字段（本地 DB 补全时使用）
  HomeSectionItem copyWith({
    String? previewImage,
    String? categoryName,
    String? categoryIcon,
    String? categoryColorHex,
  }) {
    return HomeSectionItem(
      id: id,
      name: name,
      tagLabel: tagLabel,
      tagColor: tagColor,
      tagBackground: tagBackground,
      previewImage: previewImage ?? this.previewImage,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColorHex: categoryColorHex ?? this.categoryColorHex,
      locationPath: locationPath,
    );
  }

  /// 从物品列表 JSON 解析为已过期卡片（客户端筛选回退）
  factory HomeSectionItem.fromItemJsonAsExpired(Map<String, dynamic> json) {
    final expiryRaw = json['expiry_date']?.toString();
    var daysOverdue = 0;
    if (expiryRaw != null && expiryRaw.isNotEmpty) {
      final expiry = DateTime.tryParse(expiryRaw);
      if (expiry != null) {
        final today = DateTime.now();
        final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
        final todayDay = DateTime(today.year, today.month, today.day);
        daysOverdue = todayDay.difference(expiryDay).inDays;
      }
    }
    return HomeSectionItem(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      tagLabel: daysOverdue > 0 ? '已过期 $daysOverdue 天' : '已过期',
      tagColor: const Color(0xFF8B4A42),
      tagBackground: const Color(0xFFF5E8E6),
      previewImage: json['preview_image']?.toString(),
      categoryName: json['category_name']?.toString(),
      locationPath: json['location_full_path']?.toString(),
    );
  }
}

/// 单个首页分区加载结果
class HomeSectionData {
  const HomeSectionData({
    required this.config,
    required this.items,
    this.errorMessage,
  });

  final HomeSectionConfig config;
  final List<HomeSectionItem> items;
  final String? errorMessage;

  bool get hasError => errorMessage != null;
  bool get isEmpty => items.isEmpty && !hasError;
}
