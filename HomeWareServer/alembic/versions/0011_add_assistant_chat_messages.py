"""Add assistant_chat_messages table

Revision ID: 0011_assistant_chat
Revises: 0010_add_supplier
Create Date: 2026-07-10

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = "0011_assistant_chat"
down_revision = "0010_add_supplier"
branch_labels = None
depends_on = None


def _table_exists(table_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    return table_name in inspector.get_table_names()


def upgrade() -> None:
    if _table_exists("assistant_chat_messages"):
        return
    op.create_table(
        "assistant_chat_messages",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("family_id", sa.Integer(), nullable=False, comment="家庭ID"),
        sa.Column("user_id", sa.Integer(), nullable=False, comment="用户ID"),
        sa.Column("role", sa.String(length=20), nullable=False, comment="user 或 assistant"),
        sa.Column("content", sa.Text(), nullable=False, comment="消息正文"),
        sa.Column("meta_json", sa.JSON(), nullable=True, comment="扩展字段"),
        sa.Column("created_at", sa.DateTime(), nullable=True),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.ForeignKeyConstraint(["family_id"], ["families.id"]),
        sa.ForeignKeyConstraint(["user_id"], ["users.id"]),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_assistant_chat_messages_family_id", "assistant_chat_messages", ["family_id"])
    op.create_index("ix_assistant_chat_messages_user_id", "assistant_chat_messages", ["user_id"])
    op.create_index(
        "ix_assistant_chat_messages_created_at",
        "assistant_chat_messages",
        ["created_at"],
    )


def downgrade() -> None:
    if not _table_exists("assistant_chat_messages"):
        return
    op.drop_index("ix_assistant_chat_messages_created_at", table_name="assistant_chat_messages")
    op.drop_index("ix_assistant_chat_messages_user_id", table_name="assistant_chat_messages")
    op.drop_index("ix_assistant_chat_messages_family_id", table_name="assistant_chat_messages")
    op.drop_table("assistant_chat_messages")
