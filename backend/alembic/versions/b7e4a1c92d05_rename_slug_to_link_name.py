"""rename slug columns to link_name

Revision ID: b7e4a1c92d05
Revises: a3f8c2d91b04
Create Date: 2026-05-27 14:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


revision: str = "b7e4a1c92d05"
down_revision: Union[str, Sequence[str], None] = "a3f8c2d91b04"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _column_names(table: str) -> set[str]:
    connection = op.get_bind()
    inspector = sa.inspect(connection)
    columns = inspector.get_columns(table)
    return {col["name"] for col in columns}


def upgrade() -> None:
    shelter_columns = _column_names("shelter")
    if "slug" in shelter_columns and "link_name" not in shelter_columns:
        with op.batch_alter_table("shelter", schema=None) as batch_op:
            batch_op.alter_column("slug", new_column_name="link_name")
        with op.batch_alter_table("shelter", schema=None) as batch_op:
            batch_op.drop_index("ix_shelter_slug")
            batch_op.create_index(batch_op.f("ix_shelter_link_name"), ["link_name"], unique=True)

    animal_columns = _column_names("animal")
    if "slug" in animal_columns and "link_name" not in animal_columns:
        with op.batch_alter_table("animal", schema=None) as batch_op:
            batch_op.alter_column("slug", new_column_name="link_name")
        with op.batch_alter_table("animal", schema=None) as batch_op:
            batch_op.drop_index("ix_animal_slug")
            batch_op.create_index(batch_op.f("ix_animal_link_name"), ["link_name"], unique=False)


def downgrade() -> None:
    shelter_columns = _column_names("shelter")
    if "link_name" in shelter_columns and "slug" not in shelter_columns:
        with op.batch_alter_table("shelter", schema=None) as batch_op:
            batch_op.drop_index(batch_op.f("ix_shelter_link_name"))
            batch_op.create_index(batch_op.f("ix_shelter_slug"), ["link_name"], unique=True)
        with op.batch_alter_table("shelter", schema=None) as batch_op:
            batch_op.alter_column("link_name", new_column_name="slug")

    animal_columns = _column_names("animal")
    if "link_name" in animal_columns and "slug" not in animal_columns:
        with op.batch_alter_table("animal", schema=None) as batch_op:
            batch_op.drop_index(batch_op.f("ix_animal_link_name"))
            batch_op.create_index(batch_op.f("ix_animal_slug"), ["link_name"], unique=False)
        with op.batch_alter_table("animal", schema=None) as batch_op:
            batch_op.alter_column("link_name", new_column_name="slug")
