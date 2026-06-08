import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart';
import '../../core/providers/database_provider.dart';
import '../../data/database/app_database.dart';
import '../common/widgets/app_empty_state.dart';
import '../common/widgets/app_button.dart';
import 'widgets/location_card.dart';
import 'widgets/add_location_dialog.dart';

class LocationOverviewPage extends ConsumerWidget {
  const LocationOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的家'),
        actions: [
          TextButton(
            onPressed: () => _showAddLocationDialog(context, ref),
            child: const Text('添加空间'),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final locationsAsync = ref.watch(topLevelLocationsProvider);
          return locationsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('加载失败: $error')),
            data: (locations) {
              if (locations.isEmpty) {
                return AppEmptyState(
                  icon: '🏠',
                  title: '还没有房间',
                  subtitle: '点击右上角添加第一个空间',
                  actionLabel: '添加空间',
                  onAction: () => _showAddLocationDialog(context, ref),
                );
              }
              return _buildLocationGrid(context, ref, locations);
            },
          );
        },
      ),
    );
  }

  Widget _buildLocationGrid(BuildContext context, WidgetRef ref, List<Location> locations) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: locations.length,
      itemBuilder: (context, index) {
        final location = locations[index];
        return FutureBuilder<int>(
          future: ref.read(databaseProvider).getItemCountForLocation(location.id),
          builder: (context, snapshot) {
            final itemCount = snapshot.data ?? 0;
            return LocationCard(
              name: location.name,
              icon: location.icon,
              itemCount: itemCount,
              onTap: () => context.go('/locations/${location.id}'),
            );
          },
        );
      },
    );
  }

  void _showAddLocationDialog(BuildContext context, WidgetRef ref) {
    AddLocationDialog.show(
      context,
      onConfirm: (name, icon, imagePath) async {
        final db = ref.read(databaseProvider);
        await db.insertLocation(
          LocationsCompanion.insert(
            name: name,
            icon: Value(icon),
            images: imagePath != null ? Value(jsonEncode([imagePath])) : const Value.absent(),
            level: const Value(1),
            fullPath: name,
            sortOrder: const Value(0),
          ),
        );
        ref.invalidate(topLevelLocationsProvider);
      },
    );
  }
}
