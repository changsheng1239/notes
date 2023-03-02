## Requirements:

1.  Define a proper working `docker-compose.yml`.

2.  Backup database (mysql/mariadb/pgsql).
   
3.  Edit existing `config.php` :
   
	a.  Set redis connection      

	```php
	'redis' => array (
	  'host' => 'redis',
	  'port' => '6379',
	),
	```

	b.  Make sure you have no configuration for the `apps_paths`. Delete lines like these

	```php
	'apps_paths' => array (
	   0 => array (
		   'path' => OC::$SERVERROOT.'/apps',
		   'url' => '/apps',
		   'writable' => true,
	   ),
	),
	```

	c.  Make sure to have the `apps` directory non writable and the `custom_apps` directory writable

	```php
	'apps_paths' => array (
	  0 => array (
		'path' => '/var/www/html/apps',
		'url' => '/apps',
		'writable' => false,
	  ),
	  1 => array (
		'path' => '/var/www/html/custom_apps',
		'url' => '/custom_apps',
		'writable' => true,
	  ),
	),
	```

    d.  Make sure your data directory is set to /var/www/html/data

	```php
	'datadirectory' => '/var/www/html/data',
	```

4.  Mount the `data` directory onto new docker host.

    a.  Make sure the owner is `www-data`.

1.  Copy only the custom apps you use:

```bash
mkdir custom_apps
cp -r apps/sociallogin custom_apps/
cp -r apps/impersonate custom_apps/
```

6.  Apply correct permissions to the whole nextcloud folder:

```bash
chown -R www-data:www-data nextcloud
```