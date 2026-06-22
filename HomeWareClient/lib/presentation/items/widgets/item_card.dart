import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/utils/item_image_storage.dart';
import '../../../data/database/app_database.dart';
import 'item_image_tile.dart';

class ItemCard extends StatefulWidget {
  final Item item;
  final String? locationName;
  final VoidCallback? onTap;

  const ItemCard({
    super.key,
    required this.item,
    this.locationName,
    this.onTap,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Opacity(
          opacity: widget.item.status == 3 ? 0.55 : 1.0,
          child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity( 0.05),
                blurRadius: _isPressed ? 5 : 10,
                offset: Offset(0, _isPressed ? 1 : 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildThumbnail(),
              const SizedBox(width: 12),
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.item.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.item.brand != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.item.brand ?? '',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (widget.locationName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: AppColors.textHint,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              widget.locationName ?? '',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textHint,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // 数量和单位
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${widget.item.currentQuantity.toStringAsFixed(0)} ${widget.item.unit}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                  ),
                  if (widget.item.status == 3) ...[
                    const SizedBox(height: 4),
                    _buildStatusBadge('已丢弃', AppColors.danger),
                  ] else if (widget.item.status == 1) ...[
                    const SizedBox(height: 4),
                    _buildStatusBadge('已用完', AppColors.textSecondary),
                  ] else if (widget.item.expiryDate != null) ...[
                    const SizedBox(height: 4),
                    _buildExpiryBadge(context),
                  ],
                ],
              ),
            ],
          ),
          )
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final sources = ItemImageStorage.resolveDisplaySources(widget.item.images);

    if (sources.isNotEmpty) {
      return _ItemThumbnail(
        sources: sources,
        width: 56,
        height: 56,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      );
    }

    return _placeholderThumbnail();
  }

  Widget _placeholderThumbnail() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildExpiryBadge(BuildContext context) {
    final now = DateTime.now();
    final expiryDate = widget.item.expiryDate;
    if (expiryDate == null) {
      return const SizedBox.shrink();
    }
    final daysUntilExpiry = expiryDate.difference(now).inDays;

    Color badgeColor;
    String badgeText;

    if (daysUntilExpiry < 0) {
      badgeColor = AppColors.danger;
      badgeText = '已过期';
    } else if (daysUntilExpiry <= 3) {
      badgeColor = AppColors.danger;
      badgeText = '$daysUntilExpiry天后过期';
    } else if (daysUntilExpiry <= 7) {
      badgeColor = AppColors.warning;
      badgeText = '$daysUntilExpiry天后过期';
    } else {
      badgeColor = AppColors.success;
      badgeText = '正常';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          fontSize: 10,
          color: badgeColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 物品缩略图：首张加载失败时自动尝试后续图片
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
