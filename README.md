# server-hub-docker

> Docker packaging for [Server Hub](https://github.com/eco-null/server-hub) — a self-hosted launchpad for your apps and services.

Thin wrapper: the image clones upstream `server-hub` at build time and runs it non-root with persistent storage and **host** system stats.

## Prerequisites
- Docker (with Compose v2)
- CasaOS with the terminal available, or any docker-compose-capable host
- `git` (only needed to build the image)

## Quick start (CLI)
1. Clone this repo: `git clone https://github.com/eco-null/server-hub-docker.git && cd server-hub-docker`
2. `cp .env.example .env` — set `HUB_PASSWORD` to a strong value (`openssl rand -base64 24`)
3. `docker compose up -d --build`
4. Open http://<host>:8643 — sign in at `/login`

## CasaOS install (Custom App)
1. Build the image once: `docker build -t server-hub:local .`
2. In CasaOS, go to **Apps → Custom App**.
3. Paste the contents of `docker-compose.yml`.
4. Create a `.env` file **next to the compose file** (CasaOS stores it under the app's project directory) with `HUB_USER=admin`, `HUB_PASSWORD=<your-password>`. The `.env` file must exist before install — compose refuses to start if it's missing, and there is no "set variables in the form" alternative.
5. Click **Install**. CasaOS starts the container; the dashboard appears under the configured port.

## Environment variables
| Variable | Default | Notes |
|---|---|---|
| `HUB_USER` | `admin` | Sign-in username |
| `HUB_PASSWORD` | — (required) | Sign-in password; server exits if empty |
| `HUB_PORT` | `8642` | Container listen port (compose sets `8643`) |
| `HUB_HOST` | `0.0.0.0` | Bind address |
| `HUB_DISK_PATH` | `/` | Filesystem path read for the disk widget (`/host` = CasaOS host root) |

## Persistence
- `services.json` (your added links) lives in the named volume `server-hub-data`, mounted at `/data` and symlinked to `/app/services.json`.
- Updates: `git pull`, then `docker compose up -d --build`. Data survives because it lives on the volume, not in the image.

## Host stats
The compose file mounts the host's `/proc`, `/etc/hostname`, and root `/` read-only, so CPU / memory / disk / hostname widgets show the **CasaOS host's** values. The `HUB_DISK_PATH=/host` env var (backed by a small patch to upstream `server.py`) makes the disk widget read the host root. If a mount is unavailable the widget shows `—`; the app keeps serving.

## Security notes
- The container runs as a non-root `app` user; the entrypoint drops privileges with `su-exec` before starting the server.
- Secrets live only in `.env`, which is gitignored — never commit it.
- The compose file bind-mounts `- /:/host:ro`, granting the container **read access to the whole host filesystem**. That tradeoff is required for host disk stats and is limited to this container's network — don't add other containers to this compose project.

## Troubleshooting
| Symptom | Likely cause | Fix |
|---|---|---|
| Container exits immediately | `HUB_PASSWORD` empty | Set it in `.env` |
| Stats show `—` | `/proc`/`/host` mount unavailable | Check compose `volumes:` are intact |
| Port conflict | `8643` in use | Change the left side of `8643:8643` |
