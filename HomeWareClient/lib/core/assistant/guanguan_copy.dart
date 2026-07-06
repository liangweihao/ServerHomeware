import '../config/space_skin_config.dart';
import '../constants/assistant_mascot.dart';
import 'add_item_nl_parser.dart';
import 'guanguan_weekly_insight_models.dart';

/// 管管话术库 — 默认家庭皮肤；店铺请走 [SpaceSkinConfig] 实例方法
abstract final class GuanguanCopy {
  static const _home = SpaceSkinConfig.home;

  /// 吉祥物名称
  static const mascotName = AssistantMascot.name;

  /// 会话欢迎语（家庭默认，UI 层请用 skin.welcomeMessage）
  static String get welcomeMessage => _home.welcomeMessage;

  /// 默认建议问题（家庭默认）
  static List<String> get defaultSuggestions => _home.assistantSuggestions;

  static String helpReply() => _home.helpReply();

  static String get queryError => _home.queryError;

  static String spaceNameMissing() => _home.spaceNameMissing();

  static List<String> get spaceSuggestions => _home.spaceSuggestions;

  static String spaceNotFound(String spaceName) =>
      _home.spaceNotFound(spaceName);

  static String spaceEmpty(String fullPath) => _home.spaceEmpty(fullPath);

  static String spaceItemsFound({
    required String fullPath,
    required int total,
    required int shown,
  }) =>
      _home.spaceItemsFound(fullPath: fullPath, total: total, shown: shown);

  static String itemNameMissing() => _home.itemNameMissing();

  static const itemSuggestions = ['牛奶在哪', '创可贴在哪'];

  static String itemNotFound(String itemName) => _home.itemNotFound(itemName);

  static String itemFoundSingle({
    required String name,
    required String location,
    required String quantityText,
  }) =>
      _home.itemFoundSingle(
        name: name,
        location: location,
        quantityText: quantityText,
      );

  static String itemFoundMultiple(int count, String itemName) =>
      _home.itemFoundMultiple(count, itemName);

  static String get expiringAllClear => _home.expiringAllClear;

  static String expiringFound({
    required int total,
    required int expired,
    required int expiring,
  }) =>
      _home.expiringFound(
        total: total,
        expired: expired,
        expiring: expiring,
      );

  static String get lowStockAllClear => _home.lowStockAllClear;

  static String lowStockFound(int count) => _home.lowStockFound(count);

  static String get pendingAllClear => _home.pendingAllClear;

  static String pendingFound(int count) => _home.pendingFound(count);

  static String dailyCrisisHeadline({
    required String itemName,
    required DailyCrisisKind kind,
    SpaceSkinConfig skin = _home,
  }) =>
      skin.dailyCrisisHeadline(itemName: itemName, kind: kind);

  static String dailyCrisisSubline({
    required int otherCount,
    SpaceSkinConfig skin = _home,
  }) =>
      skin.dailyCrisisSubline(otherCount: otherCount);

  static String get dailyAllClear => _home.dailyAllClear;

  static String celebrateConsume({
    required String itemName,
    required bool depleted,
    SpaceSkinConfig skin = _home,
  }) =>
      skin.celebrateConsume(itemName: itemName, depleted: depleted);

  static String celebrateDiscard(
    String itemName, {
    SpaceSkinConfig skin = _home,
  }) =>
      skin.celebrateDiscard(itemName);

  static String celebrateAddShopping(
    String itemName, {
    SpaceSkinConfig skin = _home,
  }) =>
      skin.celebrateAddShopping(itemName);

  static List<String> get addItemExamples => _home.addItemExamples;

  static String addItemPrefillReply(AddItemNlResult draft) =>
      _home.addItemPrefillReply(draft);

  static String get addItemParseFailed => _home.addItemParseFailed;

  static String weeklyInsightLabel(DateTime now) =>
      _home.weeklyInsightLabel(now);

  static String weeklyInsightHeadline({
    required GuanguanAchievementKind? achievement,
    required int recordCount,
    required int consumeCount,
    SpaceSkinConfig skin = _home,
  }) =>
      skin.weeklyInsightHeadline(
        achievement: achievement,
        recordCount: recordCount,
        consumeCount: consumeCount,
      );

  static List<String> weeklyInsightSummaryLines({
    required int recordCount,
    required int consumeCount,
    required int newItemCount,
    required int greenStreakDays,
    SpaceSkinConfig skin = _home,
  }) =>
      skin.weeklyInsightSummaryLines(
        recordCount: recordCount,
        consumeCount: consumeCount,
        newItemCount: newItemCount,
        greenStreakDays: greenStreakDays,
      );

  static String achievementTitle(
    GuanguanAchievementKind kind, {
    SpaceSkinConfig skin = _home,
  }) =>
      skin.achievementTitle(kind);

  static String achievementSubtitle(
    GuanguanAchievementKind kind, {
    SpaceSkinConfig skin = _home,
  }) =>
      skin.achievementSubtitle(kind);
}

/// 每日主危机类型 — 与 [DailyCrisisHelper] 共用
enum DailyCrisisKind {
  expired,
  expiring,
  lowStock,
}
