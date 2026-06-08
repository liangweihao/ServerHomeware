"""Add images column to locations

Revision ID: 0006_add_location_images
Revises: 0005_add_package_unit_and_quantity
Create Date: 2026-06-08 12:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = '0006_add_location_images'
down_revision = '0005_add_package_unit_and_quantity'
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    return column_name in [c['name'] for c in inspector.get_columns(table_name)]


def upgrade() -> None:
    if not _column_exists('locations', 'images'):
        op.add_column('locations', sa.Column(
            'images', sa.String(length=500), nullable=True,
            comment='位置说明图片 JSON 数组'
        ))


def downgrade() -> None:
    with op.batch_alter_table('locations') as batch_op:
        batch_op.drop_column('images')
