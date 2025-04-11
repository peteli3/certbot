# certbot
Containerized certbot with helpers for easy cert mangement with LetsEncrypt

Intended for use on Linux platforms running apps that want https support.
Clone repository onto machine and run the fetch script. LetsEncrypt may prompt you to enter an email address and answer some yes/no questions:

```bash
git clone https://github.com/peteli3/certbot.git ~/certbot
cd ~/certbot
./fetch-ssl-certs.sh $DOMAIN_NAME $SERVICE_PORT
```

If successful, new certs will be fetched to:

```bash
ls -al ~/certbot/generated/live/${DOMAIN_NAME}/
```

And new nginx config will be generated with default http and https settings:

```bash
cat ~/certbot/generated/nginx.conf
```

Include a nginx proxy service with the generated certs in the docker-compose.yaml for app that wants https support:

```bash
services:
  # ... other services

  nginx:
    image: nginx:latest
    platform: linux/amd64
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "~/certbot/generated/nginx.conf:/etc/nginx/nginx.conf:ro"
      - "~/certbot/generated/:/etc/nginx/ssl/:ro"
    restart: unless-stopped

  # ... other services
```

When certs are nearing expiration, renew and restart app:

```bash
pushd ~/certbot
docker compose run --rm certbot renew
popd
docker compose restart
```
