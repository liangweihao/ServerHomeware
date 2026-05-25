# Server Phase 6：文件上传 & 高级功能 - 实施计划

## 1. 需求分析

根据 Phase 6 文档，需要实现以下功能：

### 当前已有功能

| 功能 | 文件 | 状态 |
|------|------|------|
| 基础图片上传 | `app/api/v1/upload.py` | ⚠️ 简单实现，需增强 |
| 静态文件服务 | `app/main.py` | ✅ 已配置 /uploads 挂载 |
| 健康检查基础 | `app/main.py` | ✅ 简单实现 |
| 用户基础 API | `app/api/v1/users.py` | ✅ 部分实现 |
| 条码查询 | `app/api/v1/items.py` | ⚠️ 仅按条码查询物品 |

### 待实现功能

| 模块 | 功能 |
|------|------|
| 文件上传 | 图片压缩、批量上传、格式转换(WebP)、删除 |
| 条码查询 | 增强条码查询服务，支持公开API查询 |
| 数据导出 | CSV导出、JSON完整导出、文件下载 |
| WebSocket | 实时通知推送（可选增强） |
| 用户设置 | 完整用户信息、密码修改、账户注销 |
| 健康检查 | 数据库/Redis连接状态、版本、运行时间 |
| API限流 | 使用 slowapi + Redis 实现限流 |

---

## 2. 文件清单

### 2.1 新增文件

| 文件路径 | 说明 |
|----------|------|
| `app/services/upload_service.py` | 图片上传服务（压缩、格式转换） |
| `app/services/export_service.py` | 数据导出服务 |
| `app/services/websocket_manager.py` | WebSocket 连接管理器 |
| `app/api/v1/export.py` | 数据导出 API |
| `app/api/v1/barcode.py` | 条码查询 API |
| `app/api/v1/health.py` | 健康检查 API |
| `app/api/v1/ws.py` | WebSocket API |
| `app/core/limiter.py` | 限流配置 |
| `app/core/security.py` | 安全工具（密码强度校验等） |

### 2.2 修改文件

| 文件路径 | 修改内容 |
|----------|----------|
| `app/api/v1/upload.py` | 增强图片上传（压缩、批量、删除） |
| `app/api/v1/users.py` | 添加完整用户信息、密码修改、账户注销 |
| `app/main.py` | 注册新路由、配置限流中间件 |
| `app/config.py` | 添加限流相关配置 |

---

## 3. 详细实现步骤

### 步骤 1：增强配置

**文件**: `app/config.py`

```python
class Settings(BaseSettings):
    # 限流配置
    RATE_LIMIT_STORAGE_URL: str = "redis://localhost:6379/1"
    LOGIN_RATE_LIMIT: str = "10/minute"
    REGISTER_RATE_LIMIT: str = "5/hour"
    DEFAULT_RATE_LIMIT: str = "60/minute"
    UPLOAD_RATE_LIMIT: str = "20/minute"
    
    # 图片处理配置
    MAX_IMAGE_WIDTH: int = 1080
    IMAGE_QUALITY: int = 85
```

### 步骤 2：创建上传服务

**文件**: `app/services/upload_service.py`

```python
class UploadService:
    """文件上传服务"""

    async def upload_image(self, file, family_id: int) -> str:
        """
        上传并处理图片
        - 校验文件类型和大小
        - 自动旋转（EXIF）
        - 等比缩放到最大1080px
        - 转为WebP格式
        - 保存到 {UPLOAD_DIR}/{family_id}/{timestamp}_{uuid}.webp
        """

    async def upload_images(self, files, family_id: int) -> List[str]:
        """批量上传图片（最多5张）"""

    async def delete_image(self, url: str) -> bool:
        """删除图片文件"""
```

### 步骤 3：创建导出服务

**文件**: `app/services/export_service.py`

```python
class ExportService:
    """数据导出服务"""

    async def export_items_csv(self, family_id: int, status_filter: List[int]) -> str:
        """
        导出物品为CSV格式
        列：名称、品牌、分类、位置、单价、数量、剩余、单位、购买日期、过期日期、状态
        返回下载路径
        """

    async def export_items_json(self, family_id: int) -> Dict:
        """
        导出完整家庭数据为JSON格式
        包含：物品、分类、位置、使用记录
        """

    async def get_export_file(self, filename: str) -> Optional[str]:
        """获取导出文件路径（验证存在且未过期）"""
```

### 步骤 4：创建 WebSocket 管理器

**文件**: `app/services/websocket_manager.py`

```python
class WebSocketManager:
    """WebSocket 连接管理器"""

    def __init__(self):
        self.active_connections: Dict[int, List[WebSocket]] = {}  # family_id -> connections

    async def connect(self, websocket: WebSocket, family_id: int):
        """建立连接"""

    def disconnect(self, websocket: WebSocket, family_id: int):
        """断开连接"""

    async def broadcast(self, family_id: int, message: Dict):
        """向同家庭所有连接广播消息"""

    async def send_personal_message(self, websocket: WebSocket, message: Dict):
        """发送个人消息"""
```

