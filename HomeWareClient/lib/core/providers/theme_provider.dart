import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme_variant.dart';

const kAppThemeVariantPrefKey = 'app_theme_variant';

final initialThemeVariantProvider = Provider<AppThemeVariant>(
  (ref) => AppThemeVariant.defaultVariant,
);

/// 主题 Provider — 仅糖果轻点，保留持久化以兼容旧安装
final appThemeVariantProvider =
    NotifierProvider<AppThemeVariantNotifier, AppThemeVariant>(
  AppThemeVariantNotifier.new,
);

class AppThemeVariantNotifier extends Notifier<AppThemeVariant> {
  @override
  AppThemeVariant build() {
    return ref.watch(initialThemeVariantProvider);
  }

  /// 切换主题（当前仅单一主题，调用为 no-op）
  Future<void> setVariant(AppThemeVariant variant) async {
    if (state == variant) return;
    debugPrint('[Theme] 应用主题: ${variant.label}');
    AppColors.applyPalette(variant.palette);
    state = variant;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kAppThemeVariantPrefKey, variant.storageKey);
    } catch (e, stack) {
      debugPrint('[Theme] ERROR 保存主题失败: $e\n$stack');
    }
  }
}

/// 启动前加载主题 — 旧版多主题键一律迁移为糖果轻点
Future<AppThemeVariant> loadInitialThemeVariant() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString(kAppThemeVariantPrefKey);
    if (storedKey != null &&
        storedKey != AppThemeVariant.vividClean.storageKey) {
      debugPrint('[Theme] INFO: 旧主题 $storedKey → 糖果轻点');
      await prefs.setString(
        kAppThemeVariantPrefKey,
        AppThemeVariant.vividClean.storageKey,
      );
    }
    const variant = AppThemeVariant.vividClean;
    AppColors.applyPalette(variant.palette);
    debugPrint('[Theme] 启动加载: ${variant.label}');
    return variant;
  } catch (e, stack) {
    debugPrint('[Theme] WARN 加载失败，使用默认: $e\n$stack');
    AppColors.applyPalette(AppThemeVariant.defaultVariant.palette);
    return AppThemeVariant.defaultVariant;
  }
}
