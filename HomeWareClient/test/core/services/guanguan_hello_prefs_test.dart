import 'package:flutter_test/flutter_test.dart';
import 'package:home_stock/core/services/guanguan_hello_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GuanguanHelloPrefs', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('首次应播放 hello', () async {
      expect(await GuanguanHelloPrefs.shouldPlayHelloToday(), isTrue);
    });

    test('标记后今日不再播放', () async {
      await GuanguanHelloPrefs.markHelloShownToday();
      expect(await GuanguanHelloPrefs.shouldPlayHelloToday(), isFalse);
    });
  });
}
