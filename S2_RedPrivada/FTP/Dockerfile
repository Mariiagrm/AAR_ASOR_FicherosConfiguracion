FROM kibatic/proftpd:latest 

# Variables para usuario FTP 
ENV FTP_LIST="alumno:alumno" 
ENV PASSIVE_MIN_PORT=50000 
ENV PASSIVE_MAX_PORT=50100 

# Crear directorio home para el usuario 
RUN mkdir -p /home/ftpuser 

# Exponer puertos FTP: 21 y rango pasivo 
EXPOSE 21 50000-50100 

# Comando para arrancar ProFTPD 
CMD ["/usr/sbin/proftpd", "--nodaemon"] 