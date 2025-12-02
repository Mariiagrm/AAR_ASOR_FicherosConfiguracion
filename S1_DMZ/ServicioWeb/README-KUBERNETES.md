**Comprobar el contexto de kubectl**
Antes de nada 
```bash
kubectl config current-context
kubectl config view
```

**Asegurarse que minikube esta arrancado**
Antes de nada 
```bash
minikube status
``
Si esta parado
```bash
minikube start
```
**Para usar ingress controller en Minikube**
Para usar el balenceador de carga dentro de kubernetes tenemos que tener habilitadas esta opcion
```bash
minikube addons enable ingress
```