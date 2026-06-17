# 01. Overview

## 1. IBM Process Mining 是什么

IBM Process Mining 是一个流程挖掘解决方案，用来自动发现、监控、分析和优化业务流程。

它通过企业系统中的业务数据和事件日志，创建并可视化端到端流程，帮助企业发现低效、瓶颈、偏差、成本和自动化机会。

## 2. Process Mining 的核心价值

Process Mining 的价值不是单纯画流程图，而是回答这些问题：

- 实际流程是不是和我们以为的一样？
- 哪些流程路径最常见？
- 哪些活动最慢？
- 哪里有等待、返工和异常？
- 哪些案例不符合标准流程？
- 哪些活动适合自动化？
- 改进后可能节省多少时间和成本？

## 3. IBM Process Mining 可以提供的洞察

官方文档中列出的流程挖掘洞察包括：

- Process models and statistics
- Model comparison
- Conformance check with a reference model
- Process deviations
- Cost and time estimation
- Process delays and inefficiencies
- Resource mapping
- Task analysis

## 4. IBM Process Mining 常见应用场景

官方文档提到的典型服务/场景包括：

- Insurance claims tasks
- Data collection and reporting
- Regulations and compliance
- Vehicle checks and reporting
- Medical claims tasks
- Order management
- Procure to pay
- Order to cash
- Intelligent automation

结合 IBM / Maximo，可以扩展为：

- Work Order Management
- Asset Maintenance
- Incident Management
- Service Request Processing
- Field Service Operations

## 5. IBM Process Mining 的能力范围

IBM Process Mining 可以帮助用户：

- Identifying the process flow in enterprise applications
- Tracking desktop interactions
- Mapping extracted data to create process models
- Discovering, visualizing, and monitoring processes
- Comparing process models with simulations of automated process models
- Identifying automation candidates
- Estimating cost and performance impact
- Demonstrating automation impact before implementation

## 6. IBM Process Mining 和 IBM Task Mining

IBM Task Mining 是 IBM Process Mining 的重要组成部分。

### Process Mining

关注系统日志中的业务流程。

数据来源：

- ERP
- CRM
- Maximo
- Ticketing system
- Workflow system
- Database logs

输出：

- Process model
- Variants
- KPI
- Bottleneck
- Conformance
- Automation opportunity

### Task Mining

关注用户桌面操作。

数据来源：

- Clicks
- Selections
- Keystrokes
- Application switching
- Screen activity

输出：

- Productivity
- Working patterns
- Manual activity inefficiencies
- Rework
- Context switches
- RPA candidates

## 7. Process Mining vs Task Mining

| 对比 | Process Mining | Task Mining |
|---|---|---|
| 层级 | 端到端业务流程 | 用户任务/桌面操作 |
| 数据 | 事件日志 | 用户交互数据 |
| 目标 | 找流程瓶颈和偏差 | 找人工操作低效和自动化点 |
| 输出 | 流程图、变体、KPI、合规分析 | 操作模式、生产时间、RPA 脚本候选 |

## 8. 一句话背诵

IBM Process Mining uses event logs from enterprise systems to discover, visualize, monitor, analyze and improve real business processes.

中文：IBM Process Mining 使用企业系统中的事件日志，发现、可视化、监控、分析并优化真实业务流程。

## 9. Maximo 工单场景表达

For a Maximo work order process, IBM Process Mining can use Work Order ID as the case ID, status changes as activities, and status change time as timestamps. Then it can discover the actual work order flow, identify bottlenecks, check conformance, monitor SLA breaches, and find automation opportunities.

中文：对于 Maximo 工单流程，可以用工单号作为 Case ID，用状态变化作为 Activity，用状态变更时间作为 Timestamp。然后用 IBM Process Mining 还原真实工单流程，识别瓶颈，检查合规性，监控 SLA 超时，并发现自动化机会。
