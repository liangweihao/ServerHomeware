# 家庭物品管理系统 API 接口文档

## 基础信息

- **Base URL**: `http://localhost:8000/api`
- **认证方式**: JWT Bearer Token
- **请求格式**: JSON
- **响应格式**: JSON

***

## 1. 用户认证模块

### 1.1 用户注册

**功能**: 注册新用户

**请求方式**: `POST`

**请求路径**: `/register/`

**请求头**:

```
Content-Type: application/json
```

**请求内容**:

```json
{
  "username": "testuser",
  "email": "test@example.com",
  "password": "password123",
  "password_confirm": "password123",
  "phone": "13800138000"
}
```

**响应结构** (201 Created):

```json
{
  "user": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "phone": "13800138000",
    "avatar": null,
    "is_verified": false,
    "created_at": "2026-03-30T12:00:00Z"
  },
  "token": {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

**错误响应** (400 Bad Request):

```json
{
  "password_confirm": ["两次密码不一致"]
}
```

***

### 1.2 用户登录

**功能**: 用户登录并获取 JWT Token

**请求方式**: `POST`

**请求路径**: `/login/`

**请求头**:

```
Content-Type: application/json
```

**请求内容**:

```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

**响应结构** (200 OK):

```json
{
  "user": {
    "id": 1,
    "username": "testuser",
    "email": "test@example.com",
    "phone": "13800138000",
    "avatar": null,
    "is_verified": false,
    "created_at": "2026-03-30T12:00:00Z"
  },
  "token": {
    "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
    "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
  }
}
```

**错误响应** (401 Unauthorized):

```json
{
  "error": "邮箱或密码错误"
}
```

**错误响应** (400 Bad Request):

```json
{
  "error": "请输入有效的邮箱地址"
}
```

***

### 1.3 获取用户信息

**功能**: 获取当前登录用户的信息

**请求方式**: `GET`

**请求路径**: `/profile/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**响应结构** (200 OK):

```json
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "phone": "13800138000",
  "avatar": null,
  "is_verified": false,
  "created_at": "2026-03-30T12:00:00Z"
}
```

***

### 1.4 更新用户信息

**功能**: 更新当前登录用户的信息

**请求方式**: `PUT`

**请求路径**: `/profile/update/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "username": "newusername",
  "email": "newemail@example.com",
  "phone": "13900139000",
  "avatar": null
}
```

**响应结构** (200 OK):

```json
{
  "id": 1,
  "username": "newusername",
  "email": "newemail@example.com",
  "phone": "13900139000",
  "avatar": null,
  "is_verified": false,
  "created_at": "2026-03-30T12:00:00Z"
}
```

***

## 2. 家庭管理模块

### 2.1 获取家庭列表

**功能**: 获取当前用户所属的所有家庭

**请求方式**: `GET`

**请求路径**: `/families/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**响应结构** (200 OK):

```json
[
  {
    "id": 1,
    "name": "张三家庭",
    "invite_code": "abc123def4",
    "created_by": 1,
    "created_by_username": "张三",
    "members": [
      {
        "id": 1,
        "username": "张三",
        "email": "zhangsan@example.com",
        "role": "admin",
        "joined_at": "2026-03-30T12:00:00Z"
      }
    ],
    "created_at": "2026-03-30T12:00:00Z"
  }
]
```

***

### 2.2 创建家庭

**功能**: 创建一个新的家庭

**请求方式**: `POST`

**请求路径**: `/families/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "name": "张三家庭"
}
```

**响应结构** (201 Created):

```json
{
  "id": 1,
  "name": "张三家庭",
  "invite_code": "abc123def4",
  "created_by": 1,
  "created_by_username": "张三",
  "members": [
    {
      "id": 1,
      "username": "张三",
      "email": "zhangsan@example.com",
      "role": "admin",
      "joined_at": "2026-03-30T12:00:00Z"
    }
  ],
  "created_at": "2026-03-30T12:00:00Z"
}
```

***

### 2.3 获取家庭详情

**功能**: 获取指定家庭的详细信息

**请求方式**: `GET`

