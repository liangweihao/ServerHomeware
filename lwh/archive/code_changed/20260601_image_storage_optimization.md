# 图片上传存储优化 — 三级压缩 + 删除清理

## 背景

用户担心 50G 服务器存储不够用，又预算有限无法购买 OSS。分析发现：
- 当前服务端 Pillow 未安装，图片以原始 JPG 保存（3-5MB/张），50G 仅能存 ~1.5 万张
- 删除物品时磁盘图片文件未清理，造成孤儿文件堆积
- 客户端未做预压缩，上传流量浪费

## 实现方案

### 方案概述

**三级压缩链**：客户端选图 → flutter_image_compress 预压缩(720px/80%) → 上传 → 服务端 Pillow 二次处理(720px/WebP/75%)

优化后单张图片约 60-100KB，50G 可存 **50 万张以上**，完全满足家庭场景。

### 改动点

#### 1. 服务端：安装 Pillow + 降低压缩参数

**文件**：
- `HomeWareServer/requirements.txt` — 新增 `Pillow>=10.0.0`
- `HomeWareServer/app/config.py` — 调整压缩参数

| 参数 | 旧值 | 新值 | 说明 |
|------|------|------|------|
| MAX_IMAGE_WIDTH | 1080 | 720 | 手机屏幕 720px 足够，容量降 55% |
| IMAGE_QUALITY | 85 | 75 | WebP 格式下肉眼无区别 |

**效果**：安装 Pillow 后，上传的图片会自动转为 WebP 格式（之前降级存原始 JPG）。

#### 2. 服务端：删除物品时清理磁盘图片文件（修 Bug）

**文件**：`HomeWareServer/app/services/item_service.py`

**Bug**：`delete_item()` 物理删除物品时，数据库级联删除了 `item_images` 记录，但 `UploadService.delete_image()` 从未被调用，磁盘文件变成孤儿。

**修复**：
1. 改用 `get_by_id_with_relations()` 提前加载物品的关联图片
2. 收集所有 `image_urls` 后再执行 `hard_delete()`
3. 遍历 URL 调用 `UploadService.delete_image()` 删除磁盘文件
4. 单张删除失败不影响其他文件清理（catch + warn）

#### 3. Flutter 客户端：上传前压缩图片

**文件**：
- `HomeWareClient/pubspec.yaml` — 新增 `flutter_image_compress: ^2.4.0`
- `HomeWareClient/lib/core/utils/item_image_storage.dart` — 修改压缩逻辑

**改动**：
- 新增 `compressionMaxWidth=720`、`compressionQuality=80` 常量
- `persistPickedImage()` 中调用 `FlutterImageCompress.compressWithFile()` 先压缩再保存
- 使用 `CompressFormat.jpeg` 统一格式，兼容性最好
- 压缩失败时降级：直接复制原文件

**压缩效果**：客户端压缩一次（720px/80% JPEG），服务端再转 WebP，双重压缩确保最小体积。

### 影响范围

- **服务端**：新上传的图片将转为 WebP 格式；已有旧图片不受影响（需手动迁移或保持原样）
- **删除物品**：现在会同步删除磁盘图片，首次运行时会清理之前遗留的孤儿文件（非本次改动范围，需单独清理脚本）
- **客户端**：需要重新 `flutter pub get` 安装新依赖；选图后保存的是压缩后的 JPEG
- **已上传的旧图片**：之前保存的原始 JPG 文件不会自动转换，建议后续写个迁移脚本批量处理

## 测试点

### 服务端
1. 安装 Pillow 后重启服务，上传一张 JPG 图片，确认保存为 `.webp` 格式
2. 上传大尺寸图片（>1080px），确认被缩放到 720px
3. 上传 WebP 图片，确认正常处理
4. 删除一个带图片的物品，检查 `uploads/{family_id}/` 目录下对应文件是否被删除
5. 删除无图片的物品，确认不报错
6. 批量上传 5 张图片后删除物品，确认 5 张全部清理

### 客户端
1. `flutter pub get` 无报错
2. 从相册选图，确认本地保存的是压缩后的 JPEG（<200KB）
3. 拍照后确认正常压缩保存
4. 编辑物品添加新图片，确认上传正常
5. 添加物品后查看服务端 uploads 目录，确认上传的是压缩版
6. Windows/Mac/Linux 桌面端压缩功能正常（flutter_image_compress 全平台支持）

## 注意事项

- `flutter_image_compress` 在 iOS 上需要添加 Photo Library 权限（已有 image_picker 的权限配置）
- 服务端 `IMAGE_QUALITY=75` 对 WebP 格式质量影响很小，如需更高画质可调回 80-85
- 目前只优化了新增上传，已有旧图片文件建议后续写脚本批量转换（可选）
- 建议后续增加存储用量统计功能，方便监控
