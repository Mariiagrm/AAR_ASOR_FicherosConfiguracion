#!/usr/bin/env bash
# instalacion_kubernetes_minikube.sh
# Script para instalar Docker, Kubectl y Minikube en una máquina Linux basada en Debian/Ubuntu
# Uso: sudo ./instalacion_kubernetes_minikube.sh


#----- CONFIGURACIÓN -----------------------------------------------------------
MINIKUBE_VERSION="${MINIKUBE_VERSION:-latest}"    # latest o número concreto
KUBECTL_VERSION="${KUBECTL_VERSION:-stable}"      # stable o v1.xx.x
MINIKUBE_DRIVER="${MINIKUBE_DRIVER:-docker}"      # docker, none, virtualbox, etc.

#----- FUNCIONES AUXILIARES ----------------------------------------------------

log()  { echo -e "[INFO ] $*"; }
warn() { echo -e "[WARN ] $*" >&2; }
err()  { echo -e "[ERROR] $*" >&2; exit 1; }

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        err "Este script debe ejecutarse como root (usa: sudo $0)"
    fi
}

detect_os() {
    if [[ -r /etc/os-release ]]; then
        . /etc/os-release
        OS_ID=$ID
        OS_VERSION_ID=$VERSION_ID
    else
        err "No se pudo detectar el sistema operativo (falta /etc/os-release)."
    fi

    case "$OS_ID" in
        ubuntu|debian)
            PKG_MGR="apt"
            ;;
        *)
            err "Sistema operativo no soportado: $OS_ID. Solo Debian/Ubuntu."
            ;;
    esac

    log "Sistema detectado: $OS_ID $OS_VERSION_ID"
}

update_system() {
    log "Actualizando índice de paquetes..."
    apt-get update -y
}

install_basic_tools() {
    log "Instalando herramientas básicas..."
    apt-get install -y ca-certificates curl wget apt-transport-https gnupg lsb-release software-properties-common
    apt-get install curl -y
}

install_docker() {
    if command -v docker >/dev/null 2>&1; then
        log "Docker ya está instalado, omitiendo."
        return
    fi

    log "Instalando Docker CE..."

    install_basic_tools

    install -m 0755 -d /etc/apt/keyrings
    if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
        curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg \
            | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        chmod a+r /etc/apt/keyrings/docker.gpg
    fi

    ARCH=$(dpkg --print-architecture)
    . /etc/os-release
    echo \
        "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} \
        ${VERSION_CODENAME} stable" \
        | tee /etc/apt/sources.list.d/docker.list >/dev/null

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable docker
    systemctl start docker

    log "Docker instalado correctamente."
}

install_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        log "kubectl ya está instalado, omitiendo."
        return
    fi

    log "Instalando kubectl..."

    if [[ "$KUBECTL_VERSION" == "stable" ]]; then
        VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
    else
        VERSION="$KUBECTL_VERSION"
    fi

    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7l) ARCH="arm" ;;
        *) err "Arquitectura no soportada para kubectl: $ARCH" ;;
    esac

    curl -LO "https://dl.k8s.io/release/${VERSION}/bin/linux/${ARCH}/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl

    log "kubectl ${VERSION} instalado correctamente."
}

install_minikube() {
    if command -v minikube >/dev/null 2>&1; then
        log "minikube ya está instalado, omitiendo."
        return
    fi

    log "Instalando Minikube..."

    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7l) ARCH="arm" ;;
        *) err "Arquitectura no soportada para Minikube: $ARCH" ;;
    esac

    if [[ "$MINIKUBE_VERSION" == "latest" ]]; then
        URL="https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${ARCH}"
    else
        URL="https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-${ARCH}"
    fi

    curl -Lo /usr/local/bin/minikube "${URL}"
    chmod +x /usr/local/bin/minikube

    log "Minikube instalado correctamente."
}

configure_user_docker() {
    local user_name="${SUDO_USER:-}"

    if [[ -z "$user_name" || "$user_name" == "root" ]]; then
        warn "No se detectó usuario no root (SUDO_USER vacío)."
        warn "Si quieres usar Docker/Minikube como usuario normal, añade el usuario manualmente al grupo docker."
        return
    fi

    if ! getent group docker >/dev/null 2>&1; then
        groupadd docker
    fi

    usermod -aG docker "$user_name"
    log "Usuario '$user_name' añadido al grupo docker. Cierra sesión y vuelve a entrar para que surta efecto."
}

start_minikube() {
    local user_name="${SUDO_USER:-root}"

    log "Intentando iniciar Minikube con driver '${MINIKUBE_DRIVER}' como usuario '${user_name}'..."

    # Creamos un script temporal para lanzarlo como el usuario normal
    local tmp_script="/tmp/start_minikube_$user_name.sh"

    cat > "$tmp_script" <<EOF
#!/usr/bin/env bash
set -euo pipefail
export MINIKUBE_IN_STYLE=false
minikube start --driver=${MINIKUBE_DRIVER}
EOF

    chmod +x "$tmp_script"

    if [[ "$user_name" != "root" ]]; then
        sudo -u "$user_name" -H bash "$tmp_script" || warn "Fallo al iniciar Minikube como $user_name. Inícialo manualmente."
    else
        bash "$tmp_script" || warn "Fallo al iniciar Minikube. Inícialo manualmente."
    fi

    rm -f "$tmp_script"

    log "Si no hubo errores, el cluster Minikube está levantado."
}

#----- MAIN --------------------------------------------------------------------

require_root
detect_os
update_system
install_docker
install_kubectl
install_minikube
configure_user_docker

log "Instalación completada."

cat <<'EOSUM'
----------------------------------------------------------------------
Kubernetes + Minikube instalados.

Pasos recomendados:

1) Cerrar sesión y volver a entrar para aplicar el grupo docker (si corresponde).

2) Iniciar Minikube manualmente (si el script no lo hizo o falló):
     minikube start --driver=docker

3) Probar el cluster:
     kubectl get nodes

Variables opcionales (antes de ejecutar el script):
    MINIKUBE_VERSION=<versión o 'latest'>
    KUBECTL_VERSION=<versión ej: v1.30.0 o 'stable'>
    MINIKUBE_DRIVER=docker|none|virtualbox|...

Ejemplo:
    sudo MINIKUBE_DRIVER=docker ./instalacion_kubernetes_minikube.sh
----------------------------------------------------------------------
EOSUM

# Intentar iniciar minikube automáticamente (no obligatorio)
start_minikube || true