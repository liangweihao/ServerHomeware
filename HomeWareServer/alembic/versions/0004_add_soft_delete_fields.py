"""添加软删除字段和家庭图标字段

Revision ID: 0004
Revises: 0003_add_notification_tables
Create Date: 2026-05-27 12:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


# revision identifiers, used by Alembic.
revision = '0004'
down_revision = '0003_add_notification_tables'
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    """检查列是否已存在"""
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [c['name'] for c in inspector.get_columns(table_name)]
    return column_name in columns


def _index_exists(index_name: str) -> bool:
    """检查索引是否已存在（简化版：尝试获取表索引列表）"""
    conn = op.get_bind()
    inspector = inspect(conn)
    for table in inspector.get_table_names():
        for idx in inspector.get_indexes(table):
            if idx['name'] == index_name:
                return True
    return False


def upgrade() -> None:
    # 添加 families.icon（幂等）
    if not _column_exists('families', 'icon'):
        op.add_column('families', sa.Column('icon', sa.String(length=10), nullable=True))
        op.execute("UPDATE families SET icon = '🏠' WHERE icon IS NULL")
        with op.batch_alter_table('families') as batch_op:
            batch_op.alter_column('icon', nullable=False)

    # 添加 families.deleted_at（幂等）
    if not _column_exists('families', 'deleted_at'):
        op.add_column('families', sa.Column('deleted_at', sa.DateTime(), nullable=True))

    # 添加 shopping_items.deleted_at（幂等）
    if not _column_exists('shopping_items', 'deleted_at'):
        op.add_column('shopping_items', sa.Column('deleted_at', sa.DateTime(), nullable=True))

    # 添加索引（幂等）
    if not _index_exists('idx_families_deleted_at'):
        op.create_index('idx_families_deleted_at', 'families', ['deleted_at'])
    if not _index_exists('idx_items_deleted_at'):
        op.create_index('idx_items_deleted_at', 'items', ['deleted_at'])


def downgrade() -> None:
    # 删除索引
    op.drop_index('idx_families_deleted_at', table_name='families')
    op.drop_index('idx_items_deleted_at', table_name='items')

    # 删除字段
    with op.batch_alter_table('shopping_items') as batch_op:
        batch_op.drop_column('deleted_at')
    with op.batch_alter_table('families') as batch_op:
        batch_op.drop_column('deleted_at')
        batch_op.drop_column('icon')
