# UI 风格方案预览（供选型）

**日期**：2026-07-02  
**预览图目录**：项目根 `assets/ui_style_*.png`  
**参考页面**：个人中心 Tab「我的」（与当前 Bento 布局一致）

---

## 方案对照

| 代号 | 名称 | 主色 | 页面底 | 气质 | 与现状关系 |
|------|------|------|--------|------|------------|
| **A** | 清爽工具风 utilityClean | `#FF6633` 橙 + `#FFDA44` 黄 FAB | `#FAFAF8` 暖灰 | 点评/闲鱼工具感 | **当前默认**（已做清爽化） |
| **B** | 居家暖白 Soft Home | `#C8956A` 暖棕 | `#FAF7F2` 米白 | 温馨居家、低饱和 | 接近现有 `communityWarm` 但更干净 |
| **C** | 森系舒缓 Calm Sage | `#6B9080` 鼠尾草绿 | `#F4F7F5` 淡绿灰 | 自然、放松、家庭感 | **新方向**，主色换绿仍保持工具结构 |
| **D** | 极简灰蓝 Nordic Minimal | `#5B7C99` 灰蓝 | `#F5F7FA` 冷灰 | 冷净、专业、Reminders 风 | **新方向**，最「干净」偏冷 |

---

## 预览文件

| 文件 | 说明 |
|------|------|
| `assets/ui_style_comparison_4options.png` | 四方案 2×2 对比总览 |
| `assets/ui_style_A_utility_clean.png` | A 单屏细节 |
| `assets/ui_style_B_soft_home.png` | B 单屏细节 |
| `assets/ui_style_C_calm_sage.png` | C 单屏细节 |
| `assets/ui_style_D_nordic_minimal.png` | D 单屏细节 |

---

## 选型建议（结合此前反馈）

- 要 **暖 + 干净、少重色**：优先看 **B** 或优化后的 **A**
- 要 **更有家庭/生活感**：**C**
- 要 **最极简、偏专业**：**D**（但可能偏冷，与「暖色」预期略冲突）

---

## 下一步（选定后）

1. 在 `AppColorPalettes` 新增对应色板（或调整 defaultVariant）
2. 全站 Token 走色板，组件逻辑不变
3. 真机走查：首页 / 物品列表 / 录入 / 提醒 / 个人中心

请回复选型代号（如 **B** 或 **A+B 混合**）。
