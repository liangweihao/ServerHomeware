# AI 助手接口响应格式修复

## 技术开发文档

### 问题

`POST /api/v1/assistant/chat` 在 DeepSeek 调用成功后返回 500，日志：

```
ValidationError: ResponseSchema - code/message Field required
```

根因：`assistant.py` 构造 `ResponseSchema` 时只传了 `data`，缺少必填字段 `code` 和 `message`。

### 改动点

| 文件 | 改动 |
|---|---|
| `app/api/v1/assistant.py` | `ResponseSchema` 补充 `code=200, message="success"` |

### 影响范围

- 仅修复 AI 助手对话接口的响应序列化，不影响 LLM 业务逻辑

---

## 提测开发文档

### 验证结果（2026-07-10）

| 检查项 | 结果 |
|---|---|
| `DEEPSEEK_API_KEY` 加载 | ✅ 已配置 |
| DeepSeek API 连通 | ✅ HTTP 200 |
| Function Calling | ✅ `check_ingredients_availability`、`query_item_stock` 正常 |
| 接口响应 | ✅ `code: 200, message: success` |

### 测试命令

```powershell
# 登录获取 token 后调用
POST http://localhost:8000/api/v1/assistant/chat
Body: { "message": "想吃红烧肉，帮我看看家里调料够不够" }
```

### Flutter 端验证

1. 打开助手页
2. 输入「想吃红烧肉」或「手划破了」
3. 日志应出现「升级到 LLM」
4. 界面显示管管回复（有/缺清单）

### 注意事项

- 需安装 `httpx==0.27.0` 并重启后端
- 旧进程未包含 `/assistant/chat` 路由时需重启
