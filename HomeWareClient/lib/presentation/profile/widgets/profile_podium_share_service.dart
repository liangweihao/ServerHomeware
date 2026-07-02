import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/family_contribution_provider.dart';
import 'profile_podium_share_poster.dart';

/// 家庭协作领奖台分享 — 美化海报 + 文字摘要
class ProfilePodiumShareService {
  ProfilePodiumShareService._();

  /// 分享排行榜：优先渲染海报图，失败则纯文本
  static Future<void> share(
    BuildContext context,
    List<FamilyMemberContribution> members, {
    GlobalKey? podiumKey,
  }) async {
    if (members.isEmpty) {
      debugPrint('[ProfilePodiumShare] WARN: 无排行数据');
      return;
    }

    final text = _buildShareText(members);
    Uint8List? png = await _capturePoster(context, members);

    if (png == null && podiumKey != null) {
      png = await _capturePng(podiumKey);
    }

    try {
      if (png != null) {
        final dir = await getTemporaryDirectory();
        final file = File(
          '${dir.path}/homestock_podium_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png',
        );
        await file.writeAsBytes(png);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: text,
          subject: 'HomeStock 家庭协作排行榜',
        );
        debugPrint('[ProfilePodiumShare] INFO: 海报分享成功');
      } else {
        await Share.share(text, subject: 'HomeStock 家庭协作排行榜');
        debugPrint('[ProfilePodiumShare] INFO: 文字分享成功');
      }
    } catch (e) {
      debugPrint('[ProfilePodiumShare] ERROR: $e');
      await Share.share(text);
    }
  }

  /// 离屏渲染分享海报
  static Future<Uint8List?> _capturePoster(
    BuildContext context,
    List<FamilyMemberContribution> members,
  ) async {
    final key = GlobalKey();
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        left: -5000,
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: key,
            child: ProfilePodiumSharePoster(members: members),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 120));
      await WidgetsBinding.instance.endOfFrame;
      return await _capturePng(key);
    } catch (e) {
      debugPrint('[ProfilePodiumShare] WARN: 海报渲染失败 $e');
      return null;
    } finally {
      entry.remove();
    }
  }

  static String _buildShareText(List<FamilyMemberContribution> members) {
    final buffer = StringBuffer();
    buffer.writeln('HomeStock 家庭协作排行榜');
    buffer.writeln('本月贡献 Top${members.length}');
    buffer.writeln('');
    for (var i = 0; i < members.length; i++) {
      final m = members[i];
      final rank = m.rank ?? (i + 1);
      final medal = rank == 1
          ? '🥇'
          : rank == 2
              ? '🥈'
              : rank == 3
                  ? '🥉'
                  : '$rank.';
      buffer.writeln(
        '$medal ${m.name} — 录入 ${m.recordCount} · 消耗 ${m.consumeCount}',
      );
    }
    buffer.writeln('');
    buffer.writeln('— 来自 HomeStock 家庭物品管家');
    return buffer.toString();
  }

  static Future<Uint8List?> _capturePng(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[ProfilePodiumShare] WARN: 截图失败 $e');
      return null;
    }
  }
}
