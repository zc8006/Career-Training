# 06. Installation, Administration and Troubleshooting

> 这部分偏系统安装和管理员内容。内部认证如果更偏产品使用，可以先快速浏览；如果认证包含平台部署、权限、日志、Task Mining Agent，则需要认真看。

## 1. 部署方式

IBM Process Mining 可以部署在：

- Red Hat OpenShift Container Platform environment
- Linux non-containerized environment
- Trial environment

## 2. Trial

IBM Process Mining 提供 30 天的 as-a-Service trial。

特点：

- 预配置环境
- 有效期 30 天
- 可创建一个 process
- 可上传最多 1 million events
- 可使用全部应用功能

## 3. Linux non-containerized installation

主要组件：

- IBM Process Mining server
- PostgreSQL
- MonetDB
- NGINX
- Optional Task Mining

基础要求示例：

| 资源 | 要求 |
|---|---|
| CPU cores | >= 16 |
| RAM | >= 64 GB |
| Storage | >= 300 GB |
| DBMS | PostgreSQL 15 or 16, MonetDB 11.53.9 |
| OS | Red Hat Linux 8/9 or Ubuntu 22/24 |
| Python | 3.12 |

## 4. OpenShift installation

OpenShift 环境涉及：

- IBM Process Mining Operator
- IBM Cloud Pak foundational services
- PostgreSQL 15 or 16
- Optional Db2
- IBM Redis Operator
- Persistent storage with RWX mode
- SSL certificates

生产环境建议使用 CA 签发的 SSL 证书。

## 5. Ports and protocols

常见端口：

| From | To | Port | Function |
|---|---|---|---|
| IBM Process Mining Web Client | REST server | 443 HTTPS | User interface |
| IBM Process Mining REST API client | REST server | 443 HTTPS | API calls |
| IBM Task Mining Windows Client | Task Miner server | 443 HTTPS | Recording user behavior |
| Task Mining server | External PostgreSQL | 5432 TCP | Optional external DB |
| Task Mining server | External DB2 | 50000 TCP | Optional external DB |

## 6. Logging

IBM Process Mining application logs 常见路径：

```text
<PM_HOME>/repository/logs/pm-app-web.log
<PM_HOME>/repository/logs/pm-app-analytics.log
<PM_HOME>/repository/logs/pm-engine-process-discovery.log
<PM_HOME>/repository/logs/pm-engine-analytics.log
<PM_HOME>/repository/logs/pm-engine-monitoring.log
```

Web server logs：

```text
/var/log/nginx/access.log
/var/log/nginx/error.log
```

日志级别：

- ERROR
- WARN
- INFO
- DEBUG

生产环境一般不要随意把 log level 设置到 INFO 以下，除非排查问题需要。

## 7. User, group and organization

IBM Process Mining 里有：

- Users
- Groups
- Authorizations
- Organizations
- Tenants

Organization 是一组在同一 tenant 下共同处理项目的用户。要共享 project，用户需要加入对应 organization。

Tenant 是具有共同访问权限的软件实例用户组。

## 8. Permissions

常见权限范围：

- Analytics read
- Business repository read
- IBM Process Mining read
- Monitor and Action read
- Taskminer read/write/create
- RPA Script read/write

如果用户看不到某个模块，优先检查：

- 是否在正确 organization
- 是否有对应 project 权限
- 是否有 Analytics / Monitor / Taskminer 权限
- 是否在正确 tenant

## 9. Task Mining Agent

Task Mining Agent 安装在 Windows 客户端。

要求：

- Windows 10 or later 64-bit
- Microsoft Edge WebView2
- .NET Desktop Runtime
- Browser plugin for Chrome or Edge

它可以记录：

- Clicks
- Selections
- Keystrokes
- Web application interactions
- Application usage

## 10. 常见已知问题记忆

IBM Process Mining 2.0.3 文档列出了一些已知问题，例如：

- Legacy project migration 不允许 event log column name 中包含 full stop `.`
- CSV header 不要使用 reserved SQL keywords，例如 `select`、`count`、`from`
- FILTERED_EVENTS 在 multi-level processes 中可能计算不正确
- Monitor 可能长期 Running，需要复制 monitor、删除原 monitor、运行 duplicate
- Task Mining event log 只包含一个 task 时，RPA Candidates 可能无法计算 productive time
- Median toggle 在 NextGen projects 中不可用，需要用 Analytics 计算 median

## 11. Troubleshooting 思路

遇到问题按这个顺序查：

1. 用户权限是否正确
2. Data source / event log 是否正确
3. Mapping 是否正确
4. Timestamp 是否正确
5. Object table join 是否正确
6. Monitor 是否卡住
7. Logs 是否有 ERROR / WARN
8. OpenShift pods 是否健康
9. NGINX / SSL / port 是否正确
10. Task Mining Agent endpoint 是否可信

## 12. 考试易错点

| 问题 | 正确理解 |
|---|---|
| IBM Process Mining 只能 SaaS 吗？ | 不是，也支持 OpenShift 和 Linux non-containerized |
| Task Mining Agent 装在哪里？ | Windows 客户端 |
| 用户看不到模块只可能是安装问题吗？ | 不一定，可能是权限/organization/tenant 问题 |
| Monitor 卡住怎么办？ | 可 duplicate monitor，删除原 monitor，再运行 duplicate |
| CSV header 能随便命名吗？ | 不建议使用 `.` 或 SQL reserved keywords |

## 13. 一句话背诵

Administration and troubleshooting in IBM Process Mining focus on deployment, user permissions, organizations, tenants, logs, monitors, and Task Mining Agent configuration.

中文：IBM Process Mining 的管理和排错重点包括部署、用户权限、组织、租户、日志、监控器和 Task Mining Agent 配置。
