# Deployment Guide — Bastet Shelter

This document covers how to deploy the backend to Render, link it to the PostgreSQL database, and build the Flutter APK for testing.

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
   - **Start Command**: `uvicorn app.main:app --host 0.0.0.0 --port $PORT`
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
3. Redeploy the backend — `create_all` will recreate all tables on startup

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
- [ ] If DB schema changed: wipe the DB and let `create_all` rebuild it
- [ ] Verify `/` and `/docs` are responding after deploy
- [ ] Build new APK with `flutter build apk --split-per-abi`
