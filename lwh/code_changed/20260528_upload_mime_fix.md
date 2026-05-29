# 修复图片上传 MIME 类型校验失败

## 问题

Android 通过 `MultipartFile.fromPath` 上传时 Content-Type 常为 `application/octet-stream`，服务端仅接受 `image/jpeg` 等，返回 400「不支持的文件类型」。

## 改动

| 文件 | 变更 |
|------|------|
| `upload_service.dart` | 按扩展名显式设置 `contentType` + `filename` |
| `upload_service.py` | 扩展名合法时允许 `application/octet-stream` |

## 提测

添加物品选图保存，日志应出现上传成功及 `image_urls` 创建成功。
