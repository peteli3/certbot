# certbot
Containerized certbot with helpers for easy cert mangement with LetsEncrypt

For use on Linux platforms running apps that want https support.
Clone repo onto machine and run the provision script. LetsEncrypt may prompt you to enter an email address and answer some yes/no questions:

```bash
git clone https://github.com/peteli3/certbot.git ~/certbot
cd ~/certbot
./provision-new-certs.sh $DOMAIN_NAME $SERVICE_PORT
```

If successful, new certs will be written to disk at:
```bash
ls -al ~/certbot/generated/live/${DOMAIN_NAME}/
```

And new nginx config will be generated with default http and https settings:
```bash
cat ~/certbot/generated/nginx.conf
```

## Enable https connections via nginx

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

## Automatic certificate renewal

Assuming your app docker-compose is in $HOME.
If not, edit the line with `docker compose restart`.

Append to existing crontab:
```bash
(crontab -l; \
    echo "# Added by certbot"; \
    echo "30 2 1 * * cd $HOME/certbot && ./renew-certs.sh >> $HOME/certbot/renewal.log 2>&1"; \
    echo "00 3 * * * docker compose restart") \
    | crontab -
```

Replace existing crontab:
```bash
(echo "# Added by certbot"; \
    echo "30 2 1 * * cd $HOME/certbot && ./renew-certs.sh >> $HOME/certbot/renewal.log 2>&1";
    echo "00 3 * * * docker compose restart") \
    | crontab -
```

## Manual certificate renewal

Run renew script and restart app services:
```bash
cd ~/certbot
./renew-certs.sh

cd ~
docker compose restart
```
