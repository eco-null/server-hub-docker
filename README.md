<p align="center"><img src="logo.png" width="120" height="120" alt="Server Hub logo"></p>

# server-hub-docker

> Docker packaging for [Server Hub](https://github.com/eco-null/server-hub) — a self-hosted launchpad for your apps and services.

Thin wrapper: runs the prebuilt `ghcr.io/eco-null/server-hub:latest` image non-root with persistent storage and **host** system stats.

Includes the latest Server Hub dashboard features: compact two-column layout, bookmarks, wallpaper + dynamic theming, and Beszel multi-server stats.

## Prerequisites
- Docker (with Compose v2)
- CasaOS with the terminal available, or any docker-compose-capable host
- `git` (only needed to fetch this repo's compose file)

## Quick start (CLI)
1. Clone this repo (or just copy `docker-compose.yml`): `git clone https://github.com/eco-null/server-hub-docker.git && cd server-hub-docker`
2. Edit `HUB_PASSWORD` in `docker-compose.yml` to a strong value (`openssl rand -base64 24`).
3. `docker compose up -d`
4. Open http://<host>:8643 — sign in at `/login`

## CasaOS install (Custom App)
1. In CasaOS, go to **Apps → Custom App**.
2. Paste the contents of `docker-compose.yml`.
3. Set `HUB_USER` and `HUB_PASSWORD` in the compose env block (or the CasaOS environment form) to your values.
4. Click **Install**. CasaOS pulls the prebuilt image `ghcr.io/eco-null/server-hub:latest` and starts the container.

## Icon
`logo.png` can be used as the CasaOS custom-app icon — when installing a custom app, point the icon field at this file (e.g. `/DATA/AppData/server-hub-docker/logo.png` or wherever you cloned the repo).

## Environment variables
| Variable | Default | Notes |
|---|---|---|
| `HUB_USER` | `admin` | Sign-in username |
| `HUB_PASSWORD` | — (required) | Sign-in password; server exits if empty |
| `HUB_PORT` | `8642` | Container listen port (compose sets `8643`) |
| `HUB_HOST` | `0.0.0.0` | Bind address |
| `HUB_DISK_PATH` | `/` | Filesystem path read for the disk widget (`/host` = CasaOS host root) |
| `BESZEL_URL` | (empty) | Beszel hub URL (e.g. `http://beszel:9520`). Leave empty to disable multi-server stats. |
| `BESZEL_USER` / `BESZEL_PASSWORD` | (empty) | Beszel login credentials used to fetch system stats. |

## Beszel multi-server stats
Set `BESZEL_URL` (e.g. `http://beszel:9520` or `https://bs.example.com`) plus `BESZEL_USER` / `BESZEL_PASSWORD` to watch CPU / memory / disk across all servers in your Beszel hub. The Beszel account must be a **member** of the systems you want to see (add it in the Beszel UI, or enable `SHARE_ALL_SYSTEMS` on the hub). When Beszel is unconfigured or unreachable, the dashboard falls back to the single-host stats widget.

## Persistence
- `services.json` (your added links and bookmarks) lives in the bind-mounted directory `./data` (mapped to `/DATA/AppData/server-hub` on the host), symlinked to `/app/services.json` inside the container.
- Updates: `docker compose pull && docker compose up -d`. Data survives because it lives on the host path, not in the image.

## Host stats
The compose file mounts the host's `/proc`, `/etc/hostname`, and `/etc` read-only, so CPU / memory / disk / hostname widgets show the **CasaOS host's** values. The `HUB_DISK_PATH=/host` env var (backed by a small patch to upstream `server.py`) makes the disk widget read the host filesystem. If a mount is unavailable the widget shows `—`; the app keeps serving.

## Security notes
> **Before first start:** replace the placeholder `HUB_PASSWORD: CHANGE_ME` in the compose file — leaving it unchanged starts the server with a known, weak password.

- The container runs as a non-root `app` user; the entrypoint drops privileges with `su-exec` before starting the server.
- The compose file bind-mounts `- /etc:/host:ro`, granting the container **read access to part of the host filesystem**. That tradeoff is required for host disk stats and is limited to this container's network — don't add other containers to this compose project.

## Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| Container exits immediately | `HUB_PASSWORD` empty | Set it in `docker-compose.yml` |
| Stats show `—` | `/proc`/`/host` mount unavailable | Check compose `volumes:` are intact |
| Port conflict | `8643` in use | Change the left side of `8643:8643` |
