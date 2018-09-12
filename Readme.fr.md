# Installer un reverse proxy SSL sur un routeur Asus avec un nom de domaine Ovh
  
Read in another language: [English 🇬🇧](Readme.md), [Français 🇫🇷](Readme.fr.md).  
 
## Au menu
0. [Quoi ? Pourquoi ?](#0-quoi--pourquoi-)
1. [Installer Merlin sur son routeur](#1-installer-merlin-sur-son-routeur)
2. [Activer SSH et partition JFFS](#2-activer-ssh-et-partition-jffs)
3. [Installer Entware](#3-installer-entware)
4. [Utiliser le DynHost d'Ovh sur son routeur](#4-utiliser-le-dynhost-dovh-sur-son-routeur)
5. [Installer nginx](#5-installer-nginx)
6. [Configurer nginx](#6-configurer-nginx)
7. [Obtenir un certificat Let's Encrypt](#7-obtenir-un-certificat-lets-encrypt)
8. [Conclusion](#8-quelques-mots-en-conclusion)
9. [Sources](#sur-les-épaules-des-géants-)

## 0. Quoi ? Pourquoi ?
Un reverse proxy ou proxy inverse est un petit serveur web qui permet d'accéder aux interfaces utilisateur situées derrière lui, par exemple : interfaces web de caméras, serveurs multimédia, Nas, calendrier ou email auto-hébergées, etc. Le but est de pouvoir accéder aux différentes ressources depuis l'extérieur, sans avoir à utiliser un VPN. VPN et reverse proxy ne s'excluent pas pour autant, le proxy n'étant vraiment utile que pour les interfaces web. De plus, le VPN permet une sécurité accrue, lors de l'utilisation de wifi gratuits par exemple.  

### 0.1. Et la sécurité ?  
Le reverse proxy est *sécurisable*. Il suffit pour cela d'utiliser un certificat, la connexion sera chiffrée entre votre ordinateur extérieur et le proxy. Et avec Let's Encrypt, il est possible d'avoir un certificat reconnu par les navigateurs et d'avoir le petit cadenas vert ! D'autre part, Let's Encrypt a lancé en 2018 le support des certificats *wildcard* : il est désormais possible de demander un certificat pour "\*.domaine.com" plutôt que pour "pouet.domaine.com, pouet2.domaine.com, ...".  

### 0.2. Concrètement...
J'ai mis en place cette configuration car je possède un routeur Asus - un AC86U - derrière ma box, il est là pour combler les manques de la box fournie par mon opérateur : DNS personnalisé, firewall et DHCP plus avancés et plus fins, serveur et client VPN, dnsmasq, etc. Et ce routeur me permet également de faire tourner nginx - que j'utilise justement comme reverse proxy - et d'utiliser un nom de domaine loué chez Ovh avec mon adresse IP dynamique (DynHost).  
  
J'ai fait ce tuto à la base pour me souvenir de ce que j'avais fait. Alors, pourquoi ne pas partager ?
  
## 1. Installer Merlin sur son routeur
<a href="https://asuswrt.lostrealm.ca/" target="_blank"><img src="https://dpfpic.com/data/medias/Box/Asuswrt-Merlin.png" width="250"></a>  
Le firmware (programme intégré au matériel) Merlin est une modification du firmware officiel d'Asus. Il a l'avantage de proposer pas mal d'améliorations sans pour autant supprimer l'interface graphique bien agréable d'Asus. Il permet également d'utiliser Entware - j'y reviendrais juste un peu après.  
Installer Merlin se fait très simplement, comme une mise à jour du routeur, il y a énormément de tutos en ligne, en voici un, très clair : http://tex.fr/firmware-asuswrt-merlin/  
Il n'y a pas vraiment de risque à utiliser Merlin, car il est très facile de revenir en arrière, et de réinstaller le firmware officiel.  
  
## 2. Activer SSH et partition JFFS
Une fois que le routeur fait tourner Merlin, il faudra se rendre dans Administration > Système, et activer la partition JFFS.
>![Interface routeur, activation de JFFS](https://i.imgur.com/ryhJJ6K.png)  
  
Toujours sur la même page, on active l'accès SSH, et on passe l'interface en https sur le port 8443 :  
>![Interface routeur, activation SSH et GUI en https 8443](https://i.imgur.com/nq3UtuH.png)  
  
JFFS est une partition en écriture de la mémoire flash du routeur, ce qui vous permettra de stocker de petits fichiers (comme des scripts) sans avoir besoin d'avoir un disque USB branché. Cet espace survivra au redémarrage. Il sera également disponible assez tôt au démarrage (avant les disques USB). Bref, cette partition est nécessaire pour ce que l'on veut faire.  
  
L'interface graphique du routeur, que l'on atteint avec l'adresse 192.168.1.1, utilise le port 80 par défaut. Sauf que notre reverse proxy aura besoin des ports 80 et 443, on déplace donc l'interface graphique sur le port 8443. Le routeur sera ainsi accessible via https://192.168.1.1:8443, libérant les ports 80 et 443.  
  
Quant à l'accès SSH, il sera nécessaire par la suite, car la quasi-totalité du tuto utilisera un terminal et des lignes de commandes. A titre personnel, sous Windows j'utilise [PuTTY](https://www.putty.org/).  
  
## 3. Installer Entware
<a href="http://entware.net/about.html" target="_blank"><img src="https://avatars3.githubusercontent.com/u/6337854?s=200&v=4" width="165"></a>  
[Entware](http://entware.net/about.html) est un logiciel libre, c'est un gestionnaire de paquets pour les systèmes embarqués, comme les Nas ou les routeurs. Cela permet d'ajouter tout un tas de logiciels normalement indisponibles, comme l'éditeur de texte nano par exemple. L'intérêt d'Entware pour ce tuto, c'est qu'il permet d'installer nginx.
  
### 3.1. Configuration de la clé usb
Entware nécessite une clé usb formatée en EXT2, branchée sur le port usb du routeur. Facile si vous avez un ordinateur sous linux. Moins facile sous Windows... Le mieux, est d'utiliser [MiniTool Partition Wizard Home Edition](https://www.partitionwizard.com/free-partition-manager.html) si votre PC est sous Windows. Rien de bien complexe : on installe l'application, on clique droit sur sa clé, on supprime la ou les partitions déjà présentes. On reclique droit et on crée une partition EXT2 d'au moins 2Go. On clique ok, et appliquer.  
  
### 3.2. Installation d'entware
La clé branchée, on se connecte en SSH au routeur avec PuTTY, et on tape :
```shell
entware-setup.sh
```
Le terminal va afficher :
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
On choisit la partition en tapant le chiffre correspondant, et hop. C'est fini.  

## 4. Utiliser le DynHost d'Ovh sur son routeur
<a href="https://www.ovh.com/" target="_blank"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/Logo-OVH.svg/256px-Logo-OVH.svg.png"></a>  
Comme indiqué en introduction, je possède un nom de domaine Ovh, et je souhaite accéder aux différents services que j'héberge chez moi, via cette adresse. Problème, je n'ai pas une ip fixe : si je lie pouet.fr à mon adresse ip, au premier changement d'ip, l'adresse ne pointera plus chez moi. Je vais donc créer des enregistrements chez Ovh et utiliser mon routeur pour mettre à jour l'adresse ip liée. Pour cela, il faut faire une manipulation chez Ovh, et créer un script sur le routeur.  
  
### 4.1. Côté Ovh
Dans l'espace client Ovh, on se rend sur le domaine que l'on souhaite utiliser, et on clique sur DynHost :one: , puis sur gérer les accès :two:. Dans la fenêtre qui s'ouvre, on crée un accès :three:  
- Le suffixe sera l'identifiant que l'on utilisera dans le script après : mettez ce que vous voulez.  
- Le sous-domaine permet d'indiquer quelle sera l'étendue de la mise à jour de l'adresse ip. Personnellement, j'indique "\*".  
- Et enfin, un mot de passe au choix qui sera utilisé pour le script.  
  
De retour dans la fenêtre Dynhost, on clique sur ajouter un Dynhost :four: et on ajoute son ip actuelle que l'on a récupérée sur http://myip.dnsomatic.com/ par exemple. Pour le sous-domaine, je ne mets personnellement rien, mais rien n'oblige à faire comme moi.
>![Dynhost Ovh, sous domaines](https://i.imgur.com/snYImlC.png)  
  
>![Dynhost Ovh, création des accès](https://i.imgur.com/AsdDX9m.png)  
  
Enfin, dernière étape, on va créer autant de redirections que ce qu'il y a de services auxquels vous souhaitez accéder. Pour ça, on va dans redirection, et on créée une redirection CNAME vers le domaine dynhost :
>![Redirections Ovh 1](https://i.imgur.com/ILhgyAd.png)
  
>![Redirections Ovh 2](https://i.imgur.com/Umkr7iA.png)
  
>![Redirections Ovh 3](https://i.imgur.com/LFvjVmD.png)
  
>![Redirections Ovh 4](https://i.imgur.com/Unx2Kjl.png)
  
A noter qu'il est possible créer une redirection wildcard. Il suffit pour cela de supprimer les redirections CNAME existantes s'il y en a, puis d'ajouter une entrée CNAME dans la zone DNS de \*.pouet.fr vers pouet.fr  
  
>![Redirection Ovh 5](https://i.imgur.com/0II2GZY.png)  

### 4.2. Côté routeur
Pour que le routeur puisse mettre à jour l'adresse ip sur laquelle pointe le domaine, il faut utiliser la fonction DDNS du routeur. Par défaut, une série de fournisseurs comme no-ip est proposée, mais pas Ovh. Il faut donc créer un script personnel. Vous avez de la chance, j'en ai testé et adapté [un](https://gist.github.com/pedrom34/0bfdf2bb7f2e17a8859c1fad7204d7bf).  
  
On se connecte au routeur via le terminal, et :
```shell
wget https://gist.githubusercontent.com/pedrom34/0bfdf2bb7f2e17a8859c1fad7204d7bf/raw/d92e3c5f87afd6b0870db8a8eb0fd597ec904a7c/asuswrt-ovh-ddns.sh -O /jffs/scripts/ddns-start
``` 
Puis on édite le script téléchargé.
```shell
vi /jffs/scripts/ddns-start
``` 
On met à jour les informations d'identification du DynHost Ovh (user & password) que l'on a créé à l'étape [4.1.](#41-côté-ovh), ainsi que le domaine (pouet.fr). Dans vi, il suffit de taper "i" pour insérer du texte au niveau du curseur. 
```bash
U=user
P=password
H=domain
```
Pour quitter vi et sauvegarder le script, on appuie Esc, et on tape "ZZ" sans les guillemets et en majuscules.
On rend le script exécutable :
```shell
chmod a+x /jffs/scripts/ddns-start
```
Et on retourne dans l'interface du routeur, dans réseau étendu et DDNS, on active le DynHost custom :
>![DynHost dans la GUI du routeur](https://i.imgur.com/HbA7ydG.png)  
  
Puis on applique et redémarre.  
Tada ! Nous avons un nom de domaine qui pointe sur l'ip de notre routeur ! Et ce, même en cas de changement d'adresse IP !  
  
A noter que le script ddns-start considère par défaut que le routeur est, comme le mien, en double Nat derrière une box. Si ça n'est pas le cas, adaptez le script en rajoutant "#" devant "IP=$(wget..." à la ligne 29 du script.

## 5. Installer nginx
<a href="https://nginx.org/" target="_blank"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c5/Nginx_logo.svg/256px-Nginx_logo.svg.png"></a>  
  
Bon, maintenant que tout est bon, on installe nginx.  
```shell
opkg install nginx-extras
```
Pourquoi nginx-extras et pas nginx ? Simplement car nginx tout court n'inclus pas certains modules intéressants pour la sécurité https.
  
On ajoute des règles dans le firewall pour que nginx puisse écouter les ports 80 et 443 :  
```shell
vi /jffs/scripts/firewall-start
```
On colle ça dans le script (et comme précédemment, pour quitter vi, on fait Esc, puis "ZZ") :  
```bash
#!/bin/sh
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
```
On rajoute une ligne dans services-start pour que nginx démarre avec le routeur :  
```shell
vi /jffs/scripts/services-start
```
```shell
/opt/etc/init.d/S80nginx start
```
On rend le tout exécutable :  
```shell
chmod a+x /jffs/scripts/*
```

## 6. Configurer nginx
Sans doute la partie la plus complexe car la configuration de nginx dépend complètement des services auxquels vous souhaitez accéder... Quoi qu'il arrive, il faut modifier la configuration présente dans "/opt/etc/nginx/nginx.conf". Ainsi, avec vi :  
```shell
vi /opt/etc/nginx/nginx.conf
```
Et quitter vi comme expliqué précédemment pour sauvegarder.  
  
### 6.1. Exemple de configuration  
Un petit exemple avec https exclusivement, il existe des tas d'autres configurations sur internet :

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
Pour le resolver, vers la fin du fichier, il faut indiquer un résolveur DNS. J'ai indiqué ici [le DNS de cloudflare](https://1.1.1.1/), mais il est possible d'utiliser l'adresse ip locale du routeur.  
  
Une fois cette modification faite, il faut créer un fichier .conf par service à proxifier dans le dossier /opt/etc/nginx/sites-enabled/. Par exemple :  
```shell
vi /opt/etc/nginx/sites-enabled/kodi.domain.tld
```
Et :
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
  
## 7. Obtenir un certificat Let's Encrypt
Il existe de multiples façon pour obtenir un certificat gratuit Let's Encrypt. Pour les routeurs, je trouve que la méthode la plus adaptée est l'utilisation du script [acme.sh](https://acme.sh).  
Ce script est fabuleux : il s'adapte à énormément de situations grâce à ses nombreuses options, et il est très léger !  
Sur la partie qui suit, j'utilise le script avec mon nom de domaine, via l'API d'Ovh. Si vous n'êtes pas dans cette situation, référez-vous au wiki de [acme.sh](https://wiki.acme.sh).  

### 7.1. Installation du script
<a href="https://letsencrypt.org/" target="_blank"><img src="https://upload.wikimedia.org/wikipedia/en/thumb/0/07/Let's_Encrypt.svg/256px-Let's_Encrypt.svg.png"></a>  
  
Alors, on commence par télécharger Acme.sh
```shell
wget https://github.com/Neilpang/acme.sh/archive/master.zip
```

Décompresser l'archive. J'ai choisi de décompresser l'archive dans /jffs/acme.sh. Mais de toutes façons, ce dossier sera supprimé après.
```shell
unzip master.zip -d /jffs/acme.sh
```

On va dans le dossier créé
```shell
cd /jffs/acme.sh/
```

On rend le script exécutable
```shell
chmod a+x /jffs/acme.sh/*
```

Et on installe le script dans /jffs/scripts/acme.sh, l'argument "--home" permet de définir l'emplacement de l'installation ; cet argument devra être utilisé à CHAQUE FOIS. La partition jffs sera conservée lors d'un reboot. Il est donc conseillé d'installer le script dedans.
```shell
./acme.sh --install --home "/jffs/scripts/acme.sh"
```
### 7.2. Création des clés api de Ovh
Je configure le script pour qu'il utilise l'api d'Ovh pour créer des champs TXT dans les enregistrements de domaine, justifiant ainsi ma propriété pour Let's Encrypt. 
  
On crée les clés sur https://eu.api.ovh.com/createApp/  
Notez bien les informations affichées, puis, dans le terminal, on se rend le dossier acme.sh
```shell
cd /jffs/scripts/acme.sh
```

Et on installe les clés d'api Ovh que l'on a eu à l'étape précédente, en tapant dans le terminal (remplacez par vos informations) :
```shell
export OVH_AK="Ovh Application Key"
export OVH_AS="Ovh Application Secret"
```
  
Ensuite, on génère le certificat, ici, on voit que je demande un certificat wildcard \*.domain.tld* ainsi que pour la racine du domaine (domain.tld).
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --issue -d *.domain.tld -d domain.tld --dns dns_ovh
```
  
Quoi qu'il en soit, cela va échouer, et renvoyer un message d'erreur comme suivant :
```bash
Using Ovh endpoint: ovh-eu
Ovh consumer key is empty, Let's get one:
Please open this link to do authentication: https://eu.api.ovh.com/auth/?credentialToken=n0Qbjm6wBdBr2KiSqIuYSEnixxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
Here is a guide for you: https://github.com/Neilpang/acme.sh/wiki/How-to-use-Ovh-domain-api
Please retry after the authentication is done.
Error add txt for domain:_acme-challenge.*.domain.tld
```
  
En effet, il faut se rendre, la première fois uniquement, à l’adresse qu'indique le script pour pouvoir activer l'Api. Sélectionnez "Unlimited" pour la durée de validité.  
  
>![Api Ovh](https://i.imgur.com/rtgqHZS.png)
  
Ensuite, on recommence, cette fois, ça doit fonctionner :
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --issue -d *.domain.tld -d domain.tld --dns dns_ovh
```
  
On installe le script dans nginx.
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --install-cert -d domain.tld \
--key-file       /opt/etc/nginx/cert.key  \
--fullchain-file /opt/etc/nginx/cert.crt \
--reloadcmd     "/opt/etc/init.d/S80nginx reload"
```
A noter, que le chemin que j'indique pour la clé et le certificat est celui indiqué dans la configuration de nginx. Indiquez bien la même !  
  
On ajoute cette ligne pour le renouvellement automatique des certificats, qui se lancera tous les jours à 2h du matin.
```shell
cru a "acme.sh" '0 2 * * * /jffs/scripts/acme.sh/acme.sh --cron --home "/jffs/scripts/acme.sh" > /dev/null'
```

On active la mise à jour automatique de acme.sh via la ligne de commande suivante :
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --upgrade --auto-upgrade
```

On peut supprimer le dossier acme.sh présent dans jffs.
```shell
rm -r /jffs/acme.sh/
```
  
Et on peut enfin lancer nginx :
```shell
/opt/etc/init.d/S80nginx start
```

## 8. Quelques mots en conclusion
Chez moi, nginx fonctionne très bien, mais une mise à jour du routeur peut supprimer la totalité du travail fait ici. Pensez donc à bien sauvegarder la configuration du routeur et la partition JFFS depuis l'interface du routeur !
  
Si nginx ne se lance pas, essayez la commande permettant de tester la configuration pour diagnostiquer les soucis :
```shell
nginx -t
```
En cas de modification du fichier de configuration on recharge la configuration, sans redémarrer nginx en faisant :
```shell
nginx -s reload
```

## 9. Sur les épaules des géants
N'étant pas informaticien ou administrateur réseau, si j'ai pu faire tout cela, [c'est en montant sur les épaules des géants](https://fr.wikipedia.org/wiki/Des_nains_sur_des_%C3%A9paules_de_g%C3%A9ants). N'hésitez pas à consulter ces sites qui m'ont énormément aidé, pour adapter ce modeste tuto à votre situation :  
  
1. Sauvageau E. asuswrt-merlin: Enhanced version of Asus’s router firmware (Asuswrt) - Wiki [En ligne]. 2018 [visité le 19 avr 2018]. Disponible sur : https://github.com/RMerl/asuswrt-merlin/wiki
2. Neilpang. acme.sh: A pure Unix shell script implementing ACME client protocol - Wiki [En ligne]. 2018 [visité le 19 avr 2018]. Disponible sur : https://github.com/Neilpang/acme.sh/wiki
3. Xuplus. 搞定Merlin使用DNS实现Let’s Encrpt证书，使用SSL安全访问后台 - 梅林 - KoolShare - 源于玩家 服务玩家 [En ligne]. Koolshare. 2016 [visité le 19 avr 2018]. Disponible sur : http://koolshare.cn/thread-79146-1-1.html
4. HTPC Guides [En ligne]. Mike. Use Afraid Custom Dynamic DNS on Asus Routers; 17 mai 2016 [visité le 19 avr 2018]. Disponible: https://www.htpcguides.com/use-afraid-custom-dynamic-dns-asus-routers/
5. Törnqvist G. nginx Reverse Proxy on Asus Merlin [En ligne]. Göran Törnqvist Website. 2015 [visité le 19 avr 2018]. Disponible sur : http://goran.tornqvist.ws/nginx-reverse-proxy-on-asus-merlin/
6. jeromeadmin. Firmware Asuswrt-Merlin - T[echnical] eXpertise [En ligne]. T[echnical] eXpertise. 2014 [visité le 19 avr 2018]. Disponible: http://tex.fr/firmware-asuswrt-merlin/
7. SSL Configuration Generator [En ligne]. Fondation Mozilla. Generate Mozilla Security Recommended Web Server Configuration Files; [Visité le 23 avr 2018]. Disponible: https://mozilla.github.io/server-side-tls/ssl-config-generator/  

## 10. Bonus
- 2018-09-11 : utiliser plus d'un DynDNS: [Français 🇫🇷](20180911-bonusFr.md), [English 🇬🇧](20180911-bonusEn.md)
  
