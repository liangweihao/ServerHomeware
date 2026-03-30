# 家庭物品管理系统 - 服务端

基于 Django REST Framework 开发的家庭物品管理系统后端服务。

## 技术栈

- **后端框架**: Django 4.2.7
- **API框架**: Django REST Framework 3.14.0
- **认证**: JWT (djangorestframework-simplejwt)
- **数据库**: SQLite (本地开发)
- **任务队列**: Celery 5.3.4
- **API文档**: drf-spectacular
- **部署**: 直接运行 (无需Docker)

## 项目结构

```
server/
├── apps/
│   ├── users/          # 用户管理模块
│   ├── items/          # 物品管理模块
│   ├── inventory/      # 库存管理模块
│   └── sync/           # 数据同步模块
├── home_inventory/     # 项目配置
├── logs/               # 日志目录
├── manage.py          # Django管理脚本
├── requirements.txt   # Python依赖
├── .env               # 环境变量配置
├── .env.example       # 环境变量模板
├── run.sh             # 启动脚本
└── db.sqlite3         # SQLite数据库文件
```

## 功能模块

### 1. 用户模块 (apps/users)
- 用户注册/登录
- JWT认证
- 个人信息管理
- 家庭管理（创建/加入）
- 家庭成员管理

### 2. 物品管理模块 (apps/items)
- 物品CRUD操作
- 分类管理
- 位置管理
- 物品搜索
- 批量操作

### 3. 库存管理模块 (apps/inventory)
- 库存预警（低库存、过期、即将过期）
- 库存报表
- 采购建议
- 库存日志

### 4. 数据同步模块 (apps/sync)
- 全量/增量同步
- 冲突检测与解决
- 同步记录管理

## 快速开始

### 环境要求

- Python 3.9+

### 本地开发

1. 进入项目目录
```bash
cd ServerHomeWare/server
```

2. 创建虚拟环境
```bash
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate  # Windows
```

3. 安装依赖
```bash
pip install -r requirements.txt
```

4. 配置环境变量
```bash
cp .env.example .env
# 编辑 .env 文件（默认配置已适用于本地开发）
```

5. 数据库迁移
```bash
python manage.py makemigrations
python manage.py migrate
```

6. 创建超级用户
```bash
# 创建默认超级用户
python manage.py createsuperuser --username admin --email admin@example.com --noinput
# 创建测试用户（用户名：123，密码：123456）
python manage.py createsuperuser --username 123 --email 123@example.com --noinput
python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); user = User.objects.get(username='123'); user.set_password('123456'); user.save()"
```

7. 启动开发服务器

**方法一：使用启动脚本（推荐）**
```bash
chmod +x run.sh
./run.sh
```

**方法二：直接运行**
```bash
python manage.py runserver 0.0.0.0:8000
```

## 访问地址

启动服务后，您可以通过以下地址访问：

- **API 根路径**：http://localhost:8000/api/ (自动重定向到API文档)
- **API文档 (ReDoc)**：http://localhost:8000/api/redoc/
- **API文档 (Swagger)**：http://localhost:8000/api/docs/
- **管理后台**：http://localhost:8000/admin/ (使用创建的用户登录)

## 主要API端点

### 认证相关
- `POST /api/auth/register/` - 用户注册
- `POST /api/auth/login/` - 用户登录
- `GET /api/auth/profile/` - 获取用户信息
- `PUT /api/auth/profile/update/` - 更新用户信息

### 家庭管理
- `GET /api/auth/families/` - 获取家庭列表
- `POST /api/auth/families/` - 创建家庭
- `GET /api/auth/families/{id}/` - 获取家庭详情
- `POST /api/auth/families/{id}/join/` - 加入家庭

### 物品管理
- `GET /api/items/` - 获取物品列表
- `POST /api/items/` - 添加物品
- `GET /api/items/{id}/` - 获取物品详情
- `PUT /api/items/{id}/` - 更新物品
- `DELETE /api/items/{id}/` - 删除物品
- `GET /api/items/categories/` - 获取分类列表
- `POST /api/items/categories/` - 创建分类
- `GET /api/items/locations/` - 获取位置列表
- `POST /api/items/locations/` - 创建位置

### 库存管理
- `GET /api/inventory/alert/` - 获取库存预警
- `POST /api/inventory/alert/resolve/` - 解决预警
- `GET /api/inventory/report/` - 获取库存报表
- `GET /api/inventory/suggestions/` - 获取采购建议
- `GET /api/inventory/logs/` - 获取库存日志
- `POST /api/inventory/logs/log-action/` - 记录库存操作

### 数据同步
- `POST /api/sync/initiate/` - 发起数据同步
- `POST /api/sync/upload/` - 上传客户端数据
- `GET /api/sync/records/` - 获取同步记录
- `GET /api/sync/conflicts/` - 获取同步冲突
- `POST /api/sync/conflicts/resolve/` - 解决同步冲突

## 定时任务

系统使用Celery Beat执行以下定时任务：

- **每日00:00** - 检查库存预警
- **每日02:00** - 清理30天前的已解决预警
- **每日08:00** - 生成每日库存摘要

## 数据库设计

### 主要数据表
- `users` - 用户表
- `families` - 家庭表
- `family_members` - 家庭成员表
- `items` - 物品表
- `categories` - 分类表
- `locations` - 位置表
- `inventory_alerts` - 库存预警表
- `inventory_logs` - 库存日志表
- `sync_records` - 同步记录表
- `sync_conflicts` - 同步冲突表

## 安全性

- JWT认证
- 密码加密存储
- CORS配置
- SQL注入防护
- XSS防护
- API请求限流

## 性能优化

- 数据库索引优化
- 分页查询
- 异步任务处理
- 静态文件压缩

## 部署说明

### 生产环境配置

1. 修改 `settings.py` 中的以下配置：
   - `DEBUG = False`
   - `SECRET_KEY` - 使用强随机密钥
   - `ALLOWED_HOSTS` - 添加域名

2. 使用HTTPS
3. 配置防火墙
4. 定期备份数据库

### 监控和日志

- 应用日志存储在 `logs/django.log`

## 开发规范

### 代码风格
- 遵循PEP 8规范
- 使用类型提示
- 编写单元测试
- 添加文档字符串

### Git提交规范
```
feat: 新功能
fix: 修复bug
docs: 文档更新
style: 代码格式调整
refactor: 重构
test: 测试相关
chore: 构建/工具相关
```

## 联系方式

- 项目负责人: [您的姓名]
- 技术支持: [您的邮箱]

## 许可证

MIT License