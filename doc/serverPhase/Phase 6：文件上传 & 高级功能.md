# HomeStock Server — Phase 6：文件上传 & 高级功能

## 前置条件
Phase 1-5 已完成。

## 本阶段目标
实现文件上传（图片）、条码查询服务、数据导出、WebSocket实时通信。

---

## 任务1：文件上传

### 图片上传 API

**POST /api/v1/upload/image**
```
请求：multipart/form-data，字段 file
限制：最大10MB，格式 jpg/jpeg/png/webp
逻辑：
- 校验文件类型和大小
- 压缩图片（最大宽度1080px，质量85%）
- 生成文件名：{family_id}/{timestamp}_{uuid}.webp
- 保存到 UPLOAD_DIR
- 返回文件URL
响应：{url: "/uploads/1/20240125_abc123.webp"}
```

**POST /api/v1/upload/images**
```
说明：批量上传（最多5张）
请求：multipart/form-data，字段 files（多文件）
响应：{urls: [...]}
```

**DELETE /api/v1/upload/image**
```
请求：{url}
逻辑：删除文件
```

### 静态文件服务
配置 FastAPI StaticFiles 挂载 /uploads 目录，供 Flutter 端访问图片。
或配置 Nginx 反向代理静态资源。

### 图片处理
使用 Pillow 库：
- 读取上传文件
- 自动旋转（根据EXIF）
- 等比缩放到最大1080px宽度
- 转为WebP格式（节省空间）
- 保存

---

## 任务2：条码查询服务

**GET /api/v1/barcode/{code}**
```
逻辑优先级：
1. 先查本地数据库：当前家庭是否已有该条码的物品
   - 有 → 返回物品信息 + "already_exists": true
2. 查询公开商品信息API（如有对接）
   - 找到 → 返回商品名称、品牌、规格
3. 都没有 → 返回 404

响应（已存在）：
{
  "already_exists": true,
  "item": { ... }
}

响应（新商品，从公开API获取）：
{
  "already_exists": false,
  "product_info": {
    "name": "蒙牛纯牛奶",
    "brand": "蒙牛",
    "specification": "250ml",
    "barcode": "6907992500867"
  }
}
```

注：公开商品API可后续对接，MVP阶段只检查本地数据库即可。

---

## 任务3：数据导出

**POST /api/v1/export/items**
```
请求：{format: "csv", status_filter: [0,1,2,3]}
逻辑：
- 根据筛选条件查询物品
- 生成CSV文件（包含列：名称、品牌、分类、位置、单价、数量、剩余、单位、购买日期、过期日期、状态）
- 保存到临时文件
- 返回下载URL
响应：{download_url: "/api/v1/export/download/abc123.csv", expires_in: 3600}
```

**GET /api/v1/export/download/{filename}**
```
说明：下载导出文件
逻辑：验证文件存在且未过期，返回文件流
```

**POST /api/v1/export/items/json**
```
说明：JSON格式完整导出（用于数据备份）
响应：完整的家庭数据JSON（物品+分类+位置+使用记录）
```

---

## 任务4：WebSocket 实时通知（可选增强）

### 实时通知 WebSocket

**WS /api/v1/ws/notifications**
```
连接时需要传 token 参数进行认证
连接后服务端推送实时事件：

事件类型：
- item_updated: 物品信息变更（其他家庭成员操作时推送给你）
- item_used: 物品被使用
- new_notification: 新提醒产生
- shopping_updated: 购物清单变更

消息格式：
{
  "event": "item_used",
  "data": {
    "item_id": 123,
    "item_name": "牛奶",
    "operator": "爸爸",
    "quantity": 1,
    "remaining": 2
  },
  "timestamp": "2024-01-25T10:30:00Z"
}
```

实现方式：
- 使用 FastAPI WebSocket
- 连接管理器维护 family_id → [connections] 映射
- 当有操作发生时，向同家庭其他在线设备广播
- 支持心跳检测（30秒一次ping/pong）
- 断线自动清理

---

## 任务5：用户设置 & 个人信息

**GET /api/v1/users/me**
```
响应：完整用户信息 + 当前家庭信息 + 通知偏好
```

**PUT /api/v1/users/me**
```
请求：{nickname, avatar_url, email, family_nickname}
说明：family_nickname 写入 family_members.nickname_in_family（当前家庭内称呼）
```

**PUT /api/v1/users/me/password**
```
请求：{old_password, new_password}
逻辑：验证旧密码 → 更新新密码hash
```

**DELETE /api/v1/users/me**
```
说明：注销账户
逻辑：
- 如果是家庭owner且家庭有其他成员 → 拒绝（先转让）
- 否则：软删除用户 + 退出所有家庭
```

---

## 任务6：健康检查 & 管理接口

**GET /api/v1/health**
```
响应：
{
  "status": "ok",
  "database": "connected",
  "redis": "connected",
  "version": "1.0.0",
  "uptime": "3d 12h 30m"
}
无需认证
```

**GET /api/v1/admin/stats**（仅开发环境）
```
响应：系统级统计
{
  "total_users": 150,
  "total_families": 80,
  "total_items": 5600,
  "active_today": 45
}
```

---

## 任务7：API 限流 & 安全

### 限流规则
使用 slowapi 或 Redis 实现：
- 登录接口：每IP 10次/分钟（防暴力破解）
- 注册接口：每IP 5次/小时
- 普通接口：每用户 60次/分钟
- 上传接口：每用户 20次/分钟

### 安全措施
- 密码强度校验：至少8位，包含字母和数字
- SQL注入防护：ORM参数化查询（SQLAlchemy默认安全）
- XSS防护：Pydantic 自动转义
- 文件上传：类型检查 + 文件头校验（防伪造扩展名）
- 敏感信息：响应中不返回 password_hash

---

## 验收标准

1. ✅ 图片上传成功，压缩和格式转换正确
2. ✅ 上传后图片可通过URL正常访问
3. ✅ 条码查询：已有物品返回信息，没有返回404
4. ✅ CSV导出文件格式正确，可用Excel打开
5. ✅ JSON完整导出包含所有家庭数据
6. ✅ WebSocket连接正常，能收到其他成员操作的实时推送
7. ✅ WebSocket断线重连后恢复正常
8. ✅ 用户信息修改/密码修改正常
9. ✅ 健康检查接口正确返回服务状态
10. ✅ 限流生效：超出频率返回429
11. ✅ 上传非法文件类型被拒绝