# IBM Process Mining 内部认证学习库

这个目录用于准备 IBM Process Mining 内部认证。内容基于 IBM Process Mining 2.0.3 documentation，并结合流程挖掘通用知识与 Maximo 工单 demo 场景整理。

## 学习目标

学完后要能回答三个问题：

1. IBM Process Mining 是什么，解决什么业务问题。
2. 一个 Process Mining project 如何从 event log 建起来。
3. 如何用 Process model、Analytics、Conformance、Action Hub、Prescriptive、Simulation、RPA Candidates 和 Task Mining 做流程改进。

## 推荐学习顺序

1. [Core concepts](01-core-concepts.md)
2. [Project, data source and event log](02-project-event-log.md)
3. [KPI, custom metrics and analytics](03-kpi-analytics.md)
4. [Process model, variants, conformance and filters](04-conformance-variants-filters.md)
5. [Action Hub, Prescriptive, Simulation, RPA and Task Mining](05-action-hub-prescriptive-rpa-task-mining.md)
6. [Internal certification cheat sheet](06-internal-cert-cheatsheet.md)
7. [Practice questions](07-practice-questions.md)
8. [Maximo Work Order demo story](demo-maximo-work-order/README.md)

## 一句话记忆

IBM Process Mining uses event logs from enterprise systems to discover, visualize, monitor, analyze, and improve real business processes.

中文：IBM Process Mining 使用企业系统中的事件日志，还原真实业务流程，发现瓶颈、偏差、耗时、成本和自动化机会。

## 最小数据要求

一个最基础的 event log 至少需要：

| 字段 | 含义 | Maximo 工单例子 |
|---|---|---|
| Case ID | 一个流程实例 | Work Order ID |
| Activity | 发生的动作 | Create / Approve / Start / Complete / Close |
| Timestamp | 动作发生时间 | Status Change Time |

## 认证备考重点

- Process Mining 基础概念
- IBM Process Mining project 创建
- Data source / Event log / Object tables
- Data cleansing
- KPIs / Custom metrics / KPI benchmark
- Process model / Process variants
- Model conformance / Reference model
- Analytics widgets and filters
- Action Hub and monitors
- Prescriptive reports
- Simulation and What-if
- RPA Candidates
- IBM Task Mining

## 适合面试/会议的说法

I can start from an event log, define the case ID, activities and timestamps, then use IBM Process Mining to discover the actual process, identify bottlenecks and deviations, and propose automation opportunities.

中文：我可以从事件日志入手，定义 Case ID、Activity 和 Timestamp，然后用 IBM Process Mining 还原真实流程，识别瓶颈、偏差和自动化机会。
