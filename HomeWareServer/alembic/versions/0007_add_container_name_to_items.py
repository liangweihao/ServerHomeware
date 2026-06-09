"""Add container_name to items

Revision ID: 0007_add_container_name
Revises: 0006_add_location_images
Create Date: 2026-06-09 12:00:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy import inspect


revision = '0007_add_container_name'
down_revision = '0006_add_location_images'
branch_labels = None
depends_on = None


def _column_exists(table_name: str, column_name: str) -> bool:
    conn = op.get_bind()
    inspector = inspect(conn)
    return column_name in [c['name'] for c in inspector.get_columns(table_name)]


def upgrade() -> None:
    if not _column_exists('items', 'container_name'):
        op.add_column('items', sa.Column(
            'container_name', sa.String(length=50), nullable=True,
            comment='容器名（收纳箱/药盒等）'
        ))


def downgrade() -> None:
    with op.batch_alter_table('items') as batch_op:
        batch_op.drop_column('container_name')
