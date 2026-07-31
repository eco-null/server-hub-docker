#!/bin/sh
set -e

# Ensure the data volume exists and is owned by the app user
mkdir -p /data
if [ ! -f /data/services.json ]; then
  if [ -f /app/services.json ]; then
    cp /app/services.json /data/services.json
  else
    printf '{"services": []}\n' > /data/services.json
  fi
fi
chown -R app:app /data
# /app is root-owned (git clone) but upstream writes services.json.tmp alongside
# services.json on every save, so the app user must own the whole tree.
chown -R app:app /app
ln -sf /data/services.json /app/services.json

exec su-exec app python3 server.py
