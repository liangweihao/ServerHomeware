import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/icons/preset_icon.dart';
import '../../core/icons/preset_icon_picker.dart';
import '../../core/icons/preset_icon_registry.dart';
import '../../core/icons/candy_icon.dart';
import '../../core/icons/candy_icons.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/database_provider.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_card.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/app_fab.dart';
import '../common/widgets/warm_scaffold.dart';
import '../common/widgets/cartoon_ui.dart';

// Provider for categories
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getTopLevelCategories();
});

// Provider for child categories
final childCategoriesProvider = FutureProvider.family<List<Category>, int>((ref, parentId) async {
  final db = ref.watch(databaseProvider);
  return db.getChildCategories(parentId);
});

class CategoryManagementPage extends ConsumerStatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  ConsumerState<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends ConsumerState<CategoryManagementPage> {
  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return WarmScaffold(
      title: '分类管理',
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const AppEmptyState(
              icon: '🏷️',
              title: '暂无分类',
              subtitle: '添加你的第一个分类',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return _buildCategoryItem(category);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => AppEmptyState(
          icon: '❌',
          title: '加载失败',
          subtitle: error.toString(),
        ),
      ),
      floatingActionButton: AppFloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: const CandyIcon(CandyIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    final childCategoriesAsync = ref.watch(childCategoriesProvider(category.id));

    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          // 父分类
          InkWell(
            onTap: () {
              // TODO: 展开/收起子分类
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  PresetIcon(
                    storageKey: category.icon,
                    name: category.name,
                    accentHex: category.color,
                    wellSize: 40,
                    iconSize: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (category.isSystem)
                          Text(
                            '系统预设',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textHint,
                                ),
                          ),
                      ],
                    ),
                  ),
                  if (!category.isSystem)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showEditCategoryDialog(context, category);
                        } else if (value == 'delete') {
                          _deleteCategory(category);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('编辑')),
                        const PopupMenuItem(value: 'delete', child: Text('删除')),
                      ],
                    ),
                ],
              ),
            ),
          ),
          // 子分类
          childCategoriesAsync.when(
            data: (children) {
              if (children.isEmpty) return const SizedBox.shrink();

              return Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppRadius.lg),
                    bottomRight: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Column(
                  children: children.map((child) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          const SizedBox(width: 52),
                          PresetIcon(
                            storageKey: child.icon,
                            name: child.name,
                            accentHex: child.color,
                            wellSize: 32,
                            iconSize: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              child.name,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          if (!child.isSystem)
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditCategoryDialog(context, child);
                                } else if (value == 'delete') {
                                  _deleteCategory(child);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'edit', child: Text('编辑')),
                                const PopupMenuItem(value: 'delete', child: Text('删除')),
                              ],
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppColors.isUtilityStyle
          ? AppCard(padding: const EdgeInsets.all(16), child: card)
          : AppSurface(child: card),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';
    String selectedColor = AppColors.primaryHex;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('添加分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                  hintText: '请输入分类名称',
                ),
              ),
              const SizedBox(height: 16),
              // 图标选择 — 糖果轻点预置圆角图标
              PresetIconPickerWrap(
                options: PresetIconRegistry.categoryPickerOptions,
                selectedKey: selectedIcon,
                onSelected: (key) => setState(() => selectedIcon = key),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final db = ref.read(databaseProvider);
                await db.into(db.categories).insert(
                  CategoriesCompanion.insert(
                    name: nameController.text.trim(),
                    icon: selectedIcon,
                    color: selectedColor,
                    isSystem: const drift.Value(false),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(categoriesProvider);
                }
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon;
    String selectedColor = category.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('编辑分类'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '分类名称',
                ),
              ),
              const SizedBox(height: 16),
              // 图标选择 — 糖果轻点预置圆角图标
              PresetIconPickerWrap(
                options: PresetIconRegistry.categoryPickerOptions,
                selectedKey: selectedIcon,
                onSelected: (key) => setState(() => selectedIcon = key),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final db = ref.read(databaseProvider);
                await (db.update(db.categories)..where((c) => c.id.equals(category.id))).write(
                  CategoriesCompanion(
                    name: drift.Value(nameController.text.trim()),
                    icon: drift.Value(selectedIcon),
                    color: drift.Value(selectedColor),
                  ),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ref.invalidate(categoriesProvider);
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定删除 "${category.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final db = ref.read(databaseProvider);
              await (db.delete(db.categories)..where((c) => c.id.equals(category.id))).go();

              if (context.mounted) {
                Navigator.pop(context);
                ref.invalidate(categoriesProvider);
              }
            },
            child: const Text('删除', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
