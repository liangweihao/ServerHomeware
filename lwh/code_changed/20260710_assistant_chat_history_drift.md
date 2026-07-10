# 问管管本地对话历史（Drift 方案 A）

## 技术开发文档

### 实现方案

采用 **本地 Drift 持久化**，退出页面 / 重启 App 后仍可恢复聊天记录与 LLM 多轮上下文。

### 改动点

| 文件 | 改动 |
|---|---|
| `lib/data/database/app_database.dart` | 新增 `AssistantMessages` 表；schema v7；DAO 增删查裁剪 |
| `lib/core/assistant/assistant_chat_storage.dart` | **新增** 序列化/反序列化、加载、保存、清空 |
| `lib/core/assistant/assistant_executor.dart` | 支持 `initialHistory` 恢复；`clearHistory()` |
| `lib/presentation/assistant/assistant_chat_page.dart` | 进入时加载历史；发送后写入；AppBar 清空对话 |

### 表结构

```
assistant_messages
  id, is_user, text, meta_json, created_at
```

- `meta_json`：可选，存 items 卡片 / action 按钮信息
- 最多保留 **100** 条（自动裁剪）
- 进入页面加载最近 **50** 条

### 数据流

```
进入问管管 → load Drift → 渲染气泡 + 恢复 Executor._history
用户发送   → save 用户消息 → LLM → save 助手回复
清空对话   → clear Drift + 重置为欢迎语
```

---

## 提测开发文档

### 测试点

| 场景 | 预期 |
|---|---|
| 首次进入 | 仅欢迎语 |
| 对话后返回再进 | 历史气泡完整展示 |
| 连续追问 | LLM 携带已恢复上下文 |
| 重启 App 再进 | 历史仍在 |
| 清空对话 | 确认后只剩欢迎语；再进无旧记录 |
| 超过 100 条 | 最早记录被自动删除 |

### 验证方式

1. 问管管发送 2～3 轮对话
2. 返回首页，再次进入问管管 → 历史应在
3. 完全关闭 App 重开 → 历史仍在
4. 点右上角垃圾桶清空 → 历史消失

### 注意事项

- 欢迎语不写入数据库（仅内存展示）
- 换设备不同步（方案 B 服务端同步后续再做）
