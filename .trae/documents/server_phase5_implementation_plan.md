# Server Phase 5：购物清单 & 统计 & 预测 - 实施计划

## 1. 需求分析

根据 Phase 5 文档，需要实现以下功能：

### 当前已有功能

| 功能 | 文件 | 状态 |
|------|------|------|
| 购物清单基础 CRUD | `app/api/v1/shopping.py` | ⚠️ 部分实现 |
| 统计基础接口 | `app/api/v1/statistics.py` | ⚠️ 仅占位 |
| ShoppingItem 模型 | `app/models/shopping.py` | ✅ 已完成 |
| ShoppingRepository | `app/repositories/shopping_repo.py` | ⚠️ 基础实现 |
| Item 模型（含预测字段） | `app/models/item.py` | ✅ 已完成 |

### 待实现功能

| 模块 | 功能 |
|------|------|
| 购物清单 API | 分页、状态筛选、一键入库、分享文本、推荐 |
| 统计 API | 概览、消费趋势、分类占比、浪费统计、消耗排行 |
| 预测服务 | 日均消耗计算、预计用完日期、批量更新 |
| 智能推荐 | 实时购物推荐计算 |

---

## 2. 文件清单

### 2.1 新增文件

| 文件路径 | 说明 |
|----------|------|
| `app/services/prediction_service.py` | 消耗预测服务 |
| `app/services/shopping_service.py` | 购物清单服务 |
| `app/services/statistics_service.py` | 统计服务 |
| `app/schemas/prediction.py` | 预测相关 Schema |
| `app/schemas/statistics.py` | 统计相关 Schema |

### 2.2 修改文件

| 文件路径 | 修改内容 |
|----------|----------|
| `app/api/v1/shopping.py` | 增强购物清单 API（分页、状态筛选、一键入库、分享、推荐） |
| `app/api/v1/statistics.py` | 实现完整统计接口 |
| `app/api/v1/items.py` | 添加物品预测端点 |
| `app/repositories/shopping_repo.py` | 添加分页查询、批量更新方法 |
| `app/repositories/item_repo.py` | 添加预测相关查询 |
| `app/repositories/usage_record_repo.py` | 添加统计查询方法 |
| `app/schemas/shopping.py` | 扩展请求/响应模型 |

---

## 3. 详细实现步骤

### 步骤 1：扩展购物清单 Schema

**文件**: `app/schemas/shopping.py`

```python
class CreateShoppingItemRequest(BaseModel):
    name: str
    quantity: float = 1.0
    unit: str = "个"
    estimated_price: Optional[float] = None
    related_item_id: Optional[int] = None
    notes: Optional[str] = None

class UpdateShoppingItemRequest(BaseModel):
    name: Optional[str] = None
    quantity: Optional[float] = None
    unit: Optional[str] = None
    estimated_price: Optional[float] = None
    priority: Optional[int] = None

class PurchaseRequest(BaseModel):
    actual_price: Optional[float] = None

class ToItemRequest(BaseModel):
    location_id: Optional[int] = None
    expiry_date: Optional[date] = None

class ShoppingItemWithRelatedResponse(BaseModel):
    id: int
    name: str
    quantity: float
    unit: str
    estimated_price: Optional[float]
    actual_price: Optional[float]
    related_item_id: Optional[int]
    related_item_name: Optional[str]
    is_purchased: bool
    is_auto_generated: bool
    priority: int
    purchased_at: Optional[datetime]
    purchased_by: Optional[int]
    created_at: datetime
    # ... 其他字段

class ShareTextResponse(BaseModel):
    text: str
    total_estimated: float

class ShoppingRecommendationResponse(BaseModel):
    item_id: int
    item_name: str
    reason: str
    priority: str
    suggested_quantity: int
    suggested_unit: str
    last_price: Optional[float]
    last_channel: Optional[str]
```

### 步骤 2：创建预测 Schema

**文件**: `app/schemas/prediction.py`

