import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/icons/preset_icon.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../category_form_policy.dart';
import '../category_recent_storage.dart';
import '../../common/widgets/category_selector.dart';

/// 录入页分类 Chip：最近 3 个 + 7 个常用一级 +「全部分类」
class ItemFormCategoryChips extends ConsumerStatefulWidget {
  final Category? selectedCategory;
  final bool isEditMode;
  final ValueChanged<Category> onSelected;

  const ItemFormCategoryChips({
    super.key,
    required this.selectedCategory,
    required this.onSelected,
    this.isEditMode = false,
  });

  @override
  ConsumerState<ItemFormCategoryChips> createState() =>
      _ItemFormCategoryChipsState();
}

class _ItemFormCategoryChipsState extends ConsumerState<ItemFormCategoryChips> {
  List<int> _recentIds = [];

  @override
  void initState() {
    super.initState();
    if (!widget.isEditMode) {
      _loadRecent();
    }
  }

  Future<void> _loadRecent() async {
    final ids = await CategoryRecentStorage.load();
    if (mounted) setState(() => _recentIds = ids);
  }

  void _openFullSelector() {
    if (!mounted) return;
    CategorySelector.show(
      context,
      selectedCategory: widget.selectedCategory,
      onSelected: (category) async {
        if (!widget.isEditMode) {
          await CategoryRecentStorage.record(category.id);
          await _loadRecent();
        }
        widget.onSelected(category);
      },
    );
  }

  Color _chipColor(Category category) {
    final hex = category.color?.replaceFirst('#', '') ?? '';
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16)).withOpacity(0.15);
    }
    return AppColors.chipBackground;
  }

  Color _chipFill(Category category) {
    final selected = widget.selectedCategory?.id == category.id;
    if (AppColors.isUtilityStyle) {
      return selected ? AppColors.chipSelectedBackground : AppColors.chipBackground;
    }
    return _chipColor(category);
  }

  Color _chipBorder(Category category) {
    final selected = widget.selectedCategory?.id == category.id;
    return selected ? AppColors.primary : AppColors.border;
  }

  double _chipBorderWidth(Category category) {
    return widget.selectedCategory?.id == category.id ? 2 : 1;
  }

  Widget _buildChip(Category category, {VoidCallback? onTap}) {
    final selected = widget.selectedCategory?.id == category.id;
    return Padding(
      padding: const EdgeInsets.only(right: 8, bottom: 8),
      child: InkWell(
        onTap: onTap ??
            () async {
              if (!widget.isEditMode) {
                await CategoryRecentStorage.record(category.id);
                await _loadRecent();
              }
              widget.onSelected(category);
            },
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _chipFill(category),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(
              color: _chipBorder(category),
              width: _chipBorderWidth(category),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (category.icon != null && category.icon!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: PresetIcon(
                    storageKey: category.icon,
                    name: category.name,
                    accentHex: category.color,
                    wellSize: 22,
                    iconSize: 12,
                  ),
                ),
              Text(
                category.name,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(databaseProvider);

    return FutureBuilder<List<Category>>(
      future: db.getTopLevelCategories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 36,
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final allTop = snapshot.data!;
        final pinned = CategoryFormPolicy.pinnedTopLevelIds
            .map((id) => allTop.where((c) => c.id == id).firstOrNull)
            .whereType<Category>()
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isEditMode && _recentIds.isNotEmpty)
              FutureBuilder<List<Category?>>(
                future: Future.wait(
                  _recentIds.map((id) => db.getCategoryById(id)),
                ),
                builder: (context, recentSnap) {
                  if (!recentSnap.hasData) return const SizedBox.shrink();
                  final recent = recentSnap.data!.whereType<Category>().toList();
                  if (recent.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '最近使用',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        children: recent.map((c) => _buildChip(c)).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              ),
            Wrap(
              children: [
                ...pinned.map((c) => _buildChip(c)),
                Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: OutlinedButton(
                    onPressed: _openFullSelector,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    ),
                    child: const Text('全部分类', style: TextStyle(fontSize: 13)),
                  ),
                ),
              ],
            ),
            if (widget.selectedCategory != null &&
                !pinned.any((c) => c.id == widget.selectedCategory!.id) &&
                !_recentIds.contains(widget.selectedCategory!.id))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  children: [
                    Text(
                      '已选：',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    _buildChip(widget.selectedCategory!),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
