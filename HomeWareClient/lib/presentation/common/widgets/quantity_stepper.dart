import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class QuantityStepper extends StatelessWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final String? unit;
  final ValueChanged<double> onChanged;

  const QuantityStepper({
    super.key,
    required this.value,
    this.min = 0.0,
    this.max = 9999.0,
    this.step = 1.0,
    this.unit,
    required this.onChanged,
  });

  bool get canDecrease => value > min;
  bool get canIncrease => value < max;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDecreaseButton(context),
          _buildValueDisplay(context),
          _buildIncreaseButton(context),
        ],
      ),
    );
  }

  Widget _buildDecreaseButton(BuildContext context) {
    return InkWell(
      onTap: canDecrease ? () => onChanged((value - step).clamp(min, max)) : null,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          Icons.remove,
          color: canDecrease ? AppColors.primary : AppColors.disabled,
        ),
      ),
    );
  }

  Widget _buildValueDisplay(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      constraints: const BoxConstraints(minWidth: 64),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        unit != null ? '$value $unit' : value.toString(),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildIncreaseButton(BuildContext context) {
    return InkWell(
      onTap: canIncrease ? () => onChanged((value + step).clamp(min, max)) : null,
      borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: Icon(
          Icons.add,
          color: canIncrease ? AppColors.primary : AppColors.disabled,
        ),
      ),
    );
  }
}
