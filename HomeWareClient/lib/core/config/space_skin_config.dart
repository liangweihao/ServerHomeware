import '../assistant/add_item_nl_parser.dart';
import '../assistant/guanguan_copy.dart';
import '../assistant/guanguan_weekly_insight_models.dart';
import '../models/space_type.dart';

/// Phase B 文案皮肤配置 — home/shop 全局 Label 与管管话术真源
class SpaceSkinConfig {
  const SpaceSkinConfig({
    required this.spaceType,
    required this.orgLabel,
    required this.createSpaceTitle,
    required this.createSpaceSubtitle,
    required this.nameFieldHint,
    required this.createButtonLabel,
    required this.spaceEmoji,
    required this.addItemLabel,
    required this.consumeVerb,
    required this.consumeActionLabel,
    required this.shoppingListLabel,
    required this.addToShoppingLabel,
    required this.searchHint,
    required this.stockNoneLabel,
    required this.stockRedundantHint,
    required this.defaultSpaceName,
    required this.welcomeMessage,
    required this.assistantSuggestions,
    required this.spaceSuggestions,
    required this.addItemExamples,
    required this.addItemConfirmLabel,
    required this.panelNoTaskHint,
    required this.orgMemberQuipSuffix,
    required this.alertUseTodayLabel,
    required this.discardShortLabel,
    required this.purchasePriceLabel,
    required this.purchasePriceFieldLabel,
    required this.salePriceLabel,
    required this.salePriceFieldLabel,
    required this.supplierLabel,
    required this.supplierFieldLabel,
    required this.csvImportTitle,
    required this.csvImportSubtitle,
    required this.csvTemplateButtonLabel,
    required this.csvExportButtonLabel,
  });

  final SpaceType spaceType;
  final String orgLabel;
  final String createSpaceTitle;
  final String createSpaceSubtitle;
  final String nameFieldHint;
  final String createButtonLabel;
  final String spaceEmoji;

  /// 添加入库 / 进货
  final String addItemLabel;

  /// 消耗动词：用了 / 卖出
  final String consumeVerb;

  /// 记消耗 / 记卖出
  final String consumeActionLabel;

  /// 购物清单 / 采购清单
  final String shoppingListLabel;

  /// 加入购物清单 / 加入采购清单
  final String addToShoppingLabel;

  /// 首页搜索框 hint
  final String searchHint;

  /// 清单库存：家里暂无 / 店里暂无
  final String stockNoneLabel;

  /// 采购前确认提示
  final String stockRedundantHint;

  /// 管管熟练度默认空间：厨房 / 店面
  final String defaultSpaceName;

  /// 问管管欢迎语
  final String welcomeMessage;

  /// 默认建议 Chip
  final List<String> assistantSuggestions;

  /// 缺空间名时的建议
  final List<String> spaceSuggestions;

  /// NL 入库示例
  final List<String> addItemExamples;

  /// 去确认入库 / 去确认进货
  final String addItemConfirmLabel;

  /// 面板无任务提示
  final String panelNoTaskHint;

  /// 协作 quip 后缀：全家协作 / 团队继续加油
  final String orgMemberQuipSuffix;

  /// 提醒卡片：今天用掉 / 今天卖出
  final String alertUseTodayLabel;

  /// 提醒卡片：已丢弃 / 已下架
  final String discardShortLabel;

  /// 详情/表单：购买价格 / 进货单价
  final String purchasePriceLabel;

  /// 表单进货价字段 label
  final String purchasePriceFieldLabel;

  /// 详情售价行 label（店铺）
  final String salePriceLabel;

  /// 表单售价字段 label（店铺）
  final String salePriceFieldLabel;

  /// 详情供应商行 label（店铺）
  final String supplierLabel;

  /// 表单供应商字段 label（店铺）
  final String supplierFieldLabel;

  /// CSV 批量进货页标题
  final String csvImportTitle;

  /// CSV 导入说明
  final String csvImportSubtitle;

  /// 下载模板按钮
  final String csvTemplateButtonLabel;

  /// 导出库存 CSV 按钮（与进货模板对齐）
  final String csvExportButtonLabel;

  /// 店铺空间展示售价字段
  bool get showSalePrice => spaceType == SpaceType.shop;

  /// 店铺空间展示供应商字段
  bool get showSupplier => spaceType == SpaceType.shop;

