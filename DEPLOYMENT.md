# Deployment Guide — Bastet Shelter

This document covers how to run the backend locally with Docker, deploy it to Render, link it to the PostgreSQL database, and build the Flutter APK for testing.

> Moving the Render deploy itself to the Docker image is a pending task, documented in [RENDER_DOCKER_DEPLOY.md](RENDER_DOCKER_DEPLOY.md).

---

## 0. Local Development with Docker

Runs the backend against PostgreSQL 16, the same engine as production, so Postgres-only issues show up locally instead of after a release.

### Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running
- `backend/.env` with your secrets. Start from the template:
  ```bash
  cp backend/.env.example backend/.env
  ```
  `DATABASE_URL` and `TEST_DATABASE_URL` in that file are ignored by Docker: `docker-compose.yml` points them at the `db` container.

### Commands (from the repo root)

| Task | Command |
|---|---|
| Start database + backend | `docker compose up -d --build` |
| Seed demo data (login `d@gmail.com` / `d`) | `docker compose run --rm seed` |
| Run the backend test suite against Postgres | `docker compose run --rm test` |
| Follow backend logs | `docker compose logs -f backend` |
| Open a SQL shell | `docker compose exec db psql -U bastet -d bastet` |
| Stop (keeps data) | `docker compose down` |
| Stop and wipe the database | `docker compose down -v` |

The API is at `http://localhost:8000` (Swagger at `/docs`), and Postgres is exposed on `localhost:5432` (user/password/db `bastet`). If those ports are taken, set `BACKEND_PORT` or `DB_PORT` before `docker compose up`.

On startup the container runs `scripts/render_start.sh`, the same script Render uses: it applies `alembic upgrade head` and then starts Uvicorn.

The seed empties every table and inserts demo data, so it can be re-run at any time. Provinces are fetched from the geo API, so `GEOAPI_KEY` must be valid.

### Without Docker

Still possible with SQLite (`DATABASE_URL=sqlite:///./bastet.db` in `backend/.env`):

```bash
cd backend
alembic upgrade head
python seed.py
uvicorn app.main:app --reload
```

---

## Database Migrations

The schema is owned by **Alembic only**. The app no longer calls `Base.metadata.create_all` on startup.

- After changing a model, generate a migration:
  ```bash
  docker compose exec backend alembic revision --autogenerate -m "describe the change"
  docker compose cp backend:/app/alembic/versions/<new_file>.py backend/alembic/versions/
  ```
  Review the generated file before committing.
- Migrations are applied automatically on every deploy and container start (`alembic upgrade head` in `scripts/render_start.sh`).
- CI runs `alembic check` against Postgres and fails if a model changed without a migration.
- Tests build their own schema in a separate database (`TEST_DATABASE_URL`, SQLite by default) and drop every table after each test. Never point `TEST_DATABASE_URL` at a database you care about.

---

## Branching Strategy

- All development happens on `dev`
- When ready to release, create a new branch from `dev`: `release-1`, `release-2`, etc.
- Each new release branch merges the previous one first, then `dev` on top
- Render is pointed at the current release branch

---

## 1. Backend — Render Web Service

### Prerequisites

