import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';

import '../common/widgets/cartoon_ui.dart';

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

    // 震动反馈
    HapticFeedback.mediumImpact();

    // 暂停扫码
    _controller.stop();

    // 跳转到添加页面，传递 barcode
    if (mounted) {
      context.pushReplacement('/items/add?barcode=${Uri.encodeComponent(barcode.rawValue!)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 相机预览
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // 半透明遮罩
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // 中间透明区域
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xl - 2),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          ),

          // 顶部 AppBar
          SafeArea(
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(
                CartoonUi.pageTitle('扫码录入', emoji: '📷'),
                style: const TextStyle(color: Colors.white),
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
                      );
                    },
                  ),
                  onPressed: () => _controller.toggleTorch(),
                ),
              ],
            ),
          ),

          // 底部提示
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
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
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '自动识别商品信息',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () {
                      // 手动输入条码
                      _showManualInputDialog();
                    },
                    child: const Text(
                      '手动输入条码',
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Loading 遮罩
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('手动输入条码'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入条形码',
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
                Navigator.pop(context);
                context.pushReplacement('/items/add?barcode=${Uri.encodeComponent(barcode)}');
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}
