# Bonus : configuration de nginx avec des liens symboliques  
  
Afin que la configuration de nginx soit plus facile, rapide et modulable, je vous recommande de créer un fichier de configuration par sous-domaines. Ces fichiers devront être mis dans le dossier */opt/etc/nginx/sites-enabled* pour être actifs.  
Cependant, c'est encore mieux de positionner les fichiers dans le dossier */opt/etc/nginx/sites-available* et de créer un lien symbolique pour activer le site.  
  
Si on reprend l'exemple d'un sous-domaine pointant vers l'interface web d'une box sous Kodi ([point 6.1](https://github.com/pedrom34/TutoAsus/blob/master/Readme.fr.md#61-exemple-de-configuration)) :  
On crée le fichier de configuration :
```shell
vi /opt/etc/nginx/sites-available/kodi.domain.tld.conf
```
On colle la configuration :
```nginx
server {
    listen       443;
    server_name  kodi.domain.tld;
...
}
```
Jusqu'ici, seul le dossier contenant les fichiers de configuration ont changé. La différence, c'est que pour activer la configuration, on fait simplement :
```shell
ln -s /opt/etc/nginx/sites-available/kodi.domain.tld.conf /opt/etc/nginx/sites-enabled/kodi.domain.tld.conf && nginx -s reload
```
Le *nginx -s reload* permettant de recharger la configuration nginx pour prendre en compte ce nouveau fichier conf.
  
Et de la même façon, pour supprimer ou désactiver un site, on fait :
```shell
rm opt/etc/nginx/sites-enabled/kodi.domain.tld.conf && nginx -s reload
```
En supprimant le lien symbolique, on désactive le site sans pour autant supprimer la configuration présente dans *sites-available*.
