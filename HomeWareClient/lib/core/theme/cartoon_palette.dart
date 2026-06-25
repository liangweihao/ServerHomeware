import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 卡通主题马卡龙色板与辅助映射
abstract final class CartoonPalette {
  static const pastelCoral = Color(0xFFFFE8DE);
  static const pastelPink = Color(0xFFFFE0EB);
  static const pastelYellow = Color(0xFFFFF0C2);
  static const pastelMint = Color(0xFFD8F5E8);
  static const pastelSky = Color(0xFFDCEEFF);
  static const pastelLavender = Color(0xFFEDE4FF);

  static const _pastels = [
    pastelCoral,
    pastelSky,
    pastelMint,
    pastelYellow,
    pastelPink,
    pastelLavender,
  ];

  static const _pastelBorders = [
    Color(0xFFFF8A65),
    Color(0xFF64B5F6),
    Color(0xFF66BB6A),
    Color(0xFFFFB74D),
    Color(0xFFE57373),
    Color(0xFFB39DDB),
  ];

  /// 按序号取马卡龙底色与描边
  static (Color fill, Color border) pairAt(int index) {
    final i = index.abs() % _pastels.length;
    return (_pastels[i], _pastelBorders[i]);
  }

  /// 统计卡轻微倾斜角（弧度），交替制造手贴感
  static const statTilts = [-0.032, 0.028, -0.022, 0.03];

  static double tiltAt(int index) {
    if (index < 0) return 0;
    return statTilts[index % statTilts.length];
  }

  /// 根据语义色返回马卡龙底 + 描边色
  static (Color fill, Color border) pairForAccent(Color accent) {
    final v = accent.toARGB32();
    if (v == AppColors.danger.toARGB32()) {
      return (pastelPink, const Color(0xFFE57373));
    }
    if (v == AppColors.warning.toARGB32()) {
      return (pastelYellow, const Color(0xFFFFB74D));
    }
    if (v == AppColors.success.toARGB32()) {
      return (pastelMint, const Color(0xFF66BB6A));
    }
    if (v == AppColors.primary.toARGB32()) {
      return (pastelCoral, AppColors.primary);
    }
    return (pastelCoral, AppColors.primary);
  }

  /// Material Icon -> 卡通 emoji
  static String emojiFor(IconData icon) {
    if (icon == Icons.schedule_outlined || icon == Icons.schedule) return '⏰';
    if (icon == Icons.inventory_2_outlined || icon == Icons.inventory_2) {
      return '📦';
    }
    if (icon == Icons.shopping_cart_outlined ||
        icon == Icons.shopping_cart) {
      return '🛒';
    }
    if (icon == Icons.payments_outlined || icon == Icons.payments) {
      return '💰';
    }
    if (icon == Icons.notifications_outlined) return '🔔';
    if (icon == Icons.home_outlined) return '🏠';
    return '✨';
  }

  /// 动态描述 -> 展示 emoji
  static String emojiForActivity(String description) {
    if (description.contains('添加') || description.contains('新增')) {
      return '✨';
    }
    if (description.contains('使用') || description.contains('消耗')) {
      return '🍽️';
    }
    if (description.contains('购买') || description.contains('购物')) {
      return '🛒';
    }
    if (description.contains('过期') || description.contains('丢弃')) {
      return '⏰';
    }
    if (description.contains('库存')) return '📦';
    return '📝';
  }
}
