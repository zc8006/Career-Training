# 07. VM Installation Runbook for IBM Process Mining

> Source: `搭建手顺_Ver1.0.xlsx`  
> 注意：本文是从 Excel 手顺整理出的脱敏版 Markdown。不要把真实 Public IP、主机名、SSH key、密码、证书私钥提交到公开仓库。

## 0. 整体流程

```text
申请虚拟机
-> 获取 SSH key / Public IP / Hostname
-> 上传 IBM Process Mining 安装包
-> 解压安装包
-> 安装并初始化 PostgreSQL
-> 配置 Process Mining 数据库连接
-> 部署 Python
-> 安装和配置 NGINX
-> 创建 SSL 自签证书
-> 禁用数据衍生 End Activity
-> 生成 Process App 公私钥
-> 修改本机和服务器 hosts
-> 启动 Process Mining 服务
-> 浏览器登录
```

## 1. 申请虚拟机

通过 IBM TechZone reservation link 申请虚拟机。

操作要点：

1. 打开 TechZone reservation link。
2. 选择区域，推荐优先选择东京。
3. 若东京没有资源，可选择日本或其他可用区域。
4. 提交申请后等待 provision 完成。
5. 收到创建成功邮件后，进入虚拟机详情页。
6. 下载 SSH key。
7. 记录 Public IP 和 Hostname。
8. 必要时延长虚拟机使用期限。

敏感信息不要提交到 GitHub：

```text
<PUBLIC_IP>
<HOSTNAME>
<SSH_KEY_FILE>
<VM_PASSWORD>
```

## 2. 准备 SSH key

Windows 本地需要确认 SSH key 权限。

示例命令：

```powershell
icacls C:\path\to\key.pem /inheritance:r
icacls C:\path\to\key.pem /remove "BUILTIN\Users"
icacls C:\path\to\key.pem /remove "NT AUTHORITY\Authenticated Users"
icacls C:\path\to\key.pem /grant "%USERNAME%:R"
```

连接虚拟机：

```bash
ssh <VM_USER>@<PUBLIC_IP> -i <SSH_KEY_FILE>
```

或指定端口：

```bash
ssh <VM_USER>@<PUBLIC_IP> -p <SSH_PORT> -i <SSH_KEY_FILE>
```

## 3. 上传 IBM Process Mining 安装包

从本地上传安装包到服务器。

示例：

```bash
scp -P <SSH_PORT> -i <SSH_KEY_FILE> <LOCAL_PM_PACKAGE>.tgz <VM_USER>@<PUBLIC_IP>:/home/<VM_USER>/
```

注意：

- `<SSH_PORT>` 按实际虚拟机信息填写。
- `<PUBLIC_IP>` 按 TechZone 页面显示填写。
- `<LOCAL_PM_PACKAGE>` 是本地安装包路径。

## 4. 解压安装包

登录服务器后，切换到目标目录并解压。

```bash
cd /opt
sudo tar xvf /home/<VM_USER>/<PM_PACKAGE>.tgz -C /opt/
```

如果安装包中包含 setup 和 update 包，需要分别解压。

示例目录：

```text
/opt/processmining
```

修改目录权限：

```bash
sudo chown -R <VM_USER>:<VM_USER> /opt/processmining
```

## 5. 确认服务器配置文件

进入 Process Mining bin 目录：

```bash
cd /opt/processmining/bin
cat environment.conf
```

确认或修改：

```text
PM_HOME=/opt/processmining
TMPDIR=/opt/processmining/repository/temp
```

如果安装目录不是 `/opt/processmining`，需要同步修改配置中的路径。

## 6. 安装 PostgreSQL

使用 root 用户或 sudo 执行。

示例命令：

```bash
sudo rpm -ivh https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
sudo yum -qy module disable postgresql
sudo yum install -y postgresql15-server
sudo postgresql-15-setup initdb
sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15
```

检查状态：

```bash
sudo systemctl status postgresql-15
```

## 7. 创建 PostgreSQL 用户和数据库

定义环境变量：

```bash
export POSTGRES_PROCESSMINER_PWD="<DB_PASSWORD>"
export POSTGRES_PROCESSMINER_USER="processmining"
export POSTGRES_PROCESSMINER_DATABASE="processmining"
```

