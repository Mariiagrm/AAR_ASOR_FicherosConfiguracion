#!/bin/bash

#Hay que asegurarse de que todos los archivos de configuracion de todos los servicios tengan permisos para otros
# Script para ajustar permisos de la carpeta DNS para Docker BIND

# Carpeta donde está la configuración de BIND
DNS_DIR="./dns/bind"

# UID/GID que usa el contenedor de BIND (999 por defecto)
BIND_UID=999
BIND_GID=999

echo "Ajustando propietario a UID:GID $BIND_UID:$BIND_GID ..."
sudo chown -R $BIND_UID:$BIND_GID "$DNS_DIR"

echo "Ajustando permisos de carpetas a 755 ..."
find "$DNS_DIR" -type d -exec chmod 755 {} \;

echo "Ajustando permisos de archivos a 644 ..."
find "$DNS_DIR" -type f -exec chmod 644 {} \;

echo "Permisos ajustados correctamente para $DNS_DIR."
