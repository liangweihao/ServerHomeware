"""Add ActivityLog and UserDevice tables

Revision ID: 0002_add_activity_log_and_device_tables
Revises: 0001_create_all_tables
Create Date: 2024-01-03 00:00:00

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0002_add_activity_log_and_device_tables'
down_revision = '0001_create_all_tables'
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ==========================================
    # 创建 activity_logs 表
    # ==========================================
    op.create_table(
        'activity_logs',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('family_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('action', sa.String(length=50), nullable=False),
        sa.Column('target_type', sa.String(length=50), nullable=True),
        sa.Column('target_id', sa.Integer(), nullable=True),
        sa.Column('target_name', sa.String(length=100), nullable=True),
        sa.Column('detail', sa.JSON(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['family_id'], ['families.id'], ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.Index('ix_activity_logs_family_id', 'family_id'),
        sa.Index('ix_activity_logs_user_id', 'user_id'),
        sa.Index('ix_activity_logs_created_at', 'created_at'),
    )

    # ==========================================
    # 创建 user_devices 表
    # ==========================================
    op.create_table(
        'user_devices',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('device_token', sa.String(length=500), nullable=False),
        sa.Column('device_type', sa.String(length=20), nullable=False),
        sa.Column('device_name', sa.String(length=100), nullable=True),
        sa.Column('last_active_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
        sa.Index('ix_user_devices_user_id', 'user_id'),
    )

    # ==========================================
    # 为 items、locations、categories 添加 deleted_at 字段
    # ==========================================
    op.add_column('items', sa.Column('deleted_at', sa.DateTime(), nullable=True))
    op.add_column('locations', sa.Column('deleted_at', sa.DateTime(), nullable=True))
    op.add_column('categories', sa.Column('deleted_at', sa.DateTime(), nullable=True))

    op.create_index('ix_items_deleted_at', 'items', ['deleted_at'])
    op.create_index('ix_locations_deleted_at', 'locations', ['deleted_at'])
    op.create_index('ix_categories_deleted_at', 'categories', ['deleted_at'])


def downgrade() -> None:
    # 删除索引
    op.drop_index('ix_activity_logs_family_id', table_name='activity_logs')
    op.drop_index('ix_activity_logs_user_id', table_name='activity_logs')
    op.drop_index('ix_activity_logs_created_at', table_name='activity_logs')
    op.drop_index('ix_user_devices_user_id', table_name='user_devices')
    op.drop_index('ix_items_deleted_at', table_name='items')
    op.drop_index('ix_locations_deleted_at', table_name='locations')
    op.drop_index('ix_categories_deleted_at', table_name='categories')

    # 删除表
    op.drop_table('activity_logs')
    op.drop_table('user_devices')

    # 删除字段
    op.drop_column('items', 'deleted_at')
    op.drop_column('locations', 'deleted_at')
    op.drop_column('categories', 'deleted_at')
