import 'dart:io';

import 'package:flutter/material.dart';
import '../../../core/config/app_env.dart';
import '../../../core/constants/app_radius.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/upload_service.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/theme/cartoon_decorations.dart';
import '../../../core/theme/cartoon_palette.dart';
import '../../../core/utils/item_image_storage.dart';
import '../../../core/utils/item_list_reason_helper.dart';
import '../../common/widgets/cartoon_pressable.dart';
import '../../common/widgets/cartoon_ui.dart';
import '../../../data/database/app_database.dart';
import 'item_image_tile.dart';

/// 物品卡片展示模式
enum ItemCardLayout {
  /// 经典模式：分类/品牌/位置标签（兼容搜索等场景）
  classic,
  /// 理由优先：突出「我为什么看它」
  reasonFirst,
  /// 抖音式网格磁贴：大图/文本海报 + 底部基本信息
  grid,
}

/// 物品列表卡片 — 支持多种信息优先级布局
class ItemCard extends StatelessWidget {
  final Item item;
  final String? locationName;
  final String? categoryName;
  final String? categoryColorHex;
  final VoidCallback? onTap;
  final ItemCardLayout layout;
  /// 列表出现理由；reasonFirst / 全部 Tab 使用
  final ItemListReason? reason;

  const ItemCard({
    super.key,
    required this.item,
    this.locationName,
    this.categoryName,
    this.categoryColorHex,
    this.onTap,
    this.layout = ItemCardLayout.classic,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final colorIndex = item.id.hashCode;
    final (pastelFill, pastelBorder) = CartoonPalette.pairAt(colorIndex);
    final tilt = layout == ItemCardLayout.grid
        ? 0.0
        : CartoonPalette.tiltAt(colorIndex % 4) * 0.35;

    final cardBody = Opacity(
      opacity: item.status == 3 ? 0.55 : 1.0,
      child: AppSurface(
        // 内缩留出描边宽度，避免白底内容贴边盖住彩色边框
        padding: layout == ItemCardLayout.grid
            ? const EdgeInsets.all(CartoonDecorations.borderWidth)
            : const EdgeInsets.all(10),
        fillColor: pastelFill,
        borderColor: pastelBorder,
        clipBehavior: Clip.none,
        shadowLevel: layout == ItemCardLayout.grid
            ? CartoonShadowLevel.subtle
            : CartoonShadowLevel.card,
        child: layout == ItemCardLayout.grid
            ? ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppRadius.xl - CartoonDecorations.borderWidth,
                ),
                child: _buildContent(context, pastelBorder),
              )
            : _buildContent(context, pastelBorder),
      ),
    );

    return Padding(
      padding: EdgeInsets.only(bottom: layout == ItemCardLayout.grid ? 0 : 12),
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
    switch (layout) {
      case ItemCardLayout.grid:
        return _buildGridContent(context, accentBorder);
      case ItemCardLayout.reasonFirst:
        return _buildReasonFirstContent(context, accentBorder);
      case ItemCardLayout.classic:
        return _buildClassicContent(context, accentBorder);
    }
  }

