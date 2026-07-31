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
ln -sf /data/services.json /app/services.json

exec su-exec app python3 server.py
