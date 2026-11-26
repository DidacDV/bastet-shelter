# Task: Deploy the backend to Render as a Docker image

**Status: pending.** This file is a self-contained brief for whoever picks the task up (a person or an AI assistant). Read it fully before changing anything.

## Goal

Switch the Render web service `bastet-backend` from Render's native Python runtime to building `backend/Dockerfile`, so production runs the exact image used locally and in CI. Behaviour, URL, environment variables and database must stay the same.

**Out of scope:** running PostgreSQL in a container on Render. Production keeps the managed Render PostgreSQL `bastet-db`. Container filesystems are wiped on every deploy and the free plan has no persistent disk, so a containerised database would lose all data.

## Current state

| Piece | Where | Notes |
|---|---|---|
| Render config | `backend/render.yaml` | `runtime: python`, `buildCommand: pip install -r requirements.txt`, `startCommand: bash scripts/render_start.sh`, env vars, `bastet-db` link |
| Start script | `backend/scripts/render_start.sh` | Bootstraps `alembic_version` on legacy DBs, runs `alembic upgrade head`, then `exec uvicorn ... --port "$PORT"`. Requires `PORT` to be set. Must keep LF line endings (enforced by `.gitattributes`). |
| Image | `backend/Dockerfile` | `python:3.12-slim`, runs as non-root user `bastet`, `ENV PORT=8000`, `CMD ["bash", "scripts/render_start.sh"]` |
| Build context exclusions | `backend/.dockerignore` | Excludes `.env`, `.venv`, `*.db`, caches |
| Local stack | `docker-compose.yml` (repo root) | Postgres 16 + backend, plus `seed` and `test` helper services |
| CI | `.github/workflows/backend-ci.yml` | Tests against Postgres, `alembic check`, and a `docker build` of `backend/` |
| Docs | `DEPLOYMENT.md` | Release process, env var table, local Docker usage |
| Legacy | `backend/Procfile` | Not used by Render (it uses `render.yaml` / dashboard settings); runs Uvicorn without migrations |

Render deploys from the **current release branch** (`release/#N`), not `main`. See "Branching Strategy" in `DEPLOYMENT.md`.

Python version: the image pins 3.12 (same as CI). The native Render runtime may currently use a different default version, so this switch can also change the Python version in production. That is intended, but keep it in mind if something behaves differently.

## Steps

1. **Find out how the service is managed.** In the Render dashboard, check whether `bastet-backend` is linked to a Blueprint. `render.yaml` lives in `backend/`, not the repo root, so it may not be applied automatically.
   - If it is Blueprint-managed: change `render.yaml` (step 2) and sync the Blueprint.
   - If not: apply the same settings in **Settings** in the dashboard (step 3), and still update `render.yaml` so the repo stays the source of truth.

2. **Update `backend/render.yaml`** for the web service:
   ```yaml
   - type: web
     name: bastet-backend
     runtime: docker
     rootDir: backend
     dockerfilePath: ./Dockerfile
     healthCheckPath: /
     envVars:
       # unchanged
   ```
   - Remove `buildCommand` and `startCommand`; they don't apply to Docker services. The image's `CMD` already runs `scripts/render_start.sh`.
   - Keep the `databases:` block and every `envVars` entry exactly as they are.
   - Do **not** add `preDeployCommand`. It is only available on paid plans, and migrations already run in the start script.

3. **Dashboard equivalent** (if not Blueprint-managed): Settings → set **Language/Runtime** to `Docker`, **Root Directory** `backend`, **Dockerfile Path** `./Dockerfile`, leave **Docker Command** empty, **Health Check Path** `/`. Render allows changing an existing service's runtime, so don't create a new service: that would change the URL used by the web app, the mobile app and the UptimeRobot / `scheduled-ping` monitor.

4. **Port.** Render provides a `PORT` env var to web services (default `10000`) and routes traffic to it. The script binds to `$PORT`, and the `ENV PORT=8000` in the Dockerfile is only a fallback for local runs. After the first deploy, confirm in the logs that Uvicorn listens on the port Render expects.

5. **Secrets.** Render passes service env vars to the Docker build as build args. The Dockerfile must never declare `ARG`s for secrets or bake them into layers. Today it references none; keep it that way.

6. **Deploy on a release branch first.** Do the change on a new `release/#N` branch, point Render at it, deploy, and verify (see below) before merging to `main`.

## Verify locally before touching Render

From the repo root, with `backend/.env` filled in:

```bash
docker build -t bastet-backend:render backend
docker run --rm -p 10000:10000 -e PORT=10000 --env-file backend/.env \
  -e DATABASE_URL=<a disposable postgres URL> bastet-backend:render
curl http://localhost:10000/          # {"message":"bastet is running"}
```

Or use the full stack: `docker compose up -d --build` and check `http://localhost:8000/docs`.

## Verify on Render (acceptance criteria)

- [ ] Build log shows the Dockerfile build (BuildKit steps), not `pip install` from the native runtime
- [ ] Deploy log shows `alembic upgrade head` completing (no "Bootstrapped alembic_version" on an already-migrated DB), then `Uvicorn running on http://0.0.0.0:<PORT>`
- [ ] `GET /` returns `{"message":"bastet is running"}` and `HEAD /` returns 200 (used by uptime monitoring)
- [ ] `GET /docs` loads
- [ ] Logging in from the web app and the mobile app works against the existing data (proves the same `bastet-db` is connected)
- [ ] An image upload works (Cloudinary env vars present) and an email-triggering flow works (mail env vars present)
- [ ] `DEPLOYMENT.md`: section 1 says Runtime **Docker** and no longer lists the build/start commands; release checklist updated
- [ ] `backend/Procfile` deleted if nothing else uses it

## Rollback

Set the runtime back to Python with build command `pip install -r requirements.txt` and start command `bash scripts/render_start.sh` (or revert the `render.yaml` change and resync), then redeploy. The database isn't affected by the switch, so rollback is safe.

## Gotchas

- `scripts/render_start.sh` must stay LF. With CRLF, bash fails inside the container with errors like `set: pipefail\r: invalid option`. `.gitattributes` enforces LF for `*.sh`; don't remove it.
- Render caches pulled base images. If you need a specific Python patch release, pin it (e.g. `python:3.12.x-slim`) instead of relying on the floating `3.12-slim` tag.
- Free-tier instances spin down after inactivity. The first request after a spin-down includes container start and the migration check (a few seconds more than native). The `scheduled-ping` workflow keeps it warm.
- Changing files outside `backend/` won't trigger a deploy once `rootDir: backend` is set. That is intended.
