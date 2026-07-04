# _LocationPhotoButton 增加从相册导入功能

**日期**：2026-06-18  
**变更类型**：功能增强  
**影响范围**：物品添加/编辑表单 - 存放位置区域

---

## 技术开发文档

### 需求背景

`_LocationPhotoButton` 原本只能打开相机拍照，用户希望也能从系统相册导入已有照片来记录物品存放位置。

### 实现方案

**参照现有模式**：`ItemImagePickerSection`（`widgets/item_image_picker_section.dart`）已有成熟的「拍照/相册」底部弹窗选择模式，本次改动直接复用这个 UI 交互模式。

**改动点**（单文件：`item_form_view.dart`）：

| 位置 | 改动前 | 改动后 |
|------|--------|--------|
| `_takePhoto` 方法 | 直接调用 `ImagePicker.pickImage(source: camera)` | 重命名为 `_pickImage`，先弹出 `showModalBottomSheet` 让用户选择 source（gallery / camera），再调用 picker |
| 异常提示 | `'拍照失败'` | `'获取图片失败'`（更通用，覆盖两类失败场景） |
| Tooltip | `'拍照记录存放位置'` | `'拍照或从相册选择位置照片'` |
| 类注释 | `位置拍照按钮` | `位置拍照/相册按钮` |

**底部弹窗选项**：
- 从相册选择 → `ImageSource.gallery`
- 拍照 → `ImageSource.camera`

### 不变的部分

- `onPhotoTaken` 回调签名
- 按钮外观（48×48，`Icons.add_a_photo_outlined`，主题色）
- 图片持久化逻辑（`ItemImageStorage.persistPickedImage`）
- 成功/异常时的 SnackBar 提示模式

---

## 提测开发文档

### 测试点

1. **底部菜单弹出**：点击位置拍照按钮，确认弹出底部菜单，包含「从相册选择」和「拍照」两个选项
2. **拍照 → 原有功能**：选择「拍照」→ 系统相机打开 → 拍照 → 照片出现在位置预览区
3. **从相册选择 → 新功能**：选择「从相册选择」→ 系统相册打开 → 选择照片 → 照片出现在位置预览区
4. **取消选择**：弹出菜单后点空白区域关闭，不应该有任何副作用
5. **取消拍照/相册**：在相机或相册中取消，不应该添加照片
6. **删除照片**：位置照片预览区的删除按钮仍然正常工作
7. **编辑模式**：编辑已有物品时仍然可以添加/删除位置照片

### 注意事项

- 需要在真机或模拟器上测试，相机功能在非移动设备上不可用
- Windows 桌面端：`ImageSource.camera` 可能不可用（取决于是否有摄像头），`ImageSource.gallery` 应该可用
- 不需要修改任何权限配置，`image_picker` 权限已就绪