  /// 理由优先：名称 → 出现理由 → 位置·数量
  Widget _buildReasonFirstContent(BuildContext context, Color accentBorder) {
    final listReason = reason ?? computeItemListReason(item);
    final thumbSize = 56.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(accentBorder, size: thumbSize),
        const SizedBox(width: 10),
        Expanded(
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
              const SizedBox(height: 6),
              CartoonStickerBadge(
                emoji: listReason.emoji,
                label: listReason.label,
                accentColor: listReason.color,
                fillColor: listReason.color.withValues(alpha: 0.12),
                fontSize: 12,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              ),
              const SizedBox(height: 6),
              Text(
                _auxiliaryLine(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                      height: 1.2,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 抖音式网格磁贴 — 图片 contain 居中 + 高度随内容自适应
  Widget _buildGridContent(BuildContext context, Color accentBorder) {
    final listReason = reason ?? computeItemListReason(item);
    final sources = ItemImageStorage.resolveDisplaySources(item.images);
    final hasImage = sources.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasImage)
          _buildGridImageArea(sources, accentBorder, listReason)
        else
          _buildGridTextArea(context, accentBorder, listReason),
        _buildGridFooter(context, accentBorder, listReason, hasImage),
      ],
    );
  }

  /// 底部信息条 — 高度随文案自适应
  Widget _buildGridFooter(
    BuildContext context,
    Color accentBorder,
    ItemListReason listReason,
    bool hasImage,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(
            color: accentBorder.withValues(alpha: 0.35),
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasImage) ...[
            Text(
              item.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    height: 1.15,
                    color: AppColors.textPrimary,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
          ],
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              CartoonStickerBadge(
                emoji: '📦',
                label: '${item.currentQuantity.toStringAsFixed(0)}${item.unit}',
                accentColor: accentBorder,
                fillColor: accentBorder.withValues(alpha: 0.12),
                fontSize: 9,
                compact: true,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              ),
              if (listReason.isActionable)
                CartoonStickerBadge(
                  emoji: listReason.emoji,
                  label: listReason.label,
                  accentColor: listReason.color,
                  fillColor: listReason.color.withValues(alpha: 0.12),
                  fontSize: 9,
                  compact: true,
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 有图：contain 居中，高度按图片比例自适应
  Widget _buildGridImageArea(
    List<String> sources,
    Color accentBorder,
    ItemListReason listReason,
  ) {
    return _GridAdaptiveImage(
      sources: sources,
      backgroundColor: AppColors.white.withValues(alpha: 0.92),
      overlay: _buildGridImageOverlays(accentBorder, listReason),
    );
  }

  /// 图片区角标 overlay
  Widget _buildGridImageOverlays(Color accentBorder, ItemListReason listReason) {
    return Stack(
      children: [
        if (listReason.isActionable)
          Positioned(
            top: 6,
            right: 6,
            child: CartoonStickerBadge(
              emoji: listReason.emoji,
              label: listReason.label,
              accentColor: listReason.color,
              fillColor: AppColors.white.withValues(alpha: 0.92),
              fontSize: 9,
              compact: true,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          ),
        if (categoryName != null)
          Positioned(
            top: 6,
            left: 6,
            child: CartoonStickerBadge(
              emoji: '🏷️',
              label: categoryName!,
              accentColor: _parseHexColor(categoryColorHex) ?? accentBorder,
              fillColor: AppColors.white.withValues(alpha: 0.92),
              fontSize: 9,
              compact: true,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          ),
      ],
    );
  }

  /// 无图：马卡龙文本海报 — 大 emoji + 名称 + 品牌
  Widget _buildGridTextArea(
    BuildContext context,
    Color accentBorder,
    ItemListReason listReason,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentBorder.withValues(alpha: 0.18),
            AppColors.white.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _placeholderEmoji(),
            style: const TextStyle(fontSize: 40, height: 1),
          ),
          const SizedBox(height: 6),
          Text(
            item.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  height: 1.2,
                  color: AppColors.textPrimary,
                ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (item.brand != null && item.brand!.isNotEmpty) ...[
            const SizedBox(height: 6),
            CartoonStickerBadge(
              emoji: '🏪',
              label: item.brand!,
              accentColor: AppColors.textSecondary,
              fillColor: AppColors.white.withValues(alpha: 0.9),
              fontSize: 9,
              compact: true,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          ],
          if (listReason.isActionable) ...[
            const SizedBox(height: 6),
            CartoonStickerBadge(
              emoji: listReason.emoji,
              label: listReason.label,
              accentColor: listReason.color,
              fillColor: AppColors.white.withValues(alpha: 0.92),
              fontSize: 9,
              compact: true,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            ),
          ],
        ],
      ),
    );
  }

  /// 经典双层贴纸布局
  Widget _buildClassicContent(BuildContext context, Color accentBorder) {
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

  String _auxiliaryLine() {
    final parts = <String>[];
    if (locationName != null && locationName!.isNotEmpty) {
      parts.add('📍 $locationName');
    }
    parts.add(
      '📦 ${item.currentQuantity.toStringAsFixed(0)} ${item.unit}',
    );
    return parts.join('  ·  ');
  }

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

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 6, runSpacing: 6, children: chips);
  }

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

  Widget _buildThumbnail(Color accentBorder, {double size = 62}) {
    Widget thumb;
    final sources = ItemImageStorage.resolveDisplaySources(item.images);

    if (sources.isNotEmpty) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(size > 50 ? 12 : 10),
        child: _ItemThumbnail(
          sources: sources,
          width: size,
          height: size,
          borderRadius: BorderRadius.circular(size > 50 ? 12 : 10),
        ),
      );
    } else {
      thumb = Center(
        child: Text(
          _placeholderEmoji(),
          style: TextStyle(fontSize: size * 0.45, height: 1),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(size > 50 ? 14 : 12),
        border: Border.all(color: accentBorder, width: 2.5),
      ),
      child: thumb,
    );
  }

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
    final reason = computeItemListReason(item);
    if (item.expiryDate == null) return const SizedBox.shrink();
    return CartoonStickerBadge(
      emoji: reason.emoji,
      label: reason.label,
      accentColor: reason.color,
      fontSize: 10,
      compact: true,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    );
  }
}

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

/// 网格图片区 — 预读宽高比 + 固定容器高度，contain 居中且不影响 ListView 布局
class _GridAdaptiveImage extends StatefulWidget {
  const _GridAdaptiveImage({
    required this.sources,
    required this.backgroundColor,
    required this.overlay,
  });