```python
class ItemPredictionResponse(BaseModel):
    avg_daily_consumption: float
    predicted_empty_date: Optional[str]
    days_until_empty: Optional[int]
    confidence: str  # low/medium/high
    should_repurchase: bool
    usage_history: List[dict]

class ConsumptionHistoryItem(BaseModel):
    date: str
    quantity: float
    operator: Optional[str]
```

### 步骤 3：创建统计 Schema

**文件**: `app/schemas/statistics.py`

```python
class PeriodRange(BaseModel):
    start: str
    end: str

class ExpenseData(BaseModel):
    total: float
    previous_total: float
    trend_percentage: float
    trend_direction: str

class InventoryData(BaseModel):
    total_items: int
    new_items: int
    consumed_items: int
    warning_items: int

class OverviewResponse(BaseModel):
    period: str
    date_range: PeriodRange
    expense: ExpenseData
    inventory: InventoryData

class ExpenseTrendItem(BaseModel):
    month: str
    amount: float

class CategoryBreakdownItem(BaseModel):
    category_id: int
    name: str
    color: str
    amount: float
    percentage: float

class WasteItem(BaseModel):
    name: str
    price: float
    expired_at: str
    reason: str

class WasteResponse(BaseModel):
    total_count: int
    total_amount: float
    items: List[WasteItem]
    suggestion: str

class ConsumptionRankingItem(BaseModel):
    item_name: str
    total_consumed: float
    unit: str
    total_cost: float
```

### 步骤 4：创建预测服务

**文件**: `app/services/prediction_service.py`

```python
class PredictionService:
    """消耗预测服务"""

    async def calculate_avg_daily_consumption(self, item_id: int) -> float:
        """
        计算日均消耗量
        算法：
        1. 查询该物品所有 type=1(使用) 的 usage_records，按 created_at 排序
        2. 如果记录 < 2 条：
           - consumed = purchase_quantity - current_quantity
           - days = (today - item.created_at).days
           - 如果 days <= 0：返回 0
           - 返回 consumed / days
        3. 如果记录 >= 2 条：加权平均法
        """

    async def predict_empty_date(self, item_id: int) -> Optional[date]:
        """预测物品用完日期"""

    async def get_prediction(self, item_id: int) -> dict:
        """获取物品预测信息"""

    async def batch_update_predictions(self, family_id: Optional[int] = None):
        """批量更新所有物品的预测数据"""
```

### 步骤 5：创建购物清单服务

**文件**: `app/services/shopping_service.py`

```python
class ShoppingService:
    """购物清单服务"""

    async def get_shopping_list(
        self,
        family_id: int,
        status: str = "all",
        page: int = 1,
        page_size: int = 20
    ) -> dict:
        """获取购物清单（分页）"""

    async def create_shopping_item(
        self,
        family_id: int,
        user_id: int,
        name: str,
        quantity: float = 1,
        unit: str = "件",
        estimated_price: Optional[float] = None,
        related_item_id: Optional[int] = None
    ) -> ShoppingItem:
        """创建购物项"""

    async def mark_as_purchased(
        self,
        item_id: int,
        user_id: int,
        actual_price: Optional[float] = None
    ) -> dict:
        """标记为已购买，返回是否需要提示入库"""

    async def to_item(
        self,
        shopping_item_id: int,
        user_id: int,
        location_id: Optional[int] = None,
        expiry_date: Optional[date] = None
    ) -> Item:
        """从已购物品一键创建入库"""

    async def mark_all_purchased(self, family_id: int, user_id: int) -> int:
        """全部标记已购买"""

    async def generate_share_text(self, family_id: int) -> dict:
        """生成分享文本"""

    async def get_recommendations(self, family_id: int) -> list:
        """获取智能购物推荐"""
```

### 步骤 6：创建统计服务

**文件**: `app/services/statistics_service.py`

