import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// 预置图标解析结果
class PresetIconResolved {
  const PresetIconResolved({
    required this.icon,
    required this.accent,
    required this.storageKey,
  });

  final IconData icon;
  final Color accent;
  /// 写入 DB 的 emoji 键（兼容旧数据）
  final String storageKey;
}

/// 可选预置项 — 用于分类/位置选择器
class PresetIconOption {
  const PresetIconOption({
    required this.storageKey,
    required this.icon,
    required this.accent,
    this.label,
  });

  final String storageKey;
  final IconData icon;
  final Color accent;
  final String? label;
}

/// 分类/空间预置图标注册表 — emoji 存储 + 圆润 Material 渲染
abstract final class PresetIconRegistry {
  /// 解析展示用图标（优先 emoji，其次中文名称）
  static PresetIconResolved resolve({
    String? storageKey,
    String? name,
    String? accentHex,
  }) {
    final key = storageKey?.trim();
    if (key != null && key.isNotEmpty) {
      final hit = _emojiMap[key];
      if (hit != null) {
        return PresetIconResolved(
          icon: hit.$1,
          accent: _accentFromHex(accentHex) ?? hit.$2,
          storageKey: key,
        );
      }
    }

    if (name != null && name.isNotEmpty) {
      for (final entry in _nameHints.entries) {
        if (name.contains(entry.key)) {
          return PresetIconResolved(
            icon: entry.value.$1,
            accent: _accentFromHex(accentHex) ?? entry.value.$2,
            storageKey: key ?? entry.value.$3,
          );
        }
      }
    }

    return PresetIconResolved(
      icon: Icons.category_rounded,
      accent: _accentFromHex(accentHex) ?? AppColors.gray500,
      storageKey: key ?? '📦',
    );
  }

  /// 分类选择器预置列表
  static List<PresetIconOption> get categoryPickerOptions => _categoryPicker;

  /// 空间/位置选择器预置列表
  static List<PresetIconOption> get locationPickerOptions => _locationPicker;

