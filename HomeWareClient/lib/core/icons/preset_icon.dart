import 'package:flutter/material.dart';

import 'app_icon.dart';
import 'preset_icon_registry.dart';

/// 分类/空间预置图标 — 糖果轻点饱和圆角底 + 白标
class PresetIcon extends StatelessWidget {
  const PresetIcon({
    super.key,
    this.storageKey,
    this.name,
    this.accentHex,
    this.wellSize = 40,
    this.iconSize = 20,
  });

  /// DB 中的 emoji 键
  final String? storageKey;

  /// 分类/位置名称（辅助匹配）
  final String? name;

  /// 分类色板 hex，如 #FF8A65
  final String? accentHex;

  final double wellSize;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final resolved = PresetIconRegistry.resolve(
      storageKey: storageKey,
      name: name,
      accentHex: accentHex,
    );
    return AppIcon.feature(
      icon: resolved.icon,
      accent: resolved.accent,
      wellSize: wellSize,
      iconSize: iconSize,
    );
  }
}
