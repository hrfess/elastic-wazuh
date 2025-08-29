FROM nginx:stable

# Install dependencies for certbot
RUN apt-get update && apt-get install -y cron certbot python3-certbot-nginx \
    && rm -rf /var/lib/apt/lists/*

# Copy entrypoint script
COPY ../../security/nginx/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose HTTP/HTTPS
EXPOSE 80 443

# Use our entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]

