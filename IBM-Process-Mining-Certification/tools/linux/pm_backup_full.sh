#!/bin/bash
set -euo pipefail

# IBM Process Mining 2.0.3 full backup script
# Run this on the OLD IBM TechZone RHEL VM.
# It backs up application files, NGINX config/certs, hosts, and PostgreSQL database.
# Do NOT commit generated backup bundles, certificates, keys, or dumps to GitHub.

PM_HOME="${PM_HOME:-/opt/processmining}"
PM_USER="${PM_USER:-itzuser}"
DB_NAME="${DB_NAME:-processmining}"
DATE="$(date +%Y%m%d_%H%M%S)"
BACKUP_DIR="/home/${PM_USER}/pm_backup_${DATE}"
BUNDLE="/home/${PM_USER}/pm_backup_${DATE}.tar.gz"

echo "=== IBM Process Mining Full Backup ==="
echo "PM_HOME      : ${PM_HOME}"
echo "DB_NAME      : ${DB_NAME}"
echo "BACKUP_DIR   : ${BACKUP_DIR}"
echo "BUNDLE       : ${BUNDLE}"
echo

mkdir -p "${BACKUP_DIR}"

echo "[1/7] Backup ${PM_HOME}"
sudo tar -czf "${BACKUP_DIR}/processmining.tar.gz" "${PM_HOME}"

echo "[2/7] Backup /etc/nginx"
if [ -d /etc/nginx ]; then
  sudo tar -czf "${BACKUP_DIR}/nginx.tar.gz" /etc/nginx
else
  echo "WARN: /etc/nginx not found, skipping NGINX backup"
fi

echo "[3/7] Backup /etc/hosts"
cp /etc/hosts "${BACKUP_DIR}/hosts.bak"

echo "[4/7] Backup certificate directories"
CERT_TARGETS=()
[ -d "${PM_HOME}/cert" ] && CERT_TARGETS+=("${PM_HOME}/cert")
[ -d /etc/nginx/ssl ] && CERT_TARGETS+=(/etc/nginx/ssl)
if [ ${#CERT_TARGETS[@]} -gt 0 ]; then
  sudo tar -czf "${BACKUP_DIR}/cert.tar.gz" "${CERT_TARGETS[@]}"
else
  echo "WARN: no certificate directory found, skipping cert backup"
fi

echo "[5/7] Backup PostgreSQL database"
if command -v pg_dump >/dev/null 2>&1 || [ -x /usr/pgsql-15/bin/pg_dump ]; then
  PG_DUMP_BIN="$(command -v pg_dump || true)"
  [ -z "${PG_DUMP_BIN}" ] && PG_DUMP_BIN="/usr/pgsql-15/bin/pg_dump"
  sudo -u postgres "${PG_DUMP_BIN}" -Fc -d "${DB_NAME}" -f "${BACKUP_DIR}/postgres_${DB_NAME}.dump"
else
  echo "WARN: pg_dump not found, skipping PostgreSQL dump"
fi

echo "[6/7] Write backup metadata"
cat > "${BACKUP_DIR}/README_RESTORE.txt" <<EOF
IBM Process Mining backup created at: ${DATE}
PM_HOME: ${PM_HOME}
DB_NAME: ${DB_NAME}

Files:
- processmining.tar.gz             : /opt/processmining application and repository files
- nginx.tar.gz                     : /etc/nginx config, if present
- cert.tar.gz                      : PM/NGINX certificate directories, if present
- hosts.bak                        : old VM /etc/hosts
- postgres_${DB_NAME}.dump         : PostgreSQL custom-format dump, if present

Security:
- Do not upload this backup bundle to public GitHub.
- It may contain certificates, private keys, DB data, and system config.
EOF

echo "[7/7] Fix ownership and create final bundle"
sudo chown -R "${PM_USER}:${PM_USER}" "${BACKUP_DIR}"
tar -czf "${BUNDLE}" -C "/home/${PM_USER}" "$(basename "${BACKUP_DIR}")"

ls -lh "${BUNDLE}"
echo
echo "Backup completed: ${BUNDLE}"
