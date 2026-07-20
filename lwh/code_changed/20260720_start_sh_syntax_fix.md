# start.sh prod 启动失败修复

## 问题

执行 `./start.sh prod` 立即失败：

```text
start.sh: line 161: syntax error near unexpected token `else'
```

## 根因

`HomeWareServer/start.sh` 加载 `.env` 的分支误写了两个连续 `else`，bash 语法解析失败，脚本无法执行。

附带风险（历史日志）：若 Git Bash 曾把以 `/` 开头的环境变量（如 `API_PREFIX=/api/v1`）转义为 `C:/Program Files/Git/api/v1`，uvicorn 会报：

```text
AssertionError: A path prefix must start with '/'
```

## 改动

文件：`HomeWareServer/start.sh`

1. 删除重复 `else`，恢复正常 `if / else / fi`
2. 去掉多余的二次 `export ENV_FILE`
3. 在确认存在 `.env` 后 `unset` 可能被污染的路径类变量（`API_PREFIX`、`DATABASE_URL` 等），强制由 pydantic 从 `.env` 文件读取

## 验证

```bash
cd HomeWareServer
bash -n start.sh          # 语法通过
./start.sh prod
curl http://127.0.0.1:8000/api/v1/health
```

预期：脚本正常跑完并打印 PID；健康检查返回成功。

## 影响范围

- 仅本地/服务器通过 `start.sh` 的启动路径
- 不改动业务 API 与数据库逻辑
