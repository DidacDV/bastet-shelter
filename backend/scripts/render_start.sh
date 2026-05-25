#!/usr/bin/env bash
set -euo pipefail

python <<'PY'
from sqlalchemy import create_engine, inspect, text

from app.core.config import settings

engine = create_engine(settings.DATABASE_URL)
inspector = inspect(engine)
tables = set(inspector.get_table_names())

if "alembic_version" not in tables and "shelter" in tables:
    with engine.begin() as conn:
        conn.execute(
            text(
                "CREATE TABLE alembic_version ("
                "version_num VARCHAR(32) NOT NULL, "
                "CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num)"
                ")"
            )
        )
        conn.execute(
            text("INSERT INTO alembic_version (version_num) VALUES ('c0725a976e10')")
        )
    print("Bootstrapped alembic_version for existing database.")
PY

alembic upgrade head
exec uvicorn app.main:app --host 0.0.0.0 --port "${PORT:?PORT is required}"
