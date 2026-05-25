# 家庭物品管理系统 — Figma 组件描述文档

***

## 一、设计基础（Design Tokens）

### 1.1 颜色系统（Color Styles）

```
📁 Colors/
├── 📁 Primary/
│   ├── Primary-50      #E3F2FD    (最浅/背景)
│   ├── Primary-100     #BBDEFB    (浅色/hover)
│   ├── Primary-300     #64B5F6    (次要)
│   ├── Primary-500     #2196F3    (主色/按钮)
│   ├── Primary-700     #1976D2    (深色/pressed)
│   └── Primary-900     #0D47A1    (最深)
│
├── 📁 Status/
│   ├── Success-light   #E8F5E9
│   ├── Success         #4CAF50    (正常/充足/安全)
│   ├── Warning-light   #FFF3E0
│   ├── Warning         #FF9800    (注意/偏低/即将过期)
│   ├── Danger-light    #FFEBEE
│   ├── Danger          #F44336    (紧急/过期/不足)
│   ├── Info-light      #E3F2FD
│   └── Info            #2196F3    (信息/提示)
│
├── 📁 Neutral/
│   ├── White           #FFFFFF
│   ├── Gray-50         #FAFAFA    (页面背景)
│   ├── Gray-100        #F5F5F5    (卡片背景)
│   ├── Gray-200        #EEEEEE    (分割线)
│   ├── Gray-300        #E0E0E0    (边框)
│   ├── Gray-400        #BDBDBD    (禁用文字)
│   ├── Gray-500        #9E9E9E    (辅助文字)
│   ├── Gray-700        #616161    (次要文字)
│   ├── Gray-900        #212121    (主文字)
│   └── Black           #000000
│
└── 📁 Extended/
    ├── Food            #FF8A65    (食品分类色)
    ├── Daily           #4DB6AC    (日用品分类色)
    ├── Medicine        #7986CB    (药品分类色)
    ├── Electronics     #FFD54F    (电器分类色)
    ├── Clothing        #F06292    (衣物分类色)
    └── Other           #A1887F    (其他分类色)
```

### 1.2 字体系统（Text Styles）

```
📁 Typography/
├── 📁 Heading/
│   ├── H1-Bold         28px / LineH 36px / Weight 700 / Letter 0
│   ├── H2-Bold         24px / LineH 32px / Weight 700 / Letter 0
│   ├── H3-Semibold     20px / LineH 28px / Weight 600 / Letter 0
│   ├── H4-Semibold     18px / LineH 26px / Weight 600 / Letter 0
│   └── H5-Medium       16px / LineH 24px / Weight 500 / Letter 0
│
├── 📁 Body/
│   ├── Body-Large      16px / LineH 24px / Weight 400 / Letter 0
│   ├── Body-Regular    14px / LineH 22px / Weight 400 / Letter 0.1
│   ├── Body-Small      12px / LineH 18px / Weight 400 / Letter 0.2
│   └── Body-Tiny       10px / LineH 14px / Weight 400 / Letter 0.3
│
├── 📁 Label/
│   ├── Label-Large     14px / LineH 20px / Weight 500 / Letter 0.1
│   ├── Label-Regular   12px / LineH 16px / Weight 500 / Letter 0.2
│   └── Label-Small     10px / LineH 14px / Weight 500 / Letter 0.3
│
└── 📁 Number/
    ├── Num-Display      32px / LineH 40px / Weight 700 (金额大数字)
    ├── Num-Large        24px / LineH 32px / Weight 600
    └── Num-Regular      16px / LineH 24px / Weight 500
```

### 1.3 间距系统（Spacing）

```
📁 Spacing/
├── space-2      2px
├── space-4      4px
├── space-8      8px
├── space-12     12px
├── space-16     16px    (基础间距)
├── space-20     20px
├── space-24     24px
├── space-32     32px
└── space-40     40px
```

### 1.4 圆角（Border Radius）

```
📁 Radius/
├── radius-xs    4px     (小标签)
├── radius-sm    8px     (按钮、输入框)
├── radius-md    12px    (卡片)
├── radius-lg    16px    (大卡片、弹窗)
├── radius-xl    20px    (底部弹窗)
└── radius-full  9999px  (圆形/药丸形)
```

### 1.5 阴影（Effects/Shadows）

```
📁 Shadows/
├── shadow-sm    0 1px 2px rgba(0,0,0,0.05)           (轻微浮起)
├── shadow-md    0 4px 8px rgba(0,0,0,0.08)           (卡片)
├── shadow-lg    0 8px 24px rgba(0,0,0,0.12)          (弹窗)
└── shadow-xl    0 16px 48px rgba(0,0,0,0.16)         (模态框)
```

***

## 二、原子组件（Atoms）

### 2.1 按钮 Button

```
组件名称：Button
组件路径：Components/Atoms/Button

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│                                            │
│ Variant      │ Primary / Secondary /       │
│              │ Outline / Ghost / Danger     │
│──────────────┼─────────────────────────────│
│ Size         │ Large(48px) / Medium(40px)  │
│              │ / Small(32px) / Mini(24px)  │
│──────────────┼─────────────────────────────│
│ State        │ Default / Hover / Pressed   │
│              │ / Disabled / Loading        │
│──────────────┼─────────────────────────────│
│ Icon         │ None / Left / Right / Only  │
│──────────────┼─────────────────────────────│
│ Width        │ Hug / Fill                  │
│──────────────┼─────────────────────────────│
│ Label        │ Text (可编辑)               │
│                                            │
└────────────────────────────────────────────┘

样式规格：
┌─────────────────────────────────────────────────────────┐
│ Variant    │ Background    │ Text       │ Border        │
├────────────┼──────────────┼────────────┼───────────────┤
│ Primary    │ Primary-500  │ White      │ None          │
│ Secondary  │ Primary-50   │ Primary-500│ None          │
│ Outline    │ White        │ Gray-700   │ Gray-300 1px  │
│ Ghost      │ Transparent  │ Primary-500│ None          │
│ Danger     │ Danger       │ White      │ None          │
└────────────┴──────────────┴────────────┴───────────────┘

Auto Layout:
- Padding: 水平 16px / 垂直 根据Size
- Gap (icon与text之间): 8px
- Alignment: Center Center

示例：
┌──────────────────┐
│   ✓ 保存入库     │  ← Primary / Large / Icon-Left
└──────────────────┘
┌──────────────────┐
│     使用1件      │  ← Secondary / Medium / No Icon
└──────────────────┘
┌──────────────────┐
│   加入购物清单    │  ← Outline / Medium / No Icon
└──────────────────┘
```

### 2.2 输入框 Input

```
组件名称：Input
组件路径：Components/Atoms/Input

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Type         │ Text / Number / Date /      │
│              │ Select / Textarea           │
│──────────────┼─────────────────────────────│
│ State        │ Default / Focus / Filled    │
│              │ / Error / Disabled          │
│──────────────┼─────────────────────────────│
│ Size         │ Large(48px) / Medium(40px)  │
│──────────────┼─────────────────────────────│
│ Label        │ Show / Hide                 │
│──────────────┼─────────────────────────────│
│ Placeholder  │ Text (可编辑)               │
│──────────────┼─────────────────────────────│
│ Helper Text  │ Show / Hide                 │
│──────────────┼─────────────────────────────│
│ Prefix       │ None / Icon / Text          │
│──────────────┼─────────────────────────────│
│ Suffix       │ None / Icon / Text / Clear  │
│──────────────┼─────────────────────────────│
│ Required     │ True / False                │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│ 物品名称 *                  ← Label层    │
│ ┌─────────────────────────────────┐     │
│ │ 🔍  请输入物品名称         ✕    │     │ ← 输入框层
│ └─────────────────────────────────┘     │
│ 请输入2-30个字符              ← Helper  │
└─────────────────────────────────────────┘

Auto Layout:
- 方向: Vertical
- Gap: 4px (Label与Input之间), 4px (Input与Helper之间)
- Input内部 Padding: 左12px 右12px 上下居中
- Border: 1px Gray-300 / Focus时 2px Primary-500
- Border Radius: radius-sm (8px)
```

