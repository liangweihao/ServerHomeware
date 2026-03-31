- 基本信息
- 描述：提供物品的详细信息，包括名称、描述、数量、分类、位置、价格、过期日期和创建时间。当用户需要查看或编辑物品详情时调用。
- 功能特性

- 物品详情显示：展示物品的完整信息， 
-  排列顺序：名称、描述、数量、单位、分类、位置、价格、购买日期、过期日期、创建时间  
- 编辑功能：允许用户导航到编辑屏幕修改物品详情
- 删除功能：提供删除确认对话框，处理删除成功和失败的场景
- 加载状态：在获取物品详情时显示加载指示器
- 使用流程

- 查看物品详情：导航到物品详情屏幕，加载并显示所有可用信息
- 编辑物品：点击应用栏中的编辑图标，导航到编辑屏幕
- 删除物品：点击应用栏中的删除图标，在对话框中确认删除
- 技术细节

- 文件： lib/screens/item_detail_screen.dart
- 状态管理：使用 Provider
- 数据加载：从 ItemProvider 获取物品详情
- UI 组件：使用 Scaffold、AppBar、Card、ListView 和 AlertDialog

- 依赖项

- flutter/material.dart
- provider/provider.dart
- app/providers/item_provider.dart
- app/models/item.dart
- 