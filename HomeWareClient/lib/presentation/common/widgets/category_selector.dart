import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/database/app_database.dart';

class CategorySelector extends StatelessWidget {
  final Category? selectedCategory;
  final ValueChanged<Category> onSelected;

  const CategorySelector({
    super.key,
    this.selectedCategory,
    required this.onSelected,
  });

  static void show(
    BuildContext context, {
    Category? selectedCategory,
    required ValueChanged<Category> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategorySelector(
        selectedCategory: selectedCategory,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.85,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _buildCategoryGrid(context, scrollController),
            ),
            _buildAddButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '选择分类',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(BuildContext context, ScrollController scrollController) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(topLevelCategoriesProvider);
        return categoriesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('加载失败: $error')),
          data: (categories) => GridView.builder(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory?.id == category.id;
              return _buildCategoryItem(context, category, isSelected);
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category category, bool isSelected) {
    return GestureDetector(
      onTap: () {
        onSelected(category);
        Navigator.pop(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.disabled.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('新增自定义分类'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => _showAddDialog(context, ref),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';

    final icons = [
      '📦', '🍎', '🥩', '🥦', '🍪', '🥤', '🧂',
      '🧹', '🧴', '💊', '📺', '👕', '🛋️', '🔌',
      '📎', '🐾', '🍼', '⚽', '🚗', '🔧', '💡',
      '🖼️', '🛏️', '🧸', '🦴', '🏋️', '🛟', '📱',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('新增自定义分类'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '分类名称',
                    hintText: '如：茶具、相册',
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: icons.map((icon) => GestureDetector(
                    onTap: () => setDialogState(() => selectedIcon = icon),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: selectedIcon == icon
                            ? AppColors.primary.withOpacity(0.15)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: selectedIcon == icon
                            ? Border.all(color: AppColors.primary)
                            : null,
                      ),
                      child: Text(icon, style: const TextStyle(fontSize: 24)),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                final db = ref.read(databaseProvider);
                final category = CategoriesCompanion.insert(
                  name: name,
                  icon: selectedIcon,
                  color: '#78909C',
                  isSystem: Value(false),
                  sortOrder: Value(99),
                );
                await db.insertCategory(category);
                // 刷新分类列表
                ref.invalidate(topLevelCategoriesProvider);
                Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已添加分类「$name」')),
                  );
                }
              },
              child: const Text('创建'),
            ),
          ],
        ),
      ),
    );
  }
}
