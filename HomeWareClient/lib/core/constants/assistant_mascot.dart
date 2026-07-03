/// 问管家 AI 吉祥物「管管」— 名称与序列帧资源
abstract final class AssistantMascot {
  /// 定稿中文名
  static const name = '管管';

  /// 三视图 turnaround（运行时裁切正面 1/3）
  static const turnaroundAsset =
      'assets/illustrations/homestock_ai_mascot_guanguan_turnaround.png';

  /// 第一组序列帧：打招呼「你好」（4 张关键帧）
  static const helloFrames = <String>[
    'assets/illustrations/guanguan/hello/guanguan_hello_01_idle.png',
    'assets/illustrations/guanguan/hello/guanguan_hello_02_raise_hand.png',
    'assets/illustrations/guanguan/hello/guanguan_hello_03_wave_hello.png',
    'assets/illustrations/guanguan/hello/guanguan_hello_04_settle.png',
  ];

  /// 各关键帧建议停留时长（毫秒）；帧 3 在播放时会重复 2 次模拟挥手
  static const helloFrameDurationsMs = <int>[500, 350, 280, 450];
}
