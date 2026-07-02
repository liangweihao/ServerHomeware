import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

/// 扫码录入页 — 相机预览 + 工具风扫描框与提示
class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);
    debugPrint('[ScanPage] INFO: 识别条码 ${barcode.rawValue}');

    HapticFeedback.mediumImpact();
    _controller.stop();

    if (mounted) {
      context.pushReplacement(
        '/items/add?barcode=${Uri.encodeComponent(barcode.rawValue!)}&step=location',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),
          _buildDimOverlay(),
          Center(child: _buildScanFrame()),
          _buildTopBar(context),
          _buildBottomHint(context),
          if (_isProcessing) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  /// 四周半透明遮罩，中间留扫描区域
  Widget _buildDimOverlay() {
    return CustomPaint(
      painter: _ScanHolePainter(
        holeSize: 260,
        overlayColor: Colors.black.withValues(alpha: 0.55),
        borderRadius: AppRadius.lg,
      ),
    );
  }

  /// 扫描框 — 点评橙描边 + 四角强调
  Widget _buildScanFrame() {
    const size = 260.0;
    const cornerLen = 24.0;
    const stroke = 3.0;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          for (final corner in _ScanCorner.values)
            Positioned(
              left: corner.isLeft ? 0 : null,
              right: corner.isRight ? 0 : null,
              top: corner.isTop ? 0 : null,
              bottom: corner.isBottom ? 0 : null,
              child: _buildCorner(
                corner: corner,
                length: cornerLen,
                stroke: stroke,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    required _ScanCorner corner,
    required double length,
    required double stroke,
  }) {
    return SizedBox(
      width: length,
      height: length,
      child: CustomPaint(
        painter: _CornerPainter(
          corner: corner,
          color: AppColors.primary,
          strokeWidth: stroke,
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SafeArea(
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '扫码录入',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, state, child) {
                return Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_on
                      : Icons.flash_off,
                  color: Colors.white,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomHint(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(32, 24, 32, 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.75),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '将条形码对准框内',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '识别后自动跳转添加入库',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                debugPrint('[ScanPage] INFO: 改用手动向导');
                context.go('/items/add');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white.withValues(alpha: 0.9),
              ),
              child: const Text('改用手动向导'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showManualInputDialog,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryLight,
              ),
              child: Text(
                '手动输入条码',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        title: const Text('手动输入条码'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: '请输入条形码',
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide.none,
            ),
          ),
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final barcode = controller.text.trim();
              if (barcode.isNotEmpty) {
                debugPrint('[ScanPage] INFO: 手动输入条码 $barcode');
                Navigator.pop(context);
                context.pushReplacement(
                  '/items/add?barcode=${Uri.encodeComponent(barcode)}&step=location',
                );
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

enum _ScanCorner { topLeft, topRight, bottomLeft, bottomRight }

extension on _ScanCorner {
  bool get isLeft =>
      this == _ScanCorner.topLeft || this == _ScanCorner.bottomLeft;
  bool get isRight =>
      this == _ScanCorner.topRight || this == _ScanCorner.bottomRight;
  bool get isTop =>
      this == _ScanCorner.topLeft || this == _ScanCorner.topRight;
  bool get isBottom =>
      this == _ScanCorner.bottomLeft || this == _ScanCorner.bottomRight;
}

/// 四角 L 形描边
class _CornerPainter extends CustomPainter {
  _CornerPainter({
    required this.corner,
    required this.color,
    required this.strokeWidth,
  });

  final _ScanCorner corner;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    switch (corner) {
      case _ScanCorner.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
      case _ScanCorner.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
      case _ScanCorner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
      case _ScanCorner.bottomRight:
        path.moveTo(size.width, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 中间透明、四周遮罩
class _ScanHolePainter extends CustomPainter {
  _ScanHolePainter({
    required this.holeSize,
    required this.overlayColor,
    required this.borderRadius,
  });

  final double holeSize;
  final Color overlayColor;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final holeRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: holeSize,
      height: holeSize,
    );
    final rrect = RRect.fromRectAndRadius(
      holeRect,
      Radius.circular(borderRadius),
    );

    final overlayPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final holePath = Path()..addRRect(rrect);
    final combined = Path.combine(PathOperation.difference, overlayPath, holePath);

    canvas.drawPath(
      combined,
      Paint()..color = overlayColor,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanHolePainter oldDelegate) => false;
}
