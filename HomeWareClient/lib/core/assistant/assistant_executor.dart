import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import '../utils/item_list_reason_helper.dart';
import '../utils/search_utils.dart';
import 'assistant_models.dart';
import 'assistant_parser.dart';

/// 对话助手执行器 — 查询本地 Drift，离线可用
class AssistantExecutor {
  AssistantExecutor(this._db);

  final AppDatabase _db;

  static const _defaultSuggestions = [
    '厨房有什么',
    '什么快过期',
    '库存不足',
    '有什么要处理',
  ];

  /// 处理用户一句话
  Future<AssistantReply> handle(String userMessage) async {
    final parsed = AssistantParser.parse(userMessage);
    debugPrint('[AssistantExecutor] INFO: intent=${parsed.intent} '
        'space=${parsed.spaceName} item=${parsed.itemName}');

    await _db.ensureInitialized();

    switch (parsed.intent) {
      case AssistantIntentType.querySpaceItems:
        return _querySpaceItems(parsed.spaceName ?? '');
      case AssistantIntentType.queryItemLocation:
        return _queryItemLocation(parsed.itemName ?? userMessage.trim());
      case AssistantIntentType.queryExpiring:
        return _queryExpiring();
      case AssistantIntentType.queryLowStock:
        return _queryLowStock();
      case AssistantIntentType.queryPending:
        return _queryPending();
      case AssistantIntentType.unknown:
        return _helpReply();
    }
  }

  Future<AssistantReply> _helpReply() {
    return Future.value(AssistantReply(
      text: '我可以帮你查库存位置、空间物品和待处理提醒。试试下面这些问题：',
      suggestions: _defaultSuggestions,
    ));
  }

  Future<Map<int, String>> _locationPathById() async {
    final locations = await _db.getAllLocations();
    return {for (final l in locations) l.id: l.fullPath};
  }

  String _formatItemSubtitle(Item item, Map<int, String> pathById) {
    final loc = item.locationId != null ? pathById[item.locationId] : null;
    final locText = loc ?? '未指定位置';
    final qty = item.currentQuantity.toStringAsFixed(
      item.currentQuantity == item.currentQuantity.roundToDouble() ? 0 : 1,
    );
    return '$locText · 剩余 $qty${item.unit}';
  }

  List<AssistantItemSummary> _toSummaries(
    List<Item> items,
    Map<int, String> pathById, {
    int limit = 20,
  }) {
    final slice = items.length > limit ? items.sublist(0, limit) : items;
    return slice
        .map(
          (i) => AssistantItemSummary(
            itemId: i.id,
            name: i.name,
            subtitle: _formatItemSubtitle(i, pathById),
          ),
        )
        .toList();
  }

  Future<AssistantReply> _querySpaceItems(String spaceName) async {
    if (spaceName.isEmpty) {
      return const AssistantReply(
        text: '请告诉我要查哪个空间，例如「厨房有什么」。',
        suggestions: ['厨房有什么', '卫生间有什么'],
      );
    }

    final locations = await _db.getAllLocations();
    final matched = _matchLocation(spaceName, locations);
    if (matched == null) {
      return AssistantReply(
        text: '没有找到叫「$spaceName」的空间。请检查名称或到「位置管理」里确认。',
        suggestions: _defaultSuggestions,
      );
    }

    final items = await _db.getItemsInLocationTree(matched.id);
    final pathById = await _locationPathById();

    if (items.isEmpty) {
      return AssistantReply(
        text: '「${matched.fullPath}」下暂时没有使用中的物品。',
        suggestions: ['什么快过期', '库存不足'],
      );
    }

    final summaries = _toSummaries(items, pathById);
    final more = items.length > summaries.length ? '（共 ${items.length} 件，仅展示前 ${summaries.length} 件）' : '';
    return AssistantReply(
      text: '「${matched.fullPath}」下有 ${items.length} 件物品$more：',
      items: summaries,
      suggestions: ['什么快过期', '${matched.name}还有什么要处理'],
    );
  }