### 步骤 5：创建安全工具

**文件**: `app/core/security.py`

```python
def validate_password_strength(password: str) -> Tuple[bool, str]:
    """
    验证密码强度
    - 至少8位
    - 包含字母和数字
    """

def generate_token(length: int = 32) -> str:
    """生成随机token"""
```

### 步骤 6：创建限流配置

**文件**: `app/core/limiter.py`

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address, storage_uri=settings.RATE_LIMIT_STORAGE_URL)
```

### 步骤 7：增强上传 API

**文件**: `app/api/v1/upload.py`

```python
@router.post("/image", summary="上传图片")
async def upload_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.post("/images", summary="批量上传图片")
async def upload_images(
    files: List[UploadFile] = File(...),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.delete("/image", summary="删除图片")
async def delete_image(
    url: str = Body(..., embed=True),
    current_user: User = Depends(get_current_user)
)
```

### 步骤 8：创建条码查询 API

**文件**: `app/api/v1/barcode.py`

```python
router = APIRouter(prefix="/barcode", tags=["barcode"])

@router.get("/{code}", summary="查询条码")
async def query_barcode(
    code: str,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    优先查本地数据库，然后查公开API
    """
```

### 步骤 9：创建导出 API

**文件**: `app/api/v1/export.py`

```python
router = APIRouter(prefix="/export", tags=["export"])

@router.post("/items", summary="导出物品CSV")
async def export_items_csv(
    request: ExportRequest,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.post("/items/json", summary="导出物品JSON")
async def export_items_json(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.get("/download/{filename}", summary="下载导出文件")
async def download_export_file(
    filename: str
)
```

### 步骤 10：创建 WebSocket API

**文件**: `app/api/v1/ws.py`

```python
router = APIRouter(prefix="/ws", tags=["websocket"])

@router.websocket("/notifications")
async def websocket_endpoint(
    websocket: WebSocket,
    token: str = Query(...)
):
    """WebSocket 实时通知"""
```

### 步骤 11：创建健康检查 API

**文件**: `app/api/v1/health.py`

```python
router = APIRouter(prefix="/health", tags=["health"])

@router.get("", summary="健康检查")
async def health_check():
    """无需认证的健康检查接口"""

@router.get("/admin/stats", summary="系统统计（仅开发环境）")
async def admin_stats(
    db: AsyncSession = Depends(get_db)
):
    """系统级统计信息"""
```

### 步骤 12：增强用户 API

**文件**: `app/api/v1/users.py`

```python
@router.get("/me", summary="获取完整用户信息")
async def get_current_user_full(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
)

@router.put("/me", summary="更新用户信息")
async def update_user_info(
    request: UpdateUserRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
)

@router.delete("/me", summary="注销账户")
async def delete_account(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
)
```

### 步骤 13：更新主应用

**文件**: `app/main.py`

```python
# 注册限流
from app.core.limiter import limiter, _rate_limit_exceeded_handler
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# 注册新路由
from app.api.v1 import barcode_router, export_router, health_router, ws_router
app.include_router(barcode_router)
app.include_router(export_router)
app.include_router(health_router)
```

---

## 4. 代码规范

遵循 `/Users/lwh/Desktop/Project/ServerHomeWare/doc/rules/codestyle.mdc`：

- ✅ 所有新增代码添加注释/注解
- ✅ 核心业务代码（服务层、任务）添加日志
- ✅ 关键流程：INFO 日志
- ✅ 异常/WARN 情况：WARNING/ERROR 日志

---

## 5. 验收标准

| 验收项 | 验证方式 |
|--------|----------|
| 图片上传成功，压缩和格式转换正确 | API 测试 |
| 上传后图片可通过URL正常访问 | 浏览器访问 |
| 批量上传最多5张限制 | API 测试 |
| 删除图片成功 | API 测试 |
| 条码查询：已有物品返回信息 | API 测试 |
| CSV导出文件格式正确 | 下载后用Excel打开 |
| JSON完整导出包含所有家庭数据 | API 测试 |
| WebSocket连接正常 | 客户端测试 |
| 用户信息修改/密码修改正常 | API 测试 |
| 账户注销逻辑正确 | API 测试 |
| 健康检查接口正确返回服务状态 | API 测试 |
| 限流生效：超出频率返回429 | API 测试 |
| 上传非法文件类型被拒绝 | API 测试 |

---

## 6. 注意事项

1. **图片处理**: 使用 Pillow 库，注意 EXIF 方向信息处理
2. **文件存储**: 按家庭ID分目录存储，便于数据隔离
3. **导出文件**: 设置合理的过期时间（如1小时），定期清理临时文件
4. **WebSocket**: 实现心跳检测，断线自动清理连接
5. **限流**: 使用 Redis 存储限流状态，支持分布式部署
6. **安全**: 文件上传时校验文件头，防止伪造扩展名攻击
