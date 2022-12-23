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
**php tuning**
```bash
# backup before tuning
cp /etc/php/7.3/fpm/pool.d/www.conf /etc/php/7.3/fpm/pool.d/www.conf.bak
cp /etc/php/7.3/cli/php.ini /etc/php/7.3/cli/php.ini.bak
cp /etc/php/7.3/fpm/php.ini /etc/php/7.3/fpm/php.ini.bak
cp /etc/php/7.3/fpm/php-fpm.conf /etc/php/7.3/fpm/php-fpm.conf.bak
cp /etc/ImageMagick-6/policy.xml /etc/ImageMagick-6/policy.xml.bak

# /etc/php/7.3/cli/php.ini
sed -i "s/output_buffering =.*/output_buffering = 'Off'/" /etc/php/7.3/cli/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/7.3/cli/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/7.3/cli/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10240M/" /etc/php/7.3/cli/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10240M/" /etc/php/7.3/cli/php.ini

# /etc/php/7.3/fpm/php.ini
sed -i "s/memory_limit = 128M/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
sed -i "s/output_buffering =.*/output_buffering = 'Off'/" /etc/php/7.3/fpm/php.ini
sed -i "s/max_execution_time =.*/max_execution_time = 3600/" /etc/php/7.3/fpm/php.ini
sed -i "s/max_input_time =.*/max_input_time = 3600/" /etc/php/7.3/fpm/php.ini
sed -i "s/post_max_size =.*/post_max_size = 10240M/" /etc/php/7.3/fpm/php.ini
sed -i "s/upload_max_filesize =.*/upload_max_filesize = 10240M/" /etc/php/7.3/fpm/php.ini
sed -i "s/;date.timezone.*/date.timezone = Europe\/\Berlin/" /etc/php/7.3/fpm/php.ini
sed -i "s/;session.cookie_secure.*/session.cookie_secure = True/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.enable=.*/opcache.enable=1/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.enable_cli=.*/opcache.enable_cli=1/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.memory_consumption=.*/opcache.memory_consumption=128/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.interned_strings_buffer=.*/opcache.interned_strings_buffer=8/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.max_accelerated_files=.*/opcache.max_accelerated_files=10000/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.revalidate_freq=.*/opcache.revalidate_freq=1/" /etc/php/7.3/fpm/php.ini
sed -i "s/;opcache.save_comments=.*/opcache.save_comments=1/" /etc/php/7.3/fpm/php.ini

# /etc/ImageMagic-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"PS\"/rights=\"read|write\" pattern=\"PS\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"EPI\"/rights=\"read|write\" pattern=\"EPI\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"PDF\"/rights=\"read|write\" pattern=\"PDF\"/" /etc/ImageMagick-6/policy.xml
sed -i "s/rights=\"none\" pattern=\"XPS\"/rights=\"read|write\" pattern=\"XPS\"/" /etc/ImageMagick-6/policy.xml
```

**nextcloud**
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
'memcache.local' => '\OC\Memcache\APCu',
'memcache.distributed' => '\OC\Memcache\Redis',
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

---
## Multiple Instances

**1. Connect to same database.**

**2. Three folders are required to be identical:**
```
1. config
2. themes
3. data (nfs mount)
4. custom_apps
```

## Apps to be installed
```
1. Custom CSS   (theming_customcss)
2. Social Login (sociallogin)
3. ONLYOFFICE (onlyoffice)
4. Impersonate (impersonate)
```

## Apps to be disabled
```
1. First Run Wizard (firstrunwizard)
2. Privacy (privacy)
```

## Apps to be enabled
```
1. External Storage Support (files_external)
2. LDAP user and group backend (user_ldap)
```
---
### php commands 
```
run_as "php /var/www/html/occ app:enable files_external"
run_as "php /var/www/html/occ app:enable user_ldap"
run_as "php /var/www/html/occ app:disable firstrunwizard"
run_as "php /var/www/html/occ app:disable privacy"
run_as "php /var/www/html/occ app:install impersonate"
run_as "php /var/www/html/occ app:install sociallogin"
run_as "php /var/www/html/occ app:install theming_customcss"
run_as "php /var/www/html/occ app:install onlyoffice"

run_as "php occ ldap:create-empty-config"
run_as "php occ ldap:set-config s01 ldapBase 'dc=cs-debian-10,dc=lan,dc=sql,dc=com,dc=my'"
run_as "php occ ldap:set-config s01 ldapBaseGroups 'dc=cs-debian-10,dc=lan,dc=sql,dc=com,dc=my'"
run_as "php occ ldap:set-config s01 ldapBaseUsers 'dc=cs-debian-10,dc=lan,dc=sql,dc=com,dc=my'"
run_as "php occ ldap:set-config s01 ldapHost 'cs-debian-10.lan.sql.com.my'"
run_as "php occ ldap:set-config s01 ldapPort '389'"
run_as "php occ ldap:set-config s01 ldapLoginFilter '(&(|(objectclass=inetOrgPerson))(uid=%uid))'"
run_as "php occ ldap:test-config s01"
```