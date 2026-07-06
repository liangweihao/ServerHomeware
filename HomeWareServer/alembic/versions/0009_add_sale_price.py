"""Add sale_price to items

Revision ID: 0009_add_sale_price
Revises: 0008_add_family_space_type
Create Date: 2026-07-06

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = '0009_add_sale_price'
down_revision = '0008_add_family_space_type'
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    return column_name in [c['name'] for c in inspector.get_columns(table_name)]


def upgrade() -> None:
    if not _column_exists('items', 'sale_price'):
        op.add_column(
            'items',
            sa.Column(
                'sale_price',
                sa.Numeric(10, 2),
                nullable=True,
                comment='售价（店铺场景）',
            ),
        )


def downgrade() -> None:
    if _column_exists('items', 'sale_price'):
        with op.batch_alter_table('items') as batch_op:
            batch_op.drop_column('sale_price')
