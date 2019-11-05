# Openresty 

## Installation

**Debian**
```bash
sudo apt-get -y install --no-install-recommends wget gnupg ca-certificates
wget -O - https://openresty.org/package/pubkey.gpg | sudo apt-key add -
sudo apt-get -y install --no-install-recommends software-properties-common
sudo add-apt-repository -y "deb http://openresty.org/package/debian $(lsb_release -sc) openresty"
sudo apt-get update
sudo apt-get -y install openresty
```
Installed at `/usr/local/openresty`


## Configuration file

```
mkdir /usr/local/openresty/nginx/conf.d
mkdir /usr/local/openresty/nginx/lua.d
```

**nginx.conf**

`/usr/local/openresty/nginx/conf`

```
user  www-data;
worker_processes  auto;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;

    access_log /var/log/openresty/access.log;
    error_log /var/log/openresty/error.log;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    sendfile        on;
    tcp_nopush      on;
    tcp_nodelay     on;

    keepalive_timeout  65;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;
    gzip  on;
    gzip_disable "msie6";

    include ../conf.d/*.conf;
}
```