"""
条码查询路由模块
定义条码查询相关接口
"""
from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_db
from app.core.dependencies import get_current_user, get_current_family
from app.models.item import Item
from app.models.user import User
from app.schemas.common import ResponseSchema

router = APIRouter(prefix="/barcode", tags=["barcode"])


@router.get("/{code}", summary="查询条码")
async def query_barcode(
    code: str,
    current_user: User = Depends(get_current_user),
    current_family_id: int = Depends(get_current_family),
    db: AsyncSession = Depends(get_db)
):
    """
    查询条码信息
    
    优先级：
    1. 先查本地数据库：当前家庭是否已有该条码的物品
    2. 查询公开商品信息API（如有对接）
    3. 都没有 → 返回404
    
    - code: 条码值
    """
    # 1. 查询本地数据库
    result = await db.execute(
        Item.__table__.select().where(
            Item.barcode == code,
            Item.family_id == current_family_id,
            Item.status != 3  # 排除已删除
        )
    )
    item = result.first()

    if item:
        # 转换为字典
        item_dict = {
            "id": item[0],
            "name": item[1],
            "brand": item[2],
            "specification": item[3],
            "barcode": item[4],
            "category_id": item[5],
            "location_id": item[6],
            "current_quantity": float(item[14]),
            "unit": item[16],
            "status": item[44]
        }

        return ResponseSchema(
            code=200,
            message="success",
            data={
                "already_exists": True,
                "item": item_dict
            }
        )

    # 2. 查询公开API（预留接口，MVP阶段跳过）
    # product_info = await _query_public_api(code)
    # if product_info:
    #     return ResponseSchema(
    #         code=200,
    #         message="success",
    #         data={
    #             "already_exists": False,
    #             "product_info": product_info
    #         }
    #     )

    # 3. 未找到
    return ResponseSchema(
        code=404,
        message="未找到该条码对应的物品",
        data=None
    )


# async def _query_public_api(code: str) -> dict:
#     """
#     查询公开商品信息API（预留接口）
#     :param code: 条码
#     :return: 商品信息
#     """
#     # TODO: 对接公开商品API
#     # 例如：淘宝开放平台、京东万象等
#     return None