  /// 格式化售价展示：¥12.50/瓶
  String formatSalePrice({required double? salePrice, required String unit}) {
    if (salePrice == null) return '—';
    return '¥${salePrice.toStringAsFixed(2)}/$unit';
  }

  /// 近7日经营卡片标题
  String get dailySalesCardTitle =>
      spaceType == SpaceType.shop ? '近7日经营' : '';

  /// 首页日销主行
  String dailySalesHeadline({
    required int sellTimes,
    required double totalRevenue,
    required bool revenueComplete,
    double totalGrossProfit = 0,
    bool costIsComplete = true,
  }) {
    if (sellTimes <= 0) {
      return '近7日暂无卖出，记一笔「卖出」后这里会汇总';
    }
    final revenuePart = totalRevenue > 0
        ? ' · 营业额 ${formatCurrency(totalRevenue)}${revenueComplete ? '' : '（部分未设售价）'}'
        : '';
    final profitPart = totalGrossProfit != 0 || (totalRevenue > 0 && costIsComplete)
        ? ' · 毛利 ${formatCurrency(totalGrossProfit)}${costIsComplete ? '' : '（部分未设进价）'}'
        : '';
    return '卖出 $sellTimes 次$revenuePart$profitPart';
  }

  /// 详情页单商品近7日卖出
  String formatItemSales7d({
    required int sellTimes,
    required double sellQuantity,
    required String unit,
    required double revenue,
    required bool revenueComplete,
    double grossProfit = 0,
    bool costIsComplete = true,
  }) {
    if (sellTimes <= 0) return '近7日暂无卖出';
    final qtyText = _formatQty(sellQuantity);
    final base = '卖出 $sellTimes 次 · 售 $qtyText $unit';
    if (revenue <= 0) return base;
    final profitSuffix = grossProfit != 0 || costIsComplete
        ? ' · 毛利 ${formatCurrency(grossProfit)}${costIsComplete ? '' : '（部分未设进价）'}'
        : '';
    return '$base · ${formatCurrency(revenue)}'
        '${revenueComplete ? '' : '（部分未设售价）'}$profitSuffix';
  }

  /// 使用记录描述 — 消耗/卖出
  String usageConsumeLine({
    required double quantity,
    required double remaining,
  }) {
    final qty = _formatQty(quantity);
    final remain = _formatQty(remaining);
    if (spaceType == SpaceType.shop) {
      return '$consumeVerb $qty  剩余$remain';
    }
    return '使用 $qty  剩余$remain';
  }

  String formatCurrency(double amount) => '¥${amount.toStringAsFixed(2)}';

  static String _formatQty(double v) => v == v.roundToDouble()
      ? v.toInt().toString()
      : v.toStringAsFixed(1);

  /// 一键出库按钮：用了 1 / 卖出 1（含单位）
  String consumeQuickLabel({String unit = ''}) {
    final trimmed = unit.trim();
    if (trimmed.isNotEmpty) return '$consumeVerb 1 $trimmed';
    return '$consumeVerb 1 件';
  }

  /// 清单库存展示：现有 x 瓶
  String stockDisplayLabel({required double quantity, required String unit}) {
    final qtyText = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    return '现有 $qtyText $unit';
  }

  /// 分享清单标题行
  String shoppingListShareHeader(String date) => '📋 $shoppingListLabel ($date)';

  /// 无法理解时的引导
  String helpReply() => '我没太听懂，不过查库存我在行。试试下面这些问题：';

  /// 查询出错
  String get queryError => '查询时出了点问题，稍后再问我吧。';

  String spaceNameMissing() => '得告诉我要查哪个空间哦，比如「${spaceSuggestions.first}」。';

  String spaceNotFound(String spaceName) =>
      '没找到叫「$spaceName」的空间，去「位置管理」瞅一眼？';

  String spaceEmpty(String fullPath) =>
      spaceType == SpaceType.shop
          ? '「$fullPath」现在空空如也，适合新进一批货～'
          : '「$fullPath」现在空空如也，正好适合新囤货～';

  String spaceItemsFound({
    required String fullPath,
    required int total,
    required int shown,
  }) {
    final more = total > shown ? '（共 $total 件，先列前 $shown 件）' : '';
    final tail = spaceType == SpaceType.shop ? '货架挺满：' : '挺热闹：';
    return '「$fullPath」下有 $total 件东西$more，$tail';
  }

