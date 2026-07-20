"""Add search_aliases to items

Revision ID: 0014_add_search_aliases
Revises: 0013_backfill_last_used_at
Create Date: 2026-07-20

用于管管语义检索：入库魔法备注时由 AI 生成别名/俗称关键词。
存储为 JSON 数组字符串，例如 ["护肤霜","精华液","护肤品"]。
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = "0014_add_search_aliases"
down_revision = "0013_backfill_last_used_at"
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [c["name"] for c in inspector.get_columns(table_name)]
    return column_name in columns


def upgrade() -> None:
    if not _column_exists("items", "search_aliases"):
        op.add_column(
            "items",
            sa.Column(
                "search_aliases",
                sa.Text(),
                nullable=True,
                comment="检索别名 JSON 数组，供问管管模糊匹配",
            ),
        )


def downgrade() -> None:
    if _column_exists("items", "search_aliases"):
        op.drop_column("items", "search_aliases")
