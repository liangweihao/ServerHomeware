"""
文件上传路由模块
定义文件上传相关接口
"""
from fastapi import APIRouter, Body, Depends, File, UploadFile
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.user import User
from app.schemas.common import ResponseSchema
from app.services.upload_service import UploadService

router = APIRouter(prefix="/upload", tags=["upload"])


@router.post("/image", summary="上传图片")
async def upload_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    上传并处理图片
    
    - 限制：最大10MB，格式 jpg/jpeg/png/webp
    - 自动处理：旋转(EXIF)、等比缩放(max 1080px)、转为WebP格式
    - 返回：图片URL
    """
    try:
        service = UploadService()
        url = await service.upload_image(file, current_family_id)
        
        return ResponseSchema(
            code=200,
            message="上传成功",
            data={"url": url}
        )
    except ValueError as e:
        return ResponseSchema(
            code=400,
            message=str(e),
            data=None
        )


@router.post("/images", summary="批量上传图片")
async def upload_images(
    files: List[UploadFile] = File(...),
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    批量上传图片（最多5张）
    
    - 限制：最多5张，每张最大10MB
    - 返回：图片URL列表
    """
    if len(files) > 5:
        return ResponseSchema(
            code=400,
            message="最多支持上传5张图片",
            data=None
        )

    try:
        service = UploadService()
        urls = await service.upload_images(files, current_family_id)
        
        return ResponseSchema(
            code=200,
            message="上传成功",
            data={"urls": urls}
        )
    except ValueError as e:
        return ResponseSchema(
            code=400,
            message=str(e),
            data=None
        )


@router.delete("/image", summary="删除图片")
async def delete_image(
    url: str = Body(..., embed=True, description="图片URL"),
    current_user: User = Depends(get_current_user)
):
    """
    删除指定图片
    
    - url: 需要删除的图片URL，如 /uploads/1/20240125_abc123.webp
    """
    service = UploadService()
    success = await service.delete_image(url)

    if success:
        return ResponseSchema(
            code=200,
            message="删除成功",
            data=None
        )
    else:
        return ResponseSchema(
            code=400,
            message="删除失败，文件不存在或路径无效",
            data=None
        )
