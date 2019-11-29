# Nextcloud Setup

## Installation
**nginx**
```
apt update && apt install nginx -y
```

**redis**
```
apt update && apt install redis -y
```

**php7.3**
```
apt update && apt install php7.3-fpm php7.3-gd php7.3-mysql php7.3-curl php7.3-xml php7.3-zip php7.3-intl php7.3-mbstring php7.3-json php7.3-bz2 php7.3-ldap php-apcu imagemagick php-imagick php-smbclient php-redis -y
```

```
curl -s https://download.nextcloud.com/server/releases/nextcloud-17.0.0.tar.bz2 | tar -xj
mkdir /var/www
mv nextcloud/ /var/www
chown -R www-data:www-data /var/www
```

**nginx nextcloud.conf**
```
nano /etc/nginx/conf.d/nextcloud.conf
```
**Use the latest configuration from [nextcloud documentation](https://docs.nextcloud.com/server/15/admin_manual/installation/nginx.html)**

---
## Configuration
### config.php
```php
'knowledgebaseenabled' => false,    /* Remove Help from top right menu */
'skeletondirectory' => '',          /* Empty skeleton directory */
'lost_password_link' => 'disabled', /* Disable Password Reset */
'simpleSignUpLink.shown' => false,   /* Remove 'Get your own free account' in public share */
'memcache.local' => '\OC\Memcache\Redis',
'memcache.locking' => '\OC\Memcache\Redis',
'redis' => [
    'host' => 'localhost',
    'port' => 6379,
],
```


### Custom CSS
```css
/* 
    Hide Webdav on UI Settings (Bottom left) 
*/
label[for=webdavurl] {
    display: none;
}

#webdavurl {
    display: none;
}

#app-settings-content em {
    display: none;
}

/*
    Hide FollowUp Section in Settings Page
*/
.followupsection {
    display: none;
}

/*
    Hide Change Password section in user Security setting
*/
div#security-password {
    display: none;
}
```
**Extra: Block `/remote.php/webdav` access in webserver to completely deny user webdav access**