# Bonus : utilisation de logrotate pour éviter que les logs nginx ne grossissent trop
  
Tous les évènements nginx sont enregistrés dans les logs présents dans '/opt/var/log/nginx/'. Au fur et à mesure, les fichiers error et access deviennent de plus en plus lourds. Afin d'éviter les problèmes, il peut être intéressant d'utiliser logrotate pour remplacer les journaux selon des règles prédéfinies.
  
## Installation de logrotate
  
  
