# Bonus : deux domaines DynDNS (ou plus)  
<a href="https://www.dnsomatic.com/" target="_blank"><img src="http://www.dnsomatic.com/img/dnsomatic_logo_2000.gif" width="250"></a>  
    
Quelques mois après avoir écrit ce tuto, j'ai eu besoin de faire pointer deux domaines DynDNS vers mon routeur. Après une recherche rapide, je me suis rendu compte que la meilleure solution pour moi consistait à utiliser [DNS-O-Matic](https://www.dnsomatic.com/). Pour que cela fonctionne, il suffit d'ajouter les fournisseurs DynDNS dans l'interface web.
>![Interface DNS-O-Matic](https://i.imgur.com/m1KH826.png)  
  
Et ensuite modifier le script indiqué au [point 4.2.](https://github.com/pedrom34/TutoAsus/blob/master/Readme.fr.md#42-côté-routeur) avec cette commande :  
  
```shell
vi /jffs/scripts/ddns-start
```
  
Et remplacer les lignes présentes par :  
```shell
#!/bin/sh
# mettre à jour les variables suivantes:
USERNAME=dnsomatic_username
PASSWORD=dnsomatic_password
HOSTNAME=all.dnsomatic.com

# pas besoin de modifier quoi que ce soit ici :
/usr/sbin/curl -k --silent -u "$USERNAME:$PASSWORD" "https://updates.dnsomatic.com/nic/update?hostname=$HOSTNAME&wildcard=NOCHG&mx=NOCHG&backmx=NOCHG&myip=" > /dev/null
if [ $? -eq 0 ]; then
  /sbin/ddns_custom_updated 1
else
  /sbin/ddns_custom_updated 0
fi
```
  
Maintenant, pour générer un certificat, il faut modifier les commandes du script acme.sh comme ceci :
- Générer le certificat :
```shell
./acme.sh  --home "/jffs/scripts/acme.sh" --issue  \
-d domain1.ovh  --dns dns_ovh \
-d *.domain1.ovh  --dns dns_ovh \
-d *.domain2.duckdns.org --insecure --dns dns_duckdns
```
  
- Installer le certificat dans nginx :
```shell
./acme.sh --home "/jffs/scripts/acme.sh" --install-cert \
-d domain1.ovh -d domain2.duckdns.org \
--key-file  /opt/etc/nginx/cert.key \
--fullchain-file  /opt/etc/nginx/cert.crt \
--reloadcmd "nginx -s reload"
```
  
