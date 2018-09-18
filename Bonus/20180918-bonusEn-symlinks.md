# Bonus: setup nginx with symlinks
  
In order to make nginx's configuration easier, faster and more flexible, I recommend that you create a configuration file per subdomain. These files will need to be put in the */opt/etc/nginx/sites-enabled* folder to be active.
However, it's even better to put the files in the */opt/etc/nginx/sites-available* folder and create symbolic links to activate the subdomains.
  
If we take the example of a subdomain pointing to the web interface of a Kodi box ([point 6.1](https://github.com/pedrom34/TutoAsus#61-example-conf)) :  
To create the conf file:
```shell
vi /opt/etc/nginx/sites-available/kodi.domain.tld.conf
```
Paste or type the configuration:
```nginx
server {
    listen       443;
    server_name  kodi.domain.tld;
...
}
```
So far, only the folder containing the configuration files have changed. The difference is that to activate the configuration, you just have to type this:
```shell
ln -s /opt/etc/nginx/sites-available/kodi.domain.tld.conf /opt/etc/nginx/sites-enabled/kodi.domain.tld.conf && nginx -s reload
```
*nginx -s reload* allowing you to reload the nginx configuration to include this new conf file.
  
The same way, to remove a subdomain:
```shell
rm opt/etc/nginx/sites-enabled/kodi.domain.tld && nginx -s reload
```
Deleting the symlink disables the site without deleting the configuration in *sites-available*.
