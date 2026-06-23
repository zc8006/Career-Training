#!/bin/bash
set -euo pipefail

# IBM Process Mining 2.0.3 remote restore script
# Run this on the NEW IBM TechZone RHEL VM.
# Usually invoked by tools/windows/restore_pm_one_click.bat.
#
# Usage:
#   bash pm_restore_remote.sh <backup_bundle_path> <new_public_ip> <new_hostname> <db_plain_password>
#
# Notes:
# - <db_plain_password> must match the password used for the PostgreSQL user 'processmining'.
# - The script generates the encrypted DB password and updates PM config files.
# - Do NOT store real passwords in GitHub.

if [ "$#" -lt 4 ]; then
  echo "Usage: bash $0 <backup_bundle_path> <new_public_ip> <new_hostname> <db_plain_password>"
  exit 1
fi

BACKUP_BUNDLE="$1"
NEW_PUBLIC_IP="$2"
NEW_HOSTNAME="$3"
DB_PLAIN_PASSWORD="$4"

PM_HOME="${PM_HOME:-/opt/processmining}"
PM_USER="${PM_USER:-itzuser}"
DB_USER="${DB_USER:-processmining}"
DB_NAME="${DB_NAME:-processmining}"
WORK_DIR="/home/${PM_USER}/pm_restore_work"
RESTORE_LOG="/home/${PM_USER}/pm_restore_$(date +%Y%m%d_%H%M%S).log"

exec > >(tee -a "${RESTORE_LOG}") 2>&1

echo "=== IBM Process Mining Restore ==="
echo "BACKUP_BUNDLE : ${BACKUP_BUNDLE}"
echo "NEW_PUBLIC_IP : ${NEW_PUBLIC_IP}"
echo "NEW_HOSTNAME  : ${NEW_HOSTNAME}"
echo "PM_HOME       : ${PM_HOME}"
echo "DB_NAME       : ${DB_NAME}"
echo "LOG           : ${RESTORE_LOG}"
echo

if [ ! -f "${BACKUP_BUNDLE}" ]; then
  echo "ERROR: backup bundle not found: ${BACKUP_BUNDLE}"
  exit 1
fi

install_packages() {
  echo "[1/12] Install system dependencies: PostgreSQL 15, Python 3.12, NGINX"
  sudo rpm --import https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL || true
  sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm || true
  sudo yum -qy module disable postgresql || true
  sudo yum install -y postgresql15-server python3.12 nginx
}

init_postgres() {
  echo "[2/12] Initialize and start PostgreSQL 15"
  if [ ! -f /var/lib/pgsql/15/data/PG_VERSION ]; then
    sudo postgresql-15-setup initdb
  else
    echo "PostgreSQL data directory already initialized"
  fi
  sudo systemctl enable postgresql-15
  sudo systemctl start postgresql-15
  sudo systemctl status postgresql-15 --no-pager || true
}

extract_bundle() {
  echo "[3/12] Extract backup bundle"
  rm -rf "${WORK_DIR}"
  mkdir -p "${WORK_DIR}"
  tar -xzf "${BACKUP_BUNDLE}" -C "${WORK_DIR}"
  BACKUP_DIR="$(find "${WORK_DIR}" -maxdepth 1 -type d -name 'pm_backup_*' | head -1)"
  if [ -z "${BACKUP_DIR}" ]; then
    echo "ERROR: could not find pm_backup_* directory in bundle"
    exit 1
  fi
  echo "Backup directory: ${BACKUP_DIR}"
}

stop_pm_services() {
  echo "[4/12] Stop existing PM services if present"
  if [ -d "${PM_HOME}/bin" ]; then
    cd "${PM_HOME}/bin"
    for svc in pm-monitoring.sh pm-brm.sh pm-accelerators.sh pm-analytics.sh pm-engine.sh pm-web.sh pm-monet.sh; do
      [ -x "./${svc}" ] && "./${svc}" stop || true
    done
  else
    echo "${PM_HOME}/bin not found yet, skipping stop"
  fi
}

restore_files() {
  echo "[5/12] Restore PM, NGINX, and certificate files"
  sudo tar -xzf "${BACKUP_DIR}/processmining.tar.gz" -C /
  if [ -f "${BACKUP_DIR}/nginx.tar.gz" ]; then
    sudo tar -xzf "${BACKUP_DIR}/nginx.tar.gz" -C /
  fi
  if [ -f "${BACKUP_DIR}/cert.tar.gz" ]; then
    sudo tar -xzf "${BACKUP_DIR}/cert.tar.gz" -C /
  fi
  sudo chown -R "${PM_USER}:${PM_USER}" "${PM_HOME}"
}

