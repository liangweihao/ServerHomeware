import 'package:flutter/material.dart';

/// 卡通主题动效常量 — 按压缩放、弹性曲线、时长
abstract final class CartoonMotion {
  /// 按下时缩放比例
  static const double pressScale = 0.95;

  /// 按下动画时长
  static const Duration pressDownDuration = Duration(milliseconds: 100);

  /// 松开回弹时长
  static const Duration pressUpDuration = Duration(milliseconds: 350);

  /// Tab 指示器滑动时长
  static const Duration tabSlideDuration = Duration(milliseconds: 400);

  /// 按下曲线
  static const Curve pressDownCurve = Curves.easeOut;

  /// 松开弹性曲线
  static const Curve pressUpCurve = Curves.elasticOut;

  /// Tab 滑动曲线
  static const Curve tabSlideCurve = Curves.elasticOut;

  /// 空状态插画入场时长
  static const Duration emptyEnterDuration = Duration(milliseconds: 500);

  /// 空状态插画入场曲线
  static const Curve emptyEnterCurve = Curves.elasticOut;
}
