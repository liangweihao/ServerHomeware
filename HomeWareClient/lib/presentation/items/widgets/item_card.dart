import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';
import '../../../core/utils/item_image_storage.dart';
import '../../common/widgets/cartoon_pressable.dart';
import '../../common/widgets/cartoon_ui.dart';
import '../../../data/database/app_database.dart';
import 'item_image_tile.dart';

/// 物品列表卡片 — 双层贴纸结构 + 元信息 Chip
class ItemCard extends StatelessWidget {
  final Item item;
  final String? locationName;
  /// 分类名称（由列表页预取缓存传入）
  final String? categoryName;
  /// 分类色值，如 #FF8A65
  final String? categoryColorHex;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.locationName,
    this.categoryName,
    this.categoryColorHex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorIndex = item.id.hashCode;
    final (pastelFill, pastelBorder) = CartoonPalette.pairAt(colorIndex);
    final tilt = CartoonPalette.tiltAt(colorIndex % 4) * 0.35;

    final cardBody = Opacity(
      opacity: item.status == 3 ? 0.55 : 1.0,
      child: AppSurface(
        padding: const EdgeInsets.all(10),
        fillColor: pastelFill,
        borderColor: pastelBorder,
        child: _buildContent(context, pastelBorder),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Transform.rotate(
        angle: tilt,
        child: CartoonPressable(
          onTap: onTap,
          child: cardBody,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color accentBorder) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(accentBorder),
        const SizedBox(width: 10),
        Expanded(
          child: CartoonInnerPanel(
            borderColor: accentBorder.withValues(alpha: 0.65),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        height: 1.15,
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildMetaChips(),
                const SizedBox(height: 8),
                _buildBottomBadges(context),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 分类 / 品牌 / 位置 — 独立贴纸 Chip
  Widget _buildMetaChips() {
    final chips = <Widget>[];

    if (categoryName != null) {
      final color = _parseHexColor(categoryColorHex) ?? AppColors.primaryDark;
      chips.add(
        CartoonStickerBadge(
          emoji: '🏷️',
          label: categoryName!,
          accentColor: color,
          fontSize: 10,
          compact: true,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        ),
      );
    }

    if (item.brand != null && item.brand!.isNotEmpty) {
      chips.add(
        CartoonStickerBadge(
          emoji: '🏪',
          label: item.brand!,
          accentColor: AppColors.textSecondary,
          fillColor: AppColors.gray100,
          fontSize: 10,
          compact: true,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        ),
      );
    }

    if (locationName != null && locationName!.isNotEmpty) {
      chips.add(
        CartoonStickerBadge(
          emoji: '📍',
          label: locationName!,
          accentColor: const Color(0xFF64B5F6),
          fillColor: CartoonPalette.pastelSky,
          fontSize: 10,
          compact: true,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: chips,
    );
  }

  /// 数量 + 状态 / 过期标签
  Widget _buildBottomBadges(BuildContext context) {
    return Row(
      children: [
        CartoonStickerBadge(
          emoji: '📦',
          label: '${item.currentQuantity.toStringAsFixed(0)} ${item.unit}',
          accentColor: AppColors.primaryDark,
          fillColor: AppColors.primaryLighter,
          fontSize: 12,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        ),
        const Spacer(),
        if (item.status == 3)
          _buildStatusBadge('🗑️ 已丢弃', AppColors.danger)
        else if (item.status == 1)
          _buildStatusBadge('✓ 已用完', AppColors.textSecondary)
        else if (item.expiryDate != null)
          _buildExpiryBadge(),
      ],
    );
  }

  /// 缩略图 — 白底贴纸框；无图时按名称猜 emoji
  Widget _buildThumbnail(Color accentBorder) {
    const size = 62.0;

    Widget thumb;
    final sources = ItemImageStorage.resolveDisplaySources(item.images);

    if (sources.isNotEmpty) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _ItemThumbnail(
          sources: sources,
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(12),
        ),
      );
    } else {
      thumb = Center(
        child: Text(
          _placeholderEmoji(),
          style: const TextStyle(fontSize: 28, height: 1),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentBorder, width: 2.5),
      ),
      child: thumb,
    );
  }

  /// 无图占位：按名称关键词猜测 emoji
  String _placeholderEmoji() {
    final name = item.name;
    if (name.contains('食') || name.contains('饮') || name.contains('奶')) {
      return '🍎';
    }
    if (name.contains('药')) return '💊';
    if (name.contains('衣') || name.contains('服')) return '👕';
    return '📦';
  }

  Widget _buildStatusBadge(String label, Color color) {
    return CartoonStickerBadge(
      label: label,
      accentColor: color,
      fontSize: 10,
      compact: true,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    );
  }

  Color? _parseHexColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length != 6) return null;
    return Color(int.parse('FF$normalized', radix: 16));
  }

  Widget _buildExpiryBadge() {
    final now = DateTime.now();
    final expiryDate = item.expiryDate;
    if (expiryDate == null) {
      return const SizedBox.shrink();
    }
    final daysUntilExpiry = expiryDate.difference(now).inDays;

    Color badgeColor;
    String badgeText;
    String emoji;

    if (daysUntilExpiry < 0) {
      badgeColor = AppColors.danger;
      badgeText = '已过期';
      emoji = '⏰';
    } else if (daysUntilExpiry <= 3) {
      badgeColor = AppColors.danger;
      badgeText = '$daysUntilExpiry天';
      emoji = '⚠️';
    } else if (daysUntilExpiry <= 7) {
      badgeColor = AppColors.warning;
      badgeText = '$daysUntilExpiry天';
      emoji = '⏰';
    } else {
      badgeColor = AppColors.success;
      badgeText = '新鲜';
      emoji = '✅';
    }

    return CartoonStickerBadge(
      emoji: emoji,
      label: badgeText,
      accentColor: badgeColor,
      fontSize: 10,
      compact: true,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    );
  }
}

/// 缩略图：多图源时失败自动切换下一张
class _ItemThumbnail extends StatefulWidget {
  final List<String> sources;
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const _ItemThumbnail({
    required this.sources,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  @override
  State<_ItemThumbnail> createState() => _ItemThumbnailState();
}

class _ItemThumbnailState extends State<_ItemThumbnail> {
  int _index = 0;

  void _tryNext() {
    if (_index < widget.sources.length - 1) {
      setState(() => _index++);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ItemImageTile(
      key: ValueKey(widget.sources[_index]),
      source: widget.sources[_index],
      width: widget.width,
      height: widget.height,
      borderRadius: widget.borderRadius,
      onError: _tryNext,
    );
  }
}