创建用户和数据库：

```bash
pushd /tmp
sudo -E -u postgres createuser ${POSTGRES_PROCESSMINER_USER}
sudo -E -u postgres createdb ${POSTGRES_PROCESSMINER_DATABASE}
sudo -E -u postgres psql -c "alter user ${POSTGRES_PROCESSMINER_USER} with encrypted password '${POSTGRES_PROCESSMINER_PWD}';"
sudo -E -u postgres psql -c "grant all privileges on database ${POSTGRES_PROCESSMINER_DATABASE} to ${POSTGRES_PROCESSMINER_USER};"
sudo -E -u postgres psql -c "GRANT ALL ON ALL TABLES IN SCHEMA public TO ${POSTGRES_PROCESSMINER_USER};"
sudo -E -u postgres psql -c "ALTER DATABASE ${POSTGRES_PROCESSMINER_DATABASE} OWNER TO ${POSTGRES_PROCESSMINER_USER};"
popd
```

## 8. 生成数据库加密密码

进入 crypto utils：

```bash
cd /opt/processmining/utils/crypto-utils
./crypt-utils.sh '<DB_PASSWORD>'
```

复制输出的加密密码，用于后续配置。

注意：

```text
不要把明文 DB password 或加密后的生产密码提交到 GitHub。
```

## 9. 配置 Process Mining 数据库连接

编辑：

```bash
vi /opt/processmining/etc/processmining.conf
```

配置示例：

```text
persistence: {
  jdbc: {
    database: "processmining",
    host: "127.0.0.1",
    port: 5432,
    user: "processmining",
    password: "<ENCRYPTED_DB_PASSWORD>"
  }
}
```

## 10. 配置 Process App 数据库连接

编辑：

```bash
vi /opt/processmining/etc/accelerator-core.properties
```

配置示例：

```properties
spring.datasource.database=processmining
spring.datasource.port=5432
spring.datasource.host=127.0.0.1
spring.datasource.username=processmining
spring.datasource.password=<ENCRYPTED_DB_PASSWORD>
```

## 11. 初始化数据库

执行：

```bash
export JAVA_HOME=/opt/processmining/jdk/linux/ibm-openjdk-semeru
cd /opt/processmining/utils/database-utils
./postgres-utils.sh
```

## 12. 部署 Python

Process App / Custom process app 需要 Python。

```bash
sudo yum install -y python3.12
```

如使用 Ubuntu，则一般为：

```bash
sudo apt install -y python3.12-venv
```

## 13. 安装和配置 NGINX

安装：

```bash
sudo yum install -y nginx
```

启动：

```bash
sudo systemctl enable nginx
sudo systemctl start nginx
```

修改 NGINX 目录权限：

```bash
sudo chown -R <VM_USER>:<VM_USER> /etc/nginx
```

复制 Process Mining NGINX 配置：

```bash
export PM_HOME=/opt/processmining
cp $PM_HOME/nginx/processmining.conf /etc/nginx/conf.d/default.conf
```

## 14. 创建 SSL 证书目录

```bash
mkdir /etc/nginx/ssl
export PM_HOME=/opt/processmining
mkdir $PM_HOME/cert
cd $PM_HOME/cert
```

## 15. 创建 CA 私钥

```bash
openssl genrsa -des3 -out rootCA.key 2048
```

输入 passphrase。测试环境可以使用简单密码，但生产环境必须安全管理。

## 16. 创建 CA 证书

```bash
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem
```

输入证书信息时按实际情况填写：

```text
Country Name: CN
State or Province Name: <STATE>
Locality Name: <CITY>
Organization Name: IBM
Organizational Unit Name: IBM
Common Name: <YOUR_NAME_OR_HOSTNAME>
```

## 17. 创建 v3.ext

```bash
cat > v3.ext <<'EOF'
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = pm.processmining
DNS.2 = tm.processmining
DNS.3 = <HOSTNAME>
EOF
```

## 18. 创建 NGINX server key 和 CSR

```bash
openssl req -new -nodes -out server.csr -newkey rsa:2048 -keyout server.key
```

## 19. 签发 server 证书

```bash
openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext
```

合并证书：

```bash
cat server.crt server.key > server.pem
```

