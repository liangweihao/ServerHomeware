"""Add supplier to items

Revision ID: 0010_add_supplier
Revises: 0009_add_sale_price
Create Date: 2026-07-06

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = '0010_add_supplier'
down_revision = '0009_add_sale_price'
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    return column_name in [c['name'] for c in inspector.get_columns(table_name)]


def upgrade() -> None:
    if not _column_exists('items', 'supplier'):
        op.add_column(
            'items',
            sa.Column(
                'supplier',
                sa.String(length=100),
                nullable=True,
                comment='供应商（店铺场景）',
            ),
        )


def downgrade() -> None:
    if _column_exists('items', 'supplier'):
        with op.batch_alter_table('items') as batch_op:
            batch_op.drop_column('supplier')
