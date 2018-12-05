# Bonus : Utiliser logrotate pour gérer les logs nginx
  
Tous les évènements nginx sont enregistrés dans les logs présents dans '/opt/var/log/nginx/'. Au fur et à mesure, les fichiers error et access deviennent de plus en plus lourds. Afin d'éviter les problèmes, il peut être intéressant d'utiliser logrotate pour remplacer les journaux selon des règles prédéfinies.
  
## Installation de logrotate
On peut installer logrotate via Entware :
```shell
opkg install logrotate
```

## Configuration de logrotate
Le plus simple est de créer un fichier de configuration spécial pour les logs nginx dans /opt/etc/logrotate.d/, aussi :
```shell
vi /opt/etc/logrotate.d/nginx
```
On insère du texte avec "i" et on sauvegarde avec Esc puis ":ZZ".  
Voici ma configuration :  
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
Ma config arrête nginx, fait tourner les logs, les compresse, puis relance nginx. Pour plus d'info sur la configuration, se reporter au [man](https://manpages.debian.org/stretch/logrotate/logrotate.8.en.html), [ici en français](http://www.delafond.org/traducmanfr/man/man8/logrotate.8.html).

## Mise en place d'une tâche cron
Afin que logrotate soit lancé automatiquement régulièrement, il faut modifier le fichier services-start :
```shell
vi /jffs/scripts/services-start```
  
pour y ajouter - à la fin - la ligne suivante :
```shell
cru a "logrotate" '0 2 * * 1 logrotate /opt/etc/logrotate.d/nginx > /dev/null'
```
Cette ligne permet de lancer logrotate tous les lundis à 2h du matin, avec la configuration présente dans /opt/etc/logrotate.d/nginx.