FROM python:3-alpine

RUN apk add --no-cache git su-exec

# Clone upstream at build time (current main)
RUN git clone --depth 1 https://github.com/eco-null/server-hub.git /app

# Apply the disk-path patch so host disk stats work (HUB_DISK_PATH).
# Use `git apply` (git is already installed) — busybox in alpine has no `patch` applet.
COPY patches/disk-path.patch /tmp/disk-path.patch
RUN cd /app && git apply /tmp/disk-path.patch && rm /tmp/disk-path.patch

# Entrypoint bootstraps the /data volume and drops privileges
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Non-root app user
RUN addgroup -S app && adduser -S -G app app
RUN mkdir -p /data && chown app:app /data

WORKDIR /app
EXPOSE 8643
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["python3", "server.py"]
