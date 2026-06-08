"""Add package_unit and package_quantity to items

Revision ID: 0005_add_package_unit_and_quantity
Revises: 0004
Create Date: 2026-06-08 12:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


# revision identifiers, used by Alembic.
revision = '0005_add_package_unit_and_quantity'
down_revision = '0004'
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    return column_name in [c['name'] for c in inspector.get_columns(table_name)]


def upgrade() -> None:
    if not _column_exists('items', 'package_unit'):
        op.add_column('items', sa.Column(
            'package_unit', sa.String(length=10), nullable=True,
            comment='包装单位（盒/箱/提）'
        ))
    if not _column_exists('items', 'package_quantity'):
        op.add_column('items', sa.Column(
            'package_quantity', sa.Integer(), nullable=True,
            server_default='1', comment='一包装含多少基本单位'
        ))


def downgrade() -> None:
    with op.batch_alter_table('items') as batch_op:
        batch_op.drop_column('package_quantity')
        batch_op.drop_column('package_unit')
