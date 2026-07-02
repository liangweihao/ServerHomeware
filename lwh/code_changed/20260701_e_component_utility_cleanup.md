# E 阶段：内页组件工具风收尾

## 技术开发文档

### 背景

A+B+C+D 完成后，页面外壳（WarmScaffold）已统一为工具风，但 AlertCard、LocationCard、SpaceCard、ShoppingItemCard、AppEmptyState、扫码页内部仍残留卡通贴纸组件，造成「外壳新、内容旧」的视觉割裂。

### 实现方案

按 `AppColors.isUtilityStyle` 双分支：默认工具风走白底轻阴影 + `TagChip`；切回卡通主题时保留原有 `CartoonStickerBadge` / `AppSurface` 逻辑。

### 改动点

| 文件 | 改动 |
|------|------|
| `alert_card.dart` | 移除 Cartoon 依赖；`TagChip` 标签；工具风用 `iconData` Material Icon；操作按钮改 Wrap 防溢出 |
| `location_card.dart` | 工具风白卡 + 灰底 emoji 圆 + `TagChip` 数量 |
| `space_card.dart` | 与 HomeItemCard 一致的紧凑白卡 |
| `shopping_item_card.dart` | 修复乱码「自动推荐」「约¥」；工具风列表行 + TagChip |
| `app_empty_state.dart` | 工具风用灰底圆形容器 + emoji，保留 CartoonCopy 文案 |
| `scan_page.dart` | 去掉 CartoonUi 标题；四角 L 形橙框；中间透明挖洞遮罩；手动输入对话框工具风 |

### 影响范围

- 提醒中心卡片列表
- 位置总览 / 详情、首页按空间横滑
- 购物清单条目
- 所有使用 `AppEmptyState` 的空态页（位置、家庭、统计等）
- 扫码 → 添加入库链路

---

## 提测开发文档

### 测试点

1. **提醒中心**：卡片左侧色条、TagChip 类型标签、Material Icon 图标；点击跳转详情；操作按钮（今天用掉/加入清单等）正常
2. **位置页**：LocationCard 白底、选中态主色边框、数量 TagChip
3. **首页按空间**：SpaceCard 宽度与横滑布局正常
4. **购物清单**：自动推荐 TagChip、数量/价格文案、勾选划线、删除
5. **空态页**：家庭/位置/统计等页显示灰圆 emoji + 文案（非 SVG 卡通插画）
6. **扫码页**：四角橙框、中间透明、识别后跳转添加入库；手动输入条码；手电筒开关

### 验证方式

热重启 App，逐项进入上述页面目视确认；扫码需真机或带相机模拟器。

### 注意事项

- 切换至 cartoon 主题时，LocationCard / SpaceCard / ShoppingItemCard 仍走卡通分支
- `flutter` 未在 PATH 中，本地需手动执行 `flutter analyze` 做静态检查
