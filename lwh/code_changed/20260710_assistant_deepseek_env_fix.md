# 问管管 DeepSeek 调用失败排查与修复

## 日志结论

用户日志显示：
- 首次启动：`无效的刷新令牌` → 切换 start-prod 后 JWT 密钥变化，**需重新登录**（用户已重新登录成功）
- 问管管返回：`抱歉，AI 助手暂时无法响应，请稍后再试。`（**服务端** DeepSeek 调用 `_call_api` 返回 None，非客户端网络错误）

## 根因

1. `start-dev.sh` 使用 `ENV_FILE=.env.dev`，而 `.env.dev` **未配置** `DEEPSEEK_API_KEY`
2. 用户实际数据在 `../data/homestock.db`（`.env`），说明可能混用启动方式；旧进程未重启时仍用空 Key
3. Windows 下 httpx 可能受系统代理影响（`trust_env=True`）

## 改动

1. `llm_service._call_api`：`httpx.AsyncClient(trust_env=False)` 直连 DeepSeek
2. `start-dev.sh`：加载 `.env.dev` 后，DeepSeek 未配时从 `.env` 继承
3. `.env.dev`：补充 DeepSeek 配置项占位

## 用户操作

```bash
cd HomeWareServer
./start-dev.sh restart   # 本地开发推荐
# 或
./start-prod.sh restart  # 生产模拟

# 启动日志应看到：DeepSeek: sk-f5151... 已加载
```

App **重新登录** 后再试问管管。

## 验证

问「厨房有什么」，日志应出现 `[LlmService] INFO: 对话完成`，而非 `DeepSeek API HTTP 错误`。
