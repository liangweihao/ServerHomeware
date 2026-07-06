import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/guanguan_weekly_insight_builder.dart';
import 'package:home_stock/core/assistant/guanguan_weekly_insight_models.dart';
import 'package:home_stock/core/services/profile_health_history_service.dart';
import 'package:home_stock/data/database/app_database.dart';

void main() {
  final now = DateTime(2026, 7, 4, 12);

  UsageRecord usage({
    required int id,
    required int type,
    DateTime? createdAt,
  }) {
    return UsageRecord(
      id: id,
      itemId: 1,
      type: type,
      quantity: 1,
      remainingQuantity: 1,
      createdAt: createdAt ?? now,
    );
  }

  Item item({required int id, required String name, DateTime? createdAt}) {
    return Item(
      id: id,
      name: name,
      categoryId: 1,
      purchaseQuantity: 1,
      packageQuantity: 1,
      currentQuantity: 1,
      unit: '件',
      safetyStock: 1,
      expiryAlertDays: 7,
      stockAlert: true,
      status: 0,
      createdAt: createdAt ?? now,
      updatedAt: now,
    );
  }

  ProfileHealthSnapshot health(DateTime date, int score) {
    return ProfileHealthSnapshot(date: date, score: score);
  }

  group('GuanguanWeeklyInsightBuilder', () {
    test('统计近 7 日录入与消耗', () {
      final insight = GuanguanWeeklyInsightBuilder.build(
        recentRecords: [
          usage(id: 1, type: 0, createdAt: now.subtract(const Duration(days: 2))),
          usage(id: 2, type: 1, createdAt: now.subtract(const Duration(days: 1))),
          usage(
            id: 3,
            type: 1,
            createdAt: now.subtract(const Duration(days: 10)),
          ),
        ],
        allItems: [
          item(id: 1, name: '牛奶', createdAt: now.subtract(const Duration(days: 3))),
        ],
        healthHistory: [],
        now: now,
      );

      expect(insight.recordCount, 1);
      expect(insight.consumeCount, 1);
      expect(insight.newItemCount, 1);
      expect(insight.hasContent, isTrue);
    });

    test('连续 7 天满分解锁零浪费成就', () {
      final history = List.generate(
        7,
        (i) => health(
          DateTime(now.year, now.month, now.day).subtract(Duration(days: i)),
          100,
        ),
      );

      final insight = GuanguanWeeklyInsightBuilder.build(
        recentRecords: const [],
        allItems: const [],
        healthHistory: history,
        now: now,
      );

      expect(insight.greenStreakDays, 7);
      expect(insight.achievement, GuanguanAchievementKind.zeroWasteWeek);
      expect(insight.headline, contains('零浪费'));
    });

    test('健康分断档不计入连续绿', () {
      final history = [
        health(now, 100),
        health(now.subtract(const Duration(days: 1)), 100),
        health(now.subtract(const Duration(days: 2)), 88),
      ];

      final insight = GuanguanWeeklyInsightBuilder.build(
        recentRecords: const [],
        allItems: const [],
        healthHistory: history,
        now: now,
      );

      expect(insight.greenStreakDays, 2);
      expect(insight.achievement, isNull);
    });
  });
}
