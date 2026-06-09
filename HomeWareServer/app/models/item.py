"""
物品模型模块
定义 Item 和 ItemImage 模型
"""
from sqlalchemy import Boolean, Column, Date, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship

from app.core.database import Base
from app.models.base import BaseMixin


class Item(Base, BaseMixin):
    """物品模型"""
    
    __tablename__ = "items"
    
    name = Column(String(100), nullable=False, comment="物品名称")
    brand = Column(String(50), nullable=True, comment="品牌")
    specification = Column(String(100), nullable=True, comment="规格")
    barcode = Column(String(50), nullable=True, comment="条码")
    category_id = Column(Integer, ForeignKey("categories.id"), nullable=False, comment="分类ID")
    location_id = Column(Integer, ForeignKey("locations.id"), nullable=True, comment="位置ID")
    container_name = Column(String(50), nullable=True, comment="容器名（收纳箱/药盒等）")
    family_id = Column(Integer, ForeignKey("families.id"), nullable=False, comment="家庭ID")
    
    # 价格相关
    purchase_price = Column(Numeric(10, 2), nullable=True, comment="购买单价")
    total_price = Column(Numeric(10, 2), nullable=True, comment="总价")
    purchase_quantity = Column(Integer, default=1, comment="购买数量（包装数）")
    package_unit = Column(String(10), nullable=True, comment="包装单位（盒/箱/提）")
    package_quantity = Column(Integer, default=1, comment="一包装含多少基本单位")
    current_quantity = Column(Numeric(10, 2), default=1, comment="当前数量（总基本单位）")
    unit = Column(String(10), default="件", comment="基本单位（片/瓶/个）")
    safety_stock = Column(Numeric(10, 2), default=1, comment="安全库存")
    
    # 日期相关
    purchase_date = Column(Date, nullable=True, comment="购买日期")
    purchase_channel = Column(String(50), nullable=True, comment="购买渠道")
    production_date = Column(Date, nullable=True, comment="生产日期")
    expiry_date = Column(Date, nullable=True, comment="过期日期")
    shelf_life_days = Column(Integer, nullable=True, comment="保质期天数")
    opened_date = Column(Date, nullable=True, comment="开封日期")
    after_open_days = Column(Integer, nullable=True, comment="开封后保质期天数")
    warranty_date = Column(Date, nullable=True, comment="质保日期")
    
    # 提醒设置
    expiry_alert_days = Column(Integer, default=3, comment="过期提醒天数")
    stock_alert = Column(Boolean, default=True, comment="是否开启库存提醒")
    
    # 其他
    notes = Column(Text, nullable=True, comment="备注")
    status = Column(Integer, default=0, comment="状态(0使用中/1用完/2过期/3丢弃)")
    avg_daily_consumption = Column(Numeric(10, 4), nullable=True, comment="日均消耗量")
    predicted_empty_date = Column(Date, nullable=True, comment="预计用完日期")
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False, comment="创建人ID")
    deleted_at = Column(DateTime, nullable=True, comment="删除时间(软删除)")
    
    # 关系定义
    category = relationship("Category")
    location = relationship("Location")
    family = relationship("Family")
    created_by_user = relationship("User")
    images = relationship("ItemImage", back_populates="item", cascade="all, delete-orphan")
    usage_records = relationship("UsageRecord", back_populates="item")


class ItemImage(Base, BaseMixin):
    """物品图片模型"""
    
    __tablename__ = "item_images"
    
    item_id = Column(Integer, ForeignKey("items.id"), nullable=False, comment="物品ID")
    url = Column(String(500), nullable=False, comment="图片路径/URL")
    sort_order = Column(Integer, default=0, comment="排序序号")
    
    # 关系定义
    item = relationship("Item", back_populates="images")