### 2.3 标签 Tag / Badge

```
组件名称：Tag
组件路径：Components/Atoms/Tag

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Variant      │ Default / Success / Warning │
│              │ / Danger / Info / Custom    │
│──────────────┼─────────────────────────────│
│ Size         │ Medium(24px) / Small(20px)  │
│──────────────┼─────────────────────────────│
│ Style        │ Filled / Light / Outline    │
│──────────────┼─────────────────────────────│
│ Closable     │ True / False                │
│──────────────┼─────────────────────────────│
│ Icon         │ Show / Hide                 │
│──────────────┼─────────────────────────────│
│ Label        │ Text (可编辑)               │
└────────────────────────────────────────────┘

示例：
┌────────┐  ┌──────────┐  ┌────────────┐
│🔴 已过期│  │🟡 即将过期│  │🟢 状态正常  │
└────────┘  └──────────┘  └────────────┘

┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐
│ 食品 │  │ 日用 │  │ 药品 │  │ 电器 │
└──────┘  └──────┘  └──────┘  └──────┘
```

### 2.4 进度条 Progress Bar

```
组件名称：ProgressBar
组件路径：Components/Atoms/ProgressBar

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Type         │ Linear / Circular           │
│──────────────┼─────────────────────────────│
│ Value        │ 0-100 (Number)             │
│──────────────┼─────────────────────────────│
│ Color        │ Auto (根据值变色) / Fixed   │
│──────────────┼─────────────────────────────│
│ ShowLabel    │ True / False                │
│──────────────┼─────────────────────────────│
│ Size         │ Large(8px高) / Small(4px高) │
└────────────────────────────────────────────┘

颜色逻辑（Auto模式）：
- 0-30%:   Danger（库存很低/即将过期）
- 31-60%:  Warning（注意）
- 61-100%: Success（充足）

结构示例：
剩余量 50%
━━━━━━━━━━━░░░░░░░░░░  ← 绿色（充足）

过期倒计时 仅剩10%时间
━━░░░░░░░░░░░░░░░░░░░  ← 红色（紧急）
```

### 2.5 图标 Icon

```
组件名称：Icon
组件路径：Components/Atoms/Icon

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Name         │ Instance Swap (图标实例交换) │
│──────────────┼─────────────────────────────│
│ Size         │ 16px / 20px / 24px / 32px  │
│──────────────┼─────────────────────────────│
│ Color        │ Primary/Gray/White/Status   │
└────────────────────────────────────────────┘

图标集清单：
📁 Icons/
├── 📁 Navigation/
│   ├── home, list, add, bell, user
│   ├── back, close, menu, search
│   └── filter, sort, more
│
├── 📁 Action/
│   ├── scan, camera, mic, edit, delete
│   ├── share, export, copy, move
│   └── check, plus, minus, refresh
│
├── 📁 Category/
│   ├── food, drink, daily, medicine
│   ├── electronics, clothing, other
│   └── kitchen, bathroom, bedroom, balcony
│
├── 📁 Status/
│   ├── warning, error, success, info
│   ├── clock, calendar, location
│   └── lock, unlock, eye, eye-off
│
└── 📁 Object/
    ├── cart, bag, box, package
    ├── fridge, cabinet, shelf
    └── receipt, barcode, qrcode
```

### 2.6 头像 Avatar

```
组件名称：Avatar
组件路径：Components/Atoms/Avatar

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Type         │ Image / Text / Icon         │
│──────────────┼─────────────────────────────│
│ Size         │ XL(64px) / L(48px) /       │
│              │ M(36px) / S(24px)          │
│──────────────┼─────────────────────────────│
│ Badge        │ None / Number / Dot         │
│──────────────┼─────────────────────────────│
│ Shape        │ Circle / Rounded            │
└────────────────────────────────────────────┘
```

### 2.7 手机号输入框 PhoneInput

```
组件名称：PhoneInput
组件路径：Components/Atoms/PhoneInput

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ State        │ Default / Focus / Error /   │
│              │ Disabled                    │
│──────────────┼─────────────────────────────┤
│ ErrorText    │ String / Null               │
│──────────────┼─────────────────────────────┤
│ HintText     │ String (默认: "请输入手机号")│
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│ 🇨🇳 +86  [ 手机号输入框 ]                 │
│ 请输入正确的手机号 (Error State)          │
└─────────────────────────────────────────┘

样式规格：
- 高度: 48px
- 边框: 1px Gray-300 / Focus: 2px Primary-500 / Error: 2px Danger
- 圆角: radius-sm (8px)
- 左侧国旗: 固定宽度 80px, 分隔线 1px Gray-200
- 内部 Padding: 12px
```

### 2.8 验证码输入框 CodeInput

```
组件名称：CodeInput
组件路径：Components/Atoms/CodeInput

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Length       │ Number (默认: 6)            │
│──────────────┼─────────────────────────────┤
│ State        │ Default / Focus / Error /   │
│              │ Filled / Disabled           │
│──────────────┼─────────────────────────────┤
│ ErrorText    │ String / Null               │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│ [ 1 ] [ 2 ] [ 3 ] [ 4 ] [ 5 ] [ 6 ]      │
│ 请输入完整的验证码 (Error State)         │
└─────────────────────────────────────────┘

单个方格规格：
- 尺寸: 40×48px
- 边框: 1px Gray-300 / Focus: 2px Primary-500 / Error: 2px Danger
- 圆角: radius-sm (8px)
- 字体: 20px, Bold, Gray-900
- 间距: 8px between boxes
```

### 2.9 密码输入框 PasswordInput

```
组件名称：PasswordInput
组件路径：Components/Atoms/PasswordInput

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ State        │ Default / Focus / Error /   │
│              │ Disabled                    │
│──────────────┼─────────────────────────────┤
│ ShowStrength │ True / False (显示强度条)   │
│──────────────┼─────────────────────────────┤
│ ErrorText    │ String / Null               │
│──────────────┼─────────────────────────────┤
│ HintText     │ String                      │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│ [ 密码输入框 ]                [👁️]       │
│ [ ▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁ ] (强度条)       │
│ 密码至少6位 (Error State)               │
└─────────────────────────────────────────┘

密码强度条规格：
- 高度: 4px
- 圆角: radius-xs
- 弱: 1/3 宽度, Danger色
- 中: 2/3 宽度, Warning色
- 强: 满宽度, Success色
```

### 2.10 认证按钮 AuthButton

```
组件名称：AuthButton
组件路径：Components/Atoms/AuthButton

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Variant      │ Primary / Outline / Ghost   │
│──────────────┼─────────────────────────────┤
│ State        │ Default / Loading / Disabled│
│──────────────┼─────────────────────────────┤
│ Width        │ Fill / Hug                  │
│──────────────┼─────────────────────────────┤
│ LeftIcon     │ None / Icon                 │
│──────────────┼─────────────────────────────┤
│ RightIcon    │ None / Icon                 │
└────────────────────────────────────────────┘

样式规格：
┌────────────────────────────────────────────────────────┐
│ Variant   │ Background   │ Text    │ Border            │
├───────────┼──────────────┼─────────┼───────────────────┤
│ Primary   │ Primary-500  │ White   │ None              │
│ Outline   │ Transparent  │ Primary │ Gray-300 1px      │
│ Ghost     │ Transparent  │ Primary │ None              │
└───────────┴──────────────┴─────────┴───────────────────┘

尺寸:
- 高度: 48px
- 圆角: radius-sm (8px)
- Padding: 水平 16px
```

***

## 三、分子组件（Molecules）

### 3.1 物品卡片 ItemCard