  String itemNameMissing() => '想找啥？直接说名字，比如「牛奶在哪」。';

  String itemNotFound(String itemName) =>
      '没找到「$itemName」——换个词试试，或用 + $addItemLabel。';

  String itemFoundSingle({
    required String name,
    required String location,
    required String quantityText,
  }) =>
      '找到了！「$name」在 $location，还剩 $quantityText。';

  String itemFoundMultiple(int count, String itemName) =>
      '和「$itemName」相关的有 $count 个，都在这儿：';

  String get expiringAllClear => spaceType == SpaceType.shop
      ? '近 7 天没有临期或过期，货架状态不错～'
      : '近 7 天没有临期或过期，冰箱状态不错，继续保持～';

  String expiringFound({
    required int total,
    required int expired,
    required int expiring,
  }) =>
      '有 $total 件值得留意（已过期 $expired，临期 $expiring），建议先处理最急的那件：';

  String get lowStockAllClear => spaceType == SpaceType.shop
      ? '库存都挺充裕，暂时不用补货。'
      : '库存都挺充裕，暂时不用补货。';

  String lowStockFound(int count) => spaceType == SpaceType.shop
      ? '有 $count 件快断货了，采购清单可以考虑它们：'
      : '有 $count 件快见底了，补货清单可以考虑它们：';

  String get pendingAllClear => spaceType == SpaceType.shop
      ? '目前没有要优先处理的事，今天可以松口气～'
      : '目前没有要优先处理的事，今天可以偷个懒～';

  String pendingFound(int count) =>
      '建议先搞定这 $count 件，处理完会轻松不少：';

  String dailyCrisisHeadline({
    required String itemName,
    required DailyCrisisKind kind,
  }) {
    return switch (kind) {
      DailyCrisisKind.expired => '管管提醒：「$itemName」已过期',
      DailyCrisisKind.expiring => spaceType == SpaceType.shop
          ? '管管提醒：「$itemName」临期了'
          : '管管提醒：「$itemName」快过期了',
      DailyCrisisKind.lowStock => spaceType == SpaceType.shop
          ? '管管提醒：「$itemName」快断货了'
          : '管管提醒：「$itemName」快见底了',
    };
  }

  String dailyCrisisSubline({required int otherCount}) {
    if (otherCount <= 0) return '今天先搞定这一件？';
    return '还有 $otherCount 件待处理 · 先搞定这一件？';
  }

  /// 首页危机 Banner 统计行（过期/临期/低库存或断货）
  String bannerDetailLine({
    required int expiredCount,
    required int expiringCount,
    required int lowStockCount,
  }) {
    final parts = <String>[];
    if (expiredCount > 0) parts.add('$expiredCount 件已过期');
    if (expiringCount > 0) parts.add('$expiringCount 件临期');
    if (lowStockCount > 0) {
      parts.add(
        spaceType == SpaceType.shop
            ? '$lowStockCount 件快断货'
            : '$lowStockCount 件需补货',
      );
    }
    return parts.join(' · ');
  }

  /// 主危机快捷 Chip 文案
  String crisisPrimaryChipLabel(DailyCrisisKind kind) => switch (kind) {
        DailyCrisisKind.expired => '先处理过期',
        DailyCrisisKind.expiring => '先处理临期',
        DailyCrisisKind.lowStock =>
          spaceType == SpaceType.shop ? '先处理断货' : '先补货',
      };

  /// 次要低库存 Chip — 店铺显示「断货」
  String get lowStockChipLabel =>
      spaceType == SpaceType.shop ? '断货' : '低库存';

  String get dailyAllClear => spaceType == SpaceType.shop
      ? '今天暂无待处理，管管给你点个赞'
      : '今天暂无待处理，管管给你点个赞';

  String celebrateConsume({
    required String itemName,
    required bool depleted,
  }) {
    if (depleted) {
      return '干得漂亮！「$itemName」记上了，这一项搞定～';
    }
    if (spaceType == SpaceType.shop) {
      return '好嘞！「$itemName」$consumeVerb 1 份，库存更新啦。';
    }
    return '好嘞！「$itemName」用掉 1 份，离整洁厨房又近一步。';
  }

