FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar paquetes necesarios (sin rsyslog)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      postfix \
      dovecot-core \
      dovecot-pop3d \
      dovecot-imapd \
      ca-certificates \
      dnsutils && \
    rm -rf /var/lib/apt/lists/*

# 2. Crear usuario de prueba para el correo
# Usuario: alumno / contraseña: alumno
RUN useradd -m -s /bin/bash alumno && echo "alumno:alumno" | chpasswd

# 3. Copiar configuraciones mínimas
COPY postfix/main.cf /etc/postfix/main.cf
COPY dovecot/dovecot.conf /etc/dovecot/dovecot.conf
COPY dovecot/10-mail.conf /etc/dovecot/conf.d/10-mail.conf
COPY dovecot/10-auth.conf /etc/dovecot/conf.d/10-auth.conf

# 4. Exponer puertos: SMTP, POP3, IMAP
EXPOSE 25 110 143

# 5. Script de arranque: postfix + dovecot (sin rsyslog)
CMD ["/bin/sh", "-c", "\
  postfix start && \
  dovecot && \
  tail -F /var/log/mail.log 2>/dev/null || tail -F /dev/null \
"]