```
组件名称：ItemCard
组件路径：Components/Molecules/ItemCard

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Layout       │ Horizontal / Vertical       │
│──────────────┼─────────────────────────────│
│ Status       │ Normal / Warning / Danger   │
│              │ / Expired / Empty           │
│──────────────┼─────────────────────────────│
│ ShowImage    │ True / False                │
│──────────────┼─────────────────────────────│
│ ShowProgress │ True / False                │
│──────────────┼─────────────────────────────│
│ ShowLocation │ True / False                │
│──────────────┼─────────────────────────────│
│ Selectable   │ True / False                │
│──────────────┼─────────────────────────────│
│ Swipeable    │ True / False (左滑操作)     │
└────────────────────────────────────────────┘

结构（Horizontal 模式）：

┌─────────────────────────────────────────────────┐
│ ┌──────┐                                        │
│ │      │  名称: [Text] Body-Regular Bold         │
│ │ IMG  │  位置: [Icon+Text] Body-Small Gray-500  │
│ │64×64 │  数量: [Text] Body-Small                │
│ │      │  状态: [ProgressBar] + [Tag]            │
│ └──────┘                                        │
│                                                 │  
│  ← Padding: 16px all                           │
│  ← Gap: 12px (image与content之间)              │
│  ← Background: White                           │
│  ← Border Radius: radius-md (12px)             │
│  ← Shadow: shadow-sm                           │
│  ← 左侧状态指示条: 3px width, 状态色           │
└─────────────────────────────────────────────────┘

子层级结构（Layer）：
ItemCard
├── StatusIndicator (3px宽色条, 左侧)
├── Thumbnail (64×64, radius-sm)
│   └── Image / Placeholder Icon
├── Content (Auto Layout - Vertical, Gap 4px)
│   ├── Row-Top (Auto Layout - Horizontal)
│   │   ├── ItemName (Text, fill)
│   │   └── Tag-Status (Component Instance)
│   ├── Row-Location (Auto Layout - Horizontal)
│   │   ├── Icon-Location (16px, Gray-500)
│   │   └── LocationText (Text, Gray-500)
│   ├── Row-Info (Auto Layout - Horizontal)
│   │   ├── QuantityText (如"剩余：3盒")
│   │   └── ExpiryText (如"⏰还剩2天")
│   └── ProgressBar (Component Instance)
└── SwipeActions (Hidden, 左滑显示)
    ├── Button-Use (使用)
    ├── Button-Edit (编辑)
    └── Button-Delete (删除)

Auto Layout 设置：
- 方向: Horizontal
- Padding: 16 16 16 16
- Gap: 12
- Alignment: Left, Center (垂直居中)
- Resize: Fill width, Hug height
```

### 3.2 提醒卡片 AlertCard

```
组件名称：AlertCard
组件路径：Components/Molecules/AlertCard

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Type         │ Expiry / Stock / Purchase   │
│              │ / Warranty / General        │
│──────────────┼─────────────────────────────│
│ Priority     │ High / Medium / Low         │
│──────────────┼─────────────────────────────│
│ HasActions   │ True / False                │
│──────────────┼─────────────────────────────│
│ Dismissible  │ True / False                │
│──────────────┼─────────────────────────────│
│ Expanded     │ True / False                │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────────────┐
│ AlertCard                                        │
│                                                 │
│  ┌─── Header ──────────────────────────────┐    │
│  │ [Icon-Type] [Title]          [Dismiss ✕] │    │
│  └──────────────────────────────────────────┘    │
│  ┌─── Body ────────────────────────────────┐    │
│  │ [Description]                            │    │
│  │ [Location / Extra Info]                  │    │
│  └──────────────────────────────────────────┘    │
│  ┌─── Actions ─────────────────────────────┐    │
│  │ [Button-Primary] [Button-Secondary] ...  │    │
│  └──────────────────────────────────────────┘    │
│                                                 │
│  Background: Status-light (根据Type)            │
│  Left Border: 4px Status-color                  │
│  Padding: 16px                                  │
│  Radius: radius-md                              │
└─────────────────────────────────────────────────┘

示例实例：
┌─────────────────────────────────────────────┐
│ 🔴 紧急：有机生菜 明天过期！            ✕  │
│    📍 冰箱·冷藏层                           │
│    建议：今天食用或处理                     │
│                                             │
│    [今天用掉]  [已丢弃]  [忽略]            │
└─────────────────────────────────────────────┘
Background: Danger-light (#FFEBEE)
Left Border: 4px Danger (#F44336)
```

### 3.3 统计卡片 StatCard

```
组件名称：StatCard
组件路径：Components/Molecules/StatCard

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Size         │ Large / Medium / Small      │
│──────────────┼─────────────────────────────│
│ HasIcon      │ True / False                │
│──────────────┼─────────────────────────────│
│ HasTrend     │ True / False                │
│──────────────┼─────────────────────────────│
│ Clickable    │ True / False                │
└────────────────────────────────────────────┘

结构（Medium）：
┌───────────────────────┐
│  [Icon]               │
│  [Value] 数字大       │
│  [Label] 说明文字     │
│  [Trend] ↑12% 趋势   │
│                       │
│  BG: White            │
│  Radius: radius-md    │
│  Shadow: shadow-sm    │
│  Padding: 16px        │
│  Size: Fixed width    │
└───────────────────────┘

示例：
┌───────────────┐  ┌───────────────┐
│ 🔴 即将过期    │  │ 📦 库存不足    │
│    5 件       │  │    3 件       │
│ 最近：牛奶    │  │ 最近：洗衣液  │
│ 还剩2天       │  │ 预计3天用完   │
└───────────────┘  └───────────────┘
```

### 3.4 位置选择器 LocationPicker

```
组件名称：LocationPicker
组件路径：Components/Molecules/LocationPicker

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Mode         │ Display / Edit / Picker     │
│──────────────┼─────────────────────────────│
│ Depth        │ 1级 / 2级 / 3级            │
│──────────────┼─────────────────────────────│
│ ShowIcon     │ True / False                │
└────────────────────────────────────────────┘

Display 模式：
┌─────────────────────────────────────┐
│ 📍 厨房 › 冰箱 › 冷藏第二层       >│
└─────────────────────────────────────┘

Picker 模式（级联选择）：
┌─────────────────────────────────────┐
│ 选择位置                        ✕   │
│─────────────────────────────────────│
│ ┌──────┐ ┌──────────┐ ┌─────────┐  │
│ │ 房间 │ │  区域    │ │ 具体位置│  │
│ ├──────┤ ├──────────┤ ├─────────┤  │
│ │[厨房]│ │ [冰箱]   │ │ 冷藏1层│  │
│ │ 卫生间│ │  吊柜    │ │[冷藏2层]│  │
│ │ 卧室 │ │  调料架  │ │ 冷藏3层│  │
│ │ 客厅 │ │  台面    │ │ 冷冻层 │  │
│ │ 阳台 │ │  水槽下  │ │ 门侧  │  │
│ └──────┘ └──────────┘ └─────────┘  │
│                                     │
│ 当前选择：厨房 › 冰箱 › 冷藏第二层  │
│                                     │
│ [        ✓ 确认选择        ]        │
└─────────────────────────────────────┘
```

### 3.5 数量调节器 QuantityStepper

```
组件名称：QuantityStepper
组件路径：Components/Molecules/QuantityStepper

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Size         │ Large / Medium / Small      │
│──────────────┼─────────────────────────────│
│ Min          │ Number (default: 0)         │
│──────────────┼─────────────────────────────│
│ Max          │ Number (default: 999)       │
│──────────────┼─────────────────────────────│
│ Step         │ Number (default: 1)         │
│──────────────┼─────────────────────────────│
│ Unit         │ Text (件/盒/瓶/kg...)       │
│──────────────┼─────────────────────────────│
│ ShowUnit     │ True / False                │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────┐
│  [ - ]    [ 3 ]    [ + ]   │
│   32px     48px     32px   │
│                    单位:盒  │
└─────────────────────────────┘

Auto Layout:
- Horizontal, Gap: 0
- 减号按钮: 32×32, radius-sm, Border Gray-300
- 数值区域: min-width 48px, 居中
- 加号按钮: 32×32, radius-sm, Border Gray-300
```

