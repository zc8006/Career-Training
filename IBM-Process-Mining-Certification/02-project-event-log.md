# 02. Project, data source and event log

## 1. 创建 Project 的核心思路

IBM Process Mining project 的核心不是先做页面，而是先准备可分析的数据。

一般步骤：

1. Create Process Mining project
2. Add data source
3. Upload or connect data
4. Map event log fields
5. Add object tables if needed
6. Clean data
7. Visualize / Mine the process
8. Analyze process model and dashboard

## 2. Data source

Data source 是项目的数据入口。

可能的数据来源：

- CSV / Excel 文件
- Cloud storage
- Enterprise applications
- Process Apps
- APIs / integrations

内部认证一般会问：为什么需要 Data source？

答案：Data source provides the raw business and process data required to create the event log and process model.

## 3. Event log 映射

事件日志字段需要映射到 IBM Process Mining 能理解的结构。

| Event log 字段 | 作用 | 示例 |
|---|---|---|
| Case ID | 标识同一个流程实例 | WO1001 |
| Activity | 该实例发生的活动 | Create Work Order |
| Timestamp | 活动发生时间 | 2026-06-17 09:00 |
| Resource | 谁执行 | Technician / Planner |
| Cost | 活动成本 | 120 |
| Working time | 活动工作时间 | 2h |
| Role | 执行角色 | Maintenance Team |

前三个最重要：Case ID、Activity、Timestamp。

## 4. Object tables

Object tables 用于给 event log 增加上下文信息。

例子：

Event log 只有工单流程事件。

Object table 可以包含：

- Asset information
- Location
- Priority
- Work type
- Department
- Vendor
- Failure class

这些字段可以用于过滤、分组、根因分析。

## 5. Table joins

如果 object table 要参与流程分析，需要和 event log 建立 join 关系。

常见关系：

- Event log.WorkOrderID → WorkOrder.WorkOrderID
- WorkOrder.AssetID → Asset.AssetID
- WorkOrder.LocationID → Location.LocationID

注意：如果 object table 没有和 event log join，通常不能用于 Process、Action Hub、Prescriptive、What-if 的过滤，只能在 Analytics 的数据过滤中有限使用。

## 6. Data cleansing

Data cleansing 用于清理旧数据、不准确数据、异常活动或不希望分析的内容。

常见清理对象：

- 重复事件
- 错误时间戳
- 空 Case ID
- 空 Activity
- 无意义活动
- 测试数据
- 旧历史数据

认证记忆：

> Poor data quality leads to poor process analysis.

## 7. Maximo 工单 event log 示例

```csv
WORK_ORDER_ID,ACTIVITY,TIMESTAMP,RESOURCE,PRIORITY,ASSET_ID,STATUS
WO1001,Create Work Order,2026-06-01 09:00,Planner A,High,A100,WAPPR
WO1001,Approve Work Order,2026-06-01 10:30,Supervisor B,High,A100,APPR
WO1001,Start Work,2026-06-02 08:00,Technician C,High,A100,INPRG
WO1001,Complete Work,2026-06-02 15:00,Technician C,High,A100,COMP
WO1001,Close Work Order,2026-06-03 09:00,Planner A,High,A100,CLOSE
```

## 8. 考试易错点

| 问题 | 正确理解 |
|---|---|
| Event log 只需要 Activity 吗？ | 不对，至少需要 Case ID、Activity、Timestamp |
| Object table 有什么用？ | 提供额外属性，用于过滤和根因分析 |
| Data cleansing 是可选的吗？ | 技术上可选，但实际分析前非常重要 |
| Timestamp 为什么重要？ | 决定流程顺序和耗时计算 |

## 9. 一句话总结

A Process Mining project starts from clean event logs. The event log defines the process behavior, while object tables provide business context for deeper analysis.