update_hosts() {
  echo "[6/12] Update /etc/hosts"
  sudo cp /etc/hosts "/etc/hosts.bak.$(date +%Y%m%d_%H%M%S)"
  sudo sed -i '/pm\.processmining/d;/tm\.processmining/d' /etc/hosts
  echo "${NEW_PUBLIC_IP} pm.processmining tm.processmining ${NEW_HOSTNAME}" | sudo tee -a /etc/hosts >/dev/null
  cat /etc/hosts
}

setup_postgres_user_db() {
  echo "[7/12] Create PostgreSQL user/database"
  if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | grep -q 1; then
    sudo -u postgres createuser "${DB_USER}"
  fi
  sudo -u postgres psql -c "ALTER USER ${DB_USER} WITH ENCRYPTED PASSWORD '${DB_PLAIN_PASSWORD}';"

  if ! sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='${DB_NAME}'" | grep -q 1; then
    sudo -u postgres createdb -O "${DB_USER}" "${DB_NAME}"
  fi
}

restore_postgres_dump_or_init() {
  echo "[8/12] Restore PostgreSQL dump or initialize DB"
  POSTGRES_DUMP="${BACKUP_DIR}/postgres_${DB_NAME}.dump"
  if [ -f "${POSTGRES_DUMP}" ]; then
    echo "Found PostgreSQL dump: ${POSTGRES_DUMP}"
    sudo -u postgres dropdb --if-exists "${DB_NAME}"
    sudo -u postgres createdb -O "${DB_USER}" "${DB_NAME}"
    sudo -u postgres pg_restore -d "${DB_NAME}" "${POSTGRES_DUMP}"
  else
    echo "WARN: PostgreSQL dump not found. Falling back to postgres-utils.sh initialization."
    export JAVA_HOME="${PM_HOME}/jdk/linux/ibm-openjdk-semeru"
    cd "${PM_HOME}/utils/database-utils"
    ./postgres-utils.sh
  fi
}

update_pm_db_password() {
  echo "[9/12] Update encrypted DB password in PM config files"
  cd "${PM_HOME}/utils/crypto-utils"
  ENCRYPTED_DB_PASSWORD="$(./crypt-utils.sh "${DB_PLAIN_PASSWORD}" | awk -F': ' '/Encrypted String/ {print $2}')"
  if [ -z "${ENCRYPTED_DB_PASSWORD}" ]; then
    echo "ERROR: failed to generate encrypted DB password"
    exit 1
  fi

  if [ -f "${PM_HOME}/etc/processmining.conf" ]; then
    perl -0pi -e 's/(password\s*:\s*")[^"]*(")/${1}'"${ENCRYPTED_DB_PASSWORD}"'${2}/s' "${PM_HOME}/etc/processmining.conf"
  fi

  if [ -f "${PM_HOME}/etc/accelerator-core.properties" ]; then
    if grep -q '^spring.datasource.password=' "${PM_HOME}/etc/accelerator-core.properties"; then
      sed -i "s|^spring.datasource.password=.*|spring.datasource.password=${ENCRYPTED_DB_PASSWORD}|" "${PM_HOME}/etc/accelerator-core.properties"
    else
      echo "spring.datasource.password=${ENCRYPTED_DB_PASSWORD}" >> "${PM_HOME}/etc/accelerator-core.properties"
    fi
  fi
}

apply_selinux_and_nginx() {
  echo "[10/12] Apply SELinux settings and restart NGINX"
  if [ -d /etc/nginx/ssl ]; then
    sudo chcon -t httpd_config_t /etc/nginx/ssl/*.* || true
  fi
  sudo setsebool -P httpd_can_network_connect 1 || true
  sudo systemctl enable nginx
  sudo nginx -t
  sudo systemctl restart nginx
}

start_pm_services() {
  echo "[11/12] Start PM services"
  cd "${PM_HOME}/bin"
  for svc in pm-monet.sh pm-web.sh pm-engine.sh pm-analytics.sh pm-accelerators.sh pm-brm.sh pm-monitoring.sh; do
    if [ -x "./${svc}" ]; then
      echo "Starting ${svc}"
      "./${svc}" start
    else
      echo "WARN: ${svc} not found or not executable"
    fi
  done
}

verify_restore() {
  echo "[12/12] Verify restore"
  echo "Checking local PM endpoint..."
  curl -k -I https://pm.processmining || true
  echo
  echo "Expected success: HTTP/1.1 302 Found and Location: /signin"
  echo "Restore log: ${RESTORE_LOG}"
}

install_packages
init_postgres
extract_bundle
stop_pm_services
restore_files
update_hosts
setup_postgres_user_db
restore_postgres_dump_or_init
update_pm_db_password
apply_selinux_and_nginx
start_pm_services
verify_restore

echo "=== Restore completed ==="
