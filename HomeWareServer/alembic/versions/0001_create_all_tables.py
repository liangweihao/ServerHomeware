"""Create all tables with complete schema and indexes

Revision ID: 0001_create_all_tables
Revises: 
Create Date: 2024-01-02 00:00:00

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '0001_create_all_tables'
down_revision = None
branch_labels = None
depends_on = None


def upgrade() -> None:
    # ==========================================
    # 创建 users 表
    # ==========================================
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('phone', sa.String(length=20), nullable=False),
        sa.Column('email', sa.String(length=100), nullable=True),
        sa.Column('password_hash', sa.String(length=128), nullable=False),
        sa.Column('nickname', sa.String(length=50), nullable=False),
        sa.Column('avatar_url', sa.String(length=500), nullable=True),
        sa.Column('current_family_id', sa.Integer(), nullable=True),
        sa.Column('is_active', sa.Boolean(), nullable=True),
        sa.Column('last_login_at', sa.DateTime(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.Index('ix_users_phone', 'phone'),
        sa.Index('ix_users_email', 'email'),
    )
    
    # ==========================================
    # 创建 families 表
    # ==========================================
    op.create_table(
        'families',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('name', sa.String(length=50), nullable=False),
        sa.Column('invite_code', sa.String(length=8), nullable=False),
        sa.Column('owner_id', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['owner_id'], ['users.id'], ),
        sa.Index('ix_families_invite_code', 'invite_code'),
    )
    
    # ==========================================
    # 创建 family_members 表
    # ==========================================
    op.create_table(
        'family_members',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('family_id', sa.Integer(), nullable=False),
        sa.Column('user_id', sa.Integer(), nullable=False),
        sa.Column('role', sa.String(length=20), nullable=True),
        sa.Column('nickname_in_family', sa.String(length=50), nullable=True),
        sa.Column('joined_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['family_id'], ['families.id'], ),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ),
    )
    
    # ==========================================
    # 创建 categories 表
    # ==========================================
    op.create_table(
        'categories',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('name', sa.String(length=50), nullable=False),
        sa.Column('icon', sa.String(length=20), nullable=True),
        sa.Column('color', sa.String(length=10), nullable=True),
        sa.Column('family_id', sa.Integer(), nullable=True),
        sa.Column('parent_id', sa.Integer(), nullable=True),
        sa.Column('sort_order', sa.Integer(), default=0),
        sa.Column('is_system', sa.Boolean(), default=False),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['family_id'], ['families.id']),
        sa.ForeignKeyConstraint(['parent_id'], ['categories.id']),
        sa.Index('ix_categories_family_id', 'family_id'),
        sa.Index('ix_categories_parent_id', 'parent_id'),
        sa.Index('ix_categories_is_system', 'is_system'),
        sa.Index('ix_categories_is_active', 'is_active'),
    )
    
    # ==========================================
    # 创建 locations 表
    # ==========================================
    op.create_table(
        'locations',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('name', sa.String(length=50), nullable=False),
        sa.Column('icon', sa.String(length=20), nullable=True),
        sa.Column('family_id', sa.Integer(), nullable=False),
        sa.Column('parent_id', sa.Integer(), nullable=True),
        sa.Column('level', sa.Integer(), nullable=False, default=1),
        sa.Column('full_path', sa.String(length=200), nullable=True),
        sa.Column('sort_order', sa.Integer(), default=0),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['family_id'], ['families.id']),
        sa.ForeignKeyConstraint(['parent_id'], ['locations.id']),
        sa.Index('ix_locations_family_id', 'family_id'),
        sa.Index('ix_locations_parent_id', 'parent_id'),
        sa.Index('ix_locations_is_active', 'is_active'),
    )
    
    # ==========================================
    # 创建 items 表
    # ==========================================
    op.create_table(
        'items',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('brand', sa.String(length=50), nullable=True),
        sa.Column('specification', sa.String(length=100), nullable=True),
        sa.Column('barcode', sa.String(length=50), nullable=True),
        sa.Column('category_id', sa.Integer(), nullable=False),
        sa.Column('location_id', sa.Integer(), nullable=True),
        sa.Column('family_id', sa.Integer(), nullable=False),
        # 价格相关
        sa.Column('purchase_price', sa.Numeric(10, 2), nullable=True),
        sa.Column('total_price', sa.Numeric(10, 2), nullable=True),
        sa.Column('purchase_quantity', sa.Integer(), default=1),
        sa.Column('current_quantity', sa.Numeric(10, 2), default=1),
        sa.Column('unit', sa.String(length=10), default='件'),
        sa.Column('safety_stock', sa.Numeric(10, 2), default=1),
        # 日期相关
        sa.Column('purchase_date', sa.Date(), nullable=True),
        sa.Column('purchase_channel', sa.String(length=50), nullable=True),
        sa.Column('production_date', sa.Date(), nullable=True),
        sa.Column('expiry_date', sa.Date(), nullable=True),
        sa.Column('shelf_life_days', sa.Integer(), nullable=True),
        sa.Column('opened_date', sa.Date(), nullable=True),
        sa.Column('after_open_days', sa.Integer(), nullable=True),
        sa.Column('warranty_date', sa.Date(), nullable=True),
        # 提醒设置
        sa.Column('expiry_alert_days', sa.Integer(), default=3),
        sa.Column('stock_alert', sa.Boolean(), default=True),
        # 其他
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('status', sa.Integer(), default=0),
        sa.Column('avg_daily_consumption', sa.Numeric(10, 4), nullable=True),
        sa.Column('predicted_empty_date', sa.Date(), nullable=True),
        sa.Column('created_by', sa.Integer(), nullable=False),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['category_id'], ['categories.id']),
        sa.ForeignKeyConstraint(['location_id'], ['locations.id']),
        sa.ForeignKeyConstraint(['family_id'], ['families.id']),
        sa.ForeignKeyConstraint(['created_by'], ['users.id']),
        sa.Index('ix_items_family_id', 'family_id'),
        sa.Index('ix_items_status', 'status'),
        sa.Index('ix_items_category_id', 'category_id'),
        sa.Index('ix_items_location_id', 'location_id'),
        sa.Index('ix_items_expiry_date', 'expiry_date'),
        sa.Index('ix_items_barcode', 'barcode'),
    )
    
    # ==========================================
    # 创建 item_images 表
    # ==========================================
    op.create_table(
        'item_images',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('item_id', sa.Integer(), nullable=False),
        sa.Column('url', sa.String(length=500), nullable=False),
        sa.Column('sort_order', sa.Integer(), default=0),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['item_id'], ['items.id'], ),
        sa.Index('ix_item_images_item_id', 'item_id'),
    )
    
    # ==========================================
    # 创建 usage_records 表
    # ==========================================
    op.create_table(
        'usage_records',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('item_id', sa.Integer(), nullable=False),
        sa.Column('family_id', sa.Integer(), nullable=False),
        sa.Column('type', sa.Integer(), nullable=False),
        sa.Column('quantity', sa.Numeric(10, 2), nullable=False),
        sa.Column('remaining_quantity', sa.Numeric(10, 2), nullable=False),
        sa.Column('operator_id', sa.Integer(), nullable=True),
        sa.Column('operator_name', sa.String(length=50), nullable=True),
        sa.Column('from_location_id', sa.Integer(), nullable=True),
        sa.Column('to_location_id', sa.Integer(), nullable=True),
        sa.Column('notes', sa.String(length=200), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['item_id'], ['items.id'], ),
        sa.ForeignKeyConstraint(['family_id'], ['families.id'], ),
        sa.ForeignKeyConstraint(['operator_id'], ['users.id'], ),
        sa.ForeignKeyConstraint(['from_location_id'], ['locations.id'], ),
        sa.ForeignKeyConstraint(['to_location_id'], ['locations.id'], ),
        sa.Index('ix_usage_records_item_id', 'item_id'),
        sa.Index('ix_usage_records_family_id', 'family_id'),
        sa.Index('ix_usage_records_created_at', 'created_at'),
    )
    
    # ==========================================
    # 创建 shopping_items 表
    # ==========================================
    op.create_table(
        'shopping_items',
        sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
        sa.Column('name', sa.String(length=100), nullable=False),
        sa.Column('family_id', sa.Integer(), nullable=False),
        sa.Column('related_item_id', sa.Integer(), nullable=True),
        sa.Column('quantity', sa.Numeric(10, 2), default=1),
        sa.Column('unit', sa.String(length=10), default='件'),
        sa.Column('estimated_price', sa.Numeric(10, 2), nullable=True),
        sa.Column('is_purchased', sa.Boolean(), default=False),
        sa.Column('is_auto_generated', sa.Boolean(), default=False),
        sa.Column('priority', sa.Integer(), default=0),
        sa.Column('purchased_at', sa.DateTime(), nullable=True),
        sa.Column('purchased_by', sa.Integer(), nullable=True),
        sa.Column('created_at', sa.DateTime(), nullable=True),
        sa.Column('updated_at', sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        sa.ForeignKeyConstraint(['family_id'], ['families.id'], ),
        sa.ForeignKeyConstraint(['related_item_id'], ['items.id'], ),
        sa.ForeignKeyConstraint(['purchased_by'], ['users.id'], ),
        sa.Index('ix_shopping_items_family_id', 'family_id'),
        sa.Index('ix_shopping_items_is_purchased', 'is_purchased'),
    )


def downgrade() -> None:
    op.drop_table('shopping_items')
    op.drop_table('usage_records')
    op.drop_table('item_images')
    op.drop_table('items')
    op.drop_table('locations')
    op.drop_table('categories')
    op.drop_table('family_members')
    op.drop_table('families')
    op.drop_table('users')