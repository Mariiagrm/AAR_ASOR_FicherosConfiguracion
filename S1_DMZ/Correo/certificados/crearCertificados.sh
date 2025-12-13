#!/bin/bash

cd "$(dirname "$0")" || exit 1
DOMINIO="server.dorayaki.org"
DOMINIOCORREO="mail.dorayaki.org"
DIAS=365
KEYBITS=4096

openssl req -x509 -newkey rsa:${KEYBITS} -nodes \
    -keyout ./privkey.pem \
    -out ./fullchain.pem \
    -sha256 -days "${DIAS}" \
    -subj "/C=ES/ST=Murcia/L=Murcia/O=DorayakiOrg/OU=IT/CN=${DOMINIOCORREO}" \
    -addext "subjectAltName = DNS:${DOMINIO}"

#Para certificados autofirmados 
#si no existe certbot, instalar con: sudo apt install certbot
if ! command -v certbot &> /dev/null
then
    echo "certbot could not be found, installing..."
    sudo apt install certbot -y
fi

sudo certbot certonly --standalone -d ${DOMINIO} -d ${DOMINIOCORREO}