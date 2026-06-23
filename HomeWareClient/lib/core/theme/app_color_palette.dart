import 'package:flutter/material.dart';

/// 可切换的应用主色色板（主色及衍生色，不含语义色与分类色）
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.primaryLighter,
    required this.primaryHex,
    required this.background,
  });

  /// 主色
  final Color primary;

  /// 主色深色（按钮按下、强调文字）
  final Color primaryDark;

  /// 主色浅色（次要强调）
  final Color primaryLight;

  /// 主色极浅（容器背景、选中态底）
  final Color primaryLighter;

  /// 主色十六进制字符串
  final String primaryHex;

  /// 页面背景（部分主题带轻微色调）
  final Color background;

  /// 信息色与主色统一
  Color get info => primary;

  /// 信息浅色底与主色极浅统一
  Color get infoLight => primaryLighter;
}

/// 预设色板集合
abstract final class AppColorPalettes {
  /// 默认：青松 Teal
  static const teal = AppColorPalette(
    primary: Color(0xFF3A9B8A),
    primaryDark: Color(0xFF2D7F71),
    primaryLight: Color(0xFFA8D5CC),
    primaryLighter: Color(0xFFE8F5F2),
    primaryHex: '#3A9B8A',
    background: Color(0xFFFAFAFA),
  );

  /// 创意紫 — 偏创意、会员感
  static const creativePurple = AppColorPalette(
    primary: Color(0xFF7C4DFF),
    primaryDark: Color(0xFF5E35B1),
    primaryLight: Color(0xFFB388FF),
    primaryLighter: Color(0xFFEDE7F6),
    primaryHex: '#7C4DFF',
    background: Color(0xFFFAFAFA),
  );

  /// 暖橙活力 — 温暖、行动导向
  static const warmOrange = AppColorPalette(
    primary: Color(0xFFFF9800),
    primaryDark: Color(0xFFF57C00),
    primaryLight: Color(0xFFFFB74D),
    primaryLighter: Color(0xFFFFF3E0),
    primaryHex: '#FF9800',
    background: Color(0xFFFFF8F5),
  );

  /// 翡翠清新 — 自然、轻量
  static const emeraldFresh = AppColorPalette(
    primary: Color(0xFF10B981),
    primaryDark: Color(0xFF059669),
    primaryLight: Color(0xFF6EE7B7),
    primaryLighter: Color(0xFFD1FAE5),
    primaryHex: '#10B981',
    background: Color(0xFFF5FAF8),
  );
}
