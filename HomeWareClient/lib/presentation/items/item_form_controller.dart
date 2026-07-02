import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/constants/app_constants.dart';
import '../../core/utils/item_image_storage.dart';
import '../../data/database/app_database.dart';
import 'category_form_policy.dart';

/// 添加/编辑物品表单共享状态
class ItemFormController {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final brandController = TextEditingController();
  final notesController = TextEditingController();
  final priceController = TextEditingController();

  Category? selectedCategory;
  Location? selectedLocation;
  String? containerName;
  DateTime? purchaseDate = DateTime.now();
  DateTime? productionDate;
  DateTime? expiryDate;
  int? shelfLifeDays;
  double quantity = 1;
  String unit = '件';
  /// 包装单位（盒/箱/提），null 表示无包装
  String? packageUnit;
  /// 一包装含多少基本单位，默认 1
  int packageQuantity = 1;
  String? purchaseChannel;
  int expiryAlertDays = 3;
  double safetyStock = 1;
  List<String> imagePaths = [];
  /// 存放位置参考照片（独立于物品图片）
  List<String> locationImagePaths = [];

  /// 扫码录入条码
  String? barcode;

  /// 预计使用天数（可选）— 用于估算日均消耗与预计用完日
  int? estimatedUseDays;

  /// 编辑模式：当前剩余（只读展示，保存时不改）
  double? editCurrentQuantity;

  /// 首屏单位下拉显示值（包装单位或基本单位）
  String get displayUnit => packageUnit ?? unit;

  bool get usesPackageLikeUnit =>
      CategoryFormPolicy.packageLikeUnits.contains(displayUnit);

  /// 切换首屏单位并同步 package_unit / unit
  void setDisplayUnit(String value) {
    if (CategoryFormPolicy.packageLikeUnits.contains(value)) {
      packageUnit = value;
      if (CategoryFormPolicy.packageLikeUnits.contains(unit)) {
        unit = '个';
      }
    } else {
      unit = value;
      packageUnit = null;
      packageQuantity = 1;
    }
  }

