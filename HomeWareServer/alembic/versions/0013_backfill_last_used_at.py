"""Backfill items.last_used_at from usage_records

Revision ID: 0013_backfill_last_used_at
Revises: 0012_add_last_used_at
Create Date: 2026-07-20

用历史 type=1 使用记录的最大 created_at 回填 last_used_at，
避免上线后把所有老库存误判为「从未使用」。
"""
from alembic import op


revision = "0013_backfill_last_used_at"
down_revision = "0012_add_last_used_at"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # SQLite / PostgreSQL 均支持相关子查询
    op.execute(
        """
        UPDATE items
        SET last_used_at = (
            SELECT MAX(usage_records.created_at)
            FROM usage_records
            WHERE usage_records.item_id = items.id
              AND usage_records.type = 1
        )
        WHERE last_used_at IS NULL
          AND EXISTS (
            SELECT 1 FROM usage_records
            WHERE usage_records.item_id = items.id
              AND usage_records.type = 1
          )
        """
    )


def downgrade() -> None:
    # 回填不可逆，降级为空操作
    pass
