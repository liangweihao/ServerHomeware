# 更新家庭删除接口 - 代码变更记录

## 日期
2026-05-27

## 技术开发文档

### 实现方案

本次修改主要是为了配合服务端的家庭删除接口更新，在客户端实现了以下功能：

1. 在 `FamilyService.deleteFamily` 方法中新增 `confirmName` 参数
2. 将确认的家庭名称作为 JSON 数据发送到服务端
3. 更新相关的 UI 调用代码，传递确认名称

### 改动点

#### 1. FamilyService 更新
**文件位置**: `HomeWareClient/lib/core/services/family_service.dart`
- **方法**: `deleteFamily`
- **变更内容**:
  - 新增 `confirmName` 必填参数
  - 更新文档注释，添加请求参数说明
  - 在 HTTP DELETE 请求体中添加 `confirm_name` 字段
  - 更新日志记录，包含 confirmName 信息

#### 2. 底部弹窗组件更新
**文件位置**: `HomeWareClient/lib/presentation/profile/widgets/switch_family_bottom_sheet.dart`
- **方法**: `_buildDeleteConfirmDialog`
  - 更新调用 `_handleDeleteFamily` 时传递 `controller.text.trim()` 作为确认名称
- **方法**: `_handleDeleteFamily`
  - 新增 `confirmName` 参数
  - 更新调用 `service.deleteFamily` 时传递 `confirmName` 参数

### 影响范围

- 家庭删除功能的服务端调用方式发生变化
- 删除家庭时需要通过确认家庭名称进行双重验证

---

## 提测开发文档

### 测试点

1. **家庭删除流程测试**
   - 验证删除家庭时需要输入家庭名称确认
   - 验证只有输入正确的家庭名称时才能删除
   - 验证删除成功后，家庭列表会正确更新

2. **API 接口测试**
   - 验证 DELETE /api/v1/families/{familyId} 接口是否正常调用
   - 验证请求体中是否包含正确的 confirm_name 字段
   - 验证接口返回结果是否正常处理

3. **UI 交互测试**
   - 验证删除确认对话框的行为是否正常
   - 验证确认按钮的状态是否根据输入内容正确切换
   - 验证删除成功/失败的提示信息是否正确显示

### 验证方式

1. 在应用中创建多个家庭
2. 尝试删除一个非当前家庭
3. 在确认对话框中输入错误的家庭名称，验证无法删除
4. 输入正确的家庭名称，验证能够成功删除
5. 检查家庭列表是否正确更新

### 注意事项

- 只有家庭创建者（owner）可以删除家庭
- 当前家庭无法删除，需要先切换到其他家庭
- 至少需要保留一个家庭
- 删除操作不可逆，会永久删除该家庭下的所有数据
