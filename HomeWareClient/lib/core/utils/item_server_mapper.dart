import 'package:drift/drift.dart' show Value;

/// 服务端物品 JSON → Drift 预测字段映射
class ItemServerMapper {
  ItemServerMapper._();

  /// 解析 avg_daily_consumption
  static Value<double?> avgDailyConsumptionFromJson(Map<String, dynamic> json) {
    final raw = json['avg_daily_consumption'];
    if (raw == null) return const Value.absent();
    final parsed = _parseDouble(raw);
    if (parsed == null || parsed <= 0) return const Value.absent();
    return Value(parsed);
  }

  /// 解析 predicted_empty_date
  static Value<DateTime?> predictedEmptyDateFromJson(Map<String, dynamic> json) {
    final raw = json['predicted_empty_date'];
    if (raw == null) return const Value.absent();
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return const Value.absent();
    return Value(parsed);
  }

  static double? _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}