  final List<String> sources;
  final Color backgroundColor;
  final Widget overlay;

  @override
  State<_GridAdaptiveImage> createState() => _GridAdaptiveImageState();
}

class _GridAdaptiveImageState extends State<_GridAdaptiveImage> {
  /// 宽/高比下限 → 竖图最高约 列宽×1.82
  static const _minAspect = 0.55;
  /// 宽/高比上限 → 横图最矮约 列宽×0.67
  static const _maxAspect = 1.5;

  int _sourceIndex = 0;
  /// 图片原始宽/高比；null 时用 1:1 占位保证 ListView 可布局
  double? _imageAspect;
  ImageStream? _imageStream;
  ImageStreamListener? _streamListener;

  @override
  void initState() {
    super.initState();
    _resolveAspect(widget.sources[_sourceIndex]);
  }

  @override
  void didUpdateWidget(covariant _GridAdaptiveImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sources != widget.sources) {
      _sourceIndex = 0;
      _imageAspect = null;
      _resolveAspect(widget.sources[_sourceIndex]);
    }
  }

  @override
  void dispose() {
    _detachListener();
    super.dispose();
  }

  void _detachListener() {
    if (_imageStream != null && _streamListener != null) {
      _imageStream!.removeListener(_streamListener!);
    }
    _imageStream = null;
    _streamListener = null;
  }

  /// 预读图片尺寸，用于计算固定展示高度（避免 ListView 子项高度为 0）
  void _resolveAspect(String source) {
    _detachListener();

    final ImageProvider provider;
    if (ItemImageRefs.isRemotePath(source) ||
        source.startsWith('http://') ||
        source.startsWith('https://')) {
      provider = NetworkImage(AppEnv.resolveUploadUrl(source));
    } else {
      provider = FileImage(File(source));
    }

    final stream = provider.resolve(const ImageConfiguration());
    _imageStream = stream;
    _streamListener = ImageStreamListener(
      (ImageInfo info, bool _) {
        final w = info.image.width.toDouble();
        final h = info.image.height.toDouble();
        if (h > 0 && mounted) {
          setState(() => _imageAspect = w / h);
        }
        _detachListener();
      },
      onError: (dynamic _, StackTrace? __) {
        _detachListener();
        _tryNextSource();
      },
    );
    stream.addListener(_streamListener!);
  }

  void _tryNextSource() {
    if (_sourceIndex >= widget.sources.length - 1) return;
    setState(() {
      _sourceIndex++;
      _imageAspect = null;
    });
    _resolveAspect(widget.sources[_sourceIndex]);
  }

  /// 展示用宽/高比（限制极端比例，防止卡片过高/过扁）
  double _displayAspect(double width) {
    final raw = _imageAspect ?? 1.0;
    return raw.clamp(_minAspect, _maxAspect);
  }

  double _heightForWidth(double width) {
    final aspect = _displayAspect(width);
    return width / aspect;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = _heightForWidth(width);

        return ColoredBox(
          color: widget.backgroundColor,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: width,
                height: height,
                child: ItemImageTile(
                  key: ValueKey(widget.sources[_sourceIndex]),
                  source: widget.sources[_sourceIndex],
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.zero,
                  onError: _tryNextSource,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: height,
                child: widget.overlay,
              ),
            ],
          ),
        );
      },
    );
  }
}
