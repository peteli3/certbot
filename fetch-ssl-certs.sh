#!/usr/bin/env bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 \$DOMAIN_NAME \$SERVICE_PORT"
    exit 1
fi

DOMAIN_NAME=$1
SERVICE_PORT=$2

if lsof -i :80 > /dev/null; then
    echo "Port 80 is already in use. Please free up port 80 and try again."
    exit 1
fi

# Generate configs for challenge server
mkdir generated/
cat << EOF > generated/nginx-challenge.conf
events {
  worker_connections 16;
}

http {
  server {
    listen 80;
    server_name ${DOMAIN_NAME};

    location /.well-known/acme-challenge/ {
      root /var/www/certbot;
    }

    location / {
      deny all;
    }
  }
}
EOF

# Run challenge server in background just for certbot
docker compose up --detach challenge
docker compose run --rm \
    certbot certonly --webroot \
    --webroot-path /var/www/certbot/ \
    -d $DOMAIN_NAME \
    || echo "Failed to obtain or renew ssl certs"
docker compose down challenge

# Cleanup challenge server configs which are no longer needed
rm -f generated/nginx-challenge.conf

# Generate new nginx config
cat << EOF > generated/nginx.conf
events {
  worker_connections 512;
  multi_accept on;
  use epoll;
}
http {
  server {
    listen 80;
    server_name ${DOMAIN_NAME};

    location / {
      proxy_pass http://${DOMAIN_NAME}:${SERVICE_PORT};
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
    }
  }

  server {
    listen 443 default_server ssl http2;
    listen [::]:443 ssl http2;
    server_name ${DOMAIN_NAME};

    ssl_certificate     /etc/nginx/ssl/live/${DOMAIN_NAME}/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/${DOMAIN_NAME}/privkey.pem;

    location / {
      proxy_pass http://${DOMAIN_NAME}:${SERVICE_PORT};
      proxy_set_header Host \$host;
      proxy_set_header X-Real-IP \$remote_addr;
      proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto \$scheme;
    }
  }
}
EOF