  Future<AssistantReply> _queryItemLocation(String itemName) async {
    if (itemName.isEmpty) {
      return const AssistantReply(
        text: '请告诉我要找什么物品，例如「牛奶在哪」。',
        suggestions: ['牛奶在哪', '创可贴在哪'],
      );
    }

    final allItems = await _db.getAllItems();
    final active = allItems.where((i) => i.status == 0).toList();
    final pathById = await _locationPathById();
    final locationNameByItemId = {
      for (final i in active)
        if (i.locationId != null) i.id: pathById[i.locationId],
    };

    final matches = filterItemsByQuery(
      items: active,
      locationNameByItemId: locationNameByItemId,
      query: itemName,
      limit: 10,
    );

    if (matches.isEmpty) {
      return AssistantReply(
        text: '没有找到与「$itemName」相关的使用中物品。你可以换个关键词，或用 + 添加入库。',
        suggestions: _defaultSuggestions,
      );
    }

    if (matches.length == 1) {
      final m = matches.first;
      final loc = m.locationName ?? '未指定位置';
      final item = m.item;
      final qty = item.currentQuantity.toStringAsFixed(
        item.currentQuantity == item.currentQuantity.roundToDouble() ? 0 : 1,
      );
      return AssistantReply(
        text: '「${item.name}」在 $loc，剩余 $qty${item.unit}。',
        items: [
          AssistantItemSummary(
            itemId: item.id,
            name: item.name,
            subtitle: _formatItemSubtitle(item, pathById),
          ),
        ],
        suggestions: ['什么快过期', '库存不足'],
      );
    }

    final summaries = matches
        .map(
          (m) => AssistantItemSummary(
            itemId: m.item.id,
            name: m.item.name,
            subtitle: _formatItemSubtitle(m.item, pathById),
          ),
        )
        .toList();

    return AssistantReply(
      text: '找到 ${matches.length} 个与「$itemName」相关的物品：',
      items: summaries,
      suggestions: _defaultSuggestions,
    );
  }

  Future<AssistantReply> _queryExpiring() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final sevenDaysEnd = todayStart.add(const Duration(days: 7));

    final all = await _db.getAllItems();
    final active = all.where((i) => i.status == 0).toList();
    final pathById = await _locationPathById();

    final expired = active.where((i) {
      final d = i.expiryDate;
      return d != null && d.isBefore(todayStart);
    }).toList();

    final expiring = active.where((i) {
      final d = i.expiryDate;
      return d != null &&
          !d.isBefore(todayStart) &&
          !d.isAfter(sevenDaysEnd);
    }).toList();

    final combined = [...expired, ...expiring];
    if (combined.isEmpty) {
      return const AssistantReply(
        text: '近 7 天内没有临期或已过期物品，一切正常。',
        suggestions: ['库存不足', '厨房有什么'],
      );
    }

    final summaries = _toSummaries(combined, pathById);
    return AssistantReply(
      text: '共有 ${combined.length} 件需要关注（已过期 ${expired.length}，临期 ${expiring.length}）：',
      items: summaries,
      suggestions: ['有什么要处理', '库存不足'],
    );
  }

  Future<AssistantReply> _queryLowStock() async {
    final items = await _db.getStockAlerts();
    final pathById = await _locationPathById();

    if (items.isEmpty) {
      return const AssistantReply(
        text: '目前没有库存不足的物品。',
        suggestions: ['什么快过期', '厨房有什么'],
      );
    }

    final summaries = _toSummaries(items, pathById);
    return AssistantReply(
      text: '有 ${items.length} 件物品库存偏低：',
      items: summaries,
      suggestions: ['什么快过期', '有什么要处理'],
    );
  }

  Future<AssistantReply> _queryPending() async {
    final pathById = await _locationPathById();
    final all = await _db.getAllItems();
    final active = all.where((i) => i.status == 0).toList();

    final pending = active
        .where((i) => computeItemListReason(i).isActionable)
        .toList();

    sortItemsByUrgency(pending);

    if (pending.isEmpty) {
      return const AssistantReply(
        text: '目前没有需要优先处理的物品，一切正常。',
        suggestions: ['厨房有什么', '什么快过期'],
      );
    }

    final summaries = _toSummaries(pending, pathById);
    return AssistantReply(
      text: '建议优先处理这 ${pending.length} 件：',
      items: summaries,
      suggestions: ['什么快过期', '库存不足'],
    );
  }

  /// 按名称匹配空间（精确 > 包含 > 路径段）
  Location? _matchLocation(String query, List<Location> all) {
    final q = query.trim();
    if (q.isEmpty) return null;

    for (final l in all) {
      if (l.name == q) return l;
    }

    final contains = all.where((l) => l.name.contains(q) || q.contains(l.name)).toList();
    if (contains.length == 1) return contains.first;

    for (final l in all) {
      final segments = l.fullPath.split('/');
      if (segments.any((s) => s == q || s.contains(q) || q.contains(s))) {
        return l;
      }
    }

    return contains.isNotEmpty ? contains.first : null;
  }
}
