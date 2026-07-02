import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/home_constants.dart';
import '../../../core/events/item_event_bus.dart';
import '../../../core/models/home_section.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/alert_service.dart';
import '../../../core/services/item_service.dart';
import '../../../core/services/item_sync_service.dart';
import 'home_section_image_enricher.dart';

/// 提醒 API 单例 Provider
final alertApiServiceProvider = Provider<AlertService>((ref) => AlertService());

/// 物品 API 单例 Provider
final itemApiServiceProvider = Provider<ItemService>((ref) => ItemService());

/// 首页四分区数据 — 并行拉取接口
final homeSectionsProvider = FutureProvider<List<HomeSectionData>>((ref) async {
  ref.watch(itemEventBusProvider);

  final db = ref.watch(databaseProvider);
  final alertService = ref.watch(alertApiServiceProvider);
  final itemService = ref.watch(itemApiServiceProvider);
  const limit = HomeConstants.previewLimit;

  debugPrint('[HomeSections] INFO: 开始拉取首页四分区数据');

  // 同步本地物品，确保封面图可用于补全
  await ItemSyncService(db).syncFromServer();
  final enricher = HomeSectionImageEnricher(db);

  final results = await Future.wait([
    _loadExpired(alertService, itemService, limit),
    _loadExpiring(alertService, limit),
    _loadLowStock(alertService, limit),
    _loadRecentAll(itemService, limit),
  ]);

  // 补全封面 + 过滤无数据的提醒分区
  final enriched = <HomeSectionData>[];
  for (final section in results) {
    final items = await enricher.enrichItems(section.items);
    enriched.add(HomeSectionData(
      config: section.config,
      items: items,
      errorMessage: section.errorMessage,
    ));
  }

  final visible = enriched.where(_shouldShowOnHome).toList();
  debugPrint(
    '[HomeSections] INFO: 首页数据加载完成，展示 ${visible.length}/${enriched.length} 个分区',
  );
  return visible;
});

/// 首页是否展示该分区：提醒类无数据时隐藏，「全部」始终保留
bool _shouldShowOnHome(HomeSectionData section) {
  switch (section.config.type) {
    case HomeSectionType.expired:
    case HomeSectionType.expiringSoon:
    case HomeSectionType.lowStock:
      return section.items.isNotEmpty;
    case HomeSectionType.recentAll:
      return true;
  }
}

Future<HomeSectionData> _loadExpired(
  AlertService alertService,
  ItemService itemService,
  int limit,
) async {
  final config = HomeSectionConfig.configs[0];
  final resp = await alertService.getExpiredItems();
  if (resp.code == 200 && resp.data != null) {
    final items = resp.data!
        .take(limit)
        .map(HomeSectionItem.fromExpiredJson)
        .toList();
    return HomeSectionData(config: config, items: items);
  }

  debugPrint(
    '[HomeSections] WARN: 已过期接口不可用 code=${resp.code}，回退物品列表筛选',
  );
  final fallback = await _fetchExpiredFromItems(itemService);
  return HomeSectionData(
    config: config,
    items: fallback.take(limit).toList(),
  );
}

/// 从物品列表客户端筛选已过期（接口未部署时的回退）
Future<List<HomeSectionItem>> _fetchExpiredFromItems(ItemService service) async {
  final all = <Map<String, dynamic>>[];
  var page = 1;
  while (true) {
    final resp = await service.getItems(
      page: page,
      pageSize: 50,
      status: 0,
      sortBy: 'expiry_date',
      sortOrder: 'asc',
    );
    if (resp.code != 200 || resp.data == null) break;
    final raw = resp.data!['items'] as List<dynamic>? ?? [];
    if (raw.isEmpty) break;
    all.addAll(raw.whereType<Map<String, dynamic>>());
    final pages = resp.data!['pages'] as int? ?? 1;
    if (page >= pages) break;
    page++;
  }

  final today = DateTime.now();
  final todayDay = DateTime(today.year, today.month, today.day);
  final expired = all.where((item) {
    final expiryRaw = item['expiry_date']?.toString();
    if (expiryRaw == null || expiryRaw.isEmpty) return false;
    final expiry = DateTime.tryParse(expiryRaw);
    if (expiry == null) return false;
    final expiryDay = DateTime(expiry.year, expiry.month, expiry.day);
    return expiryDay.isBefore(todayDay);
  }).toList();

  expired.sort((a, b) {
    final ea = DateTime.tryParse(a['expiry_date']?.toString() ?? '') ??
        DateTime(9999);
    final eb = DateTime.tryParse(b['expiry_date']?.toString() ?? '') ??
        DateTime(9999);
    return ea.compareTo(eb);
  });

  debugPrint('[HomeSections] INFO: 回退筛选已过期 ${expired.length} 件');
  return expired.map(HomeSectionItem.fromItemJsonAsExpired).toList();
}

