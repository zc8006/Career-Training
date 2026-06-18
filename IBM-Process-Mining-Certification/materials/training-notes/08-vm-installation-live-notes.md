# 08. IBM Process Mining VM Installation Live Notes

> Purpose: notes captured from a real IBM Process Mining 2.0.3 VM installation run.  
> This file is intentionally sanitized. Do not commit real Public IP, hostname, SSH key, DB password, encrypted password, certificate private keys, or customer data.

## 1. Environment used in the live run

Use placeholders in documentation and GitHub:

```text
<VM_USER>
<PUBLIC_IP>
<SSH_PORT>
<HOSTNAME>
<SSH_KEY_FILE>
<DB_PASSWORD>
<ENCRYPTED_DB_PASSWORD>
<INITIAL_ADMIN_PASSWORD>
```

Observed target layout:

```text
PM_HOME=/opt/processmining
PM_REPOSITORY=/opt/processmining/repository
NGINX SSL directory=/etc/nginx/ssl
Process Mining URL=https://pm.processmining/signin
Task Mining URL=https://tm.processmining
```

## 2. Windows SSH key permission issue

On Windows PowerShell, `%USERNAME%` is CMD syntax and can fail.

Use PowerShell syntax instead:

```powershell
icacls C:\path\to\key.pem /inheritance:r
icacls C:\path\to\key.pem /remove "BUILTIN\Users"
icacls C:\path\to\key.pem /remove "NT AUTHORITY\Authenticated Users"
icacls C:\path\to\key.pem /grant "$env:USERNAME`:R"
```

SSH example:

```powershell
ssh <VM_USER>@<PUBLIC_IP> -p <SSH_PORT> -i C:\path\to\key.pem
```

SCP upload example:

```powershell
scp -P <SSH_PORT> -i C:\path\to\key.pem C:\path\to\PM2.0.3-apms.tgz <VM_USER>@<PUBLIC_IP>:/home/<VM_USER>/
```

## 3. PostgreSQL setup success indicators

After installing PostgreSQL 15 and creating the `processmining` user/database, the successful output should include results like:

```text
ALTER ROLE
GRANT
GRANT
ALTER DATABASE
```

Database initialization success indicators:

```text
Start Flyway initialization...
database creation completed.
Database setup completed!
```

A warning such as the following was observed and was not blocking when the final setup completed:

```text
MonetDB connectionString not defined
```

## 4. DB password encryption and config files

Generate the encrypted password:

```bash
cd /opt/processmining/utils/crypto-utils
./crypt-utils.sh '<DB_PASSWORD>'
```

Use the encrypted value in both files:

```text
/opt/processmining/etc/processmining.conf
/opt/processmining/etc/accelerator-core.properties
```

Do not commit the encrypted password value to GitHub.

## 5. NGINX and SSL certificate notes

NGINX service success indicator:

```text
Active: active (running)
```

### Certificate file-name gotcha

In the live run, the generated server certificate was:

```text
server.crt
server.key
```

The NGINX config expected:

```nginx
ssl_certificate /etc/nginx/ssl/server.pem;
ssl_certificate_key /etc/nginx/ssl/server.key;
```

So make sure `server.pem` exists in `/etc/nginx/ssl`.

Two acceptable approaches:

```bash
# Option A: copy certificate as server.pem
cp /opt/processmining/cert/server.crt /etc/nginx/ssl/server.pem
cp /opt/processmining/cert/server.key /etc/nginx/ssl/server.key
```

or follow the original runbook style:

```bash
cat server.crt server.key > server.pem
cp server.crt server.pem server.key /etc/nginx/ssl/
```

The important point is that these two paths must exist and match `default.conf`:

```text
/etc/nginx/ssl/server.pem
/etc/nginx/ssl/server.key
```

### Root CA passphrase issue

If signing the server certificate fails with:

```text
bad decrypt
maybe wrong password
Could not find CA private key from rootCA.key
```

it usually means the passphrase for `rootCA.key` was entered incorrectly.

Re-run the signing command and enter the correct passphrase:

```bash
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext
```

If the passphrase is forgotten, recreate `rootCA.key` and `rootCA.pem`, then re-sign `server.csr`.

### SELinux settings

If NGINX has permission problems with the certificate files or upstream access:

```bash
sudo chcon -t httpd_config_t /etc/nginx/ssl/*.*
sudo setsebool -P httpd_can_network_connect 1
```

Then restart NGINX:

```bash
sudo systemctl enable nginx
sudo systemctl restart nginx
sudo systemctl status nginx
```

## 6. End Activity and Process App key pair

Disable End Activity auto-derivation in:

```bash
vi $PM_HOME/etc/processmining.conf
```

Expected block:

```text
endActivity: {
  enable: false
},
```

Generate Process App key pair:

```bash
$PM_HOME/utils/generateKeyPair.sh
```

Successful output should include files similar to:

```text
/opt/processmining/etc/acf-ext-keyPair.der
/opt/processmining/etc/acf-core-privateKey.der
/opt/processmining/etc/acf-ext-publicKey.der
```

The script reminds that these components need restart:

```text
bin/pm-web.sh
bin/pm-accelerators.sh
```

## 7. Hosts configuration

### Server-side `/etc/hosts`

```bash
sudo vi /etc/hosts
```

Add:

```text
<PUBLIC_IP> pm.processmining tm.processmining <HOSTNAME>
```

Verify:

```bash
cat /etc/hosts
hostname
```

Common typo:

```bash
cat vi /etc/hosts
```

This is wrong because it tries to read two files: `vi` and `/etc/hosts`. Use:

```bash
cat /etc/hosts
```

### Windows client hosts

Path:

```text
C:\Windows\System32\drivers\etc\hosts
```

Add the same mapping:

```text
<PUBLIC_IP> pm.processmining tm.processmining <HOSTNAME>
```

Open Notepad as Administrator before editing.

Other machines that need access must also add this hosts entry, unless a real DNS record is configured.

## 8. Proxy bypass on Windows / IBM network

If a corporate proxy is enabled, add these entries to the proxy bypass list:

```text
pm.processmining;tm.processmining;<PUBLIC_IP>;<HOSTNAME>
```

In Windows proxy settings, also enable:

```text
Do not use proxy server for local / intranet addresses
```

If using tools like Clash/V2Ray, create DIRECT rules for:

```text
pm.processmining
tm.processmining
<PUBLIC_IP>
```

## 9. Start services

Start in order:

```bash
cd $PM_HOME/bin/
./pm-monet.sh start
./pm-web.sh start
./pm-engine.sh start
./pm-analytics.sh start
./pm-accelerators.sh start
./pm-brm.sh start
./pm-monitoring.sh start
```

A successful run may print:

```text
started
OK
```

Check processes:

```bash
ps -ef | grep processmining
```

Expected components:

```text
MonetDB / mserver5
jetty-web / 8080
jetty-engine / 8070
jetty-analytics / 9070
accelerators / gunicorn / python3.12
brm-service / uvicorn / 8001
jetty-monitoring / 9080
PostgreSQL processmining connections
```

## 10. Connectivity verification

From the server:

```bash
curl -k -I https://pm.processmining
```

Expected result:

```text
HTTP/1.1 302 Found
Location: /signin
```

`302 Found` is good here. It means the root URL redirects to the login page.

From Windows PowerShell:

```powershell
Test-NetConnection pm.processmining -Port 443
```

Expected:

```text
TcpTestSucceeded : True
```

`ping pm.processmining` may timeout because ICMP can be blocked. Do not use ping as the final check. The 443 test is more important.

Optional Windows HTTP check:

```powershell
curl.exe -k -I https://pm.processmining
```

Expected:

```text
HTTP/1.1 302 Found
Location: /signin
```

## 11. Browser login

Open:

```text
https://pm.processmining/signin
```

If the browser warns about an unsafe certificate, continue for the test environment. For a cleaner setup, import `rootCA.pem` into the client machine trusted root certificate store.

Default administrator account should be taken from the internal installation runbook. Do not commit the initial password to GitHub.

```text
Username: maintenance.admin
Password: <INITIAL_ADMIN_PASSWORD>
```

Change the default password immediately after first login.

## 12. Access from another machine

For another machine to access the environment:

1. It must be able to reach `<PUBLIC_IP>:443`.
2. It must resolve `pm.processmining` to `<PUBLIC_IP>`.
3. Its proxy must bypass `pm.processmining`, `tm.processmining`, and `<PUBLIC_IP>`.
4. It may need to accept or trust the self-signed certificate.

Windows test:

```powershell
Test-NetConnection pm.processmining -Port 443
curl.exe -k -I https://pm.processmining
```

Mac/Linux test:

```bash
nc -vz pm.processmining 443
curl -k -I https://pm.processmining
```

## 13. Do not commit these files or values

Never commit:

```text
real Public IP
real Hostname
SSH private key
VM/root password
DB password
encrypted DB password
rootCA.key
server.key
server.pem
real customer Excel data
initial admin password
```

Safe to commit:

```text
sanitized runbook
placeholder commands
troubleshooting notes
verification checklist
sample hosts format with placeholders
```
