"""
通用响应格式模块
定义统一的响应结构
"""
from typing import Generic, List, Optional, TypeVar

from pydantic import BaseModel

T = TypeVar("T")


class ResponseSchema(BaseModel):
    """通用响应格式"""
    
    code: int
    message: str
    data: Optional[T] = None
    
    model_config = {"arbitrary_types_allowed": True}


class PaginatedData(BaseModel, Generic[T]):
    """分页数据结构"""
    
    items: List[T]
    total: int
    page: int
    page_size: int
    pages: int


class PaginatedResponseSchema(BaseModel, Generic[T]):
    """分页响应格式"""
    
    code: int
    message: str
    data: PaginatedData[T]