### 3.6 搜索栏 SearchBar

```
组件名称：SearchBar
组件路径：Components/Molecules/SearchBar

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ State        │ Default / Active / Filled   │
│──────────────┼─────────────────────────────│
│ ShowScan     │ True / False (扫码按钮)     │
│──────────────┼─────────────────────────────│
│ ShowFilter   │ True / False (筛选按钮)     │
│──────────────┼─────────────────────────────│
│ Placeholder  │ Text                        │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│  🔍  搜索物品、位置...        📷  ≡    │
│                                         │
│  BG: Gray-100                           │
│  Radius: radius-full (药丸形)           │
│  Height: 40px                           │
│  Padding: 0 16px                        │
└─────────────────────────────────────────┘
```

### 3.7 列表项 ListItem

```
组件名称：ListItem
组件路径：Components/Molecules/ListItem

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Type         │ Navigation / Action /       │
│              │ Toggle / Checkbox           │
│──────────────┼─────────────────────────────│
│ Leading      │ None / Icon / Avatar /      │
│              │ Image / Checkbox            │
│──────────────┼─────────────────────────────│
│ Trailing     │ None / Arrow / Text /       │
│              │ Switch / Badge              │
│──────────────┼─────────────────────────────│
│ Subtitle     │ Show / Hide                 │
│──────────────┼─────────────────────────────│
│ Divider      │ Show / Hide                 │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│ [Leading]  [Title]           [Trailing] │
│            [Subtitle]                   │
│─────────────────────────── (Divider) ───│

Height: 56px (单行) / 72px (双行)
Padding: 16px horizontal
```

### 3.8 时间线项 TimelineItem

```
组件名称：TimelineItem
组件路径：Components/Molecules/TimelineItem

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Type         │ Add / Use / Move / Expire   │
│              │ / Delete / Purchase         │
│──────────────┼─────────────────────────────│
│ IsLast       │ True / False (是否最后一条) │
│──────────────┼─────────────────────────────│
│ ShowAvatar   │ True / False                │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│  ●───  01-25 10:30  使用1盒  剩余3盒   │
│  │     操作人：妈妈                     │
│  │                                      │
│  ●───  01-22 08:15  使用1盒  剩余4盒   │
│  │     操作人：孩子                     │
│  │                                      │
│  ●     01-15 20:00  入库6盒            │
│        操作人：妈妈                     │
└─────────────────────────────────────────┘

● 节点：12px圆, Type决定颜色
│ 连线：2px Gray-200
```

***

## 四、组织组件（Organisms）

### 4.1 导航栏 NavBar

```
组件名称：NavBar
组件路径：Components/Organisms/NavBar

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Type         │ Home / Detail / Modal       │
│──────────────┼─────────────────────────────│
│ Title        │ Text                        │
│──────────────┼─────────────────────────────│
│ LeftAction   │ None / Back / Close / Menu  │
│──────────────┼─────────────────────────────│
│ RightAction  │ None / Edit / Save /        │
│              │ Filter / More / Multi       │
│──────────────┼─────────────────────────────│
│ ShowBadge    │ True / False                │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│  [←]     [Title]        [Action] [Action]│
│                                         │
│  Height: 56px                           │
│  BG: White                              │
│  Border-bottom: 1px Gray-200            │
│  Safe Area Top: included                │
└─────────────────────────────────────────┘
```

### 4.2 底部标签栏 TabBar

```
组件名称：TabBar
组件路径：Components/Organisms/TabBar

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ ActiveTab    │ Home / Items / Add /        │
│              │ Alerts / Profile            │
│──────────────┼─────────────────────────────│
│ AlertBadge   │ Number (0则隐藏)            │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│                                         │
│  🏠     📦    [＋]    🔔     👤         │
│  首页   物品   录入   提醒    我的       │
│                                         │
│  Height: 60px + Safe Area Bottom        │
│  BG: White                              │
│  Shadow: shadow-md (向上)               │
│  中间+号: 56px圆形, Primary色, 上浮     │
│  Active: Primary-500色                  │
│  Inactive: Gray-400色                   │
└─────────────────────────────────────────┘

中间录入按钮特殊处理：
- 比其他tab高出12px
- 56×56 圆形
- Background: Primary-500
- Icon: Plus, 24px, White
- Shadow: shadow-md
```

### 4.3 物品列表 ItemList

```
组件名称：ItemList
组件路径：Components/Organisms/ItemList

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Layout       │ List / Grid                 │
│──────────────┼─────────────────────────────│
│ ShowHeader   │ True / False                │
│──────────────┼─────────────────────────────│
│ ShowEmpty    │ True / False                │
│──────────────┼─────────────────────────────│
│ Scrollable   │ True / False                │
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│ [SectionHeader - "食品 (12件)"]         │
│ ┌─────────────────────────────────┐     │
│ │ ItemCard Instance 1              │     │
│ └─────────────────────────────────┘     │
│ ┌─────────────────────────────────┐     │
│ │ ItemCard Instance 2              │     │
│ └─────────────────────────────────┘     │
│ ┌─────────────────────────────────┐     │
│ │ ItemCard Instance 3              │     │
│ └─────────────────────────────────┘     │
│                                         │
│ Auto Layout: Vertical                   │
│ Gap: 12px                               │
│ Padding: 16px horizontal                │
└─────────────────────────────────────────┘

Empty State:
┌─────────────────────────────────────────┐
│                                         │
│          ┌────────────┐                 │
│          │  📦 插画   │                 │
│          └────────────┘                 │
│                                         │
│        还没有添加任何物品               │
│     扫一扫或手动添加第一件物品吧        │
│                                         │
│     [  + 添加第一件物品  ]              │
│                                         │
└─────────────────────────────────────────┘
```

### 4.4 空间网格 SpaceGrid

```
组件名称：SpaceGrid
组件路径：Components/Organisms/SpaceGrid

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ Columns      │ 2 / 3                       │
│──────────────┼─────────────────────────────│
│ CardSize     │ Large / Medium              │
│──────────────┼─────────────────────────────│
│ Editable     │ True / False                │
└────────────────────────────────────────────┘

子组件 SpaceCard：
┌───────────────────┐
│                   │
│    [Emoji Icon]   │  ← 32px
│    [空间名称]     │  ← H5-Medium
│    [物品数量]件   │  ← Body-Small, Gray-500
│                   │
│  BG: Gray-50      │
│  Radius: radius-md│
│  Aspect: 1:1      │
│  Border: 1px Gray-200, hover时 Primary
└───────────────────┘

Grid Layout:
- Columns: 2
- Gap: 12px
- Padding: 16px
```

### 4.5 分类标签栏 CategoryTabs

```
组件名称：CategoryTabs
组件路径：Components/Organisms/CategoryTabs

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ ActiveIndex  │ Number                      │
│──────────────┼─────────────────────────────│
│ Scrollable   │ True / False                │
│──────────────┼─────────────────────────────│
│ ShowCount    │ True / False                │
│──────────────┼─────────────────────────────│
│ Style        │ Underline / Pill / Tag      │
└────────────────────────────────────────────┘

结构 (Underline Style):
┌─────────────────────────────────────────────┐
│  [全部]   食品   日用   药品   电器   衣物   │
│   ━━━                                       │
│                                             │
│  Active: Primary-500, 下方2px指示条         │
│  Inactive: Gray-700                         │
│  可横向滚动                                 │
│  Height: 44px                               │
└─────────────────────────────────────────────┘

结构 (Pill Style):
┌─────────────────────────────────────────────┐
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐       │
│  │全部│ │食品 │ │日用 │ │药品 │ │电器 │       │
│  └────┘ └────┘ └────┘ └────┘ └────┘       │
│                                             │
│  Active: BG Primary-500, Text White         │
│  Inactive: BG Gray-100, Text Gray-700       │
│  Radius: radius-full                        │
│  Padding: 8px 16px                          │
│  Gap: 8px                                   │
│  可横向滚动                                 │
└─────────────────────────────────────────────┘
```

