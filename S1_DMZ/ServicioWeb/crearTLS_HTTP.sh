#!/usr/bin/env bash
# Crear o recrear el certificado TLS y el secreto en Kubernetes

NAMESPACE="dorayakiweb"
SECRET_NAME="dorayakiweb-tls"
CN="dorayaki.local"
DAYS=365
KEY_FILE="dorayakiweb-tls.key"
CRT_FILE="dorayakiweb-tls.crt"

# Salir si ocurre un error
set -e

echo "Generando clave y certificado TLS autofirmado..."
openssl req -x509 -nodes -days "$DAYS" -newkey rsa:2048 \
    -keyout "$KEY_FILE" \
    -out "$CRT_FILE" \
    -subj "/CN=$CN/O=$CN"

echo "Borrando secreto TLS anterior (si existe)..."
kubectl delete secret "$SECRET_NAME" -n "$NAMESPACE" --ignore-not-found

echo "Creando secreto TLS en el namespace $NAMESPACE..."
kubectl create secret tls "$SECRET_NAME" \
    --cert="$CRT_FILE" \
    --key="$KEY_FILE" \
    -n "$NAMESPACE"

echo "Hecho."