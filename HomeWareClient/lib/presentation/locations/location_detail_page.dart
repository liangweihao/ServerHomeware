import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/app_button.dart';
import '../items/widgets/item_card.dart';
import 'widgets/location_card.dart';
import 'widgets/add_location_dialog.dart';

class LocationDetailPage extends ConsumerStatefulWidget {
  final int locationId;

  const LocationDetailPage({super.key, required this.locationId});

  @override
  ConsumerState<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends ConsumerState<LocationDetailPage> {
  bool _isEditMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Consumer(
        builder: (context, ref, child) {
          final locationAsync = FutureProvider((ref) => ref.read(databaseProvider).getLocationById(widget.locationId));
          final location = ref.watch(locationAsync);
          
          return location.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('加载失败: $error')),
            data: (location) {
              if (location == null) {
                return const AppEmptyState(
                  icon: '😕',
                  title: '位置不存在',
                  subtitle: '该位置可能已被删除',
                );
              }
              return _buildContent(context, ref, location);
            },
          );
        },
      ),
      floatingActionButton: _isEditMode ? _buildEditFAB(context, ref) : null,
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Consumer(
        builder: (context, ref, child) {
          final locationAsync = FutureProvider((ref) => ref.read(databaseProvider).getLocationById(widget.locationId));
          final location = ref.watch(locationAsync);
          return location.when(
            loading: () => const Text('加载中...'),
            error: (error, stack) => const Text('位置详情'),
            data: (location) => Text(location?.name ?? '位置详情'),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(_isEditMode ? Icons.check : Icons.edit),
          onPressed: () => setState(() => _isEditMode = !_isEditMode),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Location location) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<List<Location>>(
            future: ref.read(databaseProvider).getChildLocations(widget.locationId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 16);
              }
              final children = snapshot.data!;
              if (children.isNotEmpty) {
                return _buildChildLocations(context, ref, children);
              }
              return const SizedBox(height: 8);
            },
          ),
          FutureBuilder<List<Item>>(
            future: ref.read(databaseProvider).getItemsInLocation(widget.locationId),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 16);
              }
              final items = snapshot.data!;
              if (items.isNotEmpty) {
                return _buildItemList(context, items);
              }
              return _buildEmptyState(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChildLocations(BuildContext context, WidgetRef ref, List<Location> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '子位置',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            return FutureBuilder<int>(
              future: ref.read(databaseProvider).getItemCountForLocation(child.id),
              builder: (context, snapshot) {
                final itemCount = snapshot.data ?? 0;
                return LocationCard(
                  name: child.name,
                  icon: child.icon,
                  itemCount: itemCount,
                  onTap: () => context.go('/locations/${child.id}'),
                  onDelete: _isEditMode ? () => _confirmDeleteLocation(context, ref, child) : null,
                  showDelete: _isEditMode,
                );
              },
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildItemList(BuildContext context, List<Item> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '物品列表',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return ItemCard(
              item: items[index],
              onTap: () => context.go('/items/${items[index].id}'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return AppEmptyState(
      icon: '📦',
      title: '这个位置是空的',
      subtitle: '添加一些物品到这里吧',
      actionLabel: '添加物品',
      onAction: () => context.go('/items/add'),
    );
  }

  Widget _buildEditFAB(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () => _showAddChildLocation(context, ref),
      child: const Icon(Icons.add),
    );
  }

  void _showAddChildLocation(BuildContext context, WidgetRef ref) {
    FutureBuilder<Location?>(
      future: ref.read(databaseProvider).getLocationById(widget.locationId),
      builder: (context, snapshot) {
        AddLocationDialog.show(
          context,
          parentName: snapshot.data?.name,
          onConfirm: (data) async {
            final (name, icon) = data;
            final db = ref.read(databaseProvider);
            final parent = await db.getLocationById(widget.locationId);
            if (parent != null) {
              await db.insertLocation(
                LocationsCompanion.insert(
                  name: name,
                  icon: Value(icon),
                  parentId: Value(widget.locationId),
                  level: Value(parent.level + 1),
                  fullPath: '${parent.fullPath}/$name',
                  sortOrder: const Value(0),
                ),
              );
            }
          },
        );
        return const SizedBox();
      },
    );
  }

  void _confirmDeleteLocation(BuildContext context, WidgetRef ref, Location location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个位置吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          AppButton(
            label: '删除',
            variant: ButtonVariant.danger,
            onPressed: () async {
              final db = ref.read(databaseProvider);
              final itemCount = await db.getItemCountForLocation(location.id);
              if (itemCount > 0) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('该位置下有$itemCount件物品，请先移走物品再删除')),
                );
                return;
              }
              await db.deleteLocationAndChildren(location.id);
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('删除成功')),
                );
                context.pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
