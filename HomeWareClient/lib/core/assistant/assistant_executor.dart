import 'package:flutter/foundation.dart' show debugPrint;

import '../../data/database/app_database.dart';
import '../../presentation/items/item_add_nl_prefill_storage.dart';
import '../config/space_skin_config.dart';
import '../utils/item_list_reason_helper.dart';
import '../utils/search_utils.dart';
import 'add_item_nl_parser.dart';
import 'assistant_models.dart';
import 'assistant_parser.dart';
import 'guanguan_copy.dart';

/// 对话助手执行器 — 查询本地 Drift，离线可用；文案走 [SpaceSkinConfig]
class AssistantExecutor {
  AssistantExecutor(this._db, {SpaceSkinConfig? skin})
      : _skin = skin ?? SpaceSkinConfig.home;

  final AppDatabase _db;
  final SpaceSkinConfig _skin;

  /// 处理用户一句话
  Future<AssistantReply> handle(String userMessage) async {
    final parsed = AssistantParser.parse(userMessage);
    debugPrint('[AssistantExecutor] INFO: intent=${parsed.intent} '
        'space=${parsed.spaceName} item=${parsed.itemName} skin=${_skin.spaceType.name}');

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
      case AssistantIntentType.addItem:
        return _handleAddItem(parsed.addItemDraft!);
      case AssistantIntentType.unknown:
        return _helpReply();
    }
  }

  Future<AssistantReply> _helpReply() {
    return Future.value(AssistantReply(
      text: _skin.helpReply(),
      suggestions: _skin.assistantSuggestions,
    ));
  }

  /// M5 — 保存 NL 预填并引导进向导
  Future<AssistantReply> _handleAddItem(AddItemNlResult draft) {
    ItemAddNlPrefillStorage.save(draft);
    debugPrint('[AssistantExecutor] INFO: NL 入库预填 name=${draft.name}');
    return Future.value(AssistantReply(
      text: _skin.addItemPrefillReply(draft),
      suggestions: _skin.assistantSuggestions,
      actionLabel: _skin.addItemConfirmLabel,
      actionRoute: '/items/add?nlPrefill=1',
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
      return AssistantReply(
        text: _skin.spaceNameMissing(),
        suggestions: _skin.spaceSuggestions,
      );
    }

    final locations = await _db.getAllLocations();
    final matched = _matchLocation(spaceName, locations);
    if (matched == null) {
      return AssistantReply(
        text: _skin.spaceNotFound(spaceName),
        suggestions: _skin.assistantSuggestions,
      );
    }

    final items = await _db.getItemsInLocationTree(matched.id);
    final pathById = await _locationPathById();

    if (items.isEmpty) {
      return AssistantReply(
        text: _skin.spaceEmpty(matched.fullPath),
        suggestions: [
          _skin.assistantSuggestions[1],
          _skin.assistantSuggestions[2],
        ],
      );
    }

    const limit = 20;
    final summaries = _toSummaries(items, pathById, limit: limit);
    return AssistantReply(
      text: _skin.spaceItemsFound(
        fullPath: matched.fullPath,
        total: items.length,
        shown: summaries.length,
      ),
      items: summaries,
      suggestions: [
        _skin.assistantSuggestions[1],
        '${matched.name}还有什么要处理',
      ],
    );
  }

  Future<AssistantReply> _queryItemLocation(String itemName) async {
    if (itemName.isEmpty) {
      return AssistantReply(
        text: _skin.itemNameMissing(),
        suggestions: GuanguanCopy.itemSuggestions,
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
        text: _skin.itemNotFound(itemName),
        suggestions: _skin.assistantSuggestions,
      );
    }

    if (matches.length == 1) {
      final m = matches.first;
      final loc = m.locationName ?? '未指定位置';
      final item = m.item;
      final qty = item.currentQuantity.toStringAsFixed(
        item.currentQuantity == item.currentQuantity.roundToDouble() ? 0 : 1,
      );
      final qtyText = '$qty${item.unit}';
      return AssistantReply(
        text: _skin.itemFoundSingle(
          name: item.name,
          location: loc,
          quantityText: qtyText,
        ),
        items: [
          AssistantItemSummary(
            itemId: item.id,
            name: item.name,
            subtitle: _formatItemSubtitle(item, pathById),
          ),
        ],
        suggestions: [
          _skin.assistantSuggestions[1],
          _skin.assistantSuggestions[2],
        ],
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
      text: _skin.itemFoundMultiple(matches.length, itemName),
      items: summaries,
      suggestions: _skin.assistantSuggestions,
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
      return AssistantReply(
        text: _skin.expiringAllClear,
        suggestions: [
          _skin.assistantSuggestions[2],
          _skin.assistantSuggestions[0],
        ],
      );
    }

    final summaries = _toSummaries(combined, pathById);
    return AssistantReply(
      text: _skin.expiringFound(
        total: combined.length,
        expired: expired.length,
        expiring: expiring.length,
      ),
      items: summaries,
      suggestions: [
        _skin.assistantSuggestions[3],
        _skin.assistantSuggestions[2],
      ],
    );
  }

  Future<AssistantReply> _queryLowStock() async {
    final items = await _db.getStockAlerts();
    final pathById = await _locationPathById();

    if (items.isEmpty) {
      return AssistantReply(
        text: _skin.lowStockAllClear,
        suggestions: [
          _skin.assistantSuggestions[1],
          _skin.assistantSuggestions[0],
        ],
      );
    }

    final summaries = _toSummaries(items, pathById);
    return AssistantReply(
      text: _skin.lowStockFound(items.length),
      items: summaries,
      suggestions: [
        _skin.assistantSuggestions[1],
        _skin.assistantSuggestions[3],
      ],
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
      return AssistantReply(
        text: _skin.pendingAllClear,
        suggestions: [
          _skin.assistantSuggestions[0],
          _skin.assistantSuggestions[1],
        ],
      );
    }

    final summaries = _toSummaries(pending, pathById);
    return AssistantReply(
      text: _skin.pendingFound(pending.length),
      items: summaries,
      suggestions: [
        _skin.assistantSuggestions[1],
        _skin.assistantSuggestions[2],
      ],
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
