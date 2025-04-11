#!/usr/bin/env bash

if [ ! -d ./generated/ ]; then
    echo "No generated certs found"
    exit 1
fi

docker compose run --rm certbot renew --force-renewal
