# Troubleshooting

## 1. App Store Timeout

Update the following files to extend the timeout of app store

```
3rdparty/guzzlehttp/guzzle/src/Handler/CurlFactory.php 
line 404

increase timeout from 1000 to 10000
```

```
lib/private/App/AppStore/Fetcher/Fetcher.php
line 98

increase timeout from 10 to 30 or 90
```

```
lib/private/Http/Client.php
line 66

increase timeout from 30 to 90
```

## 2. Download stop at 1GB

Update `fast_cgi_max_temp_file_size`, default to `1G`

```
nginx.conf
fastcgi_max_temp_file_size  0; 
```
