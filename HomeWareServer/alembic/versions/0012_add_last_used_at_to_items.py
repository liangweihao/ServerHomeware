"""Add last_used_at to items

Revision ID: 0012_add_last_used_at
Revises: 0011_assistant_chat
Create Date: 2026-07-20

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = "0012_add_last_used_at"
down_revision = "0011_assistant_chat"
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    columns = [c["name"] for c in inspector.get_columns(table_name)]
    return column_name in columns


def upgrade() -> None:
    if not _column_exists("items", "last_used_at"):
        op.add_column(
            "items",
            sa.Column("last_used_at", sa.DateTime(), nullable=True, comment="最后使用时间"),
        )


def downgrade() -> None:
    if _column_exists("items", "last_used_at"):
        op.drop_column("items", "last_used_at")