复制证书到 NGINX：

```bash
cp server.crt server.pem server.key /etc/nginx/ssl/
```

## 20. 修改 NGINX default.conf

编辑：

```bash
vi /etc/nginx/conf.d/default.conf
```

将证书配置替换为：

```nginx
ssl_certificate /etc/nginx/ssl/server.pem;
ssl_certificate_key /etc/nginx/ssl/server.key;
```

## 21. SELinux 设置

如果遇到权限相关问题，执行：

```bash
sudo chcon -t httpd_config_t /etc/nginx/ssl/*.*
sudo setsebool -P httpd_can_network_connect 1
```

## 22. 重启 NGINX

```bash
sudo systemctl enable nginx
sudo systemctl restart nginx
```

检查：

```bash
sudo systemctl status nginx
```

## 23. 禁用数据衍生 End Activity

编辑：

```bash
vi $PM_HOME/etc/processmining.conf
```

在 defaults 中加入：

```text
endActivity: {
  enable: false
},
```

用途：防止系统根据数据自动推导结束活动，便于手动控制结束活动逻辑。

## 24. 为 Process App 创建公私钥

执行：

```bash
$PM_HOME/utils/generateKeyPair.sh
```

## 25. 修改本机 hosts 文件

Windows 本机路径：

```text
C:\Windows\System32\drivers\etc\hosts
```

添加：

```text
<PUBLIC_IP> pm.processmining tm.processmining <HOSTNAME>
```

## 26. 修改服务器 hosts 文件

```bash
sudo vi /etc/hosts
```

添加：

```text
<PUBLIC_IP> pm.processmining tm.processmining <HOSTNAME>
```

## 27. 启动 IBM Process Mining 服务

按顺序执行：

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

## 28. 登录页面

浏览器访问：

```text
https://pm.processmining/signin
```

默认管理员：

```text
Username: maintenance.admin
Password: <INITIAL_ADMIN_PASSWORD>
```

首次登录后必须修改默认密码。

## 29. 安装完成检查清单

| 检查项 | 期望结果 |
|---|---|
| VM 可 SSH | 可以登录 |
| PostgreSQL 状态 | running |
| processmining 数据库 | 已创建 |
| processmining 用户 | 已授权 |
| processmining.conf | DB 连接配置正确 |
| accelerator-core.properties | Process App DB 配置正确 |
| postgres-utils.sh | 执行成功 |
| NGINX | running |
| SSL 证书 | 浏览器可访问，测试环境可接受自签证书 |
| hosts | 本机和服务器均配置 |
| PM 服务 | monet/web/engine/analytics/accelerators/brm/monitoring 均已启动 |
| 登录页 | 可打开 |

## 30. 常见问题

### 1. SSH 连接失败

检查：

- Public IP 是否正确
- SSH port 是否正确
- key 权限是否过宽
- 用户名是否正确
- VM 是否启动完成

### 2. PostgreSQL 连接失败

检查：

- PostgreSQL 服务是否启动
- DB/user/password 是否正确
- password 是否已加密配置
- processmining.conf 是否路径正确

### 3. NGINX 启动失败

检查：

```bash
nginx -T
sudo journalctl -u nginx
```

重点看：

- 证书路径是否正确
- default.conf 是否语法错误
- 443 是否被占用
- SELinux 是否阻止访问

### 4. 登录页打不开

检查：

- 本机 hosts 是否配置
- 服务器 hosts 是否配置
- NGINX 是否 running
- pm-web 是否 running
- 防火墙是否放行 443

### 5. Monitor / Analytics / Engine 异常

检查日志：

```text
$PM_HOME/repository/logs/pm-app-web.log
$PM_HOME/repository/logs/pm-engine-process-discovery.log
$PM_HOME/repository/logs/pm-engine-analytics.log
$PM_HOME/repository/logs/pm-engine-monitoring.log
```

## 31. 安全提醒

不要提交到 GitHub：

- Public IP
- Hostname
- SSH private key
- VM password
- DB password
- encrypted DB password
- rootCA.key
- server.key
- server.pem
- 真实客户数据

可以提交：

- 脱敏命令模板
- 安装步骤
- 检查清单
- 排错方法
- 占位符配置样例
