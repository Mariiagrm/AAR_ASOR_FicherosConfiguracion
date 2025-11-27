#!/bin/sh
# Script sencillo para probar conexión FTP y realizar una transferencia básica

FTP_HOST="172.17.0.5"     # Cambia por la IP o nombre del servidor FTP
FTP_PORT="21"            # Puerto FTP (21 por defecto, 2121 si usas vsftpd en modo alternativo, etc.)
FTP_USER="alumno"       # Usuario FTP
FTP_PASS="alumno"      # Contraseña FTP
REMOTE_DIR="/"           # Directorio remoto a usar
LOCAL_TEST_FILE="/tmp/ftp_test_$$.txt"
REMOTE_TEST_FILE="ftp_test_$$.txt"

echo "Creando fichero local de prueba: $LOCAL_TEST_FILE"
echo "Prueba FTP $(date)" > "$LOCAL_TEST_FILE"

echo "Probando conexión FTP a $FTP_HOST:$FTP_PORT con usuario $FTP_USER"

ftp -inv "$FTP_HOST" "$FTP_PORT" <<EOF
user $FTP_USER $FTP_PASS
cd $REMOTE_DIR
put $LOCAL_TEST_FILE $REMOTE_TEST_FILE
ls
get $REMOTE_TEST_FILE /tmp/ftp_test_descargado_$$.txt
bye
EOF

RET=$?

if [ $RET -eq 0 ]; then
    echo "La sesión FTP ha finalizado sin errores (código $RET)."
else
    echo "Error en la sesión FTP (código $RET)." >&2
fi

echo "Comprobando si se ha descargado el fichero..."
if [ -f "/tmp/ftp_test_descargado_$$.txt" ]; then
    echo "Transferencia OK. Contenido descargado:"
    cat "/tmp/ftp_test_descargado_$$.txt"
else
    echo "No se ha encontrado el fichero descargado. Algo ha fallado." >&2
fi

# Limpieza opcional
# rm -f "$LOCAL_TEST_FILE" "/tmp/ftp_test_descargado_$$.txt"

exit $RET