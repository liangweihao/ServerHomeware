import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/providers/database_provider.dart';
import '../../../data/database/app_database.dart';
import '../../common/widgets/app_button.dart';

class RoomSelectStep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RoomSelectStep({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<RoomSelectStep> createState() => _RoomSelectStepState();
}

class _RoomSelectStepState extends ConsumerState<RoomSelectStep> {
  final Set<String> _selectedRooms = {};
  bool _isLoading = false;

  final List<String> _presetRooms = ['客厅', '卧室', '厨房', '卫生间', '书房', '阳台'];

  Future<void> _saveRoomsAndContinue() async {
    if (_selectedRooms.isEmpty) {
      widget.onNext();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = ref.read(databaseProvider);

      for (final roomName in _selectedRooms) {
        await db.into(db.locations).insert(
          LocationsCompanion.insert(
            name: roomName,
            icon: const Value('🏠'),
            level: const Value(1),
            fullPath: roomName,
            sortOrder: const Value(0),
          ),
        );
      }

      widget.onNext();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 返回按钮
          IconButton(
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(height: 16),

          // 标题
          Text(
            '你家有哪些空间？',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            '选择你有的房间，可以跳过',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 32),

          // 房间列表
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _presetRooms.map((room) {
                  final isSelected = _selectedRooms.contains(room);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedRooms.remove(room);
                        } else {
                          _selectedRooms.add(room);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textHint,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            room,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // 按钮
          const SizedBox(height: 24),
          AppButton(
            label: _selectedRooms.isEmpty ? '跳过' : '下一步',
            onPressed: _isLoading ? null : _saveRoomsAndContinue,
            isFullWidth: true,
            size: ButtonSize.large48,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
