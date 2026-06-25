import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// 阴影层级 — 避免嵌套元素叠多层硬阴影
enum CartoonShadowLevel {
  /// 无阴影（内层面板 / 小 Chip / 缩略图框）
  none,
  /// 轻阴影（小按钮、标签）
  subtle,
  /// 标准卡片
  card,
  /// 浮动层（底栏、FAB）
  floating,
}

/// 卡通主题专用装饰 — 柔和阴影 + 描边卡片
abstract final class CartoonDecorations {
  /// 卡通卡片描边宽度
  static const double borderWidth = 3.0;

  /// 暖色中性投影色 — 比主题色硬阴影更自然
  static Color get _shadowBase => const Color(0xFF5D4037);

  /// 统一柔和阴影（带 blur，避免 blurRadius:0 的「色块复制」感）
  static List<BoxShadow> shadows(
    CartoonShadowLevel level, {
    Color? tint,
  }) {
    final base = tint ?? _shadowBase;
    switch (level) {
      case CartoonShadowLevel.none:
        return const [];
      case CartoonShadowLevel.subtle:
        return [
          BoxShadow(
            color: base.withValues(alpha: 0.07),
            offset: const Offset(0, 2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ];
      case CartoonShadowLevel.card:
        return [
          BoxShadow(
            color: base.withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: base.withValues(alpha: 0.04),
            offset: const Offset(0, 1),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ];
      case CartoonShadowLevel.floating:
        return [
          BoxShadow(
            color: base.withValues(alpha: 0.14),
            offset: const Offset(0, 8),
            blurRadius: 20,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: base.withValues(alpha: 0.06),
            offset: const Offset(0, 2),
            blurRadius: 6,
            spreadRadius: 0,
          ),
        ];
    }
  }

  /// 兼容旧 API — 映射为柔和阴影（不再使用硬偏移 + 主题色块）
  static List<BoxShadow> stickerShadows(
    Color color, {
    Offset offset = Offset.zero,
    CartoonShadowLevel level = CartoonShadowLevel.card,
  }) {
    return shadows(level, tint: _shadowBase);
  }

  /// 卡通卡片完整装饰
  static BoxDecoration stickerCard({
    Color? fillColor,
    Color? borderColor,
    BorderRadius? borderRadius,
    CartoonShadowLevel shadowLevel = CartoonShadowLevel.card,
  }) {
    final border = borderColor ?? AppColors.primaryDark;
    return BoxDecoration(
      color: fillColor ?? AppColors.white,
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      border: Border.all(
        color: border.withValues(alpha: 0.9),
        width: borderWidth,
      ),
      // 投影用中性暖色，不用 borderColor 染色，避免「橙色/蓝色色块」
      boxShadow: shadows(shadowLevel),
    );
  }

  /// 贴纸表面装饰
  static BoxDecoration stickerSurface({BorderRadius? borderRadius}) {
    return stickerCard(borderRadius: borderRadius);
  }
}

/// 卡通点阵背景绘制
class CartoonDotGridPainter extends CustomPainter {
  CartoonDotGridPainter({required this.dotColor, this.spacing = 22});

  final Color dotColor;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dotColor;
    const radius = 1.6;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CartoonDotGridPainter oldDelegate) {
    return oldDelegate.dotColor != dotColor || oldDelegate.spacing != spacing;
  }
}

/// 卡通闪粉点缀绘制
class CartoonSparklePainter extends CustomPainter {
  CartoonSparklePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const spots = [
      Offset(0.12, 0.08),
      Offset(0.78, 0.15),
      Offset(0.92, 0.42),
      Offset(0.18, 0.55),
      Offset(0.65, 0.72),
      Offset(0.35, 0.88),
    ];

    for (final p in spots) {
      _drawStar(
        canvas,
        paint,
        Offset(p.dx * size.width, p.dy * size.height),
        5,
      );
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double r) {
    canvas.drawCircle(center, r * 0.35, paint);
    canvas.drawCircle(Offset(center.dx - r * 0.5, center.dy), r * 0.2, paint);
    canvas.drawCircle(Offset(center.dx + r * 0.5, center.dy), r * 0.2, paint);
    canvas.drawCircle(Offset(center.dx, center.dy - r * 0.5), r * 0.2, paint);
    canvas.drawCircle(Offset(center.dx, center.dy + r * 0.5), r * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CartoonSparklePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// 简易云朵装饰（重叠圆模拟）
class CartoonCloud extends StatelessWidget {
  const CartoonCloud({
    super.key,
    required this.color,
    this.width = 120,
    this.height = 56,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: width * 0.08, top: height * 0.35, child: _bubble(width * 0.28)),
          Positioned(left: width * 0.28, top: height * 0.12, child: _bubble(width * 0.38)),
          Positioned(left: width * 0.52, top: height * 0.28, child: _bubble(width * 0.32)),
          Positioned(left: width * 0.68, top: height * 0.42, child: _bubble(width * 0.22)),
        ],
      ),
    );
  }

  Widget _bubble(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryDark.withValues(alpha: 0.12),
          width: 2,
        ),
      ),
    );
  }
}
