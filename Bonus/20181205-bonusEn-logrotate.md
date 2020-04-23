# Bonus: logrotate to handle nginx logs
  
All nginx events are logged in "/opt/var/log/nginx/". As time goes by, error and access files get heavier and heavier. To avoid problems, it may be useful to use logrotate to replace logs according to predefined rules.
  
## Installation
We're gonna use Entware to install logrotate:
```shell
opkg install logrotate
```

## Configuration
The easiest way is to create a special configuration file for nginx logs in /opt/etc/logrotate.d/, so:  
```shell
vi /opt/etc/logrotate.d/nginx
```
Text is inserted with "i" and saved with Esc and then":ZZ".  
Here is my configuration:  
```shell
/opt/var/log/nginx/access.log {
		prerotate
			nginx -s stop
		weekly
		rotate 4
		postrotate
			nginx -s start
		compress
		delaycompress
		missingok
		notifempty
		create 644
}

/opt/var/log/nginx/error.log {
		prerotate
			nginx -s stop
		weekly
		rotate 4
		postrotate
			nginx -s start
		compress
		delaycompress
		missingok
		notifempty
		create 644
}
```
My config stops nginx, rotates the logs, compresses them, then restarts nginx. For more information on configuration, refer to [the man](https://manpages.debian.org/stretch/logrotate/logrotate.8.en.html).

## Setting up a cron job
In order for logrotate to be launched automatically on a regular basis, it is necessary to modify the services-start file:
```shell
vi /jffs/scripts/services-start
```
to add - at the end - the following line:
```shell
cru a "logrotate" '0 2 * * 1 logrotate /opt/etc/logrotate.d/nginx > /dev/null'
```
This line allows to launch logrotate every Monday at 2am, with the configuration present in /opt/etc/logrotate.d/nginx.
