# HomeStock Server — Phase 7：部署 & 上线准备

## 前置条件
Phase 1-6 功能开发完成。

## 本阶段目标
生产环境配置、Docker部署优化、日志监控、API文档完善。

---

## 任务1：生产环境配置

### 环境变量区分
- .env.development（本地开发）
- .env.production（生产环境）

### 生产配置要点
```
DEBUG=false
LOG_LEVEL=INFO
DATABASE_URL=（生产数据库地址）
REDIS_URL=（生产Redis地址）
JWT_SECRET_KEY=（生产环境强密钥，至少32位随机字符）
CORS_ORIGINS=["https://你的域名"]（限制来源）
```

### Dockerfile 优化
- 多阶段构建（减小镜像体积）
- 非root用户运行
- 健康检查指令

### docker-compose.production.yml
- 去掉开发模式热重载
- 添加 restart: always
- 配置日志大小限制
- uvicorn workers 数量 = CPU核心数 × 2 + 1
- 添加 Nginx 作为反向代理

---

## 任务2：Nginx 配置

```nginx
server {
    listen 80;
    server_name your-domain.com;

    # API 代理
    location /api/ {
        proxy_pass http://app:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    # WebSocket 代理
    location /api/v1/ws/ {
        proxy_pass http://app:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # 静态文件（上传的图片）
    location /uploads/ {
        alias /data/uploads/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }

    # 文件大小限制
    client_max_body_size 10M;
}
```

---

## 任务3：日志系统

### 日志配置

- 使用 Python logging 模块
- 格式：JSON格式（方便后续接入日志系统）
- 级别：开发INFO，生产WARNING
- 输出：同时输出到 stdout 和文件
- 文件轮转：每天一个文件，保留30天

### 关键日志点

- 每个API请求：method, path, status, duration, user_id
- 认证失败：IP, 尝试的手机号
- 数据库异常
- Celery任务执行结果
- 推送通知结果

---

## 任务4：数据库备份

创建备份脚本 scripts/backup.sh：

- 使用 pg_dump 导出数据库
- 压缩为 .gz 文件
- 文件名含日期：homestock_20240125.sql.gz
- 保留最近30天的备份
- 可通过 crontab 每日执行

---

## 任务5：API 文档完善

确保 Swagger UI (/docs) 中：

- 每个接口有清晰的中文描述（summary + description）
- 请求/响应示例（example）
- 参数说明完整
- 错误码说明
- 接口分组（tags）清晰：
  - 认证（Auth）
  - 用户（Users）
  - 家庭（Families）
  - 物品（Items）
  - 分类（Categories）
  - 位置（Locations）
  - 使用记录（Usage Records）
  - 购物清单（Shopping）
  - 提醒通知（Notifications）
  - 统计（Statistics）
  - 文件（Upload）

---

## 任务6：自动化测试（核心链路）

至少覆盖以下核心场景的测试：

- 注册 → 登录 → 获取Token
- 创建物品 → 查询 → 记录使用 → 数量更新
- 过期检查逻辑
- 消耗预测计算
- 权限控制（member不能删除）
- 数据隔离（不同家庭看不到对方数据）

使用 pytest + httpx (async)，conftest 中配置测试数据库。

---

## 验收标准

1. ✅ docker-compose -f docker-compose.production.yml up 一键启动
2. ✅ Nginx 正确代理API和WebSocket
3. ✅ 图片通过Nginx直接返回（不经过Python）
4. ✅ 日志正确输出到文件和stdout
5. ✅ 数据库备份脚本可正确执行
6. ✅ Swagger文档清晰完整
7. ✅ 核心测试用例全部通过
8. ✅ 限流在生产配置下生效
9. ✅ 非CORS白名单的请求被拒绝
10. ✅ 服务重启后自动恢复（restart: always）

---

## 各 Phase 关系总览

```
Phase 1：骨架 → 能跑、能登录
Phase 2：核心API → Flutter能增删改查物品
Phase 3：家庭协作 → 多人共享数据
Phase 4：提醒推送 → 到期推送、定时任务
Phase 5：智能功能 → 预测、统计、推荐
Phase 6：高级功能 → 文件、实时通信、导出
Phase 7：部署上线 → 生产可用

依赖关系：
1 → 2 → 3 → 4 → 5 → 6 → 7（严格顺序）
```

---

## 给 Trae 的使用建议

| 阶段 | 喂给 Trae 时 | 补充说明 |
|------|-------------|---------|
| Phase 1 | 整段给 | 可能需要帮它解决 alembic async 配置问题 |
| Phase 2 | 分两次：模型建表 + API实现 | 表多，一次可能太长 |
| Phase 3 | 整段给 | 逻辑不复杂但细节多 |
| Phase 4 | 分两次：Celery配置 + 推送服务 | Celery配置容易出问题 |
| Phase 5 | 分两次：购物清单API + 统计API | |
| Phase 6 | 分三次：文件上传 + WebSocket + 其余 | WebSocket最容易出bug |
| Phase 7 | 整段给 | 主要是配置文件 |

需要我为 Flutter 端补充一份**「对接服务端 API」的改造提示词**吗？（把之前纯本地存储改为调用API）