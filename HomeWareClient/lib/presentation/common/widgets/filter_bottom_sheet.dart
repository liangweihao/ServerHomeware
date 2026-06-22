import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'app_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final String? initialStatus;
  final String? initialLocation;
  final String? initialCategory;
  final String initialSort;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onLocationChanged;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<String> onSortChanged;

  const FilterBottomSheet({
    super.key,
    required this.initialStatus,
    required this.initialLocation,
    required this.initialCategory,
    required this.initialSort,
    required this.onStatusChanged,
    required this.onLocationChanged,
    required this.onCategoryChanged,
    required this.onSortChanged,
  });

  static void show(
    BuildContext context, {
    String? initialStatus,
    String? initialLocation,
    String? initialCategory,
    required String initialSort,
    required ValueChanged<String?> onStatusChanged,
    required ValueChanged<String?> onLocationChanged,
    required ValueChanged<String?> onCategoryChanged,
    required ValueChanged<String> onSortChanged,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialStatus: initialStatus,
        initialLocation: initialLocation,
        initialCategory: initialCategory,
        initialSort: initialSort,
        onStatusChanged: onStatusChanged,
        onLocationChanged: onLocationChanged,
        onCategoryChanged: onCategoryChanged,
        onSortChanged: onSortChanged,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _selectedStatus;
  late String? _selectedLocation;
  late String? _selectedCategory;
  late String _selectedSort;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus;
    _selectedLocation = widget.initialLocation;
    _selectedCategory = widget.initialCategory;
    _selectedSort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Material(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('状态筛选', _buildStatusChips()),
                    const SizedBox(height: 24),
                    _buildSection('位置筛选', _buildLocationChips()),
                    const SizedBox(height: 24),
                    _buildSection('分类筛选', _buildCategoryChips()),
                    const SizedBox(height: 24),
                    _buildSection('排序方式', _buildSortOptions()),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '筛选与排序',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedLocation = null;
                    _selectedCategory = null;
                  });
                },
                child: const Text('重置'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildStatusChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.statusFilters.map((status) {
        final isSelected = _selectedStatus == status;
        return _ChoiceChip(
          label: status,
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedStatus = selected ? status : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildLocationChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['全部', '厨房', '卫生间', '客厅', '主卧', '次卧', '阳台'].map((location) {
        final isSelected = _selectedLocation == location;
        return _ChoiceChip(
          label: location,
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedLocation = selected ? (location == '全部' ? null : location) : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ['全部', '食品饮料', '日用清洁', '个护美妆', '药品保健', '家用电器', '其他'].map((category) {
        final isSelected = _selectedCategory == category;
        return _ChoiceChip(
          label: category,
          isSelected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedCategory = selected ? (category == '全部' ? null : category) : null;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSortOptions() {
    return Column(
      children: AppConstants.sortOptions.map((sort) {
        final isSelected = _selectedSort == sort;
        return RadioListTile<String>(
          value: sort,
          groupValue: _selectedSort,
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedSort = value);
            }
          },
          title: Text(sort),
          contentPadding: EdgeInsets.zero,
          dense: true,
        );
      }).toList(),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AppButton(
          label: '确定',
          onPressed: () {
            widget.onStatusChanged(_selectedStatus);
            widget.onLocationChanged(_selectedLocation);
            widget.onCategoryChanged(_selectedCategory);
            widget.onSortChanged(_selectedSort);
            Navigator.pop(context);
          },
          isFullWidth: true,
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      backgroundColor: AppColors.primary.withOpacity(0.05),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
