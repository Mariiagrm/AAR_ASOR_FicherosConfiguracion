#Sin TLS
telnet 10.1.0.1 25
#IMAP
telnet 10.1.0.1 143
#POP3
telnet 10.1.0.1 110
#Con TLS
#puerto 587 para SMTP con STARTTLS
openssl s_client -starttls smtp -connect 10.1.0.1:25 -servername mail.dorayaki.com
#puerto 993 para IMAP con SSL/TLS
openssl s_client -connect 10.1.0.1:993 -servername mail.dorayaki.com
a1 LOGIN maria@dorayaki.org alumno
a2 LOGOUT
#puerto 995 para POP3 con SSL/TLS
openssl s_client -connect 10.1.0.1:995 -servername mail.dorayaki.com
USER maria@dorayaki.org
PASS alumno
QUIT