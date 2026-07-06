import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/assistant/add_item_nl_parser.dart';
import '../../data/database/app_database.dart';
import 'category_form_policy.dart';
import 'item_form_controller.dart';
import 'widgets/add_item_wizard_view.dart';

/// NL 预填应用到向导后的结果
class AddItemNlApplyOutcome {
  const AddItemNlApplyOutcome({
    required this.hintMessage,
    required this.startStep,
    this.completedThroughStep,
    required this.appliedFields,
    required this.missingFields,
  });

  final String hintMessage;
  final AddItemWizardStep startStep;
  final AddItemWizardStep? completedThroughStep;
  final List<String> appliedFields;
  final List<String> missingFields;
}

/// 将 [AddItemNlResult] 写入 [ItemFormController] 并建议起始步骤
Future<AddItemNlApplyOutcome> applyAddItemNlPrefill({
  required AddItemNlResult parsed,
  required ItemFormController form,
  required AppDatabase db,
}) async {
  final applied = <String>[];
  final missing = List<String>.from(parsed.missingFields);

  if (parsed.name != null) {
    form.nameController.text = parsed.name!;
    applied.add('名称');
  }

  if (parsed.quantity != null) {
    form.quantity = parsed.quantity!;
    applied.add('数量');
  }
  if (parsed.unit != null && parsed.unit!.isNotEmpty) {
    form.setDisplayUnit(parsed.unit!);
    applied.add('单位');
  }

  if (parsed.expiryDate != null) {
    form.expiryDate = parsed.expiryDate;
    form.productionDate ??= DateTime.now();
    applied.add('过期日');
    missing.remove('过期日');
  } else if (parsed.shelfLifeDays != null) {
    form.shelfLifeDays = parsed.shelfLifeDays;
    form.productionDate = DateTime.now();
    form.expiryDate =
        form.productionDate!.add(Duration(days: parsed.shelfLifeDays!));
    applied.add('保质期');
    missing.remove('过期日');
  }

  // 尝试默认「食品饮料」分类（与扫码预填一致）
  var categoryApplied = false;
  if (parsed.name != null) {
    final tops = await db.getTopLevelCategories();
    final food = tops.where((c) => c.name == '食品饮料').firstOrNull ??
        tops.where((c) => c.id == 1).firstOrNull;
    if (food != null) {
      form.selectedCategory = food;
      CategoryFormPolicy.applyAlertDefaults(form, food, food);
      categoryApplied = true;
      applied.add('分类');
    }
  }

  Location? matchedLocation;
  if (parsed.locationHint != null) {
    matchedLocation =
        _matchLocation(parsed.locationHint!, await db.getAllLocations());
    if (matchedLocation != null) {
      form.selectedLocation = matchedLocation;
      applied.add('位置');
      missing.remove('位置');
    } else {
      debugPrint(
        '[AddItemNlApplier] WARN: 未匹配位置 hint=${parsed.locationHint}',
      );
    }
  }

  var startStep = AddItemWizardStep.category;
  AddItemWizardStep? completedThrough;

  if (matchedLocation != null && categoryApplied) {
    startStep = AddItemWizardStep.location;
    completedThrough = AddItemWizardStep.basic;
  } else if (categoryApplied && parsed.name != null) {
    startStep = AddItemWizardStep.basic;
    completedThrough = AddItemWizardStep.category;
  }

  if ((parsed.expiryDate != null || parsed.shelfLifeDays != null) &&
      matchedLocation != null) {
    startStep = AddItemWizardStep.expiry;
    completedThrough = AddItemWizardStep.location;
  }

  final hintParts = <String>[];
  if (applied.isNotEmpty) {
    hintParts.add('已预填：${applied.join('、')}');
  }
  if (missing.isNotEmpty) {
    hintParts.add('还需确认：${missing.join('、')}');
  }

  return AddItemNlApplyOutcome(
    hintMessage:
        hintParts.isEmpty ? '管管帮你解析好了，请逐步确认' : hintParts.join(' · '),
    startStep: startStep,
    completedThroughStep: completedThrough,
    appliedFields: applied,
    missingFields: missing,
  );
}

Location? _matchLocation(String query, List<Location> all) {
  final q = query.trim();
  if (q.isEmpty) return null;

  for (final l in all) {
    if (l.name == q) return l;
  }

  final contains =
      all.where((l) => l.name.contains(q) || q.contains(l.name)).toList();
  if (contains.length == 1) return contains.first;

  for (final l in all) {
    final segments = l.fullPath.split('/');
    if (segments.any((s) => s == q || s.contains(q) || q.contains(s))) {
      return l;
    }
  }

  return contains.isNotEmpty ? contains.first : null;
}