**请求路径**: `/families/{id}/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**响应结构** (200 OK):

```json
{
  "id": 1,
  "name": "张三家庭",
  "invite_code": "abc123def4",
  "created_by": 1,
  "created_by_username": "张三",
  "members": [
    {
      "id": 1,
      "username": "张三",
      "email": "zhangsan@example.com",
      "role": "admin",
      "joined_at": "2026-03-30T12:00:00Z"
    }
  ],
  "created_at": "2026-03-30T12:00:00Z"
}
```

***

### 2.4 加入家庭

**功能**: 通过邀请码加入家庭

**请求方式**: `POST`

**请求路径**: `/families/{id}/join/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "invite_code": "abc123def4"
}
```

**响应结构** (200 OK):

```json
{
  "id": 2,
  "username": "李四",
  "email": "lisi@example.com",
  "role": "member",
  "joined_at": "2026-03-30T12:30:00Z"
}
```

**错误响应** (400 Bad Request):

```json
{
  "invite_code": ["邀请码无效"]
}
```

***

## 3. 物品管理模块

### 3.1 获取物品列表

**功能**: 获取物品列表，支持分页、筛选和搜索

**请求方式**: `GET`

**请求路径**: `/items/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名        | 类型     | 说明    | 示例             |
| ---------- | ------ | ----- | -------------- |
| family\_id | int    | 家庭ID  | 1              |
| category   | int    | 分类ID  | 1              |
| location   | int    | 位置ID  | 1              |
| search     | string | 搜索关键词 | "苹果"           |
| ordering   | string | 排序字段  | "-created\_at" |

**响应结构** (200 OK):

```json
{
  "count": 10,
  "next": "http://localhost:8000/api/items/?page=2",
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "红富士苹果",
      "description": "新鲜红富士苹果",
      "category": 1,
      "category_name": "水果",
      "location": 1,
      "location_name": "厨房",
      "quantity": 10,
      "unit": "个",
      "expiry_date": "2026-04-15",
      "purchase_date": "2026-03-25",
      "price": 15.50,
      "image": null,
      "image_url": null,
      "barcode": "4901234567890",
      "family": 1,
      "created_by": 1,
      "created_by_username": "张三",
      "is_expired": false,
      "is_low_stock": false,
      "created_at": "2026-03-30T12:00:00Z",
      "updated_at": "2026-03-30T12:00:00Z"
    }
  ]
}
```

***

### 3.2 添加物品

**功能**: 添加新物品

**请求方式**: `POST`

**请求路径**: `/items/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "name": "红富士苹果",
  "description": "新鲜红富士苹果",
  "category": 1,
  "location": 1,
  "quantity": 10,
  "unit": "个",
  "expiry_date": "2026-04-15",
  "purchase_date": "2026-03-25",
  "price": 15.50,
  "image": null,
  "barcode": "4901234567890",
  "family": 1
}
```

**响应结构** (201 Created):

```json
{
  "id": 1,
  "name": "红富士苹果",
  "description": "新鲜红富士苹果",
  "category": 1,
  "category_name": "水果",
  "location": 1,
  "location_name": "厨房",
  "quantity": 10,
  "unit": "个",
  "expiry_date": "2026-04-15",
  "purchase_date": "2026-03-25",
  "price": 15.50,
  "image": null,
  "image_url": null,
  "barcode": "4901234567890",
  "family": 1,
  "created_by": 1,
  "created_by_username": "张三",
  "is_expired": false,
  "is_low_stock": false,
  "created_at": "2026-03-30T12:00:00Z",
  "updated_at": "2026-03-30T12:00:00Z"
}
```

***

### 3.3 获取物品详情

**功能**: 获取指定物品的详细信息

**请求方式**: `GET`

