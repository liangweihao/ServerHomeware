# 登录会话续期修复（隔夜免登）

> 日期：2026-06-23

---

## 技术开发文档

### 问题根因

1. `.env.example` 中 `ACCESS_TOKEN_EXPIRE_MINUTES=60`，部署若沿用则 **Access Token 仅 1 小时**
2. 客户端 `ApiService` 在 **401 时不刷新 GET 请求**，启动页 `validateToken` 用 GET `/users/me`，隔夜 access 过期后直接登出
3. `validateToken` 走原生 `http.get`，未走带 refresh 的 `ApiService`
4. Refresh Token 仅 30 天，对家庭工具 App 偏短

### 实现方案

| 层级 | 改动 |
|------|------|
| 服务端 `config.py` | Access **7 天**（10080 分钟），Refresh **90 天** |
| 服务端 `.env.example` | 与默认对齐，避免新环境误配 60 分钟 |
| 客户端 `api_service.dart` | **所有 HTTP 方法**（含 GET）401 → `tryRefreshToken` → 重试；并发 refresh 共享 `Completer` |
| 客户端 `auth_service.dart` | `validateToken` 改用 `ApiService.get('/users/me')` |
| 客户端 `splash_page.dart` | 启动时先尝试 refresh，再校验 token |

### 改动文件

- `HomeWareServer/app/config.py`
- `HomeWareServer/.env.example`
- `HomeWareClient/lib/core/services/api_service.dart`
- `HomeWareClient/lib/core/services/auth_service.dart`
- `HomeWareClient/lib/presentation/auth/splash_page.dart`

### 生效后的会话策略

| Token | 时长 | 说明 |
|-------|------|------|
| Access Token | 7 天 | 日常 API 鉴权 |
| Refresh Token | 90 天 | 过期前 App 启动/请求时自动换新对 |

---

## 提测开发文档

### 测试点

| ID | 步骤 | 预期 |
|----|------|------|
| T1 | 登录后杀进程，次日冷启动 | 直接进入首页，无需重新登录 |
| T2 | 模拟 access 过期（改短 JWT 或等 1h+）但 refresh 有效 | 启动或任意 GET 请求后自动续期 |
| T3 | refresh 也过期（>90 天未用） | 跳转登录页 |
| T4 | 新注册用户登录 | SharedPreferences 同时有 `auth_token` 与 `auth_refresh_token` |

### 验证方式

1. **重启服务端**（若本地有 `.env`，请确认 `ACCESS_TOKEN_EXPIRE_MINUTES=10080`、`REFRESH_TOKEN_EXPIRE_DAYS=90`）
2. **重新登录一次**（旧会话若无 refresh_token 需补登）
3. 冷启动 App，观察日志 `[ApiService] INFO: Token 自动刷新成功`

### 注意事项

- 已有 `.env` / `.env.dev` 若仍为 60 分钟，需手动改配置并重启服务
- 服务端 refresh 每次成功会签发**新 refresh_token**（滚动续期）
