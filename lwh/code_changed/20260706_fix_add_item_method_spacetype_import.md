# 修复 add_item_method_page SpaceType 编译错误

## 技术开发文档

### 问题
`lib/presentation/items/add_item_method_page.dart` 使用 `SpaceType.shop` 判断店铺/家庭文案与 CSV 入口，但未导入 `SpaceType` 枚举，导致 Dart 编译失败。

### 改动点
1. 新增 `import '../../core/models/space_type.dart';`
2. 修正 `space_skin_provider` 相对路径：`../../../core/...` → `../../core/...`

### 影响范围
- 仅 `add_item_method_page.dart`，无业务逻辑变更

### 附注（Kotlin 构建日志）
Android 构建日志中 `file_picker` 的 Kotlin 增量缓存警告（C: Pub Cache 与 D: 工程盘符不同）在 `flutter clean` 后仍可出现，但不阻塞构建；属已知环境现象，非本次代码问题。

## 提测开发文档

### 测试点
1. 家庭空间：录入方式页副标题为「选最快的方式把物品记进家庭库存」，无 CSV 批量入口
2. 店铺空间：副标题为「选最快的方式把商品记进店里」，显示 CSV 批量进货卡片
3. 各录入方式（说话/扫码/手动/草稿）跳转正常

### 验证方式
```powershell
cd HomeWareClient
flutter analyze lib/presentation/items/add_item_method_page.dart
flutter build apk --debug
```

### 注意事项
- 若本地仍遇 Kotlin daemon 缓存错误，执行 `flutter clean` 后重试
