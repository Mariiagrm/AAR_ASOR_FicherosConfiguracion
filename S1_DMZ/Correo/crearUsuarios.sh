#!/bin/bash

nombre="$1"
contrasena="$2"

if [ -z "$nombre" ] || [ -z "$contrasena" ]; then
	echo "Uso: $0 <nombre_usuario> <contrasena>"
	exit 1
fi

docker="dorayaki-mail"

docker exec -i "$docker" sh -c "echo \"$nombre@dorayaki.org:{PLAIN}$contrasena\" >> /etc/dovecot/passwd"
#Crear carpeta maildir
docker exec -i "$docker" sh -c "maildirmake.dovecot /var/mail/vhosts/dorayaki.org/$nombre/Maildir"	