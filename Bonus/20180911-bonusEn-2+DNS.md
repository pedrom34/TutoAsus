# Bonus: two (or more) DynDNS domains  
  
<a href="https://www.dnsomatic.com/" target="_blank"><img src="http://www.dnsomatic.com/img/dnsomatic_logo_2000.gif" width="250"></a>  
  
Some months after I wrote this tutorial, I needed to add another DynDNS domain to my router. With a quick search, I found that the best solution for me was to use [DNS-O-Matic](https://www.dnsomatic.com/). To make this work, simply add your DynDNS providers in the web interface.
>![Interface DNS-O-Matic](https://i.imgur.com/m1KH826.png)  
  
And then modify the script given in [point 4.2.](https://github.com/pedrom34/TutoAsus#42-router-side) with this command:  
  
```shell
vi /jffs/scripts/ddns-start
```
  
Replace every line by:  
```shell
#!/bin/sh
# Update the following variables:
USERNAME=dnsomatic_username
PASSWORD=dnsomatic_password
HOSTNAME=all.dnsomatic.com

# Should be no need to modify anything beyond this point
/usr/sbin/curl -k --silent -u "$USERNAME:$PASSWORD" "https://updates.dnsomatic.com/nic/update?hostname=$HOSTNAME&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG&myip=" > /dev/null
if [ $? -eq 0 ]; then
  /sbin/ddns_custom_updated 1
else
  /sbin/ddns_custom_updated 0
fi
```
  
Now, to get the certificate with this particular situation, you just have to modify the acme.sh commands like this:  
- Issue the cert:  
```shell
./acme.sh  --home "/jffs/scripts/acme.sh" --issue  \
-d domain1.ovh  --dns dns_ovh \
-d *.domain1.ovh  --dns dns_ovh \
-d domain2.duckdns.org  --dns dns_duckdns  \
-d *.domain2.duckdns.org --dns dns_duckdns
```
  
- Install the cert in nginx:  
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --install-cert \
-d domain1.ovh -d domain2.duckdns.org \
--key-file  /opt/etc/nginx/cert.key \
--fullchain-file  /opt/etc/nginx/cert.crt \
--reloadcmd "nginx -s reload"
```
  
