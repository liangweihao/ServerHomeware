import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum ColorMode { auto, fixed }

class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final ColorMode colorMode;
  final Color? fixedColor;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 4.0,
    this.colorMode = ColorMode.auto,
    this.fixedColor,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    
    final Color progressColor;
    if (colorMode == ColorMode.fixed && fixedColor != null) {
      progressColor = fixedColor!;
    } else {
      // Auto color based on value (value is remaining ratio, lower = more critical)
      if (clampedValue <= 0.3) {
        progressColor = AppColors.danger;
      } else if (clampedValue <= 0.6) {
        progressColor = AppColors.warning;
      } else {
        progressColor = AppColors.success;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: AppColors.border.withOpacity(0.5),
            borderRadius: BorderRadius.circular(height),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: clampedValue,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
        );
      },
    );
  }
}
