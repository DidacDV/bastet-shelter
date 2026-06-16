"""add link names for external adoption links

Revision ID: a3f8c2d91b04
Revises: 06edd51fb5ab
Create Date: 2026-05-27 12:00:00.000000

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa

from app.core.utils import generate_unique_link_name


revision: str = "a3f8c2d91b04"
down_revision: Union[str, Sequence[str], None] = "06edd51fb5ab"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _backfill_link_names(connection) -> None:
    shelters = connection.execute(sa.text("SELECT id, name FROM shelter")).fetchall()
    used_shelter_names: set[str] = set()

    for shelter_id, name in shelters:
        link_name = generate_unique_link_name(name, lambda candidate: candidate in used_shelter_names)
        used_shelter_names.add(link_name)
        connection.execute(
            sa.text("UPDATE shelter SET link_name = :link_name WHERE id = :id"),
            {"link_name": link_name, "id": shelter_id},
        )

    animals = connection.execute(
        sa.text(
            """
            SELECT animal.id, animal.name, refuge.shelter_id
            FROM animal
            JOIN refuge ON animal.refuge_id = refuge.id
            """
        )
    ).fetchall()

    used_animal_names_by_shelter: dict[int, set[str]] = {}

    for animal_id, name, shelter_id in animals:
        used = used_animal_names_by_shelter.setdefault(shelter_id, set())
        link_name = generate_unique_link_name(name, lambda candidate: candidate in used)
        used.add(link_name)
        connection.execute(
            sa.text("UPDATE animal SET link_name = :link_name WHERE id = :id"),
            {"link_name": link_name, "id": animal_id},
        )


def upgrade() -> None:
    with op.batch_alter_table("shelter", schema=None) as batch_op:
        batch_op.add_column(sa.Column("link_name", sa.String(), nullable=True))

    with op.batch_alter_table("animal", schema=None) as batch_op:
        batch_op.add_column(sa.Column("link_name", sa.String(), nullable=True))

    connection = op.get_bind()
    _backfill_link_names(connection)

    with op.batch_alter_table("shelter", schema=None) as batch_op:
        batch_op.alter_column("link_name", nullable=False)
        batch_op.create_index(batch_op.f("ix_shelter_link_name"), ["link_name"], unique=True)

    with op.batch_alter_table("animal", schema=None) as batch_op:
        batch_op.alter_column("link_name", nullable=False)
        batch_op.create_index(batch_op.f("ix_animal_link_name"), ["link_name"], unique=False)


def downgrade() -> None:
    with op.batch_alter_table("animal", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_animal_link_name"))
        batch_op.drop_column("link_name")

    with op.batch_alter_table("shelter", schema=None) as batch_op:
        batch_op.drop_index(batch_op.f("ix_shelter_link_name"))
        batch_op.drop_column("link_name")
