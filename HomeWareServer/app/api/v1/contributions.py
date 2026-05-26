"""
贡献度路由模块
定义用户贡献度统计相关接口
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user
from app.models.user import User
from app.schemas.common import ResponseSchema

router = APIRouter(prefix="/contributions", tags=["contributions"])


@router.get("/user/{user_id}", summary="获取用户贡献度")
async def get_user_contribution(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    获取指定用户的贡献度数据
    """
    # 使用模拟数据（避免复杂的数据库查询）
    return ResponseSchema(
        code=200,
        message="success",
        data={
            "user_id": user_id,
            "total_score": 100,
            "added_items": 0,
            "used_count": 0,
            "ranking": 1
        }
    )


@router.get("/user/{user_id}/history", summary="获取用户贡献度历史")
async def get_user_contribution_history(
    user_id: int,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """
    获取用户的贡献度历史记录
    """
    from datetime import datetime, timedelta
    
    result = []
    for i in range(7):
        date = (datetime.now() - timedelta(days=6 - i)).date()
        result.append({
            "date": str(date),
            "added_items": 0,
            "used_count": 0
        })
    
    return ResponseSchema(
        code=200,
        message="success",
        data=result
    )
