import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/providers/database_provider.dart';
import '../../core/services/export_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            title: Text(
              '我的',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // 个人信息卡片
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '用户',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '管理员',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          // TODO: 编辑个人信息
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 功能列表
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        context,
                        icon: '🏠',
                        title: '空间管理',
                        onTap: () => context.push('/locations'),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        context,
                        icon: '🏷️',
                        title: '分类管理',
                        onTap: () => context.push('/profile/categories'),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        context,
                        icon: '👨‍👩‍👧‍👦',
                        title: '家庭成员',
                        onTap: () => context.push('/profile/family'),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        context,
                        icon: '📊',
                        title: '数据统计',
                        onTap: () => context.push('/statistics'),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        context,
                        icon: '🛒',
                        title: '购物清单',
                        onTap: () => context.push('/shopping'),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        context,
                        icon: '🔔',
                        title: '提醒设置',
                        onTap: () => context.push('/profile/notification-settings'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 第二组功能
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingItem(
                        context,
                        icon: '📤',
                        title: '数据导出',
                        onTap: () => _showExportDialog(context, ref),
                      ),
                      _buildDivider(),
                      _buildSettingItem(
                        context,
                        icon: 'ℹ️',
                        title: '关于',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 56),
      child: Divider(height: 1),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('数据导出'),
        content: const Text('选择导出范围'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await exportData(context, ref, ExportScope.all);
            },
            child: const Text('全部物品'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await exportData(context, ref, ExportScope.inUse);
            },
            child: const Text('仅使用中'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await exportData(context, ref, ExportScope.expired);
            },
            child: const Text('仅已过期'),
          ),
        ],
      ),
    );
  }

  Future<void> exportData(
    BuildContext context,
    WidgetRef ref,
    ExportScope scope,
  ) async {
    try {
      final db = ref.read(databaseProvider);
      final exportService = ExportService(db);

      final filePath = await exportService.exportToCsv(scope);

      if (filePath != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('导出成功'),
              action: SnackBarAction(
                label: '分享',
                onPressed: () => exportService.shareFile(filePath),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('关于 HomeStock'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: 1.0.0'),
            SizedBox(height: 8),
            Text('HomeStock 是一款家庭物品管理应用，帮助你管理家庭物品、追踪保质期、预测消耗。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
