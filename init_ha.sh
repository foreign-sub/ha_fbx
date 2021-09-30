#!/usr/bin/env bash
set -e

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y ansible
ANSIBLE_FORCE_COLOR=1 PYTHONUNBUFFERED=1 ansible-playbook /root/ha_fbx.yml

declare -a MISSING_PACKAGES

function info { echo -e "\e[32m[info] $*\e[39m"; }
function warn  { echo -e "\e[33m[warn] $*\e[39m"; }
function error { echo -e "\e[31m[error] $*\e[39m"; exit 1; }

ARCH=$(uname -m)

IP_ADDRESS=$(hostname -I | awk '{ print $1 }')

BINARY_DOCKER=/usr/bin/docker

DOCKER_REPO=homeassistant

SERVICE_DOCKER="docker.service"
SERVICE_NM="NetworkManager.service"

FILE_DOCKER_CONF="/etc/docker/daemon.json"
FILE_INTERFACES="/etc/network/interfaces"
FILE_NM_CONF="/etc/NetworkManager/NetworkManager.conf"
FILE_NM_CONNECTION="/etc/NetworkManager/system-connections/default"

URL_RAW_BASE="https://raw.githubusercontent.com/home-assistant/supervised-installer/master/files"
URL_VERSION="https://version.home-assistant.io/stable.json"
URL_BIN_APPARMOR="${URL_RAW_BASE}/hassio-apparmor"
URL_BIN_HASSIO="${URL_RAW_BASE}/hassio-supervisor"
URL_DOCKER_DAEMON="${URL_RAW_BASE}/docker_daemon.json"
URL_HA="${URL_RAW_BASE}/ha"
URL_INTERFACES="${URL_RAW_BASE}/interfaces"
URL_NM_CONF="${URL_RAW_BASE}/NetworkManager.conf"
URL_NM_CONNECTION="${URL_RAW_BASE}/system-connection-default"
URL_SERVICE_APPARMOR="${URL_RAW_BASE}/hassio-apparmor.service"
URL_SERVICE_HASSIO="${URL_RAW_BASE}/hassio-supervisor.service"
URL_APPARMOR_PROFILE="https://version.home-assistant.io/apparmor.txt"

# Check env
command -v systemctl > /dev/null 2>&1 || MISSING_PACKAGES+=("systemd")
command -v nmcli > /dev/null 2>&1 || MISSING_PACKAGES+=("network-manager")
command -v apparmor_parser > /dev/null 2>&1 || MISSING_PACKAGES+=("apparmor")
command -v docker > /dev/null 2>&1 || MISSING_PACKAGES+=("docker")
command -v jq > /dev/null 2>&1 || MISSING_PACKAGES+=("jq")
command -v curl > /dev/null 2>&1 || MISSING_PACKAGES+=("curl")
command -v dbus-daemon > /dev/null 2>&1 || MISSING_PACKAGES+=("dbus")

if [ ! -z "${MISSING_PACKAGES}" ]; then
    warn "The following is missing on the host and needs "
    warn "to be installed and configured before running this script again"
    error "missing: ${MISSING_PACKAGES[@]}"
fi

# Check if Modem Manager is enabled
if systemctl list-unit-files ModemManager.service | grep enabled; then
    warn "[Warning] ModemManager service is enabled. This might cause issue when using serial devices."
fi

# Detect wrong docker logger config
if [ ! -f "$FILE_DOCKER_CONF" ]; then
  # Write default configuration
  info "Creating default docker daemon configuration $FILE_DOCKER_CONF"
  curl -sL ${URL_DOCKER_DAEMON} > "${FILE_DOCKER_CONF}"

  # Restart Docker service
  info "Restarting docker service"
  systemctl restart "$SERVICE_DOCKER"
else
  STORAGE_DRIVER=$(docker info -f "{{json .}}" | jq -r -e .Driver)
  LOGGING_DRIVER=$(docker info -f "{{json .}}" | jq -r -e .LoggingDriver)
  if [[ "$STORAGE_DRIVER" != "overlay2" ]]; then 
    warn "Docker is using $STORAGE_DRIVER and not 'overlay2' as the storage driver, this is not supported."
  fi
  if [[ "$LOGGING_DRIVER"  != "journald" ]]; then 
    warn "Docker is using $LOGGING_DRIVER and not 'journald' as the logging driver, this is not supported."
  fi
fi

# Check dmesg access
if [[ "$(sysctl --values kernel.dmesg_restrict)" != "0" ]]; then
    info "Fix kernel dmesg restriction"
    echo 0 > /proc/sys/kernel/dmesg_restrict
    echo "kernel.dmesg_restrict=0" >> /etc/sysctl.conf
fi

