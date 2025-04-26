#!/usr/bin/env bash

if [ ! -d ./generated/ ]; then
    echo "No generated certs found"
    exit 1
fi

echo
echo "***** Renewing certs - $(date) *****"

docker compose run --rm certbot renew --force-renewal

echo "***** Completed renewal - $(date) *****"
echo
