#!/bin/bash
set -e

# Check if first run is enabled
if [ "$FIRST_RUN" = "true" ]; then
    echo "[INFO] First run detected, running certbot..."
    certbot certonly --nginx --non-interactive --agree-tos -m "$CERTBOT_EMAIL" -d "$CERTBOT_DOMAINS"
    echo "[INFO] Certificates obtained."
fi

# Setup cron jobs for renewal and nginx reload
echo "0 */12 * * * certbot renew --quiet && nginx -s reload" >> /etc/crontab
echo "0 */6 * * * nginx -s reload" >> /etc/crontab

# Start cron in background
cron &

# Start nginx (keep it in foreground)
exec "$@"

