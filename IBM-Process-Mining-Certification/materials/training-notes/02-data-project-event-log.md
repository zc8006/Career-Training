# 02. Project, Data Source and Event Log

## 1. Project 是什么

IBM Process Mining 的 Project 是一个流程分析项目。一个 Project 通常围绕一个业务流程建立，例如：

- Purchase-to-Pay
- Order-to-Cash
- Claims processing
- Ticketing process
- Maximo Work Order process

Project 里包含：

- Data source
- Event log
- Object tables
- Attributes
- KPIs
- Cost settings
- Business calendar
- Reference model
- Analytics
- Monitors

## 2. 创建 Project 的基本思路

```text
Create project
-> Add data source
-> Configure event log
-> Add object tables
-> Clean data
-> Map attributes / KPIs / costs
-> Visualize process
-> Analyze and monitor
```

中文：

```text
创建项目
-> 添加数据源
-> 配置事件日志
-> 添加对象表
-> 清洗数据
-> 配置属性/KPI/成本
-> 生成流程图
-> 分析和监控
```

## 3. Data source

Data source 是 IBM Process Mining 获取数据的入口。

常见来源：

- Uploaded files
- CSV files
- Cloud storage
- Data stream
- Process Apps
- Enterprise tools
- APIs

IBM Process Mining 2.0.3 支持一次上传多个 CSV 文件，这对快速 demo 很有用。

## 4. Event log 是核心

Event log 是流程挖掘最核心的数据结构。

一个 event log 通常包含：

| 信息 | 含义 | 例子 |
|---|---|---|
| What | 发生了什么活动 | Approve Work Order |
| When | 什么时候发生 | 2026-06-17 09:30 |
| Who | 谁执行 | Supervisor A |
| Case | 属于哪个流程实例 | WO1001 |

## 5. 最小字段

最小可用 event log 至少需要：

| 字段 | 英文 | 作用 |
|---|---|---|
| 案例 ID | Case ID | 区分一个流程实例 |
| 活动 | Activity | 表示流程步骤 |
| 时间戳 | Timestamp | 表示活动发生时间和顺序 |

## 6. Maximo 工单 event log 例子

```csv
WORK_ORDER_ID,ACTIVITY,TIMESTAMP,RESOURCE,PRIORITY,STATUS,ASSET_ID
WO1001,Create Work Order,2026-06-01 09:00,Planner A,High,WAPPR,A100
WO1001,Approve Work Order,2026-06-01 10:00,Supervisor B,High,APPR,A100
WO1001,Start Work,2026-06-02 08:00,Technician C,High,INPRG,A100
WO1001,Complete Work,2026-06-02 15:00,Technician C,High,COMP,A100
WO1001,Close Work Order,2026-06-03 09:00,Planner A,High,CLOSE,A100
```

映射：

| IBM Process Mining 字段 | Maximo 字段 |
|---|---|
| Case ID | WORK_ORDER_ID |
| Activity | ACTIVITY / STATUS_CHANGE |
| Timestamp | STATUS_CHANGE_TIME |
| Resource | RESOURCE / OWNER / CHANGED_BY |
| Cost | LABOR_COST / MATERIAL_COST |
| Attribute | PRIORITY / ASSET_ID / LOCATION / WORK_TYPE |

## 7. Object tables

Object table 是给流程提供上下文的表。

Event log 记录“发生了什么”。

Object table 说明“这个对象是什么”。

Maximo 例子：

| Object table | 说明 |
|---|---|
| Work Orders | 工单主数据 |
| Assets | 资产主数据 |
| Locations | 地点主数据 |
| Technicians | 维修人员信息 |
| Spare Parts | 备件信息 |

## 8. Table joins

Object table 需要和 event log 建立关系。

例子：

```text
EventLog.WORK_ORDER_ID -> WorkOrders.WORK_ORDER_ID
WorkOrders.ASSET_ID -> Assets.ASSET_ID
WorkOrders.LOCATION_ID -> Locations.LOCATION_ID
```

如果关系不正确，会影响：

- 属性分析
- 筛选
- 根因分析
- KPI 计算
- Dashboard 结果

## 9. Data cleansing

Data cleansing 用来清理旧数据、不准确数据和不希望参与分析的数据。

常见清理内容：

- 空 Case ID
- 空 Activity
- 空 Timestamp
- 重复事件
- 错误时间顺序
- 测试数据
- 过期历史数据
- 不相关活动

IBM Process Mining 2.0.3 中 Data Cleansing 是一个重要可用性改进，用于清理旧的和不准确的数据。

## 10. Data quality

数据质量决定分析质量。

重点检查：

- Case ID 是否唯一标识流程实例
- Activity 命名是否清晰一致
- Timestamp 是否完整且格式正确
- 同一 case 内活动顺序是否合理
- 是否存在重复事件
- 是否有大量缺失值
- Object table join 是否正确

## 11. 考试易错点

| 问题 | 正确理解 |
|---|---|
| Event log 是什么？ | 记录流程事件的表 |
| Event log 最少需要什么？ | Case ID、Activity、Timestamp |
| Object table 是 event log 吗？ | 不是，它是上下文/主数据表 |
| Data cleansing 只是美化数据吗？ | 不是，它直接影响流程模型和 KPI 质量 |
| Timestamp 为什么重要？ | 用于决定活动顺序和计算时间指标 |

## 12. 一句话背诵

A clean event log with case ID, activity and timestamp is the foundation of every Process Mining project.

中文：包含 Case ID、Activity 和 Timestamp 的干净事件日志，是每个流程挖掘项目的基础。