```python
class StatisticsService:
    """统计服务"""

    async def get_overview(
        self,
        family_id: int,
        period: str = "month",
        date: Optional[str] = None
    ) -> dict:
        """获取统计概览"""

    async def get_expense_trend(
        self,
        family_id: int,
        months: int = 6
    ) -> list:
        """获取消费趋势"""

    async def get_category_breakdown(
        self,
        family_id: int,
        period: str = "month",
        date: Optional[str] = None
    ) -> list:
        """获取分类占比"""

    async def get_waste_statistics(
        self,
        family_id: int,
        period: str = "month",
        date: Optional[str] = None
    ) -> dict:
        """获取浪费统计"""

    async def get_consumption_ranking(
        self,
        family_id: int,
        period: str = "month",
        limit: int = 10
    ) -> list:
        """获取消耗排行"""
```

### 步骤 7：增强购物清单 API

**文件**: `app/api/v1/shopping.py`

```python
@router.get("", summary="获取购物清单")
async def get_shopping_list(
    status: str = Query("all", description="pending/purchased/all"),
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    ...
)

@router.post("", summary="添加购物项")
async def create_shopping_item(
    request: CreateShoppingItemRequest,
    ...
)

@router.put("/{id}/purchase", summary="标记已购买")
async def mark_as_purchased(
    id: int,
    request: PurchaseRequest = None,
    ...
)

@router.post("/{id}/to-item", summary="一键入库")
async def to_item(
    id: int,
    request: ToItemRequest = None,
    ...
)

@router.put("/purchase-all", summary="全部标记已购买")
async def mark_all_purchased(...)

@router.get("/share-text", summary="生成分享文本")
async def get_share_text(...)

@router.get("/recommendations", summary="获取购物推荐")
async def get_recommendations(...)
```

### 步骤 8：实现统计 API

**文件**: `app/api/v1/statistics.py`

```python
@router.get("/overview", summary="获取统计概览")
async def get_overview(
    period: str = Query("month"),
    date: Optional[str] = Query(None),
    ...
)

@router.get("/expense-trend", summary="获取消费趋势")
async def get_expense_trend(
    months: int = Query(6, ge=1, le=24),
    ...
)

@router.get("/category-breakdown", summary="获取分类占比")
async def get_category_breakdown(
    period: str = Query("month"),
    date: Optional[str] = Query(None),
    ...
)

@router.get("/waste", summary="获取浪费统计")
async def get_waste_statistics(
    period: str = Query("month"),
    date: Optional[str] = Query(None),
    ...
)

@router.get("/consumption-ranking", summary="获取消耗排行")
async def get_consumption_ranking(
    period: str = Query("month"),
    limit: int = Query(10, ge=1, le=50),
    ...
)
```

### 步骤 9：添加物品预测 API

**文件**: `app/api/v1/items.py`

```python
@router.get("/{id}/prediction", summary="获取物品预测")
async def get_item_prediction(
    id: int,
    ...
)
```

### 步骤 10：更新定时任务

**文件**: `app/tasks/scheduled_tasks.py`

修改 `update_predictions` 任务，调用 `PredictionService.batch_update_predictions()`

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
| 购物清单 CRUD 完整可用 | API 测试 |
| 标记已购买状态正确更新 | API 测试 |
| 一键入库从历史物品复制信息 | API 测试 |
| 分享文本格式正确 | API 测试 |
| 统计概览数据准确 | API 测试 |
| 消费趋势数据可用于折线图 | API 测试 |
| 分类占比数据可用于饼图 | API 测试 |
| 浪费统计正确关联丢弃记录 | API 测试 |
| 消耗排行正确聚合 | API 测试 |
| 预测算法输出合理的日均消耗和预计日期 | API 测试 |
| 购物推荐逻辑正确，优先级分明 | API 测试 |
| 批量更新预测任务正常执行 | Celery 日志 |

---

## 6. 注意事项

1. **日期处理**: 所有日期使用 Asia/Shanghai 时区
2. **分页一致性**: 保持与其他 API 一致的分页参数命名
3. **价格计算**: 注意精度问题，使用 Decimal 进行计算
4. **性能优化**: 统计查询涉及大量数据时考虑添加索引
