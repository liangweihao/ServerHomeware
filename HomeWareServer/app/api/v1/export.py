"""
数据导出路由模块
定义数据导出相关接口
"""
import os

from fastapi import APIRouter, Depends
from fastapi.responses import FileResponse
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.services.export_service import ExportService

router = APIRouter(prefix="/export", tags=["export"])


@router.post("/items", summary="导出物品CSV")
async def export_items_csv(
    status_filter: Optional[List[int]] = None,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    导出当前家庭物品为CSV文件
    
    - status_filter: 状态筛选列表（可选），0=使用中, 1=用完, 2=过期, 3=丢弃
    - 返回：下载链接
    """
    try:
        service = ExportService(db)
        download_url = await service.export_items_csv(current_family_id, status_filter)
        
        return ResponseSchema(
            code=200,
            message="导出成功",
            data={"download_url": download_url}
        )
    except Exception as e:
        return ResponseSchema(
            code=500,
            message=f"导出失败: {str(e)}",
            data=None
        )


@router.post("/items/json", summary="导出物品JSON")
async def export_items_json(
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    导出当前家庭完整数据为JSON格式
    
    包含：物品、分类、位置、使用记录
    """
    try:
        service = ExportService(db)
        data = await service.export_items_json(current_family_id)
        
        return ResponseSchema(
            code=200,
            message="导出成功",
            data=data
        )
    except Exception as e:
        return ResponseSchema(
            code=500,
            message=f"导出失败: {str(e)}",
            data=None
        )


@router.get("/download/{filename}", summary="下载导出文件")
async def download_export_file(filename: str):
    """
    下载已导出的文件
    
    - 导出文件1小时后自动过期
    - 仅允许下载exports目录下的文件
    """
    service = ExportService(None)
    file_path = await service.get_export_file(filename)

    if not file_path:
        return ResponseSchema(
            code=404,
            message="文件不存在或已过期",
            data=None
        )

    # 获取文件名（不含路径）
    safe_filename = os.path.basename(filename)
    
    return FileResponse(
        path=file_path,
        filename=safe_filename,
        media_type="application/octet-stream"
    )