  String celebrateDiscard(String itemName) => spaceType == SpaceType.shop
      ? '「$itemName」已标记下架，腾出的位置留给新货。'
      : '「$itemName」已标记丢弃，腾出的空间留给更好的东西。';

  String celebrateAddShopping(String itemName) =>
      '「$itemName」加进$shoppingListLabel了，下次采购别忘记～';

  String addItemPrefillReply(AddItemNlResult draft) {
    final parts = <String>['好，我先帮你记一笔「${draft.name}」'];
    if (draft.locationHint != null) {
      parts.add('位置：${draft.locationHint}');
    }
    if (draft.quantity != null) {
      final u = draft.unit ?? '';
      parts.add('数量：${draft.quantity}$u');
    }
    parts.add('点下面按钮进向导确认就行');
    return parts.join('，');
  }

  String get addItemParseFailed => spaceType == SpaceType.shop
      ? '没听清要进什么货，试试：进了10箱可乐放店面'
      : '没听清要添加什么，试试：添加牛奶在冰箱';

  String weeklyInsightLabel(DateTime now) {
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return '本周复盘 · ${monday.month}/${monday.day} 起';
  }

  String weeklyInsightHeadline({
    required GuanguanAchievementKind? achievement,
    required int recordCount,
    required int consumeCount,
  }) {
    if (achievement == GuanguanAchievementKind.zeroWasteWeek) {
      return spaceType == SpaceType.shop
          ? '本周零断货！管管给你颁个小红花 🌿'
          : '本周零浪费！管管给你颁个小红花 🌿';
    }
    final actions = recordCount + consumeCount;
    if (actions >= 5) {
      return spaceType == SpaceType.shop
          ? '本周店面挺热闹，库存管得不错'
          : '本周厨房小剧场挺热闹，库存管得不错';
    }
    if (actions > 0) {
      return spaceType == SpaceType.shop ? '本周经营小结，继续加油' : '本周烟火日常小结，继续加油';
    }
    return spaceType == SpaceType.shop
        ? '本周偏安静，有空整理一下货架？'
        : '本周偏安静，有空整理一下冰箱？';
  }

  List<String> weeklyInsightSummaryLines({
    required int recordCount,
    required int consumeCount,
    required int newItemCount,
    required int greenStreakDays,
  }) {
    final outbound = spaceType == SpaceType.shop ? '卖出' : '消耗';
    final inbound = spaceType == SpaceType.shop ? '进货' : '录入';
    final lines = <String>[
      '$inbound $recordCount 次 · $outbound $consumeCount 次',
    ];
    if (newItemCount > 0) {
      lines.add(spaceType == SpaceType.shop
          ? '新进货 $newItemCount 件'
          : '新入库 $newItemCount 件');
    }
    if (greenStreakDays >= 3) {
      lines.add('健康分连续 $greenStreakDays 天满分');
    }
    return lines;
  }

  String achievementTitle(GuanguanAchievementKind kind) {
    return switch (kind) {
      GuanguanAchievementKind.zeroWasteWeek =>
        spaceType == SpaceType.shop ? '本周零断货' : '本周零浪费',
    };
  }

  String achievementSubtitle(GuanguanAchievementKind kind) {
    return switch (kind) {
      GuanguanAchievementKind.zeroWasteWeek => spaceType == SpaceType.shop
          ? '连续 7 天无断货、临期、低库存，店面状态超稳'
          : '连续 7 天无过期、临期、低库存，厨房状态超稳',
    };
  }

  /// 协作 quip：录入多 / 消耗积极
  String? collaborationQuip({
    required String recordLeader,
    required String consumeLeader,
    required int recordLeaderTotal,
    required bool multipleMembers,
  }) {
    if (!multipleMembers) return null;
    if (recordLeader != consumeLeader) {
      if (spaceType == SpaceType.shop) {
        return '$recordLeader进货多，$consumeLeader卖出积极';
      }
      return '$recordLeader录入多，$consumeLeader消耗积极';
    }
    if (recordLeaderTotal >= 2) {
      return '最近 $recordLeader 最活跃，$orgMemberQuipSuffix';
    }
    return null;
  }

