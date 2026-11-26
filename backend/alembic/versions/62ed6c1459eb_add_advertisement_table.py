"""add advertisement table

Revision ID: 62ed6c1459eb
Revises: b7e4a1c92d05
Create Date: 2026-11-26 22:58:10.982435

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '62ed6c1459eb'
down_revision: Union[str, Sequence[str], None] = 'b7e4a1c92d05'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _table_names() -> set[str]:
    return set(sa.inspect(op.get_bind()).get_table_names())


def upgrade() -> None:
    # Databases deployed before this migration already got the table from Base.metadata.create_all.
    if "advertisement" in _table_names():
        return

    op.create_table('advertisement',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('title', sa.String(), nullable=False),
    sa.Column('description', sa.Text(), nullable=False),
    sa.Column('category', sa.Enum('FOOD', 'MEDICINE', 'EQUIPMENT', 'TOYS', 'OTHER', name='adcategoryenum'), nullable=False),
    sa.Column('published_on', sa.DateTime(), nullable=False),
    sa.Column('is_active', sa.Boolean(), nullable=False),
    sa.Column('image_url', sa.String(), nullable=True),
    sa.Column('image_public_id', sa.String(), nullable=True),
    sa.Column('province_id', sa.String(), nullable=False),
    sa.Column('shelter_id', sa.Integer(), nullable=False),
    sa.ForeignKeyConstraint(['province_id'], ['provinces.id'], name=op.f('fk_advertisement_province_id_provinces')),
    sa.ForeignKeyConstraint(['shelter_id'], ['shelter.id'], name=op.f('fk_advertisement_shelter_id_shelter')),
    sa.PrimaryKeyConstraint('id', name=op.f('pk_advertisement'))
    )
    with op.batch_alter_table('advertisement', schema=None) as batch_op:
        batch_op.create_index(batch_op.f('ix_advertisement_id'), ['id'], unique=False)


def downgrade() -> None:
    if "advertisement" not in _table_names():
        return

    with op.batch_alter_table('advertisement', schema=None) as batch_op:
        batch_op.drop_index(batch_op.f('ix_advertisement_id'))

    op.drop_table('advertisement')
    sa.Enum(name='adcategoryenum').drop(op.get_bind(), checkfirst=True)
