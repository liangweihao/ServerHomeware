"""添加软删除字段和家庭图标字段

Revision ID: 0004
Revises: 0003
Create Date: 2026-05-27 12:00:00

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0004'
down_revision = '0003'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # 添加 families 表的 icon 和 deleted_at 字段
    op.add_column('families', sa.Column('icon', sa.String(length=10), nullable=True))
    op.add_column('families', sa.Column('deleted_at', sa.DateTime(), nullable=True))
    
    # 为 icon 设置默认值 '🏠'
    op.execute("UPDATE families SET icon = '🏠' WHERE icon IS NULL")
    op.alter_column('families', 'icon', nullable=False, server_default="'🏠'")
    
    # 添加 shopping_items 表的 deleted_at 字段
    op.add_column('shopping_items', sa.Column('deleted_at', sa.DateTime(), nullable=True))
    
    # 添加索引
    op.create_index('idx_families_deleted_at', 'families', ['deleted_at'])
    op.create_index('idx_items_deleted_at', 'items', ['deleted_at'])


def downgrade() -> None:
    # 删除索引
    op.drop_index('idx_families_deleted_at', table_name='families')
    op.drop_index('idx_items_deleted_at', table_name='items')
    
    # 删除字段
    op.drop_column('shopping_items', 'deleted_at')
    op.drop_column('families', 'deleted_at')
    op.drop_column('families', 'icon')