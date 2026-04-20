from logging.config import fileConfig

from sqlalchemy import engine_from_config
from sqlalchemy import pool
from app.database import Base

from app.models.adoption.adoption_steps.adoptant import Adoptant
from app.models.adoption.adoption_process import AdoptionProcess
from app.models.adoption.adoption_steps.adoption_step import AdoptionStep
from app.models.adoption.adoption_steps.animal_pickup import AnimalPickup
from app.models.adoption.adoption_steps.contract import Contract
from app.models.adoption.adoption_steps.interview import Interview
from app.models.adoption.adoption_steps.shelter_visit import ShelterVisit
from app.models.adoption.adoption_steps.adoption_form import AdoptionForm
from app.models.animal.animal import Animal, animal_trait_association
from app.models.trait import Trait
from app.models.shelter import Shelter
from app.models.refuge import Refuge
from app.models.province import Province
from app.models.shelter_member import ShelterMember
from app.models.user import User
from app.models.login import Login
from app.models.task.task import Task
from app.models.task.shift_task import ShiftTask
from app.models.shift.shift import Shift
from app.models.shift.shift_participant import ShiftParticipant
from app.models.medical.medical_treatment import AnimalTreatment
from app.models.medical.medicine import Medicine
from app.models.medical.vet_visit import VetVisit
from app.models.animal.animal_image import AnimalImage


from alembic import context

# this is the Alembic Config object, which provides
# access to the values within the .ini file in use.
config = context.config

# Interpret the config file for Python logging.
# This line sets up loggers basically.
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# add your model's MetaData object here
# for 'autogenerate' support
# from myapp import mymodel
# target_metadata = mymodel.Base.metadata
target_metadata = Base.metadata

# other values from the config, defined by the needs of env.py,
# can be acquired:
# my_important_option = config.get_main_option("my_important_option")
# ... etc.


def run_migrations_offline() -> None:
    """Run migrations in 'offline' mode.

    This configures the context with just a URL
    and not an Engine, though an Engine is acceptable
    here as well.  By skipping the Engine creation
    we don't even need a DBAPI to be available.

    Calls to context.execute() here emit the given string to the
    script output.

    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
        render_as_batch=True,
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """Run migrations in 'online' mode.

    In this scenario we need to create an Engine
    and associate a connection with the context.

    """
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata,
            render_as_batch=True,
        )

        with context.begin_transaction():
            context.run_migrations()


if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