### 4.6 操作底部弹窗 ActionSheet

```
组件名称：ActionSheet
组件路径：Components/Organisms/ActionSheet

┌────────────────────────────────────────────┐
│ Component Properties:                       │
├────────────────────────────────────────────┤
│ HasTitle     │ True / False                │
│──────────────┼─────────────────────────────│
│ ActionCount  │ 2-6                         │
│──────────────┼─────────────────────────────│
│ HasCancel    │ True / False                │
│──────────────┼─────────────────────────────│
│ Destructive  │ None / Index(哪个是危险操作)│
└────────────────────────────────────────────┘

结构：
┌─────────────────────────────────────────┐
│ ═══ (拖拽指示条, 36×4, Gray-300)        │
│                                         │
│  选择操作               ← 可选标题      │
│                                         │
│ ┌─────────────────────────────────┐     │
│ │  📷  扫码录入                    │     │
│ ├─────────────────────────────────┤     │
│ │  📸  拍照识别                    │     │
│ ├─────────────────────────────────┤     │
│ │  🎤  语音录入                    │     │
│ ├─────────────────────────────────┤     │
│ │  ✏️  手动录入                    │     │
│ └─────────────────────────────────┘     │
│                                         │
│ ┌─────────────────────────────────┐     │
│ │         取消                     │     │
│ └─────────────────────────────────┘     │
│                                         │
│  BG: White                              │
│  Radius: radius-xl (顶部)              │
│  Overlay: Black 50% opacity             │
└─────────────────────────────────────────┘
```

***

## 五、页面模板（Templates）

### 5.1 首页模板

```
组件名称：Template/HomePage
组件路径：Templates/HomePage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: HomePage (375×812, iPhone 13)     │
│                                         │
│ ├── NavBar (Type: Home)                 │
│ │   ├── Title: "我的家"                 │
│ │   └── RightActions: Bell(Badge:3), Avatar │
│ │                                       │
│ ├── ScrollView                          │
│ │   ├── SearchBar                       │
│ │   │   └── Placeholder: "搜索物品/位置"│
│ │   │                                   │
│ │   ├── Section: AlertSummary           │
│ │   │   ├── SectionHeader: "⚠️ 需要关注"│
│ │   │   └── Grid (2 columns)           │
│ │   │       ├── StatCard (Expiry)       │
│ │   │       ├── StatCard (Stock)        │
│ │   │       ├── StatCard (Shopping)     │
│ │   │       └── StatCard (Expense)      │
│ │   │                                   │
│ │   ├── Section: QuickAccess            │
│ │   │   ├── SectionHeader: "📍 快捷查看"│
│ │   │   └── SpaceGrid (Scrollable)     │
│ │   │       ├── SpaceCard (厨房)        │
│ │   │       ├── SpaceCard (卫生间)      │
│ │   │       ├── SpaceCard (客厅)        │
│ │   │       └── SpaceCard (卧室)        │
│ │   │                                   │
│ │   └── Section: RecentActivity         │
│ │       ├── SectionHeader: "📅 最近动态"│
│ │       ├── TimelineItem                │
│ │       ├── TimelineItem                │
│ │       ├── TimelineItem                │
│ │       └── TextButton: "查看全部 →"    │
│ │                                       │
│ └── TabBar (ActiveTab: Home)            │
│                                         │
└─────────────────────────────────────────┘

Constraints & Responsiveness:
- NavBar: Top, Left-Right, Fixed height
- ScrollView: Fill between NavBar and TabBar
- TabBar: Bottom, Left-Right, Fixed height
- StatCard Grid: 2 columns, equal width, gap 12
- SpaceGrid: Horizontal scroll
```

### 5.2 物品详情模板

```
组件名称：Template/ItemDetailPage
组件路径：Templates/ItemDetailPage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: ItemDetailPage (375×812)          │
│                                         │
│ ├── NavBar (Type: Detail)               │
│ │   ├── LeftAction: Back               │
│ │   └── RightActions: Edit, Delete     │
│ │                                       │
│ ├── ScrollView                          │
│ │   ├── ImageCarousel                   │
│ │   │   └── Height: 200px              │
│ │   │                                   │
│ │   ├── HeaderSection                   │
│ │   │   ├── ItemName (H3)              │
│ │   │   ├── CategoryTag + BrandText    │
│ │   │   └── StatusTag                  │
│ │   │                                   │
│ │   ├── MetricsRow (3 columns)         │
│ │   │   ├── Metric (剩余数量)          │
│ │   │   ├── Metric (过期倒计时)        │
│ │   │   └── Metric (消耗速率)          │
│ │   │                                   │
│ │   ├── ProgressSection                 │
│ │   │   ├── ProgressBar                │
│ │   │   └── PredictionText             │
│ │   │                                   │
│ │   ├── DetailSection                   │
│ │   │   ├── SectionHeader: "详细信息"  │
│ │   │   ├── ListItem (存放位置)        │
│ │   │   ├── ListItem (购买价格)        │
│ │   │   ├── ListItem (购买渠道)        │
│ │   │   ├── ListItem (购买日期)        │
│ │   │   ├── ListItem (生产日期)        │
│ │   │   ├── ListItem (到期日期)        │
│ │   │   └── ListItem (提醒设置)        │
│ │   │                                   │
│ │   ├── HistorySection                  │
│ │   │   ├── SectionHeader: "使用记录"  │
│ │   │   ├── TimelineItem               │
│ │   │   ├── TimelineItem               │
│ │   │   ├── TimelineItem               │
│ │   │   └── TextButton: "查看全部"     │
│ │   │                                   │
│ │   └── Spacer (80px for bottom bar)   │
│ │                                       │
│ └── BottomActionBar (Fixed bottom)      │
│     ├── Button: "使用1件" (Secondary)   │
│     ├── Button: "已用完" (Outline)      │
│     └── Button: "再次购买" (Primary)    │
│                                         │
└─────────────────────────────────────────┘
```

### 5.3 录入表单模板

```
组件名称：Template/AddItemPage
组件路径：Templates/AddItemPage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: AddItemPage (375×812)            │
│                                         │
│ ├── NavBar (Type: Modal)                │
│ │   ├── LeftAction: Back               │
│ │   ├── Title: "添加物品"              │
│ │   └── RightAction: Save              │
│ │                                       │
│ ├── ScrollView                          │
│ │   ├── ImageUploader                   │
│ │   │   └── Type: Add Photo            │
│ │   │                                   │
│ │   ├── FormSection: "基本信息"        │
│ │   │   ├── Input (名称, Required)     │
│ │   │   ├── Input (分类, Type:Select)  │
│ │   │   └── Input (品牌)              │
│ │   │                                   │
│ │   ├── FormSection: "购买信息"        │
│ │   │   ├── Row                        │
│ │   │   │   ├── Input (数量+单位)     │
│ │   │   │   └── Input (单价, ¥前缀)   │
│ │   │   ├── Input (购买日期, Type:Date)│
│ │   │   └── Input (购买渠道, Select)   │
│ │   │                                   │
│ │   ├── FormSection: "时效信息"        │
│ │   │   ├── Input (生产日期)           │
│ │   │   ├── Input (保质期, Select)     │
│ │   │   └── Input (到期日期, 自动计算) │
│ │   │                                   │
│ │   ├── FormSection: "存放位置"        │
│ │   │   └── LocationPicker             │
│ │   │                                   │
│ │   ├── FormSection: "提醒设置"        │
│ │   │   ├── Input (过期提前提醒)       │
│ │   │   └── Input (库存预警数量)       │
│ │   │                                   │
│ │   ├── FormSection: "备注"            │
│ │   │   └── Input (Type: Textarea)    │
│ │   │                                   │
│ │   └── Spacer (100px)                 │
│ │                                         │
│ └── BottomBar (Fixed)                   │
│     ├── Button: "保存入库" (Primary, Fill)│
│     └── TextButton: "保存并继续添加"    │
│                                         │
└─────────────────────────────────────────┘
```

