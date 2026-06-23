# IBM Process Mining 2.0.3 Backup and Restore Tools

This folder contains helper scripts for backing up and restoring an IBM Process Mining 2.0.3 environment on IBM TechZone RHEL 9 VMs.

The goal is to reduce repeated manual work when a TechZone reservation expires and a new VM is provisioned.

> Do not commit generated backup bundles, certificates, private keys, database dumps, VM passwords, or SSH private keys to GitHub.

## Files

```text
IBM-Process-Mining-Certification/tools/
├── linux/
│   ├── pm_backup_full.sh
│   └── pm_restore_remote.sh
├── windows/
│   ├── backup_pm_one_click.bat
│   └── restore_pm_one_click.bat
└── README-backup-restore.md
```

## What the backup includes

`linux/pm_backup_full.sh` creates a timestamped backup bundle on the old VM.

It backs up:

```text
/opt/processmining
/etc/nginx
/etc/hosts
/opt/processmining/cert
/etc/nginx/ssl
PostgreSQL database: processmining
```

The PostgreSQL backup is created with `pg_dump -Fc`, for example:

```text
postgres_processmining.dump
```

This is important. Backing up only `/opt/processmining` is not enough because PostgreSQL is a system service and is not inside `/opt/processmining`.

## One-click backup from Windows

Edit:

```text
tools/windows/backup_pm_one_click.bat
```

Set:

```bat
set "OLD_IP=<OLD_VM_PUBLIC_IP>"
set "SSH_PORT=2223"
set "SSH_USER=itzuser"
set "SSH_KEY=C:\IBM_PM\pem_ibmcloudvsi_download.pem"
set "LOCAL_BACKUP_DIR=%USERPROFILE%\IBM_PM_Backups"
```

Then run the BAT file from Windows.

It will:

1. upload `linux/pm_backup_full.sh` to the old VM,
2. run the backup on the old VM,
3. find the latest `pm_backup_*.tar.gz`,
4. download it to the local backup folder.

## One-click restore from Windows

Edit:

```text
tools/windows/restore_pm_one_click.bat
```

Set:

```bat
set "NEW_IP=<NEW_VM_PUBLIC_IP>"
set "NEW_HOSTNAME=<NEW_VM_HOSTNAME>"
set "SSH_PORT=2223"
set "SSH_USER=itzuser"
set "SSH_KEY=C:\IBM_PM\pem_ibmcloudvsi_download.pem"
set "BACKUP_BUNDLE=C:\IBM_PM_Backups\pm_backup_YYYYMMDD_HHMMSS.tar.gz"
```

Run as Administrator if you want the script to update Windows hosts automatically.

The restore script asks for the PostgreSQL `processmining` DB plain password at runtime. Do not hard-code it in the BAT file.

It will:

1. upload the backup bundle to the new VM,
2. upload `linux/pm_restore_remote.sh`,
3. install PostgreSQL 15, Python 3.12, and NGINX,
4. restore `/opt/processmining`, `/etc/nginx`, certs, and PostgreSQL dump,
5. update `/etc/hosts`,
6. generate and write the encrypted DB password into PM config,
7. apply SELinux settings,
8. start PM services,
9. verify `https://pm.processmining`.

Expected success result:

```text
HTTP/1.1 302 Found
Location: /signin
```

## Fixed hostname strategy

Use fixed local hostnames:

```text
pm.processmining
tm.processmining
```

When a new TechZone VM is created, only update the IP mapping:

```text
<NEW_PUBLIC_IP> pm.processmining tm.processmining <NEW_HOSTNAME>
```

This keeps the certificate reusable as long as the certificate SAN contains `pm.processmining` and `tm.processmining`.

## Common problems

### 503 Service Unavailable

Usually means NGINX is reachable but the PM backend is not ready.

Check:

```bash
sudo systemctl status postgresql-15
curl -I http://127.0.0.1:8080
curl -k -I https://pm.processmining
```

### Python 3.12 missing

BRM and Accelerators require Python 3.12.

Install:

```bash
sudo yum install -y python3.12
```

### PostgreSQL service missing

Install:

```bash
sudo rpm --import https://download.postgresql.org/pub/repos/yum/keys/PGDG-RPM-GPG-KEY-RHEL
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum -qy module disable postgresql
sudo yum install -y postgresql15-server
sudo postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15
```

### Windows hosts not updated

Edit as Administrator:

```text
C:\Windows\System32\drivers\etc\hosts
```

Add or replace:

```text
<NEW_PUBLIC_IP> pm.processmining tm.processmining <NEW_HOSTNAME>
```

### Proxy issue

If Windows uses a proxy, bypass these entries:

```text
pm.processmining;tm.processmining;<NEW_PUBLIC_IP>;<NEW_HOSTNAME>
```

## Security notes

Do not commit these files to GitHub:

```text
pm_backup_*.tar.gz
postgres_*.dump
server.key
server.pem
rootCA.key
*.pem private keys
TechZone passwords
SSH private keys
```

Generated backup bundles may contain certificates, private keys, database contents, users, project metadata, and application configuration.
