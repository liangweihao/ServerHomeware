"""
数据访问层基类模块
提供通用 CRUD 操作，自动处理 family_id 数据隔离
"""
from typing import Any, Dict, Generic, List, Optional, Type, TypeVar

from sqlalchemy import delete, func, select, update
from sqlalchemy.ext.asyncio import AsyncSession

ModelType = TypeVar("ModelType")


class BaseRepository(Generic[ModelType]):
    """通用CRUD仓库基类，支持 family_id 数据隔离"""
    
    def __init__(self, db: AsyncSession, model: Type[ModelType]):
        self.db = db
        self.model = model
    
    async def get_by_id(self, id: int, family_id: Optional[int] = None) -> Optional[ModelType]:
        """根据ID获取单条记录，支持 family_id 过滤"""
        query = select(self.model).filter(self.model.id == id)
        if family_id is not None and hasattr(self.model, "family_id"):
            query = query.filter(self.model.family_id == family_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
    
    async def get_all(self, family_id: Optional[int] = None) -> List[ModelType]:
        """获取所有记录，支持 family_id 过滤"""
        query = select(self.model)
        if family_id is not None and hasattr(self.model, "family_id"):
            query = query.filter(self.model.family_id == family_id)
        result = await self.db.execute(query)
        return result.scalars().all()
    
    async def get_list(
        self,
        filters: Optional[Dict[str, Any]] = None,
        page: int = 1,
        page_size: int = 20,
        order_by: Optional[str] = None,
        sort_order: str = "desc",
        family_id: Optional[int] = None
    ) -> Dict[str, Any]:
        """
        分页查询记录
        :param filters: 过滤条件字典
        :param page: 页码
        :param page_size: 每页大小
        :param order_by: 排序字段
        :param sort_order: 排序方向(asc/desc)
        :param family_id: 家庭ID(数据隔离)
        :return: {"items": [...], "total": int, "page": int, "page_size": int, "pages": int}
        """
        query = select(self.model)
        
        # family_id 过滤
        if family_id is not None and hasattr(self.model, "family_id"):
            query = query.filter(self.model.family_id == family_id)
        
        # 其他过滤条件
        if filters:
            for key, value in filters.items():
                if hasattr(self.model, key):
                    field = getattr(self.model, key)
                    if value is not None:
                        query = query.filter(field == value)
        
        # 排序
        if order_by and hasattr(self.model, order_by):
            sort_field = getattr(self.model, order_by)
            query = query.order_by(sort_field.desc() if sort_order == "desc" else sort_field.asc())
        
        # 统计总数
        count_query = select(func.count()).select_from(query.subquery())
        total = await self.db.scalar(count_query)
        
        # 分页
        offset = (page - 1) * page_size
        query = query.offset(offset).limit(page_size)
        
        result = await self.db.execute(query)
        
        pages = (total + page_size - 1) // page_size if total else 0
        
        return {
            "items": result.scalars().all(),
            "total": total,
            "page": page,
            "page_size": page_size,
            "pages": pages
        }
    
    async def create(self, obj_in: Dict[str, Any]) -> ModelType:
        """创建新记录"""
        obj = self.model(**obj_in)
        self.db.add(obj)
        await self.db.commit()
        await self.db.refresh(obj)
        return obj
    
    async def update(self, id: int, obj_in: Dict[str, Any], family_id: Optional[int] = None) -> Optional[ModelType]:
        """更新记录，支持 family_id 验证"""
        query = select(self.model).filter(self.model.id == id)
        if family_id is not None and hasattr(self.model, "family_id"):
            query = query.filter(self.model.family_id == family_id)
        
        result = await self.db.execute(query)
        obj = result.scalar_one_or_none()
        
        if obj:
            for key, value in obj_in.items():
                setattr(obj, key, value)
            await self.db.commit()
            await self.db.refresh(obj)
        return obj
    
    async def delete(self, id: int, family_id: Optional[int] = None, soft_delete: bool = True) -> bool:
        """
        删除记录
        :param id: 记录ID
        :param family_id: 家庭ID(数据隔离)
        :param soft_delete: 是否软删除(is_active=False)
        :return: 是否删除成功
        """
        if soft_delete and hasattr(self.model, "is_active"):
            # 软删除
            query = update(self.model).filter(self.model.id == id)
            if family_id is not None and hasattr(self.model, "family_id"):
                query = query.filter(self.model.family_id == family_id)
            query = query.values(is_active=False)
            result = await self.db.execute(query)
        else:
            # 物理删除
            query = delete(self.model).filter(self.model.id == id)
            if family_id is not None and hasattr(self.model, "family_id"):
                query = query.filter(self.model.family_id == family_id)
            result = await self.db.execute(query)
        
        await self.db.commit()
        return result.rowcount > 0
    
    async def hard_delete(self, id: int, family_id: Optional[int] = None) -> bool:
        """物理删除记录"""
        return await self.delete(id, family_id, soft_delete=False)
    
    async def get_by_field(self, field: str, value: Any, family_id: Optional[int] = None) -> Optional[ModelType]:
        """根据字段获取单条记录，支持 family_id 过滤"""
        query = select(self.model).filter(getattr(self.model, field) == value)
        if family_id is not None and hasattr(self.model, "family_id"):
            query = query.filter(self.model.family_id == family_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none()
    
    async def get_multi_by_field(self, field: str, value: Any, family_id: Optional[int] = None) -> List[ModelType]:
        """根据字段获取多条记录，支持 family_id 过滤"""
        query = select(self.model).filter(getattr(self.model, field) == value)
        if family_id is not None and hasattr(self.model, "family_id"):
            query = query.filter(self.model.family_id == family_id)
        result = await self.db.execute(query)
        return result.scalars().all()
    
    async def exists_by_field(self, field: str, value: Any, family_id: Optional[int] = None) -> bool:
        """检查字段值是否存在，支持 family_id 过滤"""
        query = select(self.model.id).filter(getattr(self.model, field) == value)
        if family_id is not None and hasattr(self.model, "family_id"):
            query = query.filter(self.model.family_id == family_id)
        result = await self.db.execute(query)
        return result.scalar_one_or_none() is not None