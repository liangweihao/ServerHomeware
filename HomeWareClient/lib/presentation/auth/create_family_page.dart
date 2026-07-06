import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:home_stock/core/icons/candy_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/space_skin_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/models/space_type.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/utils/error_handler.dart';
import 'widgets/auth_button.dart';
import 'widgets/auth_cartoon_wrap.dart';

/// 创建空间页 — Phase B：家庭 / 小店铺 二选一
class CreateFamilyPage extends ConsumerStatefulWidget {
  const CreateFamilyPage({super.key});

  @override
  ConsumerState<CreateFamilyPage> createState() => _CreateFamilyPageState();
}

class _CreateFamilyPageState extends ConsumerState<CreateFamilyPage> {
  final _nameController = TextEditingController();
  SpaceType _selectedType = SpaceType.home;
  String? _nameError;
  bool _isLoading = false;

  SpaceSkinConfig get _skin => SpaceSkinConfig.forType(_selectedType);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  /// 创建家庭或店铺空间
  Future<void> _createFamily() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _nameError = '请输入名称';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _nameError = null;
    });

    try {
      debugPrint(
        '[CreateFamilyPage] INFO: 创建空间 name=$name type=${_selectedType.apiValue}',
      );
      await ref.read(authProvider.notifier).createFamily(
            name: name,
            spaceType: _selectedType.apiValue,
          );

      if (mounted) {
        context.go('/');
      }
    } catch (e, stack) {
      ErrorHandler.handle(
        context,
        e,
        stack,
        label: '[CreateFamilyPage] _createFamily',
        userMessage: '创建失败，请稍后重试',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _goToJoinFamily() {
    context.push('/join-family');
  }

  void _selectType(SpaceType type) {
    if (_selectedType == type || _isLoading) return;
    setState(() => _selectedType = type);
    debugPrint('[CreateFamilyPage] INFO: 选择空间类型 ${type.apiValue}');
  }

  @override
  Widget build(BuildContext context) {
    final skin = _skin;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const CandyIcon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
          color: AppColors.gray700,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Text(
                        skin.spaceEmoji,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      authPageTitle('你主要管理什么？', emoji: '✨'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '选好后仍可邀请成员一起协作，同一 App 不换账号',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.gray500,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _SpaceTypeCard(
                            emoji: SpaceSkinConfig.home.spaceEmoji,
                            title: '家庭物品',
                            subtitle: '厨房、临期、购物清单',
                            selected: _selectedType == SpaceType.home,
                            onTap: () => _selectType(SpaceType.home),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SpaceTypeCard(
                            emoji: SpaceSkinConfig.shop.spaceEmoji,
                            title: '小店铺库存',
                            subtitle: '进货、卖货、补货提醒',
                            selected: _selectedType == SpaceType.shop,
                            onTap: () => _selectType(SpaceType.shop),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text(
                      skin.createSpaceTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gray900,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      skin.createSpaceSubtitle,
                      style: TextStyle(fontSize: 14, color: AppColors.gray500),
                    ),
                    const SizedBox(height: 20),
                    wrapAuthFormSurface(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _nameController,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: skin.nameFieldHint,
                              errorText: _nameError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: AppColors.gray300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: AppColors.primary),
                              ),
                              prefixIcon: CandyIcon(
                                _selectedType == SpaceType.shop
                                    ? Icons.storefront_outlined
                                    : Icons.home_outlined,
                              ),
                              prefixIconColor: AppColors.gray400,
                            ),
                            onChanged: (_) {
                              if (_nameError != null) {
                                setState(() => _nameError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '名称 2～15 个字符 · 创建后暂不支持切换类型',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gray400,
                            ),
                          ),
                          const SizedBox(height: 24),
                          AuthButton(
                            label: skin.createButtonLabel,
                            onPressed: _createFamily,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '已有邀请码？',
                          style: TextStyle(fontSize: 14, color: AppColors.gray700),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _goToJoinFamily,
                          child: Text(
                            '加入${SpaceSkinConfig.forType(_selectedType).orgLabel}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  _isLoading ? AppColors.gray400 : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// 空间类型选择卡片
class _SpaceTypeCard extends StatelessWidget {
  const _SpaceTypeCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.gray300,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.primary : AppColors.gray900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.gray500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
