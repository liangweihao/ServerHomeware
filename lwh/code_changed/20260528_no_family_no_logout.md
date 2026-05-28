# 未加入家庭不应触发退出登录

## 问题

删除唯一家庭后，`GET /api/v1/families/current` 返回 `401` + `用户未加入任何家庭`。客户端将所有 `401/403` 当作 token 失效，调用 `ApiService.handleAuthError` → 全局 `logout()`，用户被误踢出登录。同时 `AuthGuard` 在 `MaterialApp` 外层，`ScaffoldMessenger.of(context)` 找不到祖先而崩溃。

## 实现方案

1. **`auth_exception.dart`**：新增 `sessionLogoutBypassMessages` 与 `shouldTriggerSessionLogout(code, message)`，当前豁免：`用户未加入任何家庭`。
2. **`api_service.dart`**：`handleAuthError` 仅在 `shouldTriggerSessionLogout` 为 true 时触发回调。
3. **`family_service.dart`**：401/403 分支区分业务态与登录态，并打对应日志。
4. **`auth_provider.dart`**：创建/加入家庭失败时，用 `shouldTriggerSessionLogout` 替代裸 `isAuthError`。
5. **`main.dart`**：将 `AuthGuard` 放入 `MaterialApp.router` 的 `builder`，保证其 `context` 在 `MaterialApp` 子树内。
6. **`auth_guard.dart`**：SnackBar 使用 `ScaffoldMessenger.maybeOf`。

## 影响范围

- 已登录但无 `current_family_id` 的用户：个人页可正常展示空家庭态，不再被登出。
- 真实 token 失效（无效访问令牌、令牌已失效等）仍会触发退出登录。

## 提测要点

1. 登录后删除唯一家庭 → 个人页应仍保持登录，家庭信息为空，可创建/加入家庭。
2. 清除 token 或用过期 token 请求 → 仍应提示并跳转登录。
3. 无家庭时调用 `GET /families/current` → 日志应出现 `SKIP SESSION LOGOUT` 或 `业务态 401/403`，不应出现 `AuthNotifier 退出登录`（除非用户主动退出）。

---

## 补充：创建家庭解析失败（2026-05-28）

### 问题

`POST /families` 返回 `FamilyResponse`（含 `id`、`name` 等），客户端误按 `data['user']` 解析，导致 `type 'Null' is not a subtype of type 'Map<String, dynamic>'`。

### 修复

`auth_provider.dart` 中 `createFamily` / `joinFamily` 改为 `_saveFamilyFromApiData(data, role: owner|member)`，写入 `family_id` 与 `family_role`。

### 提测

创建家庭成功后应跳转首页，且本地 `family_id` 与新建家庭 id 一致。