# Create config for NetworkManager
info "Creating NetworkManager configuration"
curl -sL "${URL_NM_CONF}" > "${FILE_NM_CONF}"
if [ ! -f "$FILE_NM_CONNECTION" ]; then
    curl -sL "${URL_NM_CONNECTION}" > "${FILE_NM_CONNECTION}"
fi
info "Replacing /etc/network/interfaces"
curl -sL "${URL_INTERFACES}" > "${FILE_INTERFACES}";
info "Restarting NetworkManager"
systemctl restart "${SERVICE_NM}"

### Main

PREFIX=${PREFIX:-/usr}
SYSCONFDIR=${SYSCONFDIR:-/etc}
DATA_SHARE=${DATA_SHARE:-$PREFIX/share/hassio}
CONFIG=$SYSCONFDIR/hassio.json

MACHINE=qemuarm-64
HASSIO_DOCKER="$DOCKER_REPO/aarch64-hassio-supervisor"

# Init folders
if [ ! -d "$DATA_SHARE" ]; then
    mkdir -p "$DATA_SHARE"
fi

# Read infos from web
HASSIO_VERSION=$(curl -s $URL_VERSION | jq -e -r '.supervisor')

##
# Write configuration
cat > "$CONFIG" <<- EOF
{
    "supervisor": "${HASSIO_DOCKER}",
    "machine": "${MACHINE}",
    "data": "${DATA_SHARE}"
}
EOF

##
# Pull supervisor image
info "Install supervisor Docker container"
docker pull "$HASSIO_DOCKER:$HASSIO_VERSION" > /dev/null
docker tag "$HASSIO_DOCKER:$HASSIO_VERSION" "$HASSIO_DOCKER:latest" > /dev/null

##
# Install Hass.io Supervisor
info "Install supervisor startup scripts"
curl -sL ${URL_BIN_HASSIO} > "${PREFIX}/sbin/hassio-supervisor"
curl -sL ${URL_SERVICE_HASSIO} > "${SYSCONFDIR}/systemd/system/hassio-supervisor.service"

sed -i "s,%%HASSIO_CONFIG%%,${CONFIG},g" "${PREFIX}"/sbin/hassio-supervisor
sed -i -e "s,%%BINARY_DOCKER%%,${BINARY_DOCKER},g" \
       -e "s,%%SERVICE_DOCKER%%,${SERVICE_DOCKER},g" \
       -e "s,%%BINARY_HASSIO%%,${PREFIX}/sbin/hassio-supervisor,g" \
       "${SYSCONFDIR}/systemd/system/hassio-supervisor.service"

chmod a+x "${PREFIX}/sbin/hassio-supervisor"
systemctl enable hassio-supervisor.service > /dev/null 2>&1;

#
# Install Hass.io AppArmor
info "Install AppArmor scripts"
mkdir -p "${DATA_SHARE}/apparmor"
curl -sL ${URL_BIN_APPARMOR} > "${PREFIX}/sbin/hassio-apparmor"
curl -sL ${URL_SERVICE_APPARMOR} > "${SYSCONFDIR}/systemd/system/hassio-apparmor.service"
curl -sL ${URL_APPARMOR_PROFILE} > "${DATA_SHARE}/apparmor/hassio-supervisor"

sed -i "s,%%HASSIO_CONFIG%%,${CONFIG},g" "${PREFIX}/sbin/hassio-apparmor"
sed -i -e "s,%%SERVICE_DOCKER%%,${SERVICE_DOCKER},g" \
    -e "s,%%HASSIO_APPARMOR_BINARY%%,${PREFIX}/sbin/hassio-apparmor,g" \
    "${SYSCONFDIR}/systemd/system/hassio-apparmor.service"

chmod a+x "${PREFIX}/sbin/hassio-apparmor"
systemctl enable hassio-apparmor.service > /dev/null 2>&1;
systemctl start hassio-apparmor.service

##
# Init system
info "Start Home Assistant Supervised"
systemctl start hassio-supervisor.service

##
# Setup CLI
info "Installing the 'ha' cli"
curl -sL ${URL_HA} > "${PREFIX}/bin/ha"
chmod a+x "${PREFIX}/bin/ha"

# Parse command line parameters
while [[ $# -gt 0 ]]; do
    arg="$1"

    case $arg in
        -wh|--with-hacs)
            info "Installing 'hacs' requirements"
            apt install -y unzip
            info "Waiting 3 mins"
            sleep 180
            info "Checking 'ha' setup progress"
            timeout 1200 bash -c '{ until exec 3<>/dev/tcp/localhost/8123; do sleep 60; done } > /dev/null 2>&1 || [ "$?" = 1 ]'
            info "Waiting 6 mins"
            sleep 480
            info "Installing 'hacs'"
            cd /usr/share/hassio/homeassistant/
            wget -q -O - https://install.hacs.xyz | bash -
            shift
            ;;
        *)
            error "Unknown option $1"
            ;;
    esac
    shift
done