### 5.4 启动页模板 SplashPage

```
组件名称：Template/SplashPage
组件路径：Templates/SplashPage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: SplashPage (375×812)             │
│                                         │
│ ├── Spacer (Top)                        │
│ ├── 🏠📦 (Emoji, 64px)                │
│ ├── Text: "HomeStock" (H2, Bold)       │
│ ├── Text: "家庭物品管家" (Body, Gray-500)│
│ ├── Spacer (Middle)                     │
│ ├── Loading Indicator (Circular)       │
│ ├── Spacer (Bottom)                     │
│                                         │
│ 背景: White                             │
└─────────────────────────────────────────┘
```

### 5.5 欢迎页/引导页模板 WelcomePage

```
组件名称：Template/WelcomePage
组件路径：Templates/WelcomePage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: WelcomePage (375×812)            │
│                                         │
│ ├── Top Row                             │
│ │   └── TextButton: "跳过"              │
│ │                                       │
│ ├── PageView (3 pages)                  │
│ │   ├── Page 1:                         │
│ │   │   ├── Emoji: 📦 (80px)          │
│ │   │   ├── Text: "知道家里有什么" (H3)│
│ │   │   └── Text: "扫一扫就能轻松记录每件物品" (Body)│
│ │   ├── Page 2:                         │
│ │   │   ├── Emoji: 📍 (80px)          │
│ │   │   ├── Text: "知道东西在哪里" (H3)│
│ │   │   └── Text: "再也不用翻箱倒柜找东西" (Body)│
│ │   └── Page 3:                         │
│ │       ├── Emoji: ⏰ (80px)          │
│ │       ├── Text: "知道什么时候该买" (H3)│
│ │       └── Text: "过期提醒，智能补购" (Body)│
│ │                                       │
│ ├── Page Indicators (3 dots)            │
│ ├── Spacer (24px)                       │
│ └── AuthButton: "下一步" / "开始使用"  │
│                                         │
│ 背景: White                             │
└─────────────────────────────────────────┘
```

### 5.6 登录页模板 LoginPage

```
组件名称：Template/LoginPage
组件路径：Templates/LoginPage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: LoginPage (375×812)              │
│                                         │
│ ├── ScrollView (Padding: 24px)          │
│ │   ├── Top Section:                    │
│ │   │   ├── 🏠📦 (64px)               │
│ │   │   ├── Text: "HomeStock" (H2)      │
│ │   │   ├── Spacer (24px)               │
│ │   │   ├── Text: "欢迎回来 👋" (H3)   │
│ │   │   └── Text: "登录后同步你的家庭数据" (Body)│
│ │   │                                 │
│ │   ├── Form Section:                  │
│ │   │   ├── PhoneInput                 │
│ │   │   ├── Spacer (20px)              │
│ │   │   ├── PasswordInput              │
│ │   │   ├── Spacer (16px)              │
│ │   │   └── AlignRight TextButton: "忘记密码?"│
│ │   │                                 │
│ │   ├── Buttons Section:               │
│ │   │   ├── AuthButton: "登录" (Primary)│
│ │   │   ├── Spacer (24px)              │
│ │   │   ├── AuthButton: "📱 验证码登录" (Outline)│
│ │   │   ├── Spacer (32px)              │
│ │   │   ├── Divider + "或" + Divider  │
│ │   │   ├── Spacer (24px)              │
│ │   │   └── Row:                       │
│ │   │       ├── Text: "还没有账号?"    │
│ │   │       └── TextButton: "立即注册" │
│ │   │                                 │
│ │   └── Bottom Text: (协议)            │
│ │       "登录即代表同意《用户协议》和《隐私政策》"│
│                                         │
│ 背景: White                             │
└─────────────────────────────────────────┘
```

### 5.7 注册页模板 RegisterPage

```
组件名称：Template/RegisterPage
组件路径：Templates/RegisterPage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: RegisterPage (375×812)           │
│                                         │
│ ├── NavBar (Back Button)                │
│ ├── ScrollView (Padding: 24px)          │
│ │   ├── Title: "创建账号" (H3)          │
│ │   ├── Subtitle: "加入 HomeStock，开始管理你的家庭物品" (Body)│
│ │   ├── Spacer (40px)                   │
│ │   ├── PhoneInput                     │
│ │   ├── Spacer (16px)                   │
│ │   ├── Row:                            │
│ │   │   ├── Expanded: AuthButton: "获取验证码" (Outline)│
│ │   ├── (Code Sent 后显示)              │
│ │   │   ├── Spacer (32px)              │
│ │   │   ├── CodeInput                  │
│ │   │   ├── Spacer (24px)              │
│ │   │   ├── PasswordInput              │
│ │   │   ├── Spacer (32px)              │
│ │   │   ├── AuthButton: "注册" (Primary)│
│ │   │   ├── Spacer (24px)              │
│ │   │   └── (协议文字)                  │
│                                         │
│ 背景: White                             │
└─────────────────────────────────────────┘
```

### 5.8 创建家庭页模板 CreateFamilyPage

```
组件名称：Template/CreateFamilyPage
组件路径：Templates/CreateFamilyPage

层级结构：
┌─────────────────────────────────────────┐
│ Frame: CreateFamilyPage (375×812)       │
│                                         │
│ ├── Spacer (Top, Flex 1)                │
│ ├── Emoji: 🏠 (80px)                   │
│ ├── Spacer (32px)                       │
│ ├── Text: "创建你的家庭" (H3, Center)  │
│ ├── Text: "创建一个家庭空间，邀请家人一起管理物品" (Body, Center)│
│ ├── Spacer (40px)                       │
│ ├── Input: "给你的家庭起个名字" (Large)│
│ ├── Spacer (24px)                       │
│ ├── AuthButton: "创建家庭" (Primary)   │
│ ├── Spacer (24px)                       │
│ ├── Row (Center):                       │
│ │   ├── Text: "已有家庭?"              │
│ │   └── TextButton: "加入家庭"         │
│ ├── Spacer (Bottom, Flex 2)             │
│                                         │
│ 背景: White                             │
└─────────────────────────────────────────┘
```

***

## 六、交互状态说明（Interactive States）

### 6.1 物品卡片交互

```
┌─────────────────────────────────────────┐
│ ItemCard 交互状态                        │
├─────────────────────────────────────────┤
│                                         │
│ Default State:                          │
│  → Background: White                    │
│  → Shadow: shadow-sm                    │
│                                         │
│ Pressed State:                          │
│  → Background: Gray-50                  │
│  → Shadow: none                         │
│  → Scale: 0.98                          │
│  → Duration: 100ms                      │
│                                         │
│ Swipe Left (iOS):                       │
│  → 显示操作按钮                         │
│  → Threshold: 60px                      │
│  ┌────────────────────┬─────┬─────┬─────┐
│  │ Card Content ←←←   │ 用  │ 编  │ 删  │
│  │                    │ 🟢  │ 🔵  │ 🔴  │
│  └────────────────────┴─────┴─────┴─────┘
│                                         │
│ Long Press:                             │
│  → 弹出快捷菜单 (Context Menu)         │
│  → 震动反馈 (Haptic)                   │
│                                         │
└─────────────────────────────────────────┘
```

### 6.2 录入按钮（中间Tab）交互

```
┌─────────────────────────────────────────┐
│ Add Button (TabBar中间) 交互             │
├─────────────────────────────────────────┤
│                                         │
│ Default:                                │
│  → 56×56 圆形, Primary-500             │
│  → Icon: Plus 24px White               │
│  → Shadow: shadow-md                    │
│                                         │
│ Pressed:                                │
│  → Background: Primary-700              │
│  → Scale: 0.9                           │
│  → Duration: 150ms                      │
│                                         │
│ Action:                                 │
│  → 方案A: 直接跳转扫码页面             │
│  → 方案B: 弹出ActionSheet选择录入方式  │
│                                         │
│ 方案B动画:                              │
│  → 按钮旋转45°变成 ✕                   │
│  → 从按钮位置扇形展开多个选项          │
│  → 背景 overlay 渐显                   │
│                                         │
│  展开后：                               │
│       📷 扫码                           │
│     📸 拍照    🎤 语音                  │
│       ✏️ 手动                           │
│         [✕]   ← 原按钮变关闭           │
│                                         │
└─────────────────────────────────────────┘
```

