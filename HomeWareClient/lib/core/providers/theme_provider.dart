import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme_variant.dart';

/// SharedPreferences 中主题变体的存储键
const kAppThemeVariantPrefKey = 'app_theme_variant';

/// 旧版 cartoon / 居家暖色 缓存迁移标记
const kThemeLegacyMigratedKey = 'theme_legacy_migrated_v2';

/// 启动时注入的初始主题（由 main 预加载后 override）
final initialThemeVariantProvider = Provider<AppThemeVariant>(
  (ref) => AppThemeVariant.defaultVariant,
);

/// 当前应用主题变体 Provider
final appThemeVariantProvider =
    NotifierProvider<AppThemeVariantNotifier, AppThemeVariant>(
  AppThemeVariantNotifier.new,
);

/// 管理主题变体的读取、切换与持久化
class AppThemeVariantNotifier extends Notifier<AppThemeVariant> {
  @override
  AppThemeVariant build() {
    return ref.watch(initialThemeVariantProvider);
  }

  /// 切换主题并持久化
  Future<void> setVariant(AppThemeVariant variant) async {
    if (state == variant) return;

    debugPrint('[Theme] 切换主题: ${state.label} -> ${variant.label}');
    AppColors.applyPalette(variant.palette);
    state = variant;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kAppThemeVariantPrefKey, variant.storageKey);
      debugPrint('[Theme] 主题已保存: ${variant.storageKey}');
    } catch (e, stack) {
      debugPrint('[Theme] ERROR 保存主题失败: $e');
      debugPrint('[Theme] $stack');
    }
  }
}

/// 启动前同步加载主题（避免首帧闪烁）
Future<AppThemeVariant> loadInitialThemeVariant() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storedKey = prefs.getString(kAppThemeVariantPrefKey);

    // 旧版 cartoon / 居家暖色 → 清爽工具风，一次性迁移
    final legacyKeys = {
      AppThemeVariant.cartoon.storageKey,
      AppThemeVariant.communityWarm.storageKey,
    };
    if (storedKey != null &&
        legacyKeys.contains(storedKey) &&
        !(prefs.getBool(kThemeLegacyMigratedKey) ?? false)) {
      debugPrint(
        '[Theme] INFO: 检测到旧版主题 $storedKey，迁移为 ${AppThemeVariant.utilityClean.label}',
      );
      await prefs.setString(
        kAppThemeVariantPrefKey,
        AppThemeVariant.utilityClean.storageKey,
      );
      await prefs.setBool(kThemeLegacyMigratedKey, true);
    }

    final variant = AppThemeVariant.fromStorage(
      prefs.getString(kAppThemeVariantPrefKey),
    );
    AppColors.applyPalette(variant.palette);
    debugPrint('[Theme] 启动加载主题: ${variant.label}');
    return variant;
  } catch (e, stack) {
    debugPrint('[Theme] WARN 启动加载主题失败，使用默认: $e');
    debugPrint('[Theme] $stack');
    AppColors.applyPalette(AppThemeVariant.defaultVariant.palette);
    return AppThemeVariant.defaultVariant;
  }
}
