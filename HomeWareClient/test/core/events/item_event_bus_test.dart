import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/events/item_event_bus.dart';
import 'package:home_stock/core/events/item_events.dart';

void main() {
  group('ItemEventBus', () {
    test('notifyCreated increments state and stores event', () {
      final bus = ItemEventBus();
      expect(bus.state, 0);
      expect(bus.lastEvent, isNull);

      bus.notifyCreated(itemId: 42);

      expect(bus.state, 1);
      expect(bus.lastEvent?.itemId, 42);
      expect(bus.lastEvent?.type, ItemChangeType.created);
    });

    test('notifyUpdated increments state', () {
      final bus = ItemEventBus();
      bus.notifyUpdated(itemId: 7);
      expect(bus.state, 1);
      bus.notifyUpdated(itemId: 8);
      expect(bus.state, 2);
    });

    test('notifyDeleted increments state', () {
      final bus = ItemEventBus();
      bus.notifyDeleted(itemId: 3);
      expect(bus.state, 1);
    });
  });
}
