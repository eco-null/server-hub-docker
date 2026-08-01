<p align="center"><img src="logo.png" width="120" height="120" alt="Server Hub logo"></p>

# server-hub-docker

Docker packaging for [Server Hub](https://github.com/eco-null/server-hub) — a self-hosted dashboard for your applications and services.

This repository provides a prebuilt image (`ghcr.io/eco-null/server-hub:latest`), a CasaOS-ready `docker-compose.yml`, and the configuration reference for running Server Hub in a container. The image runs non-root with persistent storage and reports the host's system stats.

## Prerequisites

- Docker with Compose v2
- CasaOS with terminal access, or any Docker Compose-capable host
- `git` (only to fetch this repository's compose file)

## Quick Start (CLI)

```bash
git clone https://github.com/eco-null/server-hub-docker.git
cd server-hub-docker

# Set a strong password, then start
docker compose up -d
```

Open http://<host>:8643 — sign in at `/login`.

## CasaOS Install (Custom App)

1. In CasaOS, go to **Apps → Custom App**.
2. Paste the contents of `docker-compose.yml`.
3. Set `HUB_USER` and `HUB_PASSWORD` in the compose environment block (or the CasaOS environment form).
4. Install. CasaOS pulls the prebuilt image and starts the container.

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `HUB_USER` | `admin` | Sign-in username. |
| `HUB_PASSWORD` | — (required) | Sign-in password. Server exits if empty. |
| `HUB_PORT` | `8642` | Container listen port (compose sets `8643`). |
| `HUB_HOST` | `0.0.0.0` | Bind address. |
| `HUB_DISK_PATH` | `/` | Filesystem path read for the disk widget (`/host` = CasaOS host root). |
| `BESZEL_URL` | *(empty)* | Beszel hub URL, e.g. `http://beszel:9520`. Empty disables multi-server stats. |
| `BESZEL_USER` | *(empty)* | Beszel account name used to fetch system stats. |
| `BESZEL_PASSWORD` | *(empty)* | Beszel account password. |

> **Before first start:** replace the placeholder `HUB_PASSWORD: CHANGE_ME` in `docker-compose.yml`. Leaving it unchanged starts the server with a known, weak password.

## Volumes and Persistence

- `services.json` (links and bookmarks) lives in the bind-mounted host path `/DATA/AppData/server-hub` (mapped to `/data` inside the container), symlinked to `/app/services.json`.
- Data survives image updates because it lives on the host path, not in the image.
- Updates: `docker compose pull && docker compose up -d`.

## Host System Stats

The compose file mounts the host's `/proc`, `/etc/hostname`, and `/etc` read-only, so the CPU / memory / disk / hostname widgets report the **host's** values. `HUB_DISK_PATH=/host` (backed by a small patch to upstream `server.py`) makes the disk widget read the host filesystem. If a mount is unavailable, the widget shows `—`; the app keeps serving.

## Beszel Multi-Server Stats

Set `BESZEL_URL` plus `BESZEL_USER` / `BESZEL_PASSWORD` to monitor all servers registered in your Beszel hub. The Beszel account must be a member of the systems you want to see (add it in the Beszel UI, or enable `SHARE_ALL_SYSTEMS` on the hub). When Beszel is unconfigured or unreachable, the dashboard falls back to the single-host stats widget.

## Security

- The container runs as a non-root `app` user; the entrypoint drops privileges with `su-exec` before starting the server.
- The compose file bind-mounts `- /etc:/host:ro`, granting the container read access to part of the host filesystem. This is required for host disk stats and is limited to this container's network — do not add other containers to this compose project.
- Beszel credentials are server-side environment variables only.

## Icon

`logo.png` can be used as the CasaOS custom-app icon — when installing a custom app, point the icon field at this file (e.g. `/DATA/AppData/server-hub-docker/logo.png`, or wherever you cloned the repository).

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Container exits immediately | `HUB_PASSWORD` empty | Set it in `docker-compose.yml`. |
| Stats show `—` | `/proc` or `/host` mount unavailable | Check the compose `volumes:` block. |
| Port conflict | `8643` in use | Change the left side of `8643:8643`. |