### 6.3 下拉刷新 & 上拉加载

```
┌─────────────────────────────────────────┐
│ Pull-to-Refresh                          │
├─────────────────────────────────────────┤
│                                         │
│ Pulling (阈值前):                       │
│  → 显示下拉指示器                       │
│  → 箭头随距离旋转                       │
│                                         │
│ Triggered (超过阈值):                   │
│  → 箭头变为Loading动画                  │
│  → 触感反馈                             │
│                                         │
│ Loading:                                │
│  → 自定义Loading动画（家的图标跳动）    │
│  → 文案："正在更新物品信息..."          │
│                                         │
│ Complete:                               │
│  → ✓ 图标                              │
│  → "已是最新"                          │
│  → 回弹隐藏                            │
│                                         │
└─────────────────────────────────────────┘
```

***

## 七、组件变体映射表（Variant Map）

### 7.1 Button 完整变体矩阵

```
┌──────────┬─────────┬─────────┬─────────┬──────────┬──────────┐
│          │ Primary │Secondary│ Outline │  Ghost   │  Danger  │
├──────────┼─────────┼─────────┼─────────┼──────────┼──────────┤
│ Large    │    ✓    │    ✓    │    ✓    │    ✓     │    ✓     │
│ Default  │         │         │         │          │          │
├──────────┼─────────┼─────────┼─────────┼──────────┼──────────┤
│ Large    │    ✓    │    ✓    │    ✓    │    ✓     │    ✓     │
│ Disabled │         │         │         │          │          │
├──────────┼─────────┼─────────┼─────────┼──────────┼──────────┤
│ Medium   │    ✓    │    ✓    │    ✓    │    ✓     │    ✓     │
│ Default  │         │         │         │          │          │
├──────────┼─────────┼─────────┼─────────┼──────────┼──────────┤
│ Medium   │    ✓    │    ✓    │    ✓    │    ✓     │    ✓     │
│ Disabled │         │         │         │          │          │
├──────────┼─────────┼─────────┼─────────┼──────────┼──────────┤
│ Small    │    ✓    │    ✓    │    ✓    │    ✓     │    ✓     │
│ Default  │         │         │         │          │          │
├──────────┼─────────┼─────────┼─────────┼──────────┼──────────┤
│ ... (每种 Size × Variant × State)                             │
└──────────┴─────────┴─────────┴─────────┴──────────┴──────────┘

总变体数：5 Variants × 4 Sizes × 5 States × 4 Icon = 400
(实际通过 Component Properties 管理，无需400个变体)
```

### 7.2 ItemCard 变体矩阵

```
┌────────────────────────────────────────────────────────┐
│ ItemCard Variants                                       │
├────────────┬───────────────────────────────────────────┤
│ Layout     │ Horizontal          │ Vertical            │
├────────────┼─────────────────────┼─────────────────────┤
│ Status     │ ● Normal (green)    │ 正常，一切充足      │
│            │ ● Warning (yellow)  │ 库存偏低/快过期     │
│            │ ● Danger (red)      │ 库存极低/明天过期   │
│            │ ● Expired (gray)    │ 已过期              │
│            │ ● Empty (dashed)    │ 已用完              │
├────────────┼─────────────────────┼─────────────────────┤
│ ShowImage  │ True (有缩略图)     │ False (仅图标)      │
├────────────┼─────────────────────┼─────────────────────┤
│ 使用场景   │                     │                     │
│ Horizontal │ 物品列表默认        │                     │
│ Vertical   │ 网格视图/推荐       │                     │
└────────────┴─────────────────────┴─────────────────────┘
```

***

## 八、Figma 文件组织结构

```
📁 Figma File Structure
│
├── 📄 Cover (封面页)
│
├── 📁 🎨 Design System
│   ├── 📄 Colors (所有颜色样式)
│   ├── 📄 Typography (所有文字样式)
│   ├── 📄 Icons (图标集)
│   ├── 📄 Spacing & Grid (间距网格)
│   └── 📄 Effects (阴影、模糊)
│
├── 📁 🧩 Components
│   ├── 📄 Atoms
│   │   ├── Button
│   │   ├── Input
│   │   ├── Tag / Badge
│   │   ├── ProgressBar
│   │   ├── Icon
│   │   ├── Avatar
│   │   ├── Checkbox / Radio
│   │   ├── Switch / Toggle
│   │   └── Divider
│   │
│   ├── 📄 Molecules
│   │   ├── ItemCard
│   │   ├── AlertCard
│   │   ├── StatCard
│   │   ├── LocationPicker
│   │   ├── QuantityStepper
│   │   ├── SearchBar
│   │   ├── ListItem
│   │   ├── TimelineItem
│   │   ├── ImageUploader
│   │   └── FormField (Label+Input组合)
│   │
│   └── 📄 Organisms
│       ├── NavBar
│       ├── TabBar
│       ├── ItemList
│       ├── SpaceGrid
│       ├── CategoryTabs
│       ├── ActionSheet
│       ├── Modal / Dialog
│       ├── Toast / Snackbar
│       └── BottomActionBar
│
├── 📁 📱 Pages (完整页面)
│   ├── 📄 1. Home (首页)
│   ├── 📄 2. Item List (物品列表)
│   ├── 📄 3. Item Detail (物品详情)
│   ├── 📄 4. Add Item - Entry (录入入口)
│   ├── 📄 5. Add Item - Scan (扫码)
│   ├── 📄 6. Add Item - Form (表单)
│   ├── 📄 7. Location Management (位置管理)
│   ├── 📄 8. Location Detail (位置详情)
│   ├── 📄 9. Alert Center (提醒中心)
│   ├── 📄 10. Shopping List (购物清单)
│   ├── 📄 11. Statistics (数据统计)
│   ├── 📄 12. Profile (我的)
│   ├── 📄 13. Search (搜索)
│   ├── 📄 14. Inventory Check (盘点)
│   └── 📄 15. Settings (设置)
│
├── 📁 🔄 Flows (交互流程)
│   ├── 📄 Flow 1: 扫码录入完整流程
│   ├── 📄 Flow 2: 记录使用流程
│   ├── 📄 Flow 3: 处理过期提醒流程
│   ├── 📄 Flow 4: 查找物品流程
│   └── 📄 Flow 5: 生成购物清单流程
│
├── 📁 ✨ Prototyping (原型交互)
│   └── 📄 Interactive Prototype
│
└── 📁 📋 Specs (标注/交付)
    ├── 📄 Developer Handoff Notes
    └── 📄 Animation Specs
```

***

## 九、原型交互规格（Prototype Specs）

### 9.1 页面转场动画

```
┌────────────────────────────────────────────────────────┐
│ 交互          │ 动画类型       │ 持续时间  │ 缓动曲线  │
├───────────────┼───────────────┼──────────┼───────────┤
│ Tab切换       │ 渐隐渐显      │ 200ms    │ ease-out  │
│ Push新页面    │ 从右侧滑入    │ 300ms    │ ease-out  │
│ 返回上一页    │ 向右侧滑出    │ 250ms    │ ease-in   │
│ 弹出Modal     │ 从底部上滑    │ 350ms    │ spring    │
│ 关闭Modal     │ 向底部下滑    │ 250ms    │ ease-in   │
│ 弹出Toast     │ 从顶部下滑    │ 200ms    │ spring    │
│ ActionSheet   │ 从底部上滑    │ 300ms    │ spring    │
│ Dialog        │ 缩放+渐显     │ 200ms    │ ease-out  │
└───────────────┴───────────────┴──────────┴───────────┘
```

