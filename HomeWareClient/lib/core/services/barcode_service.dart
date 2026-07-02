import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;

import 'api_service.dart';

/// 条码查询结果
class BarcodeLookupResult {
  const BarcodeLookupResult({
    required this.barcode,
    this.existingItemId,
    this.existingItemName,
    this.productName,
    this.brand,
    this.imageUrl,
    this.source,
  });

  final String barcode;
  final int? existingItemId;
  final String? existingItemName;
  final String? productName;
  final String? brand;
  final String? imageUrl;

  /// local_db / server / open_food_facts / barcode_only
  final String? source;

  bool get alreadyExists => existingItemId != null;

  bool get hasProductHint =>
      productName != null && productName!.trim().isNotEmpty;
}

/// 条码查询 — 家庭库存 → 服务端 → Open Food Facts（食品）
class BarcodeService {
  /// 综合查询条码，按优先级合并结果
  Future<BarcodeLookupResult> lookup(String barcode) async {
    final code = barcode.trim();
    debugPrint('[BarcodeService] INFO: 查询条码 $code');

    // 1. 服务端（含家庭已有物品）
    final server = await _queryServer(code);
    if (server != null) {
      if (server.alreadyExists) return server;
      if (server.hasProductHint) return server;
    }

    // 2. Open Food Facts — 公开商品库（食品为主）
    final off = await _queryOpenFoodFacts(code);
    if (off != null) {
      return BarcodeLookupResult(
        barcode: code,
        productName: off.productName,
        brand: off.brand,
        imageUrl: off.imageUrl,
        source: 'open_food_facts',
      );
    }

    debugPrint('[BarcodeService] WARN: 未识别条码，仅保留条码');
    return BarcodeLookupResult(barcode: code, source: 'barcode_only');
  }

  Future<BarcodeLookupResult?> _queryServer(String code) async {
    try {
      final raw = await ApiService.get('/barcode/$code');
      final statusCode = raw['code'] as int? ?? 0;
      if (statusCode == 404) return null;
      if (statusCode != 200) {
        debugPrint('[BarcodeService] WARN: 服务端 ${raw['message']}');
        return null;
      }

      final data = raw['data'] as Map<String, dynamic>?;
      if (data == null) return null;
      if (data['already_exists'] == true) {
        final item = data['item'] as Map<String, dynamic>?;
        final id = item?['id'];
        return BarcodeLookupResult(
          barcode: code,
          existingItemId: id is int ? id : int.tryParse('$id'),
          existingItemName: item?['name']?.toString(),
          source: 'server',
        );
      }

      final product = data['product_info'] as Map<String, dynamic>?;
      if (product != null) {
        return BarcodeLookupResult(
          barcode: code,
          productName: product['name']?.toString(),
          brand: product['brand']?.toString(),
          imageUrl: product['image_url']?.toString(),
          source: 'server',
        );
      }
      return null;
    } catch (e) {
      debugPrint('[BarcodeService] ERROR: 服务端查询异常 $e');
      return null;
    }
  }

  Future<BarcodeLookupResult?> _queryOpenFoodFacts(String code) async {
    try {
      final uri = Uri.parse(
        'https://world.openfoodfacts.org/api/v0/product/$code.json',
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json['status'] != 1) return null;

      final product = json['product'] as Map<String, dynamic>?;
      if (product == null) return null;

      final name = product['product_name']?.toString() ??
          product['product_name_zh']?.toString() ??
          product['generic_name']?.toString();
      if (name == null || name.trim().isEmpty) return null;

      final brands = product['brands']?.toString();
      final image = product['image_front_small_url']?.toString() ??
          product['image_front_url']?.toString();

      debugPrint('[BarcodeService] INFO: Open Food Facts 命中 $name');
      return BarcodeLookupResult(
        barcode: code,
        productName: name.trim(),
        brand: brands?.split(',').first.trim(),
        imageUrl: image,
        source: 'open_food_facts',
      );
    } catch (e) {
      debugPrint('[BarcodeService] WARN: Open Food Facts 查询失败 $e');
      return null;
    }
  }
}