**请求路径**: `/items/{id}/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**响应结构** (200 OK):

```json
{
  "id": 1,
  "name": "红富士苹果",
  "description": "新鲜红富士苹果",
  "category": 1,
  "category_name": "水果",
  "location": 1,
  "location_name": "厨房",
  "quantity": 10,
  "unit": "个",
  "expiry_date": "2026-04-15",
  "purchase_date": "2026-03-25",
  "price": 15.50,
  "image": null,
  "image_url": null,
  "barcode": "4901234567890",
  "family": 1,
  "created_by": 1,
  "created_by_username": "张三",
  "is_expired": false,
  "is_low_stock": false,
  "created_at": "2026-03-30T12:00:00Z",
  "updated_at": "2026-03-30T12:00:00Z"
}
```

***

### 3.4 更新物品

**功能**: 更新物品信息

**请求方式**: `PUT`

**请求路径**: `/items/{id}/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "name": "红富士苹果",
  "description": "新鲜红富士苹果",
  "category": 1,
  "location": 1,
  "quantity": 15,
  "unit": "个",
  "expiry_date": "2026-04-20",
  "purchase_date": "2026-03-25",
  "price": 15.50,
  "image": null,
  "barcode": "4901234567890"
}
```

**响应结构** (200 OK):

```json
{
  "id": 1,
  "name": "红富士苹果",
  "description": "新鲜红富士苹果",
  "category": 1,
  "category_name": "水果",
  "location": 1,
  "location_name": "厨房",
  "quantity": 15,
  "unit": "个",
  "expiry_date": "2026-04-20",
  "purchase_date": "2026-03-25",
  "price": 15.50,
  "image": null,
  "image_url": null,
  "barcode": "4901234567890",
  "family": 1,
  "created_by": 1,
  "created_by_username": "张三",
  "is_expired": false,
  "is_low_stock": false,
  "created_at": "2026-03-30T12:00:00Z",
  "updated_at": "2026-03-30T13:00:00Z"
}
```

***

### 3.5 删除物品

**功能**: 删除指定物品

**请求方式**: `DELETE`

**请求路径**: `/items/{id}/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**响应结构** (204 No Content):

```
无响应内容
```

***

### 3.6 批量删除物品

**功能**: 批量删除物品

**请求方式**: `POST`

**请求路径**: `/items/batch-delete/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "item_ids": [1, 2, 3]
}
```

**响应结构** (200 OK):

```json
{
  "message": "成功删除 3 个物品",
  "deleted_count": 3
}
```

***

### 3.7 获取分类列表

**功能**: 获取分类列表

**请求方式**: `GET`

**请求路径**: `/categories/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名        | 类型  | 说明   | 示例 |
| ---------- | --- | ---- | -- |
| family\_id | int | 家庭ID | 1  |

**响应结构** (200 OK):

```json
[
  {
    "id": 1,
    "name": "水果",
    "icon": "🍎",
    "color": "#FF6B6B",
    "family": 1,
    "created_at": "2026-03-30T12:00:00Z"
  }
]
```

**响应结构** (200 OK - 无数据):

```json
{"count":0,"next":null,"previous":null,"results":[]}
```

***

### 3.8 创建分类

**功能**: 创建新分类

**请求方式**: `POST`

**请求路径**: `/categories/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "name": "水果",
  "icon": "🍎",
  "color": "#FF6B6B",
  "family": 1
}
```

**响应结构** (201 Created):

```json
{
  "id": 1,
  "name": "水果",
  "icon": "🍎",
  "color": "#FF6B6B",
  "family": 1,
  "created_at": "2026-03-30T12:00:00Z"
}
```

***

### 3.9 获取位置列表

**功能**: 获取位置列表

**请求方式**: `GET`

**请求路径**: `/locations/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名        | 类型  | 说明    | 示例 |
| ---------- | --- | ----- | -- |
| family\_id | int | 家庭ID  | 1  |
| parent     | int | 父位置ID | 1  |

**响应结构** (200 OK):

```json
[
  {
    "id": 1,
    "name": "厨房",
    "description": "存放厨房用品",
    "parent": null,
    "parent_name": null,
    "family": 1,
    "created_at": "2026-03-30T12:00:00Z"
  }
]
```

***

### 3.10 创建位置

**功能**: 创建新位置

**请求方式**: `POST`

**请求路径**: `/locations/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "name": "厨房",
  "description": "存放厨房用品",
  "parent": null,
  "family": 1
}
```

**响应结构** (201 Created):

```json
{
  "id": 1,
  "name": "厨房",
  "description": "存放厨房用品",
  "parent": null,
  "parent_name": null,
  "family": 1,
  "created_at": "2026-03-30T12:00:00Z"
}
```

***

## 4. 库存管理模块

### 4.1 获取库存预警

**功能**: 获取库存预警列表

**请求方式**: `GET`

