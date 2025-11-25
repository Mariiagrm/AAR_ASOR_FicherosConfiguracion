# Dockerfile para servidor SMTP (Postfix) + POP3/IMAP (Dovecot)
FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquetes necesarios
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      postfix \
      dovecot-core \
      dovecot-pop3d \
      dovecot-imapd \
      rsyslog \
      ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# 2. Crear usuario de prueba para el correo
# Usuario: alumno / contraseña: alumno
RUN useradd -m -s /bin/bash user && echo "alumno:alumno" | chpasswd

# 3. Copiar configuraciones mínimas
COPY postfix/main.cf /etc/postfix/main.cf
COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf
COPY dovecot/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
COPY dovecot/10-auth.conf /etc/dovecot/conf.d/10-auth.conf

# 4. Habilitar syslog para que Postfix y Dovecot puedan registrar logs
RUN sed -i 's/^#module(load="imuxsock")/module(load="imuxsock")/' /etc/rsyslog.conf || true && \
    sed -i 's/^#module(load="imklog")/module(load="imklog")/' /etc/rsyslog.conf || true

# 5. Exponer puertos: SMTP, POP3, IMAP
EXPOSE 25 110 143

# 6. Script de arranque: syslog + postfix + dovecot
CMD service rsyslog start && \
    service postfix start && \
    service dovecot start && \
    tail -F /var/log/mail.log /var/log/syslog