Future<HomeSectionData> _loadExpiring(AlertService service, int limit) async {
  final config = HomeSectionConfig.configs[1];
  final resp = await service.getExpiringItems(days: HomeConstants.expiringDays);
  if (resp.code != 200 || resp.data == null) {
    debugPrint('[HomeSections] WARN: 临期加载失败 ${resp.message}');
    return HomeSectionData(config: config, items: [], errorMessage: resp.message);
  }
  final items = resp.data!
      .take(limit)
      .map(HomeSectionItem.fromExpiringJson)
      .toList();
  return HomeSectionData(config: config, items: items);
}

Future<HomeSectionData> _loadLowStock(AlertService service, int limit) async {
  final config = HomeSectionConfig.configs[2];
  final resp = await service.getLowStockItems();
  if (resp.code != 200 || resp.data == null) {
    debugPrint('[HomeSections] WARN: 库存不足加载失败 ${resp.message}');
    return HomeSectionData(config: config, items: [], errorMessage: resp.message);
  }
  final items = resp.data!
      .take(limit)
      .map(HomeSectionItem.fromLowStockJson)
      .toList();
  return HomeSectionData(config: config, items: items);
}

Future<HomeSectionData> _loadRecentAll(ItemService service, int limit) async {
  final config = HomeSectionConfig.configs[3];
  final resp = await service.getItems(
    page: 1,
    pageSize: limit,
    status: 0,
    sortBy: 'created_at',
    sortOrder: 'desc',
  );
  if (resp.code != 200 || resp.data == null) {
    debugPrint('[HomeSections] WARN: 全部物品加载失败 ${resp.message}');
    return HomeSectionData(config: config, items: [], errorMessage: resp.message);
  }
  final raw = resp.data!['items'] as List<dynamic>? ?? [];
  final items = raw
      .whereType<Map<String, dynamic>>()
      .map(HomeSectionItem.fromItemJson)
      .toList();
  return HomeSectionData(config: config, items: items);
}

/// 刷新首页分区
void invalidateHomeSections(WidgetRef ref) {
  ref.invalidate(homeSectionsProvider);
}

/// 分区完整列表 Provider（查看全部页）
final homeSectionFullListProvider =
    FutureProvider.family<List<HomeSectionItem>, String>((ref, section) async {
  ref.watch(itemEventBusProvider);
  final db = ref.watch(databaseProvider);
  final alertService = ref.watch(alertApiServiceProvider);
  final itemService = ref.watch(itemApiServiceProvider);
  final enricher = HomeSectionImageEnricher(db);

  debugPrint('[HomeSections] INFO: 加载完整列表 section=$section');

  List<HomeSectionItem> items;
  switch (section) {
    case 'expired':
      final resp = await alertService.getExpiredItems();
      if (resp.code == 200 && resp.data != null) {
        items = resp.data!.map(HomeSectionItem.fromExpiredJson).toList();
      } else {
        debugPrint('[HomeSections] WARN: 查看全部-已过期回退物品列表筛选');
        items = await _fetchExpiredFromItems(itemService);
      }
      break;
    case 'expiring':
      final resp = await alertService.getExpiringItems(
        days: HomeConstants.expiringDays,
      );
      if (resp.code != 200 || resp.data == null) {
        throw Exception(resp.message);
      }
      items = resp.data!.map(HomeSectionItem.fromExpiringJson).toList();
      break;
    case 'low_stock':
      final resp = await alertService.getLowStockItems();
      if (resp.code != 200 || resp.data == null) {
        throw Exception(resp.message);
      }
      items = resp.data!.map(HomeSectionItem.fromLowStockJson).toList();
      break;
    case 'all':
      final all = <HomeSectionItem>[];
      var page = 1;
      while (true) {
        final resp = await itemService.getItems(
          page: page,
          pageSize: 50,
          status: 0,
          sortBy: 'created_at',
          sortOrder: 'desc',
        );
        if (resp.code != 200 || resp.data == null) {
          throw Exception(resp.message);
        }
        final raw = resp.data!['items'] as List<dynamic>? ?? [];
        if (raw.isEmpty) break;
        all.addAll(
          raw.whereType<Map<String, dynamic>>().map(HomeSectionItem.fromItemJson),
        );
        final pages = resp.data!['pages'] as int? ?? 1;
        if (page >= pages) break;
        page++;
      }
      items = all;
      break;
    default:
      throw Exception('未知分区: $section');
  }

  return enricher.enrichItems(items);
});

/// 分区标题映射
String homeSectionTitle(String section) {
  for (final c in HomeSectionConfig.configs) {
    if (c.routeSection == section) return c.title;
  }
  return '物品';
}