**请求路径**: `/inventory/alert/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名          | 类型     | 说明    | 示例           |
| ------------ | ------ | ----- | ------------ |
| family\_id   | int    | 家庭ID  | 1            |
| alert\_type  | string | 预警类型  | "low\_stock" |
| is\_resolved | bool   | 是否已解决 | true         |

**响应结构** (200 OK):

```json
[
  {
    "id": 1,
    "item": 1,
    "item_name": "红富士苹果",
    "item_details": {...},
    "alert_type": "low_stock",
    "threshold": 5,
    "message": "库存低于阈值",
    "is_resolved": false,
    "created_at": "2026-03-30T12:00:00Z",
    "resolved_at": null
  }
]
```

***

### 4.2 解决库存预警

**功能**: 解决库存预警

**请求方式**: `POST`

**请求路径**: `/inventory/alert/resolve/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "alert_ids": [1, 2, 3]
}
```

**响应结构** (200 OK):

```json
{
  "message": "成功解决 3 个预警",
  "resolved_count": 3
}
```

***

### 4.3 获取库存报表

**功能**: 获取库存统计报表

**请求方式**: `GET`

**请求路径**: `/inventory/report/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名        | 类型  | 说明   | 示例 |
| ---------- | --- | ---- | -- |
| family\_id | int | 家庭ID | 1  |

**响应结构** (200 OK):

```json
{
  "total_items": 50,
  "total_value": 1250.50,
  "category_stats": [
    {
      "name": "水果",
      "count": 20,
      "total_quantity": 100,
      "total_value": 500.00
    }
  ],
  "location_stats": [
    {
      "name": "厨房",
      "count": 30,
      "total_quantity": 80
    }
  ],
  "low_stock_count": 5,
  "expired_count": 2,
  "expiring_soon_count": 8
}
```

***

### 4.4 获取采购建议

**功能**: 获取采购建议列表

**请求方式**: `GET`

**请求路径**: `/inventory/suggestions/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名        | 类型  | 说明   | 示例 |
| ---------- | --- | ---- | -- |
| family\_id | int | 家庭ID | 1  |

**响应结构** (200 OK):

```json
[
  {
    "item_id": 1,
    "item_name": "红富士苹果",
    "current_quantity": 2,
    "suggested_quantity": 8,
    "reason": "库存不足",
    "priority": "high"
  }
]
```

***

### 4.5 获取库存日志

**功能**: 获取库存操作日志

**请求方式**: `GET`

**请求路径**: `/inventory/logs/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名        | 类型     | 说明   | 示例        |
| ---------- | ------ | ---- | --------- |
| family\_id | int    | 家庭ID | 1         |
| item\_id   | int    | 物品ID | 1         |
| action     | string | 操作类型 | "consume" |

**响应结构** (200 OK):

```json
[
  {
    "id": 1,
    "item": 1,
    "item_name": "红富士苹果",
    "action": "consume",
    "action_display": "消耗",
    "quantity_before": 10,
    "quantity_after": 8,
    "quantity_change": -2,
    "note": "食用",
    "created_at": "2026-03-30T12:00:00Z"
  }
]
```

***

### 4.6 记录库存操作

**功能**: 记录库存操作日志

**请求方式**: `POST`

**请求路径**: `/inventory/logs/log-action/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "item_id": 1,
  "action": "consume",
  "quantity_change": 2,
  "note": "食用"
}
```

**响应结构** (201 Created):

```json
{
  "id": 1,
  "item": 1,
  "item_name": "红富士苹果",
  "action": "consume",
  "action_display": "消耗",
  "quantity_before": 10,
  "quantity_after": 8,
  "quantity_change": -2,
  "note": "食用",
  "created_at": "2026-03-30T12:00:00Z"
}
```

***

## 5. 数据同步模块

### 5.1 发起数据同步

**功能**: 发起数据同步请求

**请求方式**: `POST`

**请求路径**: `/sync/initiate/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "family_id": 1,
  "sync_type": "incremental",
  "last_sync_timestamp": "2026-03-30T10:00:00Z"
}
```

**响应结构** (200 OK):

