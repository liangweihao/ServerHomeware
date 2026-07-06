import 'package:flutter/foundation.dart' show debugPrint;

/// M5 规则 NL 入库 — 解析结果（不含 DB 依赖，便于单测）
class AddItemNlResult {
  const AddItemNlResult({
    required this.raw,
    this.name,
    this.locationHint,
    this.quantity,
    this.unit,
    this.expiryDate,
    this.shelfLifeDays,
    this.missingFields = const [],
  });

  /// 无法识别为添加入库意图
  const AddItemNlResult.notAddIntent(this.raw)
      : name = null,
        locationHint = null,
        quantity = null,
        unit = null,
        expiryDate = null,
        shelfLifeDays = null,
        missingFields = const [];

  final String raw;
  final String? name;
  final String? locationHint;
  final double? quantity;
  final String? unit;
  final DateTime? expiryDate;
  final int? shelfLifeDays;
  final List<String> missingFields;

  bool get isAddIntent => name != null && name!.isNotEmpty;

  /// 序列化 — 跨页面传递
  Map<String, dynamic> toJson() => {
        'raw': raw,
        'name': name,
        'locationHint': locationHint,
        'quantity': quantity,
        'unit': unit,
        'expiryDate': expiryDate?.toIso8601String(),
        'shelfLifeDays': shelfLifeDays,
        'missingFields': missingFields,
      };

