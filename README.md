# certbot
Containerized certbot with helpers for easy cert mangement with LetsEncrypt

Intended for use on Linux platforms running apps or services that want https support.
Clone repository onto machine and run the fetch script. LetsEncrypt may prompt you to enter an email address and answer some yes/no questions:

```bash
cd ~
git clone https://github.com/peteli3/certbot.git
cd certbot/
./fetch-ssl-certs.sh $DOMAIN_NAME $SERVICE_PORT
```

If successful, new certs will be fetched to:

```bash
ls -al ~/certbot/live/${DOMAIN_NAME}/
```

And new nginx config will be generated with default http and https settings:

```bash
cat ~/certbot/nginx.conf
```
