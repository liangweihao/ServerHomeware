# ListTile Material 断言修复 & 物品封面图/详情图 404 修复

## 技术开发文档

### 问题 1：ListTile ink splash 断言

**现象**：打开位置选择器等底部弹窗时，控制台抛出：
`ListTile background color or ink splashes may be invisible`

**原因**：`ListTile` 被包在带背景色的 `Container`/`DecoratedBox`（圆角 24）内，ink splash 绘制在最近的 `Material` 祖先上，被外层装饰遮挡。

**改动**：
- `location_picker.dart`：底部弹窗外层 `Container` → `Material`（带圆角 shape）；每个 `ListTile` 外包一层 `Material`
- `filter_bottom_sheet.dart`、`category_selector.dart`：同样将外层改为 `Material`

### 问题 2：物品列表/详情封面图 404

**现象**：创建物品后列表/详情缩略图加载失败，请求的是 6 月 17 日的旧图片 URL（文件已不存在）。用户反馈「图片是在的」——实际上 `data/uploads/1/` 只有 6/22 新上传的 2 张图，DB 中 `item_images` 表仍保留 6 条历史记录（含 6/17 已删除文件）。

**根因**：
1. 服务端返回全部 `item_images` 记录，不校验磁盘文件是否存在
2. 客户端 `urlsFromServerImages` 未区分物品图与 `__loc__:` 位置图，6 张全部混入物品图轮播
3. 本地 `_saveItemLocally` 曾把服务端全部历史图片写入本地

**改动**：

**服务端**
- `upload_service.image_file_exists()`：校验 `/uploads/` 路径文件是否存在
- `item_service._serialize_item_images()`：详情 API 过滤磁盘不存在的孤儿记录
- `item_repo.get_preview_images()`：预览图取最新且文件存在的记录

**客户端**
- `item_image_storage.parseServerImages()`：分离物品图 / 位置图，`__loc__:` 前缀正确剥离
- `item_detail_provider`：使用分离后的图片列表；打开详情时用服务端有效图片纠正本地 `images` 字段
- `add_item_page`：仅保存本次上传的图片 URL
- `item_image_storage.resolveDisplaySources`：本地优先，远程较新优先
- `item_card` + `item_image_tile`：缩略图加载失败时自动尝试下一张

## 提测开发文档

### 测试点

1. **位置选择器**：添加物品 → 存放位置 → 打开底部弹窗，控制台无 ListTile 断言
2. **物品详情图**：
   - 重启后端（加载新过滤逻辑）
   - 打开物品详情，应只显示 2 张有效图片（6/22 上传），无 404 日志
   - 位置参考照片单独展示在位置行，不混入顶部轮播
3. **新建物品带图**：列表缩略图显示本次上传图片
4. **历史数据**：打开详情后本地 DB 的 `images` 字段应被纠正为仅含有效 URL

### 验证方式

```bash
# 确认磁盘上实际存在的文件
ls data/uploads/1/
# 应只有 20260622_*.webp

# 重启后端后请求详情
curl -H "Authorization: Bearer <token>" http://192.168.1.98:8000/api/v1/items/1
# images 数组应只含 2 条有效记录
```

### 注意事项

- **必须重启后端**才能生效服务端过滤逻辑
- DB 中孤儿 `item_images` 记录仍保留，只是 API 不再返回；如需彻底清理可手动 DELETE 或后续加维护脚本