  /// 加载编辑数据后对齐 displayUnit
  void syncDisplayUnitAfterLoad() {
    if (packageUnit != null &&
        CategoryFormPolicy.packageLikeUnits.contains(packageUnit)) {
      // 已是包装模式
      return;
    }
    if (CategoryFormPolicy.packageLikeUnits.contains(unit) && packageUnit == null) {
      packageUnit = unit;
      unit = '个';
    }
  }

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
    containerName = item.containerName;
    purchaseDate = item.purchaseDate;
    productionDate = item.productionDate;
    expiryDate = item.expiryDate;
    shelfLifeDays = item.shelfLifeDays;
    quantity = item.purchaseQuantity.toDouble();
    unit = item.unit;
    packageUnit = item.packageUnit;
    packageQuantity = item.packageQuantity;
    purchaseChannel = item.purchaseChannel;
    expiryAlertDays = item.expiryAlertDays;
    safetyStock = item.safetyStock;
    // 使用 decodeAllPaths 保留服务端 URL，避免编辑时已有图片丢失
    imagePaths = ItemImageStorage.decodeItemImages(item.images);
    locationImagePaths = ItemImageStorage.decodeLocationImages(item.images);
    editCurrentQuantity = item.currentQuantity;
    barcode = item.barcode;
    if (item.avgDailyConsumption != null &&
        item.avgDailyConsumption! > 0 &&
        item.currentQuantity > 0) {
      estimatedUseDays =
          (item.currentQuantity / item.avgDailyConsumption!).round();
    } else {
      estimatedUseDays = null;
    }
    syncDisplayUnitAfterLoad();
  }

  void resetForNewEntry() {
    formKey.currentState?.reset();
    nameController.clear();
    brandController.clear();
    notesController.clear();
    priceController.clear();
    selectedCategory = null;
    selectedLocation = null;
    containerName = null;
    purchaseDate = DateTime.now();
    productionDate = null;
    expiryDate = null;
    shelfLifeDays = null;
    quantity = 1;
    unit = '件';
    packageUnit = null;
    packageQuantity = 1;
    purchaseChannel = null;
    expiryAlertDays = 3;
    safetyStock = 1;
    imagePaths = [];
    locationImagePaths = [];
    barcode = null;
    editCurrentQuantity = null;
    estimatedUseDays = null;
  }

  /// 根据预计使用天数计算日均消耗与预计用完日
  ({double? avgDaily, DateTime? predictedEmpty}) computeConsumptionEstimate() {
    if (estimatedUseDays == null || estimatedUseDays! <= 0) {
      return (avgDaily: null, predictedEmpty: null);
    }
    final stock = quantity *
        ((packageUnit != null && packageQuantity > 0) ? packageQuantity : 1);
    return (
      avgDaily: stock / estimatedUseDays!,
      predictedEmpty: DateTime.now().add(Duration(days: estimatedUseDays!)),
    );
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

  Map<String, dynamic> buildCreateApiBody({
    List<String>? imageUrls,
    List<String>? locationImageUrls,
  }) {
    // 合并物品图片和位置照片，位置照片带 __loc__: 前缀
    final allUrls = <String>[
      if (imageUrls != null) ...imageUrls,
      if (locationImageUrls != null)
        for (final url in locationImageUrls) '${ItemImageStorage.locPrefix}$url',
    ];

    // 初始库存：有包装时 quantity × packageQuantity
    final initialStock = quantity *
        ((packageUnit != null && packageQuantity > 0) ? packageQuantity : 1);

    final body = <String, dynamic>{
      'name': nameController.text.trim(),
      'category_id': selectedCategory!.id,
      'purchase_quantity': quantity.round(),
      'current_quantity': initialStock,
      'unit': unit,
      'package_unit': packageUnit,
      'package_quantity': packageQuantity,
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
    if (containerName != null && containerName!.isNotEmpty) {
      body['container_name'] = containerName;
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
    if (barcode != null && barcode!.isNotEmpty) {
      body['barcode'] = barcode;
    }
    if (allUrls.isNotEmpty) {
      body['image_urls'] = allUrls;
    }
    final estimate = computeConsumptionEstimate();
    if (estimate.avgDaily != null) {
      body['avg_daily_consumption'] = estimate.avgDaily;
    }
    if (estimate.predictedEmpty != null) {
      body['predicted_empty_date'] = formatApiDate(estimate.predictedEmpty!);
    }
    return body;
  }

  Map<String, dynamic> buildUpdateApiBody() {
    return buildCreateApiBody();
  }

  ItemsCompanion buildInsertCompanion({int? serverId, List<String>? imagePathsOverride}) {
    // 如果有服务端 URL（已含 __loc__: 前缀），直接存储；否则合并本地路径并加前缀
    final Value<String?> imagesJson;
    if (imagePathsOverride != null && imagePathsOverride.isNotEmpty) {
      imagesJson = Value(ItemImageStorage.encodePaths(imagePathsOverride));
    } else if (imagePaths.isNotEmpty || locationImagePaths.isNotEmpty) {
      imagesJson = Value(ItemImageStorage.encodeAllImages(
        itemPaths: imagePaths,
        locationPaths: locationImagePaths,
      ));
    } else {
      imagesJson = const Value.absent();
    }

    final estimate = computeConsumptionEstimate();

    return ItemsCompanion(
      id: serverId != null ? Value(serverId) : const Value.absent(),
      serverItemId: serverId != null ? Value(serverId) : const Value.absent(),
      name: Value(nameController.text.trim()),
      brand: brandController.text.isEmpty
          ? const Value.absent()
          : Value(brandController.text.trim()),
      categoryId: Value(selectedCategory!.id),
      locationId: selectedLocation != null
          ? Value(selectedLocation!.id)
          : const Value.absent(),
      containerName: containerName != null ? Value(containerName!) : const Value.absent(),
      purchasePrice: priceController.text.isEmpty
          ? const Value.absent()
          : Value(double.tryParse(priceController.text)),
      purchaseQuantity: Value(quantity.round()),
      packageUnit: packageUnit != null ? Value(packageUnit!) : const Value.absent(),
      packageQuantity: Value(packageQuantity),
      currentQuantity: Value(
        quantity *
            ((packageUnit != null && packageQuantity > 0) ? packageQuantity : 1),
      ),
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
      barcode: barcode != null && barcode!.isNotEmpty
          ? Value(barcode!)
          : const Value.absent(),
      images: imagesJson,
      avgDailyConsumption: estimate.avgDaily != null
          ? Value(estimate.avgDaily)
          : const Value.absent(),
      predictedEmptyDate: estimate.predictedEmpty != null
          ? Value(estimate.predictedEmpty)
          : const Value.absent(),
    );
  }

  /// 编辑保存：保留原 currentQuantity、status、预测字段等
  Item applyToExistingItem(Item existing) {
    final imagesJson = (imagePaths.isEmpty && locationImagePaths.isEmpty)
        ? null
        : ItemImageStorage.encodeAllImages(
            itemPaths: imagePaths,
            locationPaths: locationImagePaths,
          );

    final estimate = computeConsumptionEstimate();

    return existing.copyWith(
      name: nameController.text.trim(),
      brand: brandController.text.isEmpty
          ? const Value.absent()
          : Value(brandController.text.trim()),
      categoryId: selectedCategory!.id,
      locationId: selectedLocation != null
          ? Value(selectedLocation!.id)
          : const Value.absent(),
      containerName: containerName != null ? Value(containerName!) : const Value.absent(),
      purchasePrice: priceController.text.isEmpty
          ? const Value.absent()
          : Value(double.tryParse(priceController.text)),
      purchaseQuantity: quantity.round(),
      packageUnit: packageUnit != null ? Value(packageUnit!) : const Value.absent(),
      packageQuantity: packageQuantity,
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
      avgDailyConsumption: estimate.avgDaily != null
          ? Value(estimate.avgDaily)
          : const Value.absent(),
      predictedEmptyDate: estimate.predictedEmpty != null
          ? Value(estimate.predictedEmpty)
          : const Value.absent(),
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

  /// 是否有值得保存的草稿内容
  bool get hasDraftContent =>
      nameController.text.trim().isNotEmpty ||
      brandController.text.trim().isNotEmpty ||
      selectedCategory != null ||
      selectedLocation != null ||
      (barcode != null && barcode!.isNotEmpty) ||
      expiryDate != null;

  /// 序列化为草稿
  Map<String, dynamic> toDraftMap({required int wizardStepIndex}) {
    return {
      'wizardStep': wizardStepIndex,
      'name': nameController.text,
      'brand': brandController.text,
      'notes': notesController.text,
      'price': priceController.text,
      'categoryId': selectedCategory?.id,
      'locationId': selectedLocation?.id,
      'containerName': containerName,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'productionDate': productionDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'shelfLifeDays': shelfLifeDays,
      'quantity': quantity,
      'unit': unit,
      'packageUnit': packageUnit,
      'packageQuantity': packageQuantity,
      'purchaseChannel': purchaseChannel,
      'expiryAlertDays': expiryAlertDays,
      'safetyStock': safetyStock,
      'barcode': barcode,
      'imagePaths': imagePaths,
      'locationImagePaths': locationImagePaths,
    };
  }

  /// 从草稿恢复
  Future<void> applyDraftMap(
    Map<String, dynamic> map,
    AppDatabase db,
  ) async {
    nameController.text = map['name']?.toString() ?? '';
    brandController.text = map['brand']?.toString() ?? '';
    notesController.text = map['notes']?.toString() ?? '';
    priceController.text = map['price']?.toString() ?? '';

    final categoryId = map['categoryId'] as int?;
    if (categoryId != null) {
      selectedCategory = await db.getCategoryById(categoryId);
    }
    final locationId = map['locationId'] as int?;
    if (locationId != null) {
      selectedLocation = await db.getLocationById(locationId);
    }

    containerName = map['containerName'] as String?;
    purchaseDate = _parseDate(map['purchaseDate']) ?? DateTime.now();
    productionDate = _parseDate(map['productionDate']);
    expiryDate = _parseDate(map['expiryDate']);
    shelfLifeDays = map['shelfLifeDays'] as int?;
    quantity = (map['quantity'] as num?)?.toDouble() ?? 1;
    unit = map['unit']?.toString() ?? '件';
    packageUnit = map['packageUnit'] as String?;
    packageQuantity = map['packageQuantity'] as int? ?? 1;
    purchaseChannel = map['purchaseChannel'] as String?;
    expiryAlertDays = map['expiryAlertDays'] as int? ?? 3;
    safetyStock = (map['safetyStock'] as num?)?.toDouble() ?? 1;
    barcode = map['barcode'] as String?;

    final imgs = map['imagePaths'];
    if (imgs is List) {
      imagePaths = imgs.map((e) => e.toString()).toList();
    }
    final locImgs = map['locationImagePaths'];
    if (locImgs is List) {
      locationImagePaths = locImgs.map((e) => e.toString()).toList();
    }
    syncDisplayUnitAfterLoad();
  }

  DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }
}