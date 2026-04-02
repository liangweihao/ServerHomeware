# API 接口文档

## 基础信息

- **API 基础 URL**: http://localhost:8000/api
- **认证方式**: JWT Token

## 认证相关接口

### 用户注册

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

## 用户相关接口

### 获取用户个人资料

- **请求方法**: GET
- **请求路径**: /profile/
- **请求参数**: 无
- **响应**:
    - 成功: 返回用户个人资料信息
    - 失败: 返回错误信息

### 更新用户个人资料

- **请求方法**: PUT
- **请求路径**: /profile/update/
- **请求参数**:
    - 要更新的用户资料数据 (可选)
- **响应**:
    - 成功: 返回更新后的用户资料信息
    - 失败: 返回错误信息

## 家庭相关接口

### 创建新家庭

- **请求方法**: POST
- **请求路径**: /families/
- **请求参数**:
    - name: 家庭名称 (必填)
- **响应**:
    - 成功: 返回创建的家庭信息
    - 失败: 返回错误信息

### 获取用户的家庭列表

- **请求方法**: GET
- **请求路径**: /families/
- **请求参数**: 无
- **响应**:
    - 成功: 返回家庭列表数据
    - 失败: 返回错误信息

### 获取家庭详情

- **请求方法**: GET
- **请求路径**: /families/{id}/
- **请求参数**:
    - id: 家庭ID (必填)
- **响应**:
    - 成功: 返回家庭详细信息
    - 失败: 返回错误信息

### 加入家庭

- **请求方法**: POST
- **请求路径**: /families/{id}/join/
- **请求参数**:
    - id: 家庭ID (必填)
- **响应**:
    - 成功: 返回加入结果
    - 失败: 返回错误信息

## 物品相关接口

### 添加新物品

- **请求方法**: POST
- **请求路径**: /items/
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

### 获取物品列表

- **请求方法**: GET
- **请求路径**: /items/

**请求参数**:

| 参数名        | 类型     | 说明    | 示例             |
|------------|--------|-------|----------------|
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

### 获取物品详情

- **请求方法**: GET
- **请求路径**: /items/{id}/
- **请求参数**:
    - id: 物品ID (必填)
- **响应**:
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

### 更新物品信息

- **请求方法**: PUT
- **请求路径**: /items/{id}/
- **请求参数**:
    - id: 物品ID (必填)
    - 要更新的物品数据 (必填)
- **响应**:
    - 成功: 返回更新后的物品信息
    - 失败: 返回错误信息

### 删除物品

- **请求方法**: DELETE
- **请求路径**: /items/{id}/
- **请求参数**:
    - id: 物品ID (必填)
- **响应**:
    - 成功: 无返回数据
    - 失败: 返回错误信息

## 分类相关接口

### 添加新分类

- **请求方法**: POST
- **请求路径**: /categories/
- **请求参数**:
  **请求内容**:

```json
{
  "name": "水果",
  "icon": "🍎",
  "color": "#FF6B6B",
  "family": 1
}
```

- **响应**:
    - 成功: 返回创建的分类信息
    - 失败: 返回错误信息

### 获取分类列表

- **请求方法**: GET
- **请求路径**: /categories/
- **请求参数**:
    - family_id: 家庭ID (必填)
- **响应**:
    - 成功: 返回分类列表数据

```json
{
  "count": 0,
  "next": null,
  "previous": null,
  "results": [
    {
      "id": 1,
      "name": "水果",
      "icon": "🍎",
      "color": "#FF6B6B",
      "family": 1,
      "created_at": "2026-03-30T12:00:00Z"
    }
  ]
}
```

- 失败:

```json
{
  "count": 0,
  "next": null,
  "previous": null,
  "results": []
}
```

## 位置相关接口

### 添加新位置

- **请求方法**: POST
- **请求路径**: /locations/
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

### 获取位置列表

- **请求方法**: GET
- **请求路径**: /locations/
- **请求参数**:
    - family_id: 家庭ID (必填)
    - parent: 父位置ID (可选)
- **响应**:
    - 成功: 返回位置列表数据
    - 失败: 返回错误信息

### 获取位置详情

- **请求方法**: GET
- **请求路径**: /locations/{id}/
- **请求参数**:
    - id: 位置ID (必填)
- **响应**:
    - 成功: 返回位置详细信息
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
    - 失败: 返回错误信息
    ```json
    {
      "error": "位置不存在"
    }
    ```

### 更新位置

- **请求方法**: PUT
- **请求路径**: /locations/{id}/
- **请求参数**:
    - id: 位置ID (必填)
    - 要更新的位置数据 (必填)
- **响应**:
    - 成功: 返回更新后的位置信息
    ```json
    {
      "id": 1,
      "name": "厨房",
      "description": "存放厨房用品和食材",
      "parent": null,
      "parent_name": null,
      "family": 1,
      "created_at": "2026-03-30T12:00:00Z"
    }
    ```
    - 失败: 返回错误信息
    ```json
    {
      "error": "位置不存在"
    }
    ```
    或
    ```json
    {
      "name": ["位置名称不能为空"]
    }
    ```

### 删除位置

- **请求方法**: DELETE
- **请求路径**: /locations/{id}/
- **请求参数**:
    - id: 位置ID (必填)
- **响应**:
    - 成功: 无返回数据
    - 失败: 返回错误信息
    ```json
    {
      "error": "位置不存在"
    }
    ```
    或
    ```json
    {
      "error": "该位置下存在子位置，无法删除"
    }
    ```

## 库存相关接口

### 获取库存预警

- **请求方法**: GET
- **请求路径**: /inventory/alert/
- **请求参数**:
    - family_id: 家庭ID (必填)
- **响应**:
    - 成功: 返回库存预警列表
    - 失败: 返回错误信息

### 获取库存报表

- **请求方法**: GET
- **请求路径**: /inventory/report/
- **请求参数**:
    - family_id: 家庭ID (必填)
- **响应**:
    - 成功: 返回库存报表数据
    - 失败: 返回错误信息

### 获取采购建议

- **请求方法**: GET
- **请求路径**: /inventory/suggestions/
- **请求参数**:
    - family_id: 家庭ID (必填)
- **响应**:
    - 成功: 返回采购建议列表
    - 失败: 返回错误信息