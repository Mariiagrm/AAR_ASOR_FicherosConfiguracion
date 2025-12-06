#!/bin/bash

cd "$(dirname "$0")" || exit 1

DOMINIO="mail.dorayaki.org"
DIAS=365
KEYBITS=4096

openssl req -x509 -newkey rsa:${KEYBITS} -nodes \
    -keyout ./privkey.pem \
    -out ./fullchain.pem \
    -sha256 -days "${DIAS}" \
    -subj "/C=ES/ST=Murcia/L=Murcia/O=DorayakiOrg/OU=IT/CN=${DOMINIO}"