  static const home = SpaceSkinConfig(
    spaceType: SpaceType.home,
    orgLabel: '家庭',
    createSpaceTitle: '创建你的家庭',
    createSpaceSubtitle: '创建一个家庭空间，邀请家人一起管理物品',
    nameFieldHint: '给你的家庭起个名字',
    createButtonLabel: '创建家庭',
    spaceEmoji: '🏠',
    addItemLabel: '添加入库',
    consumeVerb: '用了',
    consumeActionLabel: '记消耗',
    shoppingListLabel: '购物清单',
    addToShoppingLabel: '加入购物清单',
    searchHint: '搜索物品、位置、品牌',
    stockNoneLabel: '家里暂无',
    stockRedundantHint: '家里还有货，采购前确认',
    defaultSpaceName: '厨房',
    welcomeMessage: '你好，我是管管。可以问我物品在哪、某个空间有什么，或哪些需要处理。',
    assistantSuggestions: [
      '厨房有什么',
      '什么快过期',
      '库存不足',
      '有什么要处理',
    ],
    spaceSuggestions: ['厨房有什么', '卫生间有什么'],
    addItemExamples: [
      '添加牛奶在冰箱',
      '入库2瓶酸奶放厨房',
      '记一笔创可贴',
    ],
    addItemConfirmLabel: '去确认入库',
    panelNoTaskHint: '暂无优先任务，去提醒中心看看',
    orgMemberQuipSuffix: '全家协作继续加油',
    alertUseTodayLabel: '今天用掉',
    discardShortLabel: '已丢弃',
    purchasePriceLabel: '购买价格',
    purchasePriceFieldLabel: '单价（可选）',
    salePriceLabel: '售价',
    salePriceFieldLabel: '售价（可选）',
    supplierLabel: '',
    supplierFieldLabel: '',
    csvImportTitle: 'CSV 批量入库',
    csvImportSubtitle: '支持 Excel 另存为 CSV，按模板表头一次导入多条家庭物品。',
    csvTemplateButtonLabel: '下载模板',
    csvExportButtonLabel: '导出 CSV',
  );

  static const shop = SpaceSkinConfig(
    spaceType: SpaceType.shop,
    orgLabel: '店铺',
    createSpaceTitle: '创建你的店铺空间',
    createSpaceSubtitle: '轻量库存管理，手机记进货、查货架、补货提醒',
    nameFieldHint: '给你的店起个名字',
    createButtonLabel: '创建店铺',
    spaceEmoji: '🏪',
    addItemLabel: '进货',
    consumeVerb: '卖出',
    consumeActionLabel: '记卖出',
    shoppingListLabel: '采购清单',
    addToShoppingLabel: '加入采购清单',
    searchHint: '搜索商品、货架、品牌',
    stockNoneLabel: '店里暂无',
    stockRedundantHint: '店里还有货，采购前确认',
    defaultSpaceName: '店面',
    welcomeMessage: '你好，我是管管。可以问我商品在哪架、某个区域有什么，或哪些要补货。',
    assistantSuggestions: [
      '店面有什么',
      '什么快断货',
      '库存不足',
      '今天要补什么',
    ],
    spaceSuggestions: ['店面有什么', '库房有什么'],
    addItemExamples: [
      '进了10箱可乐放店面',
      '进货2打啤酒放冷柜',
      '记一笔红牛',
    ],
    addItemConfirmLabel: '去确认进货',
    panelNoTaskHint: '暂无优先任务，去提醒中心看看',
    orgMemberQuipSuffix: '团队继续加油',
    alertUseTodayLabel: '今天卖出',
    discardShortLabel: '已下架',
    purchasePriceLabel: '进货单价',
    purchasePriceFieldLabel: '进货单价（可选）',
    salePriceLabel: '售价',
    salePriceFieldLabel: '售价（可选）',
    supplierLabel: '供应商',
    supplierFieldLabel: '供应商（可选）',
    csvImportTitle: 'CSV 批量进货',
    csvImportSubtitle: '用 Excel 编辑后另存为 CSV，一次导入多条商品到库存。',
    csvTemplateButtonLabel: '下载进货模板',
    csvExportButtonLabel: '导出库存 CSV',
  );

  /// 按空间类型返回皮肤（未知回退 home）
  static SpaceSkinConfig forType(SpaceType type) {
    return switch (type) {
      SpaceType.home => home,
      SpaceType.shop => shop,
    };
  }

  static SpaceSkinConfig parse(String? raw) => forType(SpaceType.parse(raw));
}
