#!/bin/sh

mkdir -p /tmp/letsencrypt-auto
mkdir -p /etc/letsencrypt/ssl 2> /dev/null

[ -f /etc/letsencrypt/ssl/dhparam.pem ] || openssl dhparam -out /etc/letsencrypt/ssl/dhparam.pem 2048

# bootstrap certbot
[ -d /etc/letsencrypt/live/test.melpa.org ] || certbot certonly \
    --standalone \
    --agree-tos \
    --email dcurtis@gmail.com \
    --expand \
    --non-interactive \
    --rsa-key-size 4096 \
    --force-renewal \
    --expand \
    --staging \
    -d test.melpa.org \
    -d stable-test.melpa.org && first_run=true

nginx -g 'daemon off;' &
nginx_pid=$!

while true; do
    echo "goodnight world..."
    # sleep for 1 day
    sleep 86400

    echo "rotate them logs"
    logrotate /etc/logrotate

    echo "maybe refreshing certbot..."
    mkdir -p /tmp/letsencrypt-auto
    certbot certonly \
        --webroot \
        --webroot-path /tmp/letsencrypt-auto \
        --agree-tos \
        --email dcurtis@gmail.com \
        --expand \
        --non-interactive \
        --rsa-key-size 4096 \
        --expand \
        --staging \
        -d test.melpa.org \
        -d stable-test.melpa.org

    echo "restarting nginx..."
    kill -HUP $nginx_pid
done
