import 'add_item_nl_parser.dart';
import 'assistant_models.dart';

/// 端侧规则解析 — 不依赖大模型（Phase 1 查询 + M5 入库 + B4 店铺词表）
class AssistantParser {
  static const _expiringKeywords = ['临期', '过期', '快过期', '到期', '还能放'];
  /// 家庭 + 店铺低库存/断货关键词（skin 无关，合并匹配）
  static const _lowStockKeywords = [
    '库存不足',
    '快没了',
    '不够',
    '低库存',
    '快用完',
    '断货',
    '快断货',
  ];
  /// 家庭待处理 + 店铺补货询问
  static const _pendingKeywords = [
    '要处理',
    '待处理',
    '怎么办',
    '需要处理',
    '今天要补什么',
    '要补什么',
    '补什么',
  ];

  /// 解析用户输入
  static AssistantParsedQuery parse(String raw) {
    final msg = raw.trim();
    if (msg.isEmpty) {
      return const AssistantParsedQuery(intent: AssistantIntentType.unknown);
    }

    // M5 — 添加入库优先于查询（避免「添加」被误判）
    final addDraft = AddItemNlParser.parse(msg);
    if (addDraft.isAddIntent) {
      return AssistantParsedQuery(
        intent: AssistantIntentType.addItem,
        addItemDraft: addDraft,
      );
    }

    if (_containsAny(msg, _pendingKeywords)) {
      return const AssistantParsedQuery(intent: AssistantIntentType.queryPending);
    }
    if (_containsAny(msg, _expiringKeywords)) {
      return const AssistantParsedQuery(intent: AssistantIntentType.queryExpiring);
    }
    if (_containsAny(msg, _lowStockKeywords)) {
      return const AssistantParsedQuery(intent: AssistantIntentType.queryLowStock);
    }

    final space = _extractSpaceName(msg);
    if (space != null) {
      return AssistantParsedQuery(
        intent: AssistantIntentType.querySpaceItems,
        spaceName: space,
      );
    }

    final item = _extractItemName(msg);
    if (item != null) {
      return AssistantParsedQuery(
        intent: AssistantIntentType.queryItemLocation,
        itemName: item,
      );
    }

    // 复杂语义 / 症状护理诉求 → 交给大模型，不走短词兜底
    if (_looksLikeSymptomOrNeed(msg)) {
      return const AssistantParsedQuery(intent: AssistantIntentType.unknown);
    }

    // 短词默认当作物品名查询（如「创可贴」「牛奶」）
    if (msg.length <= 12 && !_looksLikeQuestion(msg)) {
      return AssistantParsedQuery(
        intent: AssistantIntentType.queryItemLocation,
        itemName: msg,
      );
    }

    return const AssistantParsedQuery(intent: AssistantIntentType.unknown);
  }

  static bool _containsAny(String msg, List<String> keys) {
    return keys.any(msg.contains);
  }

  static bool _looksLikeQuestion(String msg) {
    return msg.contains('?') || msg.contains('？') || msg.contains('吗');
  }

  /// 交给 LLM 处理的意图前缀 — 规则引擎无法处理的复杂语义
  static const _llmIntentPrefixes = [
    '我想吃', '想吃', '我要做', '要做', '做个', '做一个', '做一道',
    '手受伤', '脚受伤', '手划破', '手破了', '头疼', '发烧', '感冒', '肚子疼',
    '手有点', '手很', '手太', '手干', '手粗', '皮肤干燥', '皮肤粗糙',
    '有点粗糙', '有点干', '很干燥',
    '帮我', '推荐', '建议', '怎么做',
  ];

  /// 症状/护理诉求 — 应走 LLM 而非短词物品查询
  static bool _looksLikeSymptomOrNeed(String msg) {
    if (_containsAny(msg, _llmIntentPrefixes)) return true;

    // 身体部位 + 状态/不适描述（如「皮肤很干」「嗓子痒」）
    if (RegExp(r'(手|脚|皮肤|头发|嗓子|眼睛|肚子).*(粗糙|干燥|干|痒|痛|疼|裂|脱皮|不舒服|难受)')
        .hasMatch(msg)) {
      return true;
    }

    // 第一人称身体状况，排除「我…在哪/有没有」类物品查询
    if (RegExp(r'^我(的)?(手|脚|皮肤|头|肚子|嗓子|眼睛)').hasMatch(msg) &&
        !_looksLikeItemQuery(msg)) {
      return true;
    }
    return false;
  }

  /// 是否像查物品库存/位置的句式
  static bool _looksLikeItemQuery(String msg) {
    return msg.contains('在哪') ||
        msg.contains('在哪里') ||
        msg.contains('在哪儿') ||
        msg.contains('有没有') ||
        msg.contains('还有') ||
        msg.contains('剩多少');
  }


  static String? _extractSpaceName(String msg) {
    final patterns = [
      RegExp(r'^(.+?)(有什么|还有啥|还剩什么|里有什么|里面有什么|有哪些)$'),
      RegExp(r'^(.+?)(的物品|的东西)$'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(msg);
      if (m != null) {
        final space = m.group(1)?.trim();
        if (space != null && space.isNotEmpty && space.length <= 20) {
          return _stripFillers(space);
        }
      }
    }
    return null;
  }

  /// 「牛奶在哪」「红牛还剩多少」「还有牛奶吗」
  static String? _extractItemName(String msg) {
    // B4 店铺：还剩多少 / 剩多少
    final remainQty = RegExp(r'^(.+?)(还剩多少|剩多少)$');
    final mRemain = remainQty.firstMatch(msg);
    if (mRemain != null) {
      final name = _stripFillers(mRemain.group(1)?.trim() ?? '');
      if (name.isNotEmpty && name.length <= 30) return name;
    }

    final where = RegExp(r'^(.+?)(在哪|在哪里|在哪儿|放在哪|放哪|的位置)$');
    final mWhere = where.firstMatch(msg);
    if (mWhere != null) {
      final name = _stripFillers(mWhere.group(1)?.trim() ?? '');
      if (name.isNotEmpty && name.length <= 30) return name;
    }

    final has = RegExp(r'^(还有|有没有)(.+?)(吗|？|\?)?$');
    final mHas = has.firstMatch(msg);
    if (mHas != null) {
      final name = _stripFillers(mHas.group(2)?.trim() ?? '');
      if (name.isNotEmpty && name.length <= 30) return name;
    }

    final still = RegExp(r'^(.+?)还有吗$');
    final mStill = still.firstMatch(msg);
    if (mStill != null) {
      final name = _stripFillers(mStill.group(1)?.trim() ?? '');
      if (name.isNotEmpty && name.length <= 30) return name;
    }

    return null;
  }

  static String _stripFillers(String s) {
    return s
        .replaceAll(RegExp(r'^(请问|帮我查|查一下|看看)'), '')
        .replaceAll(RegExp(r'(里的|中的|里面)$'), '')
        .trim();
  }
}