- A [Render](https://render.com) account
- The repo connected to Render via GitHub

### First-time setup

1. Go to Render dashboard → **New + → Web Service**
2. Connect your GitHub repo
3. Fill in:
   - **Name**: `bastet-backend`
   - **Region**: same region as your database (important)
   - **Root Directory**: `backend`
   - **Runtime**: Python
   - **Build Command**: `pip install -r requirements.txt`
   - **Start Command**: `bash scripts/render_start.sh` (applies migrations, then starts Uvicorn)
   - **Branch**: your current release branch (e.g. `release-2`)
4. Click **Create Web Service**

### On every new release

1. Merge the previous release branch into the new one
2. Merge `dev` into the new release branch
3. Push to GitHub
4. On Render → your web service → **Settings → Branch** → update to the new release branch
5. Click **Manual Deploy** or let it auto-deploy on push

---

## 2. Database — Render PostgreSQL

### First-time setup

1. Render dashboard → **New + → PostgreSQL**
2. Fill in:
   - **Name**: `bastet-db`
   - **Region**: same as the web service
   - **Plan**: Free
3. Click **Create Database**
4. Once provisioned, go to the database page and copy the **Internal Database URL**

### Wiping and recreating (fresh deploy)

If you need to start from a clean database:

1. Connect using the **External Database URL** from the Render dashboard:
   ```bash
   psql "your_external_database_url"
   ```
2. Drop and recreate the schema:
   ```sql
   DROP SCHEMA public CASCADE;
   CREATE SCHEMA public;
   \q
   ```
3. Redeploy the backend — `alembic upgrade head` in the start script recreates all tables

> The `DATABASE_URL` env var is linked automatically via `render.yaml` — you do not need to set it manually.

---

## 3. Environment Variables

The backend reads all secrets from environment variables. These must be set manually in Render for any variable marked `sync: false` in `render.yaml`.

Go to Render → your web service → **Environment** tab and add:

| Variable | Description |
|---|---|
| `DATABASE_URL` | Auto-linked from the Render PostgreSQL service |
| `GEOAPI_KEY` | API key for the geo service |
| `ADMIN_AUTH_SECRET` | Secret for SQLAdmin authentication |
| `ADMIN_USERNAME` | SQLAdmin login username |
| `ADMIN_PASSWORD` | SQLAdmin login password |
| `AUTH_SECRET` | JWT signing secret for shelter staff |
| `ADOPTANT_SECRET` | JWT signing secret for adoptants |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name |
| `CLOUDINARY_API_KEY` | Cloudinary API key |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret |
| `MAIL_USERNAME` | SMTP username |
| `MAIL_PASSWORD` | SMTP password |
| `MAIL_FROM` | Sender email address |
| `MAIL_PORT` | SMTP port (e.g. 587) |
| `MAIL_SERVER` | SMTP server (e.g. smtp.gmail.com) |
| `FRONTEND_URL` | Public URL of the adoptant web app (e.g. `https://your-site.netlify.app`). Used in email links. Defaults to `http://localhost:5173` locally. |
| `PORTAL_BASE_URL` | Base URL of the adoption portal. Defaults to `http://localhost:5173`. |

`backend/.env.example` lists every variable with placeholder values.

> Never commit `.env` to the repository. Make sure it is in `.gitignore`.

---

## 4. Linking the Web Service to the Database

The link is handled via `render.yaml`:

```yaml
envVars:
  - key: DATABASE_URL
    fromDatabase:
      name: bastet-db
      property: connectionString
```

This tells Render to inject the internal database connection string automatically. No manual copy-paste needed as long as both services use the same name (`bastet-db`) and are in the same Render project.

---

## 5. Verifying the Deploy

Once deployed, Render gives you a URL like:

```
https://bastet-backend.onrender.com
```

Check these endpoints:

- `GET /` → should return `{"message": "bastet is running"}`
- `GET /docs` → FastAPI Swagger UI with all routes

> The free tier spins down after 15 minutes of inactivity. The first request after that will take 30–60 seconds to respond. Use [UptimeRobot](https://uptimerobot.com) with a 10-minute ping on `/` to keep it awake if needed.

---

## 6. Flutter — Building the APK

### Prerequisites

- Flutter SDK installed
- `baseUrl` in your app config pointing to the Render backend URL:
  ```dart
  static const String baseUrl = 'https://bastet-backend.onrender.com';
  ```

### Build

```bash
flutter build apk --split-per-abi
```

Output files:

```
build/app/outputs/flutter-apk/
  app-armeabi-v7a-release.apk    # older devices
  app-arm64-v8a-release.apk      # most modern phones
  app-x86_64-release.apk         # emulators
```

For testing on a real device, use `app-arm64-v8a-release.apk`.

### Install directly to a connected device

```bash
flutter install
```

Or with ADB:

```bash
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

---

## Quick Reference — Release Checklist

- [ ] Merge previous release branch into the new release branch
- [ ] Merge `dev` into the new release branch
- [ ] Push to GitHub
- [ ] Update Render web service branch to the new release branch
- [ ] Add any new environment variables in Render dashboard
- [ ] If models changed: make sure an Alembic migration is included (CI's `alembic check` enforces this); it is applied automatically on deploy
- [ ] Verify `/` and `/docs` are responding after deploy
- [ ] Build new APK with `flutter build apk --split-per-abi`
