# 编辑物品 + 表单图片能力

## 实现方案

- 抽取 `ItemFormController` / `ItemFormView`：添加、编辑共用表单与照片区
- `ItemImageStorage`：相册/相机选图 → 应用目录持久化 → `items.images` 存 JSON 路径数组
- `EditItemPage`：加载本地物品预填，PUT 更新 + `db.updateItem`
- `ItemService.updateItem`：对接 `PUT /api/v1/items/{id}`
- 列表 `ItemCard`、详情页轮播：使用 `Image.file` 显示本地图

## 改动文件

| 文件 | 说明 |
|------|------|
| `item_image_storage.dart` | 图片持久化与 JSON 编解码 |
| `item_image_picker_section.dart` | 表单顶部选图 UI |
| `item_form_controller.dart` / `item_form_view.dart` | 共享表单 |
| `add_item_page.dart` | 重构为使用共享表单 |
| `edit_item_page.dart` | 完整实现 |
| `item_service.dart` | 新增 updateItem |
| `item_card.dart` / `item_detail_page.dart` | 展示本地图片 |
| `doc/appPhase/Phase 2` / `doc/appPhase/原型图.md` | 补充照片与编辑交互 |

## 提测要点

1. 添加物品：选 1～5 张照片 → 保存 → 列表缩略图、详情轮播可见
2. 编辑物品：预填含图片，删一张/add 一张 → 保存 → 详情更新
3. 编辑改分类/位置/购买信息，当前剩余量不变
4. 无图时列表/详情仍显示占位图标
5. 服务端 PUT 失败时本地仍应保存（日志 WARN）

## 注意事项

- 图片仅存客户端本地路径，尚未对接服务端图片上传 API
- 卸载应用会清除本地图片文件
