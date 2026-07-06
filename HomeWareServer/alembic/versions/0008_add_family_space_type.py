"""Add space_type to families

Revision ID: 0008_add_family_space_type
Revises: 0007_add_container_name
Create Date: 2026-07-04

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = '0008_add_family_space_type'
down_revision = '0007_add_container_name'
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    return column_name in [c['name'] for c in inspector.get_columns(table_name)]


def upgrade() -> None:
    if not _column_exists('families', 'space_type'):
        op.add_column(
            'families',
            sa.Column(
                'space_type',
                sa.String(length=20),
                nullable=False,
                server_default='home',
                comment='空间类型：home 家庭 | shop 小店铺',
            ),
        )


def downgrade() -> None:
    if _column_exists('families', 'space_type'):
        with op.batch_alter_table('families') as batch_op:
            batch_op.drop_column('space_type')
