import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/assistant/guanguan_panel_builder.dart';
import 'package:home_stock/core/config/space_skin_config.dart';
import 'package:home_stock/core/models/alert_type.dart';
import 'package:home_stock/core/models/space_type.dart';
import 'package:home_stock/core/providers/space_skin_provider.dart';
import 'package:home_stock/core/utils/alert_display_helper.dart';
import 'package:home_stock/data/database/app_database.dart';
import 'package:home_stock/presentation/alerts/widgets/alert_card.dart';

/// 客户端 idle 提醒效果预览（不依赖服务端）
///
/// 运行：
///   cd HomeWareClient
///   flutter test test/presentation/alerts/idle_reminder_effect_test.dart --reporter expanded
void main() {
  // 固定「今天」，保证 idleDays 可断言
  final today = DateTime(2026, 7, 20, 12);

  Item demoItem({
    required int id,
    required String name,
    DateTime? lastUsedAt,
    DateTime? createdAt,
    int status = 0,
  }) {
    final created = createdAt ?? today.subtract(const Duration(days: 40));
    return Item(
      id: id,
      name: name,
      categoryId: 1,
      purchaseQuantity: 1,
      packageQuantity: 1,
      currentQuantity: 1,
      unit: '件',
      safetyStock: 1,
      expiryAlertDays: 3,
      stockAlert: true,
      status: status,
      lastUsedAt: lastUsedAt,
      createdAt: created,
      updatedAt: today,
    );
  }

  /// 终端可读的通知中心预览（跑 test 时用 --reporter expanded 查看）
  void printIdlePreview({
    required String name,
    required AlertDisplayInfo info,
    String? aiBody,
  }) {
    // ignore: avoid_print
    print('''
┌──────────────────────────────────────────
│ 😴 长期未使用提醒
│ 物品: $name
│ 标签: ${info.title}
│ 文案: ${info.description}
│ 紧急度: ${info.urgency}（1低 / 2中 / 3高）
│ AI覆盖: ${aiBody == null ? '无（本地默认）' : '有'}
└──────────────────────────────────────────''');
  }

  group('idle 文案与紧急度（通知中心同款逻辑）', () {
    test('本地默认文案：按 lastUsedAt 算闲置天数', () {
      final item = demoItem(
        id: 1,
        name: '鲜牛奶',
        lastUsedAt: today.subtract(const Duration(days: 35)),
      );
      // 用真实 today 会漂，这里直接测 helper：构造「相对今天」的 Item
      // getAlertDisplayInfo 内部用 DateTime.now()，故用接近「现在」的时间造数
      final liveNow = DateTime.now();
      final liveItem = demoItem(
        id: 1,
        name: '鲜牛奶',
        lastUsedAt: liveNow.subtract(const Duration(days: 35)),
        createdAt: liveNow.subtract(const Duration(days: 40)),
      );
      final info = getAlertDisplayInfo(liveItem, AlertType.idle);
      printIdlePreview(name: liveItem.name, info: info);
      expect(info.title, '长期未使用');
      expect(info.description, contains('已'));
      expect(info.description, contains('天未记录使用动态'));
      expect(info.urgency, 2); // 30≤days<90 → 中
      expect(item.name, '鲜牛奶'); // 保留 fixture 引用，避免 unused
    });

    test('AI 文案覆盖：descriptionOverride 优先生效', () {
      final liveNow = DateTime.now();
      final item = demoItem(
        id: 2,
        name: '旧蓝牙耳机',
        lastUsedAt: liveNow.subtract(const Duration(days: 100)),
        createdAt: liveNow.subtract(const Duration(days: 200)),
      );
      const ai = '旧蓝牙耳机100天没用了，记得充个电哦！';
      final info = getAlertDisplayInfo(
        item,
        AlertType.idle,
        descriptionOverride: ai,
      );
      printIdlePreview(name: item.name, info: info, aiBody: ai);
      expect(info.description, ai);
      expect(info.urgency, 3); // ≥90 天 → 高
    });

    test('从未使用：回落到 createdAt', () {
      final liveNow = DateTime.now();
      final item = demoItem(
        id: 3,
        name: '神秘礼盒',
        lastUsedAt: null,
        createdAt: liveNow.subtract(const Duration(days: 40)),
      );
      final info = getAlertDisplayInfo(item, AlertType.idle);
      printIdlePreview(name: item.name, info: info);
      expect(info.description, contains('40'));
      expect(info.urgency, 2);
    });
  });

  group('管管面板 idle 洞察', () {
    test('findIdleItems / buildIdleInsight 文案预览', () {
      final liveNow = DateTime.now();
      final items = [
        demoItem(
          id: 10,
          name: '鲜牛奶',
          lastUsedAt: liveNow.subtract(const Duration(days: 35)),
          createdAt: liveNow.subtract(const Duration(days: 40)),
        ),
        demoItem(
          id: 11,
          name: '旧蓝牙耳机',
          lastUsedAt: liveNow.subtract(const Duration(days: 100)),
          createdAt: liveNow.subtract(const Duration(days: 200)),
        ),
        demoItem(
          id: 12,
          name: '刚用过的牙膏',
          lastUsedAt: liveNow.subtract(const Duration(days: 2)),
          createdAt: liveNow.subtract(const Duration(days: 60)),
        ),
      ];

      final idle = GuanguanPanelBuilder.findIdleItems(
        activeItems: items,
        recentRecords: const [],
        now: liveNow,
      );
      // ignore: avoid_print
      print('\n管管 findIdleItems → ${idle.length} 件:');
      for (final row in idle) {
        // ignore: avoid_print
        print('  - 「${row.itemName}」idleDays=${row.idleDays}');
      }

      final insight = GuanguanPanelBuilder.buildIdleInsight(
        activeItems: items,
        recentRecords: const [],
        now: liveNow,
      );
      // ignore: avoid_print
      print('管管洞察: ${insight?.text}  → 点击跳转 itemId=${insight?.itemId}\n');

      expect(idle.length, 2); // 牙膏 2 天不进
      expect(insight, isNotNull);
      expect(insight!.text, contains('鲜牛奶'));
      expect(insight.text, contains('2件'));
    });
  });

  group('AlertCard Widget 预览（可在测试失败截图/树上看到文案）', () {
    testWidgets('渲染多条 idle 提醒卡，树上能找到标题与 AI 文案', (tester) async {
      final liveNow = DateTime.now();
      final milk = demoItem(
        id: 1,
        name: '鲜牛奶',
        lastUsedAt: liveNow.subtract(const Duration(days: 35)),
        createdAt: liveNow.subtract(const Duration(days: 40)),
      );
      final headphone = demoItem(
        id: 2,
        name: '旧蓝牙耳机',
        lastUsedAt: liveNow.subtract(const Duration(days: 100)),
        createdAt: liveNow.subtract(const Duration(days: 200)),
      );
      const milkAi = '鲜牛奶已买35天，快检查是否过期啦！';
      const headAi = '旧蓝牙耳机100天没用了，记得充个电哦！';

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spaceSkinProvider.overrideWithValue(
              SpaceSkinConfig.forType(SpaceType.home),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              appBar: AppBar(title: const Text('idle 提醒效果预览')),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  AlertCard(
                    item: milk,
                    type: AlertType.idle,
                    descriptionOverride: milkAi,
                    onAcknowledge: () {},
                  ),
                  const SizedBox(height: 12),
                  AlertCard(
                    item: headphone,
                    type: AlertType.idle,
                    descriptionOverride: headAi,
                    onAcknowledge: () {},
                  ),
                  const SizedBox(height: 12),
                  // 无 AI 覆盖 → 本地默认文案
                  AlertCard(
                    item: demoItem(
                      id: 3,
                      name: '神秘礼盒',
                      lastUsedAt: null,
                      createdAt: liveNow.subtract(const Duration(days: 40)),
                    ),
                    type: AlertType.idle,
                    onAcknowledge: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('鲜牛奶'), findsOneWidget);
      expect(find.text('旧蓝牙耳机'), findsOneWidget);
      expect(find.text('神秘礼盒'), findsOneWidget);
      expect(find.text('长期未使用'), findsNWidgets(3));
      expect(find.text(milkAi), findsOneWidget);
      expect(find.text(headAi), findsOneWidget);
      expect(find.textContaining('天未记录使用动态'), findsOneWidget);
      expect(find.text('已知晓'), findsWidgets);

      // ignore: avoid_print
      print('''
========== Widget 树上的 idle 提醒 ==========
鲜牛奶     → $milkAi
旧蓝牙耳机 → $headAi
神秘礼盒   → 本地默认「已N天未记录使用动态」
标签均为「长期未使用」，操作按钮「已知晓」
==========================================
''');
    });
  });
}
