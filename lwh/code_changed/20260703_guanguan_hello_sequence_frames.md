# 管管打招呼「你好」序列帧

**日期**：2026-07-03  
**状态**：4 关键帧已生成并入库  
**关联**：[`20260703_ai_mascot_character_design.md`](./20260703_ai_mascot_character_design.md) §十一

---

## 一、资源清单

| 帧 | 路径 | 动作 |
|----|------|------|
| 1 | `assets/illustrations/guanguan/hello/guanguan_hello_01_idle.png` | 起始待机 |
| 2 | `guanguan_hello_02_raise_hand.png` | 抬头抬手 |
| 3 | `guanguan_hello_03_wave_hello.png` | 挥手峰值 + 说你好 |
| 4 | `guanguan_hello_04_settle.png` | 挥手收尾 |

---

## 二、关键帧说明

### 帧 1 — 起始待机

- 身体微微下沉
- 天线缓慢左右轻晃
- 胸口爱心微弱呼吸光

### 帧 2 — 抬头抬手

- 身体轻轻向上弹起
- 右手抬起挥向镜头
- 瞳孔放大，嘴角上扬
- 天线同步向外张开

### 帧 3 — 挥手峰值

- 手掌挥动姿态（代码中播放 2 次）
- 脸颊蓝色水滴亮起（`accentSky`）
- 爱心发光强度翻倍
- 嘴巴张开露小舌（口型「你好」）

### 帧 4 — 挥手收尾

- 手缓慢落下
- 身体轻微回弹缓冲
- 天线慢慢收回
- 笑容保持

---

## 三、代码接入

```dart
GuanguanHelloAnimation(
  size: 120,
  onComplete: () => setState(() => _showIdle = true),
)
```

- 常量：`AssistantMascot.helloFrames`
- 播放顺序：`0→1→2→2→3`（帧 3 重复）
- `MediaQuery.disableAnimationsOf` 时直接显示最后一帧

---

## 四、提测

1. 四帧角色造型一致、无跳变穿帮  
2. 首次进入问管家播放一次  
3. 减少动态效果时静止在收尾帧  
4. 小屏 80～120px 仍可辨认表情  

---

## 五、后续

- 补中间帧（in-between）使挥手更顺滑  
- 或设计师出 Rive 版 `wave_hello` 状态机替换序列帧  
