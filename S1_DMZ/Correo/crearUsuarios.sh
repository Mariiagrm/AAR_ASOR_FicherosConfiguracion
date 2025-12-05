#!/bin/bash

nombre="$1"
contrasena="$2"

if [ -z "$nombre" ] || [ -z "$contrasena" ]; then
	echo "Uso: $0 <nombre_usuario> <contrasena>"
	exit 1
fi

docker="dorayaki-mail"
docker exec -it "$docker" useradd -m -s /bin/bash "$nombre" && \
docker exec -it "$docker" bash -c "echo '$nombre:$contrasena' | chpasswd"
echo "Usuario $nombre creado con éxito en el contenedor $docker."
echo "----MAILDIR DE USUARIO----"
docker exec -it "$docker" bash -c "ls /home/$nombre/Maildir"