```json
{
  "items": [
    {
      "id": 1,
      "name": "红富士苹果",
      "description": "新鲜红富士苹果",
      "category_id": 1,
      "location_id": 1,
      "quantity": 10,
      "unit": "个",
      "expiry_date": "2026-04-15",
      "purchase_date": "2026-03-25",
      "price": 15.50,
      "barcode": "4901234567890",
      "family_id": 1,
      "created_by_id": 1,
      "created_at": "2026-03-30T12:00:00Z",
      "updated_at": "2026-03-30T12:00:00Z",
      "image_url": null
    }
  ],
  "categories": [...],
  "locations": [...],
  "timestamp": "2026-03-30T12:00:00Z"
}
```

***

### 5.2 上传客户端数据

**功能**: 上传客户端数据到服务器

**请求方式**: `POST`

**请求路径**: `/sync/upload/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "family_id": 1,
  "items": [
    {
      "id": 1,
      "name": "红富士苹果",
      "quantity": 15,
      "updated_at": "2026-03-30T13:00:00Z"
    }
  ]
}
```

**响应结构** (200 OK):

```json
{
  "message": "数据上传成功",
  "conflicts": []
}
```

***

### 5.3 获取同步记录

**功能**: 获取同步记录列表

**请求方式**: `GET`

**请求路径**: `/sync/records/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名        | 类型  | 说明   | 示例 |
| ---------- | --- | ---- | -- |
| family\_id | int | 家庭ID | 1  |

**响应结构** (200 OK):

```json
[
  {
    "id": 1,
    "user": 1,
    "username": "张三",
    "family": 1,
    "family_name": "张三家庭",
    "sync_type": "incremental",
    "sync_type_display": "增量同步",
    "status": "completed",
    "status_display": "已完成",
    "last_sync_timestamp": "2026-03-30T10:00:00Z",
    "current_sync_timestamp": "2026-03-30T12:00:00Z",
    "items_count": 50,
    "error_message": null,
    "created_at": "2026-03-30T12:00:00Z",
    "completed_at": "2026-03-30T12:00:05Z"
  }
]
```

***

### 5.4 获取同步冲突

**功能**: 获取同步冲突列表

**请求方式**: `GET`

**请求路径**: `/sync/conflicts/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求参数**:

| 参数名              | 类型   | 说明     | 示例   |
| ---------------- | ---- | ------ | ---- |
| sync\_record\_id | int  | 同步记录ID | 1    |
| is\_resolved     | bool | 是否已解决  | true |

**响应结构** (200 OK):

```json
[
  {
    "id": 1,
    "sync_record": 1,
    "item": 1,
    "item_name": "红富士苹果",
    "conflict_type": "update",
    "conflict_type_display": "更新冲突",
    "server_data": {...},
    "client_data": {...},
    "resolution": null,
    "resolution_display": null,
    "is_resolved": false,
    "resolved_at": null,
    "created_at": "2026-03-30T12:00:00Z"
  }
]
```

***

### 5.5 解决同步冲突

**功能**: 解决同步冲突

**请求方式**: `POST`

**请求路径**: `/sync/conflicts/resolve/`

**请求头**:

```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**请求内容**:

```json
{
  "conflict_id": 1,
  "resolution": "server",
  "manual_data": null
}
```

**响应结构** (200 OK):

```json
{
  "message": "冲突已解决"
}
```

***

## 错误码说明

| 状态码 | 说明               |
| --- | ---------------- |
| 200 | 请求成功             |
| 201 | 创建成功             |
| 204 | 删除成功             |
| 400 | 请求参数错误           |
| 401 | 未授权（Token 无效或过期） |
| 403 | 禁止访问             |
| 404 | 资源不存在            |
| 500 | 服务器内部错误          |

***

## JWT Token 管理

### Token 说明

- **Access Token**: 用于API认证，有效期默认60分钟
- **Refresh Token**: 用于刷新Access Token，有效期默认24小时

### 刷新 Token

```http
POST /api/auth/token/refresh/
Content-Type: application/json

{
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

***

## 注意事项

1. 所有需要认证的接口必须在请求头中包含 `Authorization: Bearer <access_token>`
2. 所有POST/PUT/PATCH请求必须设置 `Content-Type: application/json`
3. 家庭成员只能访问所属家庭的数据
4. 物品、分类、位置等资源都属于特定家庭
5. 库存操作会自动记录日志
6. 同步功能支持全量同步和增量同步

***

## 更新日志

- **2026-03-30**: 初始版本发布