  factory AddItemNlResult.fromJson(Map<String, dynamic> json) {
    return AddItemNlResult(
      raw: json['raw']?.toString() ?? '',
      name: json['name']?.toString(),
      locationHint: json['locationHint']?.toString(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit']?.toString(),
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'].toString())
          : null,
      shelfLifeDays: json['shelfLifeDays'] as int?,
      missingFields: (json['missingFields'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

/// 规则 NL 解析 — 不依赖大模型
abstract final class AddItemNlParser {
  /// 家庭入库 + 店铺进货前缀（进了/进货/补货）
  static final _addPrefix = RegExp(
    r'^(帮我|请帮我|请)?(添加|加|加入|入库|记一笔|记一下|新增|购买|买了|添加入库|进了|进货|补货)(一下|一个|一件|一种)?',
  );

  static final _qtyUnit = RegExp(
    r'^(\d+(?:\.\d+)?)\s*(瓶|盒|袋|个|件|包|罐|箱|提|升|ml|mL|ML|克|g|G|kg|KG|斤|条|根|卷|片|只|双|对|套|组|桶|听|杯|支|块|颗|粒|把|捆|扎|板|板装|板)',
  );

  static final _qtyUnitInline = RegExp(
    r'(\d+(?:\.\d+)?)\s*(瓶|盒|袋|个|件|包|罐|箱|提|升|ml|mL|ML|克|g|G|kg|KG|斤|条|根|卷|片|只|双|对|套|组|桶|听|杯|支|块|颗|粒|把|捆|扎)',
  );

  static final _locationPatterns = [
    RegExp(r'(.+?)在(.+?)(里|中|内|吧|上|下)?$'),
    RegExp(r'(.+?)放(.+?)(里|中|内|上|下)?$'),
    RegExp(r'(.+?)到(.+?)(里|中|内|上|下)?$'),
  ];

  static final _expiryIso = RegExp(
    r'过期[:：]?\s*(\d{4})[-/年](\d{1,2})[-/月](\d{1,2})日?',
  );

  static final _shelfLifeDays = RegExp(r'保质期\s*(\d+)\s*天');

  /// 解析一句话；非添加入库意图返回 [AddItemNlResult.notAddIntent]
  static AddItemNlResult parse(String raw) {
    var msg = raw.trim();
    if (msg.isEmpty) {
      return AddItemNlResult.notAddIntent(raw);
    }

    final hasPrefix = _addPrefix.hasMatch(msg);
    final shortPlace = _looksLikeShortPlace(msg);
    if (!hasPrefix && !shortPlace) {
      return AddItemNlResult.notAddIntent(raw);
    }

    if (hasPrefix) {
      msg = msg.replaceFirst(_addPrefix, '').trim();
    }

    debugPrint('[AddItemNlParser] INFO: 解析入库语句 remainder=$msg');

    double? quantity;
    String? unit;
    DateTime? expiryDate;
    int? shelfLifeDays;
    String? locationHint;
    var work = msg;

    // 保质期 N 天
    final shelfM = _shelfLifeDays.firstMatch(work);
    if (shelfM != null) {
      shelfLifeDays = int.tryParse(shelfM.group(1)!);
      work = work.replaceFirst(shelfM.group(0)!, '').trim();
    }

    // 过期日期
    final expM = _expiryIso.firstMatch(work);
    if (expM != null) {
      final y = int.parse(expM.group(1)!);
      final mo = int.parse(expM.group(2)!);
      final d = int.parse(expM.group(3)!);
      expiryDate = DateTime(y, mo, d);
      work = work.replaceFirst(expM.group(0)!, '').trim();
    }

    // 数量 + 单位（句首）
    final qtyHead = _qtyUnit.firstMatch(work);
    if (qtyHead != null) {
      quantity = double.tryParse(qtyHead.group(1)!);
      unit = _normalizeUnit(qtyHead.group(2)!);
      work = work.replaceFirst(qtyHead.group(0)!, '').trim();
    }

    // 位置：X在Y / X放Y
    for (final p in _locationPatterns) {
      final m = p.firstMatch(work);
      if (m != null) {
        final left = m.group(1)?.trim() ?? '';
        final right = m.group(2)?.trim() ?? '';
        if (left.isNotEmpty &&
            right.isNotEmpty &&
            right.length <= 20 &&
            !_isQueryLocationWord(right)) {
          locationHint = _stripLocSuffix(right);
          work = left;
          break;
        }
      }
    }

    // 句中数量（名称后）
    if (quantity == null) {
      final qtyInline = _qtyUnitInline.firstMatch(work);
      if (qtyInline != null) {
        quantity = double.tryParse(qtyInline.group(1)!);
        unit = _normalizeUnit(qtyInline.group(2)!);
        work = work.replaceFirst(qtyInline.group(0)!, '').trim();
      }
    }

    var name = _stripFillers(work);
    name = name.replaceAll(RegExp(r'[，,、；;。\.]+$'), '').trim();

    if (name.isEmpty) {
      return AddItemNlResult.notAddIntent(raw);
    }

    final missing = <String>[];
    if (locationHint == null) missing.add('位置');
    if (expiryDate == null && shelfLifeDays == null) missing.add('过期日');

    return AddItemNlResult(
      raw: raw,
      name: name,
      locationHint: locationHint,
      quantity: quantity,
      unit: unit,
      expiryDate: expiryDate,
      shelfLifeDays: shelfLifeDays,
      missingFields: missing,
    );
  }

  static bool _looksLikeShortPlace(String msg) {
    if (RegExp(r'(在哪|在哪里|在哪儿|有什么|还有吗)').hasMatch(msg)) {
      return false;
    }
    if (RegExp(r'^.{1,16}(放|到).{1,16}$').hasMatch(msg)) return true;
    final m = RegExp(r'^(.{1,12})在(.{1,12})$').firstMatch(msg);
    if (m != null) {
      final place = m.group(2)?.trim() ?? '';
      return place.isNotEmpty && !_isQueryLocationWord(place);
    }
    return false;
  }

  static bool _isQueryLocationWord(String s) {
    return RegExp(r'^(哪|哪里|哪儿|何处)(里|啊|呢)?$').hasMatch(s.trim());
  }

  static String _normalizeUnit(String u) {
    final lower = u.toLowerCase();
    if (lower == 'ml') return 'ml';
    if (lower == 'g') return '克';
    if (lower == 'kg') return 'kg';
    return u;
  }

  static String _stripLocSuffix(String s) {
    return s
        .replaceAll(RegExp(r'(里|中|内|吧|上|下|里面|里面)$'), '')
        .replaceAll(RegExp(r'^的'), '')
        .trim();
  }

  static String _stripFillers(String s) {
    return s
        .replaceAll(RegExp(r'^(一|1)(个|件|瓶|盒|袋|包|罐|箱)'), '')
        .replaceAll(RegExp(r'^(请问|帮我|把)'), '')
        .trim();
  }
}
