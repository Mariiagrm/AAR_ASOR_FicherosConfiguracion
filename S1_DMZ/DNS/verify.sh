#Verificar que va serviodor DNS
#Creamos contenedor temporal en la misma red que el dns
docker run --rm -it \
  --network=testing_net \
  --name dns-client \
  alpine sh
#Dentro del contenedor cliente ejecutamos:
apk add bind-tools
dig @10.1.0.1 dorayaki.org