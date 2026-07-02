# J+K：回归修复 + 通知中心/Auth 工具风

## 技术开发文档

### J — flutter analyze 编译错误修复

| 问题 | 修复 |
|------|------|
| `ProfilePanelPage` 未导入 | `app_router.dart` 补回 `profile_panel_page.dart` |
| `family_contribution_page.dart` 错误 import 路径 | 修正为 `providers/`、`../common/` |
| `scan_page.dart` const + 非 const 色值 | 去掉 `const Center` / `const Text` 中的 `AppColors.primary*` |

### K — 通知中心 + Auth 工具风

**通知中心**
- 工具风：白卡列表行 + Material Icon + chevron，去掉 `CartoonListEntrance`
- 卡通风：保留 `CartoonListEntrance` + `CartoonListTile`

**Auth**
- `auth_cartoon_wrap.dart`：`wrapAuthFormSurface` 工具风白卡；新增 `authPageTitle`
- 登录/注册/验证码/忘记密码/创建家庭/加入家庭/欢迎页：标题改用 `authPageTitle`

---

## 提测开发文档

### 新增验证点

1. **编译**：`flutter analyze` 无 error
2. **通知中心**：列表白卡、点击跳转详情（过期带 consume）
3. **Auth 流程**：登录/注册表单白卡、标题无 emoji 前缀（工具风）
4. **家庭贡献页**：Profile → 查看全部，页面正常加载

### 回归

继续执行 `20260701_ghi_family_contribution_alerts_test.md` 全量清单。

### analyze 说明

修复后仍可能有 info/warning（deprecated withOpacity、unused import 等），不阻塞提测；后续可分批清理。
