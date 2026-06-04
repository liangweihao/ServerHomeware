# API 变更 & 客户端同步 — 技术文档

## 一、服务端 API 变更

### 1. GET /api/v1/items — 列表接口新增 preview_image

**变更前**：列表只返回 name, brand, category_id, status 等摘要字段，无图片

**变更后**：每条记录新增 `preview_image` 字段（首张图片 URL）

```json
{
  "id": 11,
  "name": "风扇",
  "status": 0,
  "preview_image": "/uploads/7/20260601_205020_4c8ca3d7.jpg",
  ...
}
```

**实现**：`ItemRepository.get_preview_images()` 批量查询 item_images 表，取每个物品 sort_order 最小的图片 URL

### 2. GET /api/v1/usage_records — 支持全家庭分页查询

**变更前**：只能按 item_id 查询单物品使用记录

**变更后**：不传 item_id 时返回当前家庭全部使用记录，支持分页

| 参数 | 类型 | 说明 |
|------|------|------|
| item_id | int? | 物品ID（不传=全家庭） |
| page | int | 页码，默认1 |
| page_size | int | 每页大小，默认20，最大100 |

响应新增 `item_name` 字段，方便前端直接展示：

```json
{
  "items": [{
    "id": 13,
    "item_id": 11,
    "item_name": "风扇",
    "type": 0,
    "quantity": 1.0,
    "remaining_quantity": 1.0,
    "operator_name": "系统",
    "created_at": "2026-06-01T12:50:20"
  }],
  "total": 13,
  "page": 1,
  "page_size": 100
}
```

**实现**：
- `UsageRecordRepository.get_recent_by_family()` — 按 family_id 分页查询，按 created_at 倒序
- `UsageRecordRepository.count_by_family()` — 统计总数

### 3. PUT /api/v1/users/me — 新增 family_nickname 字段

**变更前**：只接受 nickname, email, avatar_url

**变更后**：新增可选字段 `family_nickname`，写入 `family_members.nickname_in_family`

```json
{
  "nickname": "梁先生",
  "family_nickname": "老梁"
}
```

**实现**：
- `UpdateUserRequest` schema 新增 `family_nickname` 字段
- `update_current_user` API 传入 `current_family_id`
- `UserService.update_user()` 处理 `family_nickname`：执行 UPDATE family_members SET nickname_in_family = ?

### 4. DELETE /api/v1/items/{id} — 同步清理磁盘图片

**变更内容**：删除物品时，除软删除 DB 记录外，同步调用 `UploadService.delete_image()` 删除 `uploads/{family_id}/` 下的图片文件

## 二、Flutter 客户端变更

### 1. 物品操作同步服务端

所有物品操作现在会同步调用服务端 API（fire-and-forget，不阻塞用户）：

| 操作 | 调用的 API | 请求体 |
|------|-----------|--------|
| 用完 | PUT /items/{id} | {status: 1, current_quantity: 0} |
| 过期 | PUT /items/{id} | {status: 2} |
| 丢弃 | PUT /items/{id} | {status: 3} |
| 删除 | DELETE /items/{id} | — |
| 移动 | PUT /items/{id} | {location_id: ...} |

**涉及文件**：`item_detail_page.dart`

### 2. 服务端→本地同步

#### 物品同步（ItemSyncService）
- 来源：`GET /api/v1/items`（分页拉取全量）
- 时机：物品列表页加载时（`filteredItemsProvider`）
- 逻辑：本地不存在的物品才插入，已存在的补充 `preview_image`

#### 使用记录同步（UsageRecordSyncService）
- 来源：`GET /api/v1/usage_records`（分页拉取全量）
- 时机：首页动态加载时（`recentActivitiesProvider`）
- 逻辑：按 item_id + created_at 去重，只插入本地不存在的记录

#### 物品列表自动刷新
- `filteredItemsProvider` 改为 `ref.watch(itemEventBusProvider)`，事件总线版本号变化时自动重新查询

#### 首页统计自动刷新
- `homeStatsProvider` / `spacesProvider` / `recentActivitiesProvider` 改为 `ref.watch(itemEventBusProvider)`

### 3. 错误处理统一（ErrorHandler）

**新建** `core/utils/error_handler.dart`：
- `debugPrint` 打印完整异常 + 堆栈（含调用位置标签）
- Toast 显示用户友好的中文错误提示

**涉及 7 个文件、8 个 catch 块**：login_page, register_page, create_family_page, join_family_page, forgot_password_page, verify_code_page, edit_profile_page

### 4. UI 优化

| 文件 | 改动 |
|------|------|
| `item_card.dart` | status=3 卡片半透明 + 红色"已丢弃"标签，status=1 灰色"已用完" |
| `alert_card.dart` | 修复 `height: double.infinity` 布局报错（改用 IntrinsicHeight） |
| `family_management_page.dart` | ListTile 包 Material 消除墨水波纹警告 |
| `notification_settings_page.dart` | ListTile/SwitchListTile 包 Material 消除墨水波纹警告 |
| `edit_profile_page.dart` | 家庭内称呼现在会发送到服务端 |
| `item_form_controller.dart` | 编辑时 `decodeAllPaths` 保留服务端图片 URL |
| `item_form_view.dart` | 存放位置新增拍照按钮（调起相机拍位置参考图） |

## 三、测试点

### 服务端 API
1. `GET /api/v1/items` 返回 `preview_image` 字段（有图片的物品）
2. `GET /api/v1/usage_records?page=1&page_size=5` 返回最近5条记录含 item_name
3. `PUT /api/v1/users/me` 传入 `family_nickname` 后，`family_members.nickname_in_family` 更新
4. `DELETE /api/v1/items/{id}` 后磁盘图片文件被删除

### Flutter 客户端
1. 丢弃物品 → 服务端 status 变为 3 → 列表页显示"已丢弃"标签
2. 删除物品 → 服务端 item 被删除 → 列表页不显示
3. 清缓存后重新打开 → 物品和使用记录从服务端恢复
4. 编辑物品 → 已有图片正确显示
5. 存放位置拍照 → 照片添加到物品图片列表
6. Toast 错误提示为中文友好信息，logcat 有完整堆栈

## 四、注意事项

- 服务端新增 `ItemRepository.get_preview_images()` 使用子查询优化，避免 N+1
- `UsageRecordRepository` 新增 `get_recent_by_family` 和 `count_by_family`
- 客户端同步为增量同步，不会覆盖本地更完整的数据
- 位置拍照生成的图片与物品图片共用一个 images 字段
