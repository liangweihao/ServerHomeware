import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/providers/realtime_sync_status_provider.dart';

void main() {
  test('RealtimeSyncStatus 枚举包含四种状态', () {
    expect(RealtimeSyncStatus.values.length, 4);
    expect(RealtimeSyncStatus.values, contains(RealtimeSyncStatus.connected));
    expect(RealtimeSyncStatus.values, contains(RealtimeSyncStatus.reconnecting));
  });
}
