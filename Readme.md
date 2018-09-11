# Install a SSL reverse proxy on an Asus Router with OVH domain

Lire dans une autre langue : [Français 🇫🇷](Readme.fr.md), [English 🇬🇧](Readme.md).  

## Menu
0. [What? Why?](#0-what-why)
1. [Install Merlin on the router](#1-install-merlin-on-the-router)
2. [Activate SSH and JFFS partition](#2-activate-ssh-et-jffs-partition)
3. [Install Entware](#3-install-entware)
4. [Setup OVH DynHost on the router](#4-using-ovh-dynhost-on-your-router)
5. [Install nginx](#5-install-nginx)
6. [Set up nginx](#6-set-up-nginx)
7. [Get Let's Encrypt certificate](#7-get-lets-encrypt-certificate)
8. [Conclusion](#8-a-few-words-of-conclusion)
9. [Sources](#9-on-the-shoulders-of-giants)

## 0. What? Why?
A reverse proxy is a small server that provides access to the user interfaces behind it, for example: camera web interfaces, multimedia servers, Nas, self-hosted calendar or email, etc. The goal is to access resources from the outside, without having to use a VPN. VPN and reverse proxy are not mutually exclusive as the proxy really is useful for web interfaces. In addition, the VPN allows increased security, when using public wifi for instance.  
  
### 0.1. What about security?
The reverse proxy *can be* secrure. You just have to use a certificate, the connection will be encrypted between the external computer and the proxy. And with Let's Encrypt, it is possible to have a free certificate recognized by browsers and the little green padlock! In addition, Let's Encrypt launched in 2018 the support for *wildcard* certificates: it is now possible to request a certificate for "\*.domain.com" rather than "pouet.domain.com, pouet2.domain. com, ... ". Last, you can also add authentication for interfaces that doesn't natively provide it.
  
### 0.2. In real terms...
I set up this configuration because I have an Asus router - AC86U - behind the box provided by my ISP, it is there to fill the gaps of this box: custom DNS, firewall and advanced DHCP, VPN server and client, dnsmasq, etc. And this router also allows me to run nginx - which I use as a reverse proxy - and to use my Ovh domain with my dynamic IP address (DynHost).  
  
I originally did this markdown file to remember what I had done. So why not share?
  
## 1. Install Merlin on the router
<a href="https://asuswrt.lostrealm.ca/" target="_blank"><img src="https://dpfpic.com/data/medias/Box/Asuswrt-Merlin.png" width="250"></a>  
The Merlin firmware is a modification of the official Asus firmware. It has the advantage of offering many improvements without removing Asus pleasant graphical interface. It also allows Entware to be used - I'll come back to this a little later.  
Installing Merlin is very simple, just download the firmware from https://asuswrt.lostrealm.ca/download, and flash the file from Administration > Firmware Upgrade.  
  
There is no real risk in using Merlin, as it is very easy to go back, and reinstall the official firmware.  
  
## 2. Activate SSH et JFFS partition
Once the router is running Merlin, go to Administration > System, and activate the JFFS partition.
>![Interface routeur, activation de JFFS](https://i.imgur.com/ryhJJ6K.png)  
  
Still on the same page, enable SSH access by selecting "LAN Only", the interface will pass in https on port 8443 automatically:  
>![Interface routeur, activation SSH et GUI en https 8443](https://i.imgur.com/nq3UtuH.png)  
  
JFFS is a writeable partition of the router's flash memory, which will allow you to store small files (such as scripts) without the need to have an USB disk connected. This partition will survive a reboot. It will also be available quite early on boot (before USB disks). In short, this partition is necessary for what we want to do.  
  
The router's graphical interface, reached with address 192.168.1.1, uses port 80 by default. Except that our reverse proxy will need ports 80 and 443, so we move the GUI to port 8443. The router will be accessible via https://192.168.1.1:8443, freeing ports 80 and 443.  
  
As for SSH access, it will be necessary later, because most of the tutorial will use a terminal and command lines. I personally use [PuTTY](https://www.putty.org/) with Windows.  
  
## 3 Install Entware
<a href="http://entware.net/about.html" target="_blank"><img src="https://avatars3.githubusercontent.com/u/6337854?s=200&v=4" width="165"></a>  
[Entware](http://entware.net/about.html) is free software, it is a packet manager for embedded systems, like Nas or routers. It allows to add a lot of softwares normally unavailable, like the nano text editor for example. Entware's advantage in this tutorial is that it allows you to install nginx.
  
### 3.1. Configuring the USB flash drive
Entware requires an EXT2 formatted USB flash drive, connected to the router's USB port. Easy with Linux, less with Windows... The best is to use [MiniTool Partition Wizard Home Edition](https://www.partitionwizard.com/free-partition-manager.html) if your PC is running Windows. Nothing complex: install the application, right click on the USB key, delete the partition or partitions already present. Right-click and create an EXT2 partition of at least 2GB. Click ok, and apply.  

### 3.2 Installation of entware
The key plugged in, we connect in SSH to the router with PuTTY, and type:
```shell
entware-setup.sh
```
The terminal will show:
```shell
 Info:  This script will guide you through the Entware installation.
 Info:  Script modifies only "entware" folder on the chosen drive,
 Info:  no other data will be touched. Existing installation will be
 Info:  replaced with this one. Also some start scripts will be installed,
 Info:  the old ones will be saved to .entwarejffs_scripts_backup.tgz

 Info:  Looking for available partitions...
[1] --> /tmp/mnt/sda1
 =>  Please enter partition number or 0 to exit
```
We choose the partition by typing the corresponding digit, and hop. It's over.  
  
## 4. Using Ovh DynHost on your router
As indicated in the introduction, I have an Ovh domain name, and I want to access the different services I host at home, via this address. Problem, I don't have a static ip: if I link pouet.fr to my ip address, at the first ip change, the address will no longer point to my home. So I will create records at Ovh and use my router to update the linked ip address. To do this, you have to do a manipulation on Ovh admin console, and create a script on the router that will run periodically to update the IP address.  
  
### 4.1. Ovh side
In the Ovh admin console, go to the domain you want to use, and click on DynHost :one: , then on manage accesses :two:. In the window that opens, you create an access :three:  
- The suffix will be the identifier that we will use in the script: put what you want.  
- The subdomain is used to indicate the extent to which the ip address will be updated.
- And finally, a password of your choice that will be used for the script.  
  
Back in the Dynhost window, we click on 'add a Dynhost' :four: and we add current public ip (found on http://myip.dnsomatic.com/ for example). For the subdomain, I put nothing, but there is no obligation to do like me.
>![Dynhost Ovh, sous domaines](https://i.imgur.com/snYImlC.png)  
  
>![Dynhost Ovh, création des accès](https://i.imgur.com/AsdDX9m.png)  
  
Finally, last step, we will create as many redirections as there are services you want to access. For that, we go in redirection, and we create a CNAME redirection to the dynhost domain:
>![Redirections Ovh 1](https://i.imgur.com/ILhgyAd.png)
  
>![Redirections Ovh 2](https://i.imgur.com/Umkr7iA.png)
  
>![Redirections Ovh 3](https://i.imgur.com/LFvjVmD.png)
  
>![Redirections Ovh 4](https://i.imgur.com/Unx2Kjl.png)
  
It is also possible to create a wildcard redirect. Just delete the existing CNAME redirections if there are any, and then add a CNAME entry in the DNS zone from \*.pouet.fr to pouet.fr  
  
>![Redirection Ovh 5](https://i.imgur.com/0II2GZY.png)  

### 4.2. Router side
In order for the router to update the ip address to which the domain points, you must use the router's DDNS function. By default, a series of suppliers like no-ip is proposed, but not Ovh. So you have to create a personal script. You are lucky, I tested and adapted [one](https://gist.github.com/pedrom34/0bfdf2bb7f2e17a8859c1fad7204d7bf).  
  
We connect to the router via the terminal, and:
```shell
wget https://gist.githubusercontent.com/pedrom34/0bfdf2bb7f2e17a8859c1fad7204d7bf/raw/d92e3c5f87afd6b0870db8a8eb0fd597ec904a7c/asuswrt-ovh-ddns.sh -O /jffs/scripts/ddns-start
``` 
Then we edit the downloaded script.
```shell
vi /jffs/scripts/ddns-start
``` 
We update the identification information of the DynHost Ovh (user & password) that we created in step [4.1.](#41-ovh-side), as well as the domain (pouet.fr). In vi, simply type "i" to insert text at the cursor position. 
```bash
U=user
P=password
H=domain
```
To exit vi and save the script, press Esc, and type "ZZ" without quotes and in capital letters.
We make the script executable:
```shell
chmod a+x /jffs/scripts/ddns-start
```
And we return in router interface, in WAN and DDNS, we activate DynHost custom:
>![DynHost dans la GUI du routeur](https://i.imgur.com/HbA7ydG.png)  
  
Then we apply and restart.  
Tada! We have a domain name that points to the ip of our router! Even if your IP address changes!  
  
Note that the ddns-start script considers by default that the router is, like mine, double Nated behind an ISP box. If this is not the case, adapt the script by adding "#" before "IP=$(wget..." to line 29 of the script.

## 5. Install nginx
Now that everything is set, we can install nginx.  
```shell
opkg install nginx-extras
```
Why nginx-extras instead of nginx? Because nginx doesn't include some interesting modules for https security.
  
We add rules in the firewall so that nginx can listen to ports 80 and 443:  
```shell
vi /jffs/scripts/firewall-start
```
Copy-paste those rules in the script (and as before, to exit vi, press Esc, then "ZZ"):  
```bash
#!/bin/sh
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
```
Add a line in services-start so that nginx starts with the router:  
```shell
vi /jffs/scripts/services-start
```
```shell
/opt/etc/init.d/S80nginx start
```
Make the scripts executable:  
```shell
chmod a+x /jffs/scripts/*
```
  
## 6. Set up nginx  
Without doubt the trickiest part because the configuration of nginx depends very much on the services you want to access... In any case, it is necessary to modify the current configuration in "/opt/etc/nginx/nginx.conf". So, with vi:  
```shell
vi /opt/etc/nginx/nginx.conf
```
And exit vi as explained above to save.  
  
### 6.1. Example conf  
A short example with https only, there are lots of other configurations on the internet:

```nginx
user  nobody;
worker_processes  1;

#error_log  /opt/var/log/nginx/error.log;
#error_log  /opt/var/log/nginx/error.log  notice;
#error_log  /opt/var/log/nginx/error.log  info;

#pid        /opt/var/run/nginx.pid;

events {
    worker_connections  1024;
}
http {
    include       mime.types;
    default_type  application/octet-stream;
	server_tokens off;
	server_names_hash_bucket_size  64;
	
    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  /opt/var/log/nginx/access.log main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    ## Compression
    gzip              on;
    gzip_buffers      16 8k;
    gzip_comp_level   9;
    gzip_http_version 1.1;
    gzip_min_length   10;
    gzip_types        text/plain text/css application/x-javascript text/xml;
    gzip_vary         on;
    gzip_static       on; #Needs compilation with gzip_static support
    gzip_proxied      any;
    gzip_disable      "MSIE [1-6]\.";

    server {
        listen       80;
        server_name  localhost;

        location / {
            root   /opt/share/nginx/html;
            index  index.html index.htm;
        }

        error_page  404              /404.html;
 
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
    server {
        listen 80;
        server_name *.domain.tld;
        return 301 https://$host$request_uri;
    }
    server {
        listen       443;
        server_name  localhost;
        ssl                  on;
        ssl_certificate      cert.crt;
        ssl_certificate_key  cert.key;
        ssl_session_timeout  5m;
        ssl_protocols  TLSv1.2;
        add_header X-Content-Type-Options "nosniff" always;
        add_header X-Frame-Options "SAMEORIGIN" always;
        add_header X-Xss-Protection "1";
        add_header Content-Security-Policy "default-src 'self'";
        add_header Referrer-Policy strict-origin-when-cross-origin;
        add_header Strict-Transport-Security "max-age=31557600; includeSubDomains";
        ssl_ciphers  ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256;
        ssl_prefer_server_ciphers   on;
        ssl_stapling on;
        ssl_stapling_verify on;
        resolver 1.1.1.1 valid=60s;
        resolver_timeout 2s;
        location / {
            root   html;
            index  index.html index.htm;
        }
        location /robots.txt {
        return 200 "User-agent: *\nDisallow: /";
        }
    }
include /opt/etc/nginx/sites-enabled/*.conf;
}
```
For the resolver, near the end of the file, you must specify a DNS resolver. I specified here [the cloudflare DNS](https://1.1.1.1/), but it is possible to use the router's local ip address.  
  
Once the modification is done, create a .conf file per service you want to proxify in /opt/etc/nginx/sites-enabled/. For instance:  
```shell
vi /opt/etc/nginx/sites-enabled/kodi.domain.tld
```
and:
```nginx
server {
    listen       443;
    server_name  kodi.domain.tld;
    ssl                  on;
    ssl_certificate      cert.crt;
    ssl_certificate_key  cert.key;
    ssl_session_timeout  5m;
    ssl_protocols  TLSv1.2;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Xss-Protection "1";
    add_header Content-Security-Policy "default-src 'self'";
    add_header Referrer-Policy strict-origin-when-cross-origin;
    add_header Strict-Transport-Security "max-age=31557600; includeSubDomains";
    ssl_ciphers  ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256;
    ssl_prefer_server_ciphers   on;
    ssl_stapling on;
    ssl_stapling_verify on;
    resolver 1.1.1.1 valid=60s;
    resolver_timeout 2s;
    location / {
        proxy_pass http://192.168.0.10:8080;
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-For $remote_addr;
        proxy_set_header  X-Forwarded-Host $remote_addr;
    }
    location /robots.txt {
    return 200 "User-agent: *\nDisallow: /";
    }
}
```
  
## 7. Get Let's Encrypt certificate
There are many ways to get a free Let's Encrypt certificate. For routers, I find that the most suitable method is to use the [acme.sh](https://acme.sh) script.  
This script is amazing: it adapts to a lot of situations thanks to its many options, and is very light!  
On the following part, I use the script with my domain name, via the Ovh API. If you are not in this situation, refer to the [acme.sh](https://wiki.acme.sh) wiki.  
  
### 7.1. Install the script  
So, we start with downloading the script.
```shell
wget https://github.com/Neilpang/acme.sh/archive/master.zip
```
  
Unzip the archive. I chose to unzip it to /jffs/acme.sh. In any cases, the folder will be deleted afterwards.
```shell
unzip master.zip -d /jffs/acme.sh
```
  
Go to the folder
```shell
cd /jffs/acme.sh/
```
  
Make the script executable.
```shell
chmod a+x /jffs/acme.sh/*
```
  
And then install the script to /jffs/scripts/acme.sh, the "--home" argument allows you to define the installation folder; this argument must be used EVERY TIME. The jffs partition will be kept during a reboot. It is therefore recommended to install the script inside.
```shell
./acme.sh --install --home "/jffs/scripts/acme.sh"
```
### 7.2. Ovh API keys
I configure the script to use Ovh API to create TXT fields in domain records, thus justifying my property for Let's Encrypt. 
  
The keys are created on https://eu.api.ovh.com/createApp/  
Make a note of the information displayed, then, in the terminal, go to the acme.sh folder
```shell
cd /jffs/scripts/acme.sh
```

And install the Ovh API keys that we got in the previous step, by typing in the terminal (replace by your information):
```shell
export OVH_AK="Ovh Application Key"
export OVH_AS="Ovh Application Secret"
```
  
Then, generate the certificate. Here, we can see that I request a wildcard certificate \*.domain.tld* as well as for the root domain (domain.tld).
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --issue -d *.domain.tld -d domain.tld --dns dns_ovh
```
  
Anyway, it will fail, and return an error message like this:
```bash
Using Ovh endpoint: ovh-eu
Ovh consumer key is empty, Let's get one:
Please open this link to do authentication: https://eu.api.ovh.com/auth/?credentialToken=n0Qbjm6wBdBr2KiSqIuYSEnixxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Here is a guide for you: https://github.com/Neilpang/acme.sh/wiki/How-to-use-Ovh-domain-api
Please retry after the authentication is done.
Error add txt for domain:_acme-challenge.*.domain.tld
```
  
Indeed, you must go, the first time only, to the address indicated in the script to be able to activate the API. Select "Unlimited" for the validity period.  
  
>![Api Ovh](https://i.imgur.com/rtgqHZS.png)
  
Then do it again, this time it will work:
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --issue -d *.domain.tld -d domain.tld --dns dns_ovh
```
  
Install the script in nginx.
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --install-cert -d domain.tld \
--key-file       /opt/etc/nginx/cert.key  \
--fullchain-file /opt/etc/nginx/cert.crt \
--reloadcmd     "/opt/etc/init.d/S80nginx reload"
```
Note that the path I indicate for the key and the certificate is the one indicated in the nginx configuration. Make sure it's the same! 
  
This line is added for the automatic renewal of certificates, which will be launched every day at 2am.
```shell
cru a "acme.sh" '0 2 * * * /jffs/scripts/acme.sh/acme.sh --cron --home "/jffs/scripts/acme.sh" > /dev/null'
```

The automatic update of acme.sh is activated via the following command line:
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --upgrade --auto-upgrade
```

The acme.sh folder in jffs can now be deleted.
```shell
rm -r /jffs/acme.sh/
```
  
And finally you can start nginx:
```shell
/opt/etc/init.d/S80nginx start
```
  
## 8. A few words of conclusion
At home, nginx works very well, but a router update can remove all the work done here. Remember to save the router configuration and the JFFS partition from the router interface!
  
If nginx does not launch, try the following command to test the configuration to troubleshoot:
```shell
nginx -t
```
If the configuration file is modified, the configuration can be reloaded without restarting nginx by typing:  
```shell
nginx -s reload
```  
  
### 8.1. 2018-09-11 bonus: two (or more) DynDNS domains
Some months after I wrote this tutorial, I needed to add another DynDNS domain to my router. With a quick search, I found that the best solution for me was to use [DNS-O-Matic](https://www.dnsomatic.com/). To make this work, simply add your DynDNS providers in the web interface, and modify the script given in [point 4.2.](#42-router-side) with this command:  
  
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
  
## 9. On the shoulders of giants  
Not being a computer specialist or network administrator, if I could do all this, [it's by standing on the shoulders of giants](https://en.wikipedia.org/wiki/Standing_on_the_shoulders_of_giants). Do not hesitate to consult these sites which helped me a lot, to adapt this modest tutorial to your environment:  
  
  1. Sauvageau E. asuswrt-merlin: Enhanced version of Asus’s router firmware (Asuswrt) - Wiki [Internet]. 2018 [accessed on 19-04-2018]. Available on: https://github.com/RMerl/asuswrt-merlin/wiki
2. Neilpang. acme.sh: A pure Unix shell script implementing ACME client protocol - Wiki [Internet]. 2018 [accessed on 19-042018]. Available on: https://github.com/Neilpang/acme.sh/wiki
3. Xuplus. 搞定Merlin使用DNS实现Let’s Encrpt证书，使用SSL安全访问后台 - 梅林 - KoolShare - 源于玩家 服务玩家 [Internet]. Koolshare. 2016 [accessed on 19-04-2018]. Available on: http://koolshare.cn/thread-79146-1-1.html
4. HTPC Guides [Internet]. Mike. Use Afraid Custom Dynamic DNS on Asus Routers; 17-05-2016 [accessed on 19-04-2018]. Available on: https://www.htpcguides.com/use-afraid-custom-dynamic-dns-asus-routers/
5. Törnqvist G. Nginx Reverse Proxy on Asus Merlin [Internet]. Göran Törnqvist Website. 2015 [accessed on 19-04-2018]. Available on: http://goran.tornqvist.ws/nginx-reverse-proxy-on-asus-merlin/
6. jeromeadmin. Firmware Asuswrt-Merlin - T[echnical] eXpertise [Internet]. T[echnical] eXpertise. 2014 [accessed on 19-04-2018]. Available on: http://tex.fr/firmware-asuswrt-merlin/
7. SSL Configuration Generator [Internet]. Mozilla Foundation. Generate Mozilla Security Recommended Web Server Configuration Files; [accessed on 23-04-2018]. Available on: https://mozilla.github.io/server-side-tls/ssl-config-generator/