### 9.2 微交互动画

```
┌────────────────────────────────────────────────────────┐
│ 交互场景               │ 动画描述                       │
├────────────────────────┼───────────────────────────────┤
│ 扫码成功               │ 取景框绿色闪烁 + ✓ 图标弹出    │
│                        │ + 震动反馈                     │
├────────────────────────┼───────────────────────────────┤
│ 物品入库成功           │ 物品卡片从底部弹入列表 +       │
│                        │ 数字+1 动画                   │
├────────────────────────┼───────────────────────────────┤
│ 标记用完               │ 卡片向左滑出 + 列表收缩       │
│                        │ + "已用完" 标签浮现           │
├────────────────────────┼───────────────────────────────┤
│ 删除物品               │ 卡片向上缩小消失 +            │
│                        │ 底部显示 "撤销" Toast         │
├────────────────────────┼───────────────────────────────┤
│ 数量变化               │ 数字滚动切换动画               │
│                        │ (老数字上移消失,新数字下移出现) │
├────────────────────────┼───────────────────────────────┤
│ 进度条变化             │ 宽度平滑过渡 300ms +          │
│                        │ 颜色渐变(如果跨越阈值)        │
├────────────────────────┼───────────────────────────────┤
│ 下拉刷新               │ 自定义Lottie: 小房子呼吸动画  │
├────────────────────────┼───────────────────────────────┤
│ 空状态                 │ 插画轻微浮动呼吸动画           │
└────────────────────────┴───────────────────────────────┘
```

***

## 十、响应式 & 适配说明

### 10.1 设备适配

```
┌────────────────────────────────────────────┐
│ 设计基准：iPhone 13 (390×844)              │
│                                            │
│ 适配设备：                                  │
│ ├── iPhone SE (375×667) - 小屏适配        │
│ ├── iPhone 13 (390×844) - 基准            │
│ ├── iPhone 13 Pro Max (428×926) - 大屏    │
│ ├── iPad Mini (768×1024) - 平板适配       │
│ └── iPad Pro (1024×1366) - 大平板         │
│                                            │
│ 适配策略：                                  │
│ • 手机端：单列布局，底部TabBar            │
│ • 平板端：侧边栏导航 + 主内容区           │
│ • 卡片网格：手机2列，平板3-4列            │
│                                            │
└────────────────────────────────────────────┘
```

### 10.2 Auto Layout 规则

```
┌────────────────────────────────────────────┐
│ 组件响应规则：                              │
│                                            │
│ 页面级：                                    │
│  → 宽度 Fill Container                    │
│  → 内容区左右 Padding: 16px               │
│                                            │
│ 卡片级：                                    │
│  → Width: Fill Container                   │
│  → Height: Hug Content                    │
│  → 内部 Padding: 16px                     │
│                                            │
│ 网格级：                                    │
│  → Grid: Auto Layout Wrap                 │
│  → Min Width: 160px per item              │
│  → Gap: 12px                              │
│                                            │
│ 文字级：                                    │
│  → 标题: 单行，超出省略号                  │
│  → 描述: 最多2行，超出省略号               │
│  → 价格/数字: 固定宽度，右对齐             │
│                                            │
└────────────────────────────────────────────┘
```

***

## 十一、设计规范补充

### 11.1 空状态设计

```
每个列表/页面都需要空状态：

物品列表空状态:
┌─────────────────────────────────────────┐
│            [插画: 空箱子]               │
│                                         │
│          还没有添加物品呢               │
│    扫一扫或拍一拍，快速录入家中物品     │
│                                         │
│       [  📷 扫码添加第一件  ]           │
└─────────────────────────────────────────┘

搜索无结果:
┌─────────────────────────────────────────┐
│           [插画: 放大镜找不到]           │
│                                         │
│       没有找到 "XXX" 相关物品           │
│         试试其他关键词？                │
│                                         │
│       [  + 手动添加"XXX"  ]            │
└─────────────────────────────────────────┘

提醒为空:
┌─────────────────────────────────────────┐
│           [插画: 悠闲的猫]              │
│                                         │
│         一切安好，没有待处理提醒         │
│       物品都在保质期内，库存充足 😊     │
└─────────────────────────────────────────┘
```

### 11.2 骨架屏 (Skeleton)

```
加载状态使用骨架屏替代转圈：

┌─────────────────────────────────────────┐
│ ┌──────┐  ████████████████              │
│ │ ░░░░ │  ████████████                  │
│ │ ░░░░ │  ████████                      │
│ └──────┘  ━━━━━━━━━━━━━━━━━━━          │
├─────────────────────────────────────────│
│ ┌──────┐  ████████████████              │
│ │ ░░░░ │  ████████████                  │
│ │ ░░░░ │  ████████                      │
│ └──────┘  ━━━━━━━━━━━━━━━━━━━          │
├─────────────────────────────────────────│
│ ┌──────┐  ████████████████              │
│ │ ░░░░ │  ████████████                  │
│ │ ░░░░ │  ████████                      │
│ └──────┘  ━━━━━━━━━━━━━━━━━━━          │
└─────────────────────────────────────────┘

骨架屏动画：
- 浅灰色块 shimmer 效果
- 从左到右光泽扫过
- 周期: 1.5s
- 颜色: Gray-200 → Gray-100 → Gray-200
```

### 11.3 手势操作说明

```
┌─────────────────────────────────────────────────────┐
│ 手势          │ 使用场景              │ 反馈         │
├───────────────┼───────────────────────┼──────────────┤
│ 单击          │ 进入详情/选择         │ 涟漪/高亮    │
│ 长按          │ 弹出上下文菜单        │ 震动反馈     │
│ 左滑          │ 显示快捷操作(使用/删除)│ 操作按钮滑出 │
│ 右滑          │ 返回上一页            │ 页面跟随手势 │
│ 下拉          │ 刷新数据              │ Loading动画  │
│ 上拉          │ 加载更多              │ 列表追加     │
│ 双击          │ 快速标记使用1件       │ 数字-1动画   │
│ 捏合          │ 列表/网格视图切换     │ 布局变化动画 │
└───────────────┴───────────────────────┴──────────────┘
```

***

## 十二、交付清单 Checklist

```
┌─────────────────────────────────────────┐
│ ✅ Figma 交付物清单                      │
├─────────────────────────────────────────┤
│                                         │
│ □ Design Tokens 完整定义                │
│   □ Colors (Light Mode)                │
│   □ Colors (Dark Mode - 如需)          │
│   □ Typography                         │
│   □ Spacing                            │
│   □ Border Radius                      │
│   □ Shadows                            │
│                                         │
│ □ Component Library 组件库              │
│   □ 所有 Atoms (含全部变体)            │
│   □ 所有 Molecules (含全部变体)        │
│   □ 所有 Organisms (含全部变体)        │
│   □ 组件文档说明                       │
│                                         │
│ □ Page Designs 页面设计稿               │
│   □ 全部15个页面 (Default State)       │
│   □ 各页面的空状态                     │
│   □ 各页面的Loading状态                │
│   □ 各页面的Error状态                  │
│   □ 关键弹窗/浮层                      │
│                                         │
│ □ Prototype 可交互原型                  │
│   □ 主流程可点击走通                   │
│   □ 关键微交互说明                     │
│   □ 转场动画标注                       │
│                                         │
│ □ Developer Handoff 开发标注            │
│   □ 所有页面开启 Dev Mode              │
│   □ 标注特殊间距/逻辑                  │
│   □ 动画规格文档                       │
│   □ 切图资源导出 (SVG/PNG@2x@3x)      │
│                                         │
└─────────────────────────────────────────┘
```

***

这份文档可以直接作为 Figma 组件库搭建的参考蓝图。需要我针对某个具体组件再深入展开（如更详细的 Auto Layout 参数、具体 Figma 操作步骤），或者为某些组件提供更视觉化的描述吗？
