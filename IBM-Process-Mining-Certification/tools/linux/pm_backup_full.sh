#!/bin/bash
set -euo pipefail

# IBM Process Mining 2.0.3 FULL SAFE backup script
# Run this on the OLD/CURRENT IBM TechZone RHEL VM.
# It stops PM services, backs up application files, repository/MonetDB data,
# NGINX config/certs, hosts, and PostgreSQL database, then starts PM services again.
# Do NOT commit generated backup bundles, certificates, keys, or dumps to GitHub.

PM_HOME="${PM_HOME:-/opt/processmining}"
PM_USER="${PM_USER:-itzuser}"
DB_NAME="${DB_NAME:-processmining}"
DATE="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="/home/${PM_USER}/pm_full_backup_${DATE}"
BUNDLE="/home/${PM_USER}/pm_full_backup_${DATE}.tar.gz"

start_pm_services() {
  echo "[START] Restart Process Mining services"
  if [ -d "${PM_HOME}/bin" ]; then
    cd "${PM_HOME}/bin"
    ./pm-monet.sh start || true
    ./pm-web.sh start || true
    ./pm-engine.sh start || true
    ./pm-analytics.sh start || true
    ./pm-accelerators.sh start || true
    ./pm-brm.sh start || true
    ./pm-monitoring.sh start || true
  fi
}

on_error() {
  echo
  echo "ERROR: backup failed. Trying to start PM services before exit..."
  start_pm_services
}
trap on_error ERR

echo "=== IBM Process Mining FULL SAFE BACKUP ==="
echo "PM_HOME      : ${PM_HOME}"
echo "DB_NAME      : ${DB_NAME}"
echo "BACKUP_DIR   : ${BACKUP_DIR}"
echo "BUNDLE       : ${BUNDLE}"
echo

mkdir -p "${BACKUP_DIR}"

echo "[1/10] Stop Process Mining services for consistent backup"
if [ -d "${PM_HOME}/bin" ]; then
  cd "${PM_HOME}/bin"
  ./pm-monitoring.sh stop || true
  ./pm-brm.sh stop || true
  ./pm-accelerators.sh stop || true
  ./pm-analytics.sh stop || true
  ./pm-engine.sh stop || true
  ./pm-web.sh stop || true
  ./pm-monet.sh stop || true
else
  echo "WARN: ${PM_HOME}/bin not found, skipping PM stop"
fi

echo "[2/10] Backup ${PM_HOME}"
sudo tar -czf "${BACKUP_DIR}/processmining.tar.gz" "${PM_HOME}"

echo "[3/10] Backup PostgreSQL database"
if command -v pg_dump >/dev/null 2>&1 || [ -x /usr/pgsql-15/bin/pg_dump ]; then
  PG_DUMP_BIN="$(command -v pg_dump || true)"
  [ -z "${PG_DUMP_BIN}" ] && PG_DUMP_BIN="/usr/pgsql-15/bin/pg_dump"
  TMP_DUMP="/tmp/postgres_${DB_NAME}_${DATE}.dump"
  sudo -u postgres "${PG_DUMP_BIN}" -Fc -d "${DB_NAME}" -f "${TMP_DUMP}"
  sudo mv "${TMP_DUMP}" "${BACKUP_DIR}/postgres_${DB_NAME}.dump"
  sudo chown "${PM_USER}:${PM_USER}" "${BACKUP_DIR}/postgres_${DB_NAME}.dump"
else
  echo "WARN: pg_dump not found, PostgreSQL dump skipped"
fi

echo "[4/10] Backup /etc/nginx"
if [ -d /etc/nginx ]; then
  sudo tar -czf "${BACKUP_DIR}/nginx.tar.gz" /etc/nginx
else
  echo "WARN: /etc/nginx not found, skipping NGINX backup"
fi

echo "[5/10] Backup certificate directories"
CERT_TARGETS=()
[ -d "${PM_HOME}/cert" ] && CERT_TARGETS+=("${PM_HOME}/cert")
[ -d /etc/nginx/ssl ] && CERT_TARGETS+=(/etc/nginx/ssl)
if [ ${#CERT_TARGETS[@]} -gt 0 ]; then
  sudo tar -czf "${BACKUP_DIR}/cert.tar.gz" "${CERT_TARGETS[@]}"
else
  echo "WARN: no certificate directory found, skipping cert backup"
fi

echo "[6/10] Backup /etc/hosts"
cp /etc/hosts "${BACKUP_DIR}/hosts.bak"

echo "[7/10] Write backup metadata"
cat > "${BACKUP_DIR}/README_RESTORE.txt" <<EOF
IBM Process Mining full safe backup created at: ${DATE}
PM_HOME: ${PM_HOME}
DB_NAME: ${DB_NAME}

Files:
- processmining.tar.gz             : /opt/processmining application, repository, MonetDB/event-log data
- postgres_${DB_NAME}.dump         : PostgreSQL custom-format dump
- nginx.tar.gz                     : /etc/nginx config, if present
- cert.tar.gz                      : PM/NGINX certificate directories, if present
- hosts.bak                        : old VM /etc/hosts

Backup mode:
- PM services were stopped before backing up /opt/processmining.
- PM services were started again after the final bundle was created.

Security:
- Do not upload this backup bundle to GitHub.
- It may contain imported data, dashboards/projects, certificates, private keys, DB data, users, and system config.
EOF

echo "[8/10] Fix ownership and create final bundle"
sudo chown -R "${PM_USER}:${PM_USER}" "${BACKUP_DIR}"
tar -czf "${BUNDLE}" -C "/home/${PM_USER}" "$(basename "${BACKUP_DIR}")"

ls -lh "${BUNDLE}"

echo "[9/10] Start Process Mining services"
start_pm_services

echo "[10/10] Verify endpoint"
curl -k -I https://pm.processmining || true

echo
echo "Backup completed: ${BUNDLE}"
