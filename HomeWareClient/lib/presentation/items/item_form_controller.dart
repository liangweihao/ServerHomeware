import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/constants/app_constants.dart';
import '../../core/utils/item_image_storage.dart';
import '../../data/database/app_database.dart';

/// 添加/编辑物品表单共享状态
class ItemFormController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final notesController = TextEditingController();
  final priceController = TextEditingController();

  Category? selectedCategory;
  Location? selectedLocation;
  DateTime? purchaseDate = DateTime.now();
  DateTime? productionDate;
  DateTime? expiryDate;
  int? shelfLifeDays;
  double quantity = 1;
  String unit = '件';
  String? purchaseChannel;
  int expiryAlertDays = 3;
  double safetyStock = 1;
  List<String> imagePaths = [];

  /// 编辑模式：当前剩余（只读展示，保存时不改）
  double? editCurrentQuantity;

  void loadFromItem({
    required Item item,
    Category? category,
    Location? location,
  }) {
    nameController.text = item.name;
    brandController.text = item.brand ?? '';
    notesController.text = item.notes ?? '';
    priceController.text =
        item.purchasePrice != null ? item.purchasePrice!.toString() : '';

    selectedCategory = category;
    selectedLocation = location;
    purchaseDate = item.purchaseDate;
    productionDate = item.productionDate;
    expiryDate = item.expiryDate;
    shelfLifeDays = item.shelfLifeDays;
    quantity = item.purchaseQuantity.toDouble();
    unit = item.unit;
    purchaseChannel = item.purchaseChannel;
    expiryAlertDays = item.expiryAlertDays;
    safetyStock = item.safetyStock;
    imagePaths = ItemImageStorage.decodePaths(item.images);
    editCurrentQuantity = item.currentQuantity;
  }

  void resetForNewEntry() {
    formKey.currentState?.reset();
    nameController.clear();
    brandController.clear();
    notesController.clear();
    priceController.clear();
    selectedCategory = null;
    selectedLocation = null;
    purchaseDate = DateTime.now();
    productionDate = null;
    expiryDate = null;
    shelfLifeDays = null;
    quantity = 1;
    unit = '件';
    purchaseChannel = null;
    expiryAlertDays = 3;
    safetyStock = 1;
    imagePaths = [];
    editCurrentQuantity = null;
  }

  void dispose() {
    nameController.dispose();
    brandController.dispose();
    notesController.dispose();
    priceController.dispose();
  }

  bool validate() {
    if (!(formKey.currentState?.validate() ?? false)) return false;
    if (selectedCategory == null) return false;
    return true;
  }

  String formatApiDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Map<String, dynamic> buildCreateApiBody({List<String>? imageUrls}) {
    final body = <String, dynamic>{
      'name': nameController.text.trim(),
      'category_id': selectedCategory!.id,
      'purchase_quantity': quantity.round(),
      'current_quantity': quantity,
      'unit': unit,
      'safety_stock': safetyStock,
      'expiry_alert_days': expiryAlertDays,
      'stock_alert': true,
    };

    if (brandController.text.isNotEmpty) {
      body['brand'] = brandController.text.trim();
    }
    if (selectedLocation != null) {
      body['location_id'] = selectedLocation!.id;
    }
    final price = double.tryParse(priceController.text);
    if (price != null) {
      body['purchase_price'] = price;
    }
    if (purchaseDate != null) {
      body['purchase_date'] = formatApiDate(purchaseDate!);
    }
    if (purchaseChannel != null) {
      body['purchase_channel'] = purchaseChannel;
    }
    if (productionDate != null) {
      body['production_date'] = formatApiDate(productionDate!);
    }
    if (expiryDate != null) {
      body['expiry_date'] = formatApiDate(expiryDate!);
    }
    if (shelfLifeDays != null) {
      body['shelf_life_days'] = shelfLifeDays;
    }
    if (notesController.text.isNotEmpty) {
      body['notes'] = notesController.text.trim();
    }
    if (imageUrls != null && imageUrls.isNotEmpty) {
      body['image_urls'] = imageUrls;
    }
    return body;
  }

  Map<String, dynamic> buildUpdateApiBody() {
    return buildCreateApiBody();
  }

  ItemsCompanion buildInsertCompanion({int? serverId, List<String>? imagePathsOverride}) {
    final paths = imagePathsOverride ?? imagePaths;
    final Value<String?> imagesJson = paths.isEmpty
        ? const Value.absent()
        : Value(ItemImageStorage.encodePaths(paths));

    return ItemsCompanion(
      id: serverId != null ? Value(serverId) : const Value.absent(),
      name: Value(nameController.text.trim()),
      brand: brandController.text.isEmpty
          ? const Value.absent()
          : Value(brandController.text.trim()),
      categoryId: Value(selectedCategory!.id),
      locationId: selectedLocation != null
          ? Value(selectedLocation!.id)
          : const Value.absent(),
      purchasePrice: priceController.text.isEmpty
          ? const Value.absent()
          : Value(double.tryParse(priceController.text)),
      purchaseQuantity: Value(quantity.round()),
      currentQuantity: Value(quantity),
      unit: Value(unit),
      safetyStock: Value(safetyStock),
      purchaseDate: purchaseDate != null ? Value(purchaseDate!) : const Value.absent(),
      purchaseChannel:
          purchaseChannel != null ? Value(purchaseChannel!) : const Value.absent(),
      productionDate:
          productionDate != null ? Value(productionDate!) : const Value.absent(),
      expiryDate: expiryDate != null ? Value(expiryDate!) : const Value.absent(),
      shelfLifeDays:
          shelfLifeDays != null ? Value(shelfLifeDays!) : const Value.absent(),
      expiryAlertDays: Value(expiryAlertDays),
      stockAlert: const Value(true),
      notes: notesController.text.isEmpty
          ? const Value.absent()
          : Value(notesController.text.trim()),
      images: imagesJson,
    );
  }

  /// 编辑保存：保留原 currentQuantity、status、预测字段等
  Item applyToExistingItem(Item existing) {
    final imagesJson =
        imagePaths.isEmpty ? null : ItemImageStorage.encodePaths(imagePaths);

    return existing.copyWith(
      name: nameController.text.trim(),
      brand: brandController.text.isEmpty
          ? const Value.absent()
          : Value(brandController.text.trim()),
      categoryId: selectedCategory!.id,
      locationId: selectedLocation != null
          ? Value(selectedLocation!.id)
          : const Value.absent(),
      purchasePrice: priceController.text.isEmpty
          ? const Value.absent()
          : Value(double.tryParse(priceController.text)),
      purchaseQuantity: quantity.round(),
      unit: unit,
      safetyStock: safetyStock,
      purchaseDate: purchaseDate != null ? Value(purchaseDate!) : const Value.absent(),
      purchaseChannel:
          purchaseChannel != null ? Value(purchaseChannel!) : const Value.absent(),
      productionDate:
          productionDate != null ? Value(productionDate!) : const Value.absent(),
      expiryDate: expiryDate != null ? Value(expiryDate!) : const Value.absent(),
      shelfLifeDays:
          shelfLifeDays != null ? Value(shelfLifeDays!) : const Value.absent(),
      expiryAlertDays: expiryAlertDays,
      notes: notesController.text.isEmpty
          ? const Value.absent()
          : Value(notesController.text.trim()),
      images: imagesJson != null ? Value(imagesJson) : const Value.absent(),
      updatedAt: DateTime.now(),
    );
  }

  void onShelfLifeChanged(String? shelfLifeKey) {
    if (shelfLifeKey == null) {
      shelfLifeDays = null;
      expiryDate = null;
      return;
    }
    final days = AppConstants.shelfLifeOptions[shelfLifeKey];
    shelfLifeDays = days;
    if (productionDate != null && days != null) {
      expiryDate = productionDate!.add(Duration(days: days));
    }
  }

  void onProductionDateChanged(DateTime? date) {
    productionDate = date;
    if (productionDate != null && shelfLifeDays != null) {
      expiryDate = productionDate!.add(Duration(days: shelfLifeDays!));
    }
  }
}
