#!/bin/bash
nombre="$1"
contrasena="$2"
docker="dorayaki-mail"

if [ -z "$nombre" ] || [ -z "$contrasena" ]; then
  echo "Uso: $0 <nombre_usuario> <contrasena>"
  exit 1
fi

# Añadir usuario
docker exec -i "$docker" sh -c "echo \"$nombre@dorayaki.org:{PLAIN}$contrasena\" >> /etc/dovecot/passwd"

# Crear Maildir si no existe
docker exec -i "$docker" sh -c "mkdir -p /var/mail/vhosts/dorayaki.org/$nombre/Maildir && maildirmake.dovecot /var/mail/vhosts/dorayaki.org/$nombre/Maildir"

# Ajustar propietario y permisos
docker exec -i "$docker" sh -c "chown -R vmail:vmail /var/mail/vhosts/dorayaki.org/$nombre && chmod -R 700 /var/mail/vhosts/dorayaki.org/$nombre"