  static Color? _accentFromHex(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) return null;
    return Color(int.parse('FF$normalized', radix: 16));
  }

  // emoji → (IconData, defaultAccent, fallback storage if needed)
  static final _emojiMap = <String, (IconData, Color)>{
    // —— 空间/位置 ——
    '🏠': (Icons.home_rounded, AppColors.accentCoral),
    '🍳': (Icons.restaurant_rounded, AppColors.accentAmber),
    '🛁': (Icons.bathtub_rounded, AppColors.accentTeal),
    '🛋️': (Icons.weekend_rounded, AppColors.accentViolet),
    '🛏️': (Icons.bed_rounded, AppColors.accentRose),
    '☀️': (Icons.wb_sunny_rounded, AppColors.accentAmber),
    '📦': (Icons.inventory_2_rounded, AppColors.accentCoral),
    '🗄️': (Icons.archive_rounded, AppColors.accentViolet),
    '🏪': (Icons.storefront_rounded, AppColors.accentCoral),
    '🧾': (Icons.receipt_long_rounded, AppColors.accentSky),
    '🅰️': (Icons.looks_one_rounded, AppColors.accentSky),
    '🅱️': (Icons.looks_two_rounded, AppColors.accentTeal),
    '🧊': (Icons.ac_unit_rounded, AppColors.accentSky),
    '📍': (Icons.place_rounded, AppColors.accentRose),
    '🚿': (Icons.shower_rounded, AppColors.accentTeal),
    '🚽': (Icons.wc_rounded, AppColors.accentTeal),
    '❄️': (Icons.ac_unit_rounded, AppColors.accentSky),
    '🔥': (Icons.local_fire_department_rounded, AppColors.accentAmber),
    '🌿': (Icons.eco_rounded, AppColors.accentTeal),
    '💡': (Icons.lightbulb_rounded, AppColors.accentAmber),
    '🎮': (Icons.sports_esports_rounded, AppColors.accentViolet),
    '🪞': (Icons.flip_rounded, AppColors.accentRose),
    '🖥️': (Icons.computer_rounded, AppColors.accentSky),
    '📚': (Icons.menu_book_rounded, AppColors.accentViolet),

    // —— 分类 ——
    '🍎': (Icons.local_dining_rounded, AppColors.categoryFood),
    '🧹': (Icons.cleaning_services_rounded, AppColors.categoryDaily),
    '🧴': (Icons.soap_rounded, AppColors.categoryDaily),
    '💄': (Icons.face_retouching_natural_rounded, AppColors.accentRose),
    '💊': (Icons.medication_rounded, AppColors.categoryMedicine),
    '📺': (Icons.tv_rounded, AppColors.categoryElectronics),
    '👕': (Icons.checkroom_rounded, AppColors.categoryClothing),
    '🥛': (Icons.local_drink_rounded, AppColors.categoryFood),
    '🥩': (Icons.set_meal_rounded, AppColors.categoryFood),
    '🥦': (Icons.grass_rounded, AppColors.categoryFood),
    '🍪': (Icons.cookie_rounded, AppColors.categoryFood),
    '🥤': (Icons.local_bar_rounded, AppColors.accentSky),
    '🚬': (Icons.smoking_rooms_rounded, AppColors.categoryOther),
    '🍿': (Icons.fastfood_rounded, AppColors.accentAmber),
    '🧂': (Icons.ramen_dining_rounded, AppColors.categoryFood),
    '🌾': (Icons.rice_bowl_rounded, AppColors.categoryFood),
    '🍜': (Icons.ramen_dining_rounded, AppColors.categoryFood),
    '🍞': (Icons.bakery_dining_rounded, AppColors.categoryFood),
    '☕': (Icons.coffee_rounded, AppColors.categoryFood),
    '🧺': (Icons.local_laundry_service_rounded, AppColors.categoryDaily),
    '🧼': (Icons.wash_rounded, AppColors.categoryDaily),
    '🧻': (Icons.receipt_rounded, AppColors.categoryDaily),
    '🗑️': (Icons.delete_outline_rounded, AppColors.categoryDaily),
    '💇': (Icons.content_cut_rounded, AppColors.accentRose),
    '🪥': (Icons.brush_rounded, AppColors.accentRose),
    '✨': (Icons.auto_awesome_rounded, AppColors.accentRose),
    '🤒': (Icons.sick_rounded, AppColors.categoryMedicine),
    '🩹': (Icons.healing_rounded, AppColors.categoryMedicine),
    '🌡️': (Icons.thermostat_rounded, AppColors.categoryMedicine),
    '🫖': (Icons.local_cafe_rounded, AppColors.categoryMedicine),
    '👔': (Icons.checkroom_rounded, AppColors.categoryClothing),
    '👖': (Icons.checkroom_rounded, AppColors.categoryClothing),
    '🧥': (Icons.checkroom_rounded, AppColors.categoryClothing),
    '👟': (Icons.directions_run_rounded, AppColors.categoryClothing),
    '🧦': (Icons.checkroom_rounded, AppColors.categoryClothing),
    '🧣': (Icons.checkroom_rounded, AppColors.categoryClothing),
    '🔌': (Icons.power_rounded, AppColors.accentSky),
    '🐾': (Icons.pets_rounded, AppColors.accentAmber),
    '🍼': (Icons.child_care_rounded, AppColors.accentRose),
    '⚽': (Icons.sports_soccer_rounded, AppColors.accentTeal),
    '🚗': (Icons.directions_car_rounded, AppColors.accentViolet),
    '🔧': (Icons.build_rounded, AppColors.categoryOther),
    '🖼️': (Icons.image_rounded, AppColors.accentViolet),
    '🧸': (Icons.toys_rounded, AppColors.accentRose),
    '🦴': (Icons.pets_rounded, AppColors.accentAmber),
    '🏋️': (Icons.fitness_center_rounded, AppColors.accentTeal),
    '🛟': (Icons.pool_rounded, AppColors.accentSky),
    '📱': (Icons.smartphone_rounded, AppColors.accentSky),
    '📎': (Icons.attach_file_rounded, AppColors.gray500),
    '🦐': (Icons.set_meal_rounded, AppColors.categoryFood),
    '🪰': (Icons.pest_control_rounded, AppColors.categoryDaily),
    '🪣': (Icons.water_drop_rounded, AppColors.categoryDaily),
    '🪒': (Icons.content_cut_rounded, AppColors.accentRose),
    '🩸': (Icons.water_drop_rounded, AppColors.accentRose),
    '🏷️': (Icons.sell_rounded, AppColors.accentViolet),
  };

  /// 中文名称 → (icon, accent, default storageKey)
  static const _nameHints = <String, (IconData, Color, String)>{
    '厨房': (Icons.restaurant_rounded, AppColors.accentAmber, '🍳'),
    '卫生间': (Icons.bathtub_rounded, AppColors.accentTeal, '🛁'),
    '客厅': (Icons.weekend_rounded, AppColors.accentViolet, '🛋️'),
    '主卧': (Icons.bed_rounded, AppColors.accentRose, '🛏️'),
    '次卧': (Icons.bed_rounded, AppColors.accentRose, '🛏️'),
    '阳台': (Icons.wb_sunny_rounded, AppColors.accentAmber, '☀️'),
    '店面': (Icons.storefront_rounded, AppColors.accentCoral, '🏪'),
    '库房': (Icons.inventory_2_rounded, AppColors.accentViolet, '📦'),
    '柜台': (Icons.receipt_long_rounded, AppColors.accentSky, '🧾'),
    '冷柜': (Icons.ac_unit_rounded, AppColors.accentSky, '🧊'),
    'A架': (Icons.looks_one_rounded, AppColors.accentSky, '🅰️'),
    'B架': (Icons.looks_two_rounded, AppColors.accentTeal, '🅱️'),
    '冰箱': (Icons.kitchen_rounded, AppColors.accentSky, '🧊'),
    '食品饮料': (Icons.restaurant_rounded, AppColors.categoryFood, '🍎'),
    '日用清洁': (Icons.cleaning_services_rounded, AppColors.categoryDaily, '🧹'),
    '个护美妆': (Icons.soap_rounded, AppColors.accentRose, '🧴'),
    '药品保健': (Icons.medication_rounded, AppColors.categoryMedicine, '💊'),
    '烟酒百货': (Icons.store_rounded, AppColors.categoryOther, '🚬'),
    '休闲食品': (Icons.fastfood_rounded, AppColors.accentAmber, '🍿'),
    '日用洗护': (Icons.soap_rounded, AppColors.categoryDaily, '🧴'),
    '饮料': (Icons.local_bar_rounded, AppColors.accentSky, '🥤'),
  };

  static final _categoryPicker = [
    const PresetIconOption(storageKey: '📦', icon: Icons.inventory_2_rounded, accent: AppColors.accentCoral, label: '通用'),
    const PresetIconOption(storageKey: '🍎', icon: Icons.local_dining_rounded, accent: AppColors.categoryFood, label: '食品'),
    const PresetIconOption(storageKey: '🧴', icon: Icons.soap_rounded, accent: AppColors.categoryDaily, label: '洗护'),
    const PresetIconOption(storageKey: '💄', icon: Icons.face_retouching_natural_rounded, accent: AppColors.accentRose, label: '美妆'),
    const PresetIconOption(storageKey: '💊', icon: Icons.medication_rounded, accent: AppColors.categoryMedicine, label: '药品'),
    const PresetIconOption(storageKey: '📺', icon: Icons.tv_rounded, accent: AppColors.categoryElectronics, label: '电器'),
    const PresetIconOption(storageKey: '👕', icon: Icons.checkroom_rounded, accent: AppColors.categoryClothing, label: '衣物'),
    const PresetIconOption(storageKey: '🧹', icon: Icons.cleaning_services_rounded, accent: AppColors.categoryDaily, label: '清洁'),
    const PresetIconOption(storageKey: '🥛', icon: Icons.local_drink_rounded, accent: AppColors.categoryFood, label: '乳品'),
    const PresetIconOption(storageKey: '🥩', icon: Icons.set_meal_rounded, accent: AppColors.categoryFood, label: '肉类'),
    const PresetIconOption(storageKey: '🥦', icon: Icons.grass_rounded, accent: AppColors.categoryFood, label: '蔬果'),
    const PresetIconOption(storageKey: '🍪', icon: Icons.cookie_rounded, accent: AppColors.categoryFood, label: '零食'),
    const PresetIconOption(storageKey: '🥤', icon: Icons.local_bar_rounded, accent: AppColors.accentSky, label: '饮料'),
    const PresetIconOption(storageKey: '🐾', icon: Icons.pets_rounded, accent: AppColors.accentAmber, label: '宠物'),
    const PresetIconOption(storageKey: '🔧', icon: Icons.build_rounded, accent: AppColors.categoryOther, label: '工具'),
  ];

  static final _locationPicker = [
    const PresetIconOption(storageKey: '🏠', icon: Icons.home_rounded, accent: AppColors.accentCoral),
    const PresetIconOption(storageKey: '🍳', icon: Icons.restaurant_rounded, accent: AppColors.accentAmber),
    const PresetIconOption(storageKey: '🛁', icon: Icons.bathtub_rounded, accent: AppColors.accentTeal),
    const PresetIconOption(storageKey: '🛋️', icon: Icons.weekend_rounded, accent: AppColors.accentViolet),
    const PresetIconOption(storageKey: '🛏️', icon: Icons.bed_rounded, accent: AppColors.accentRose),
    const PresetIconOption(storageKey: '☀️', icon: Icons.wb_sunny_rounded, accent: AppColors.accentAmber),
    const PresetIconOption(storageKey: '📦', icon: Icons.inventory_2_rounded, accent: AppColors.accentCoral),
    const PresetIconOption(storageKey: '🗄️', icon: Icons.archive_rounded, accent: AppColors.accentViolet),
    const PresetIconOption(storageKey: '🏪', icon: Icons.storefront_rounded, accent: AppColors.accentCoral),
    const PresetIconOption(storageKey: '🧊', icon: Icons.ac_unit_rounded, accent: AppColors.accentSky),
    const PresetIconOption(storageKey: '💊', icon: Icons.medication_rounded, accent: AppColors.categoryMedicine),
    const PresetIconOption(storageKey: '📺', icon: Icons.tv_rounded, accent: AppColors.categoryElectronics),
    const PresetIconOption(storageKey: '👕', icon: Icons.checkroom_rounded, accent: AppColors.categoryClothing),
    const PresetIconOption(storageKey: '🍎', icon: Icons.local_dining_rounded, accent: AppColors.categoryFood),
    const PresetIconOption(storageKey: '🧹', icon: Icons.cleaning_services_rounded, accent: AppColors.categoryDaily),
    const PresetIconOption(storageKey: '🧴', icon: Icons.soap_rounded, accent: AppColors.categoryDaily),
    const PresetIconOption(storageKey: '🖥️', icon: Icons.computer_rounded, accent: AppColors.accentSky),
    const PresetIconOption(storageKey: '📚', icon: Icons.menu_book_rounded, accent: AppColors.accentViolet),
    const PresetIconOption(storageKey: '🚿', icon: Icons.shower_rounded, accent: AppColors.accentTeal),
    const PresetIconOption(storageKey: '🚽', icon: Icons.wc_rounded, accent: AppColors.accentTeal),
    const PresetIconOption(storageKey: '❄️', icon: Icons.ac_unit_rounded, accent: AppColors.accentSky),
    const PresetIconOption(storageKey: '💡', icon: Icons.lightbulb_rounded, accent: AppColors.accentAmber),
    const PresetIconOption(storageKey: '🎮', icon: Icons.sports_esports_rounded, accent: AppColors.accentViolet),
    const PresetIconOption(storageKey: '🧾', icon: Icons.receipt_long_rounded, accent: AppColors.accentSky),
  ];
}
