"""Add notification and notification_preference tables

Revision ID: 0003_add_notification_tables
Revises: 0002_add_activity_log_and_device_tables
Create Date: 2024-01-04 00:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


# revision identifiers, used by Alembic.
revision = '0003_add_notification_tables'
down_revision = '0002_add_activity_log_and_device_tables'
branch_labels = None
depends_on = None


def _table_exists(table_name: str) -> bool:
    """检查表是否已存在（幂等迁移用）"""
    conn = op.get_bind()
    inspector = inspect(conn)
    return table_name in inspector.get_table_names()


def upgrade() -> None:
    # ==========================================
    # 创建 notifications 表（幂等）
    # ==========================================
    if not _table_exists('notifications'):
        op.create_table(
            'notifications',
            sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
            sa.Column('family_id', sa.Integer(), nullable=False, comment='家庭ID'),
            sa.Column('user_id', sa.Integer(), nullable=True, comment='用户ID（null=全家庭）'),
            sa.Column('type', sa.String(length=30), nullable=False, comment='通知类型：expiry/stock/purchase/warranty/system'),
            sa.Column('title', sa.String(length=100), nullable=False, comment='通知标题'),
            sa.Column('body', sa.String(length=500), nullable=True, comment='通知内容'),
            sa.Column('item_id', sa.Integer(), nullable=True, comment='关联物品ID'),
            sa.Column('priority', sa.String(length=10), nullable=True, comment='优先级：high/medium/low'),
            sa.Column('is_read', sa.Boolean(), nullable=True, default=False, comment='是否已读'),
            sa.Column('action_url', sa.String(length=200), nullable=True, comment='点击跳转路径'),
            sa.Column('created_at', sa.DateTime(), nullable=True, comment='创建时间'),
            sa.Column('updated_at', sa.DateTime(), nullable=True, comment='更新时间'),
            sa.PrimaryKeyConstraint('id'),
            sa.ForeignKeyConstraint(['family_id'], ['families.id'], ),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.Index('ix_notifications_family_id', 'family_id'),
            sa.Index('ix_notifications_user_id', 'user_id'),
            sa.Index('ix_notifications_type', 'type'),
            sa.Index('ix_notifications_is_read', 'is_read'),
            sa.Index('ix_notifications_created_at', 'created_at'),
        )

    # ==========================================
    # 创建 notification_preferences 表（幂等）
    # ==========================================
    if not _table_exists('notification_preferences'):
        op.create_table(
            'notification_preferences',
            sa.Column('user_id', sa.Integer(), nullable=False, comment='用户ID'),
            sa.Column('push_enabled', sa.Boolean(), nullable=True, default=True, comment='全局推送开关'),
            sa.Column('expiry_alert', sa.Boolean(), nullable=True, default=True, comment='过期提醒'),
            sa.Column('stock_alert', sa.Boolean(), nullable=True, default=True, comment='库存提醒'),
            sa.Column('purchase_alert', sa.Boolean(), nullable=True, default=True, comment='补购提醒'),
            sa.Column('warranty_alert', sa.Boolean(), nullable=True, default=True, comment='保修提醒'),
            sa.Column('quiet_start', sa.Time(), nullable=True, comment='免打扰开始时间'),
            sa.Column('quiet_end', sa.Time(), nullable=True, comment='免打扰结束时间'),
            sa.PrimaryKeyConstraint('user_id'),
            sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
            sa.Index('ix_notification_preferences_user_id', 'user_id'),
        )


def downgrade() -> None:
    # 删除索引
    op.drop_index('ix_notifications_family_id', table_name='notifications')
    op.drop_index('ix_notifications_user_id', table_name='notifications')
    op.drop_index('ix_notifications_type', table_name='notifications')
    op.drop_index('ix_notifications_is_read', table_name='notifications')
    op.drop_index('ix_notifications_created_at', table_name='notifications')
    op.drop_index('ix_notification_preferences_user_id', table_name='notification_preferences')

    # 删除表
    op.drop_table('notifications')
    op.drop_table('notification_preferences')
