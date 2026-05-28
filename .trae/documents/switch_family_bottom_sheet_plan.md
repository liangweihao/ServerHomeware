# 切换家庭弹窗功能实现计划

## 一、需求分析

根据设计文档 `Phase 9：切换家庭弹窗.md`，需要实现以下功能：

### 核心功能
1. **iOS 风格底部弹窗**：圆角卡片，毛玻璃遮罩，顶部拖拽指示条
2. **家庭列表展示**：当前家庭高亮，其他家庭普通样式
3. **切换家庭**：点击非当前家庭触发切换，带 loading 状态
4. **更多操作菜单**：点击 ··· 弹出菜单，包含编辑和删除选项
5. **删除家庭流程**：二次确认弹窗，输入家庭名称验证，防误触
6. **多种关闭方式**：遮罩点击、右上角 ✕、下拉拖拽

### 样式要求
- 主色 #4F46E5，成功色 #10B981，危险色 #EF4444
- 弹窗顶部圆角 24px，卡片圆角 16px
- 动效：弹窗滑入滑出，带回弹感

## 二、文件结构

| 文件 | 作用 | 修改类型 |
|------|------|----------|
| `lib/presentation/profile/widgets/switch_family_bottom_sheet.dart` | 新建组件文件 | 新建 |
| `lib/presentation/profile/profile_panel_page.dart` | 更新使用新组件 | 修改 |
| `lib/presentation/profile/widgets/user_panel.dart` | 更新使用新组件 | 修改 |
| `lib/core/services/family_service.dart` | 添加删除家庭方法 | 修改 |

## 三、实现步骤

### 步骤 1：创建 SwitchFamilyBottomSheet 组件

```dart
// switch_family_bottom_sheet.dart
class SwitchFamilyBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> families;
  final String? currentFamilyId;
  final Map<String, dynamic>? currentFamilyData;
  
  const SwitchFamilyBottomSheet({
    super.key,
    required this.families,
    this.currentFamilyId,
    this.currentFamilyData,
  });
  
  static Future<void> show({
    required BuildContext context,
    required List<Map<String, dynamic>> families,
    String? currentFamilyId,
    Map<String, dynamic>? currentFamilyData,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SwitchFamilyBottomSheet(
        families: families,
        currentFamilyId: currentFamilyId,
        currentFamilyData: currentFamilyData,
      ),
    );
  }
}
```

### 步骤 2：实现组件内部状态和方法

核心方法：
- `_handleSwitchFamily()` - 切换家庭
- `_showMoreMenu()` - 显示更多操作菜单
- `_showDeleteConfirmDialog()` - 显示删除确认弹窗
- `_handleDeleteFamily()` - 删除家庭

### 步骤 3：更新 profile_panel_page.dart

替换现有的 `_showSwitchFamily()` 方法，调用新组件：

```dart
void _showSwitchFamily() {
  SwitchFamilyBottomSheet.show(
    context: context,
    families: _families,
    currentFamilyId: (_familyData?['id'] as dynamic)?.toString(),
    currentFamilyData: _familyData,
  ).then((_) {
    // 刷新数据
    _loadData();
  });
}
```

### 步骤 4：更新 user_panel.dart

同样更新 `_showSwitchFamilyDialog()` 方法。

### 步骤 5：添加删除家庭 API 调用

在 `FamilyService` 中添加：

```dart
Future<ApiResponse<Map<String, dynamic>>> deleteFamily({
  required String familyId,
}) async {
  // 调用 DELETE /api/v1/families/{familyId}
}
```

## 四、删除家庭规则

1. 当前正在使用的家庭不允许删除
2. 仅创建者可删除家庭
3. 家庭内只有 1 个家庭时，不允许删除

## 五、API 接口需求

| 接口 | 方法 | 说明 |
|------|------|------|
| `/api/v1/families/{familyId}` | DELETE | 删除家庭 |

## 六、风险与注意事项

1. **状态同步**：删除或切换家庭后需要刷新页面数据
2. **错误处理**：API 调用失败需要友好提示
3. **动画流畅性**：确保各种动效不卡顿
4. **输入验证**：删除时的家庭名称输入校验

## 七、验收标准

- [ ] 底部弹窗滑入/滑出动效自然
- [ ] 当前家庭有明显视觉区分（左侧竖线、背景色、✓ 当前标签）
- [ ] 点击其他家庭 → loading → 切换成功 Toast → 列表状态更新
- [ ] ··· 菜单弹出/收起
- [ ] 删除流程：二次确认 → 输入校验 → 删除动画 → Toast
- [ ] 当前家庭的删除按钮置灰且有提示
- [ ] 非创建者不显示删除选项
- [ ] 仅剩一个家庭时不可删除
- [ ] 关闭方式：遮罩点击 / ✕ 按钮 / 下拉拖拽
- [ ] Toast 自动消失
