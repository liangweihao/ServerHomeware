# 物品图片上传与详情拉取

## 实现方案

对接 `doc/serverPhase/Phase 6` 上传 API：

1. **UploadService**：`POST /api/v1/upload/image` multipart 上传
2. **AddItemPage**：保存前先上传图片 → `image_urls` 随创建物品请求提交
3. **服务端**：`CreateItemRequest.image_urls` → 写入 `item_images` 表
4. **ItemDetailProvider**：`GET /api/v1/items/{id}` 拉取 `images` 列表
5. **AppEnv.resolveUploadUrl**：`/uploads/...` → 完整 HTTP URL
6. **ItemImageTile**：统一展示本地 file / 网络 URL

## 改动文件

| 文件 | 说明 |
|------|------|
| `upload_service.dart` | 客户端上传 |
| `item_service.dart` | getItemDetail |
| `app_env.dart` | serverOrigin / resolveUploadUrl |
| `add_item_page.dart` | 保存前上传 |
| `item_detail_provider.dart` | 服务端图片优先 |
| `item_detail_page.dart` | 网络轮播 |
| `HomeWareServer/.../item.py` | image_urls 字段 |
| `HomeWareServer/.../item_service.py` | 创建时写 item_images |

## 提测要点

1. 添加物品选图 → 保存 → 服务端 `item_images` 有记录
2. 详情页轮播显示服务端图片（需手机能访问 `192.168.x.x:8000/uploads/...`）
3. 上传失败时阻止创建并提示
4. 无图时仍显示分类 emoji 占位

## 注意事项

- 需重启 HomeWareServer 使 `image_urls` schema 生效
- 编辑页尚未接入上传（仍仅本地）
- 真机访问图片 URL 需与 API 同网段
