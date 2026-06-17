# 01. Core concepts

## 1. IBM Process Mining 是什么

IBM Process Mining 是一个流程挖掘解决方案，用来自动发现、监控、分析和优化业务流程。

它通过企业系统里的业务数据和事件日志，创建并可视化端到端流程，让用户看到真实流程是怎么运行的。

## 2. Process Mining 是什么

Process mining 是用企业应用系统记录下来的 process、case、event 数据，通过专门的数据挖掘算法分析流程。

它能提供这些洞察：

- Process models and statistics
- Model comparison
- Conformance check with a reference model
- Process deviations
- Cost and time estimation
- Process delays and inefficiencies
- Resource mapping
- Task analysis

## 3. 事件日志 Event log

Event log 是流程挖掘的核心输入。

最基础的事件日志包括：

| 字段 | 英文 | 说明 |
|---|---|---|
| 案例 | Case ID | 一个流程实例，例如一个工单、一个订单、一个申请 |
| 活动 | Activity | 这个案例经历过的动作或步骤 |
| 时间 | Timestamp | 活动发生的时间 |

一句话：

> No event log, no process mining.

## 4. Process Mining 和 Process Modeling 的关系

Process Modeling 通常描述理想流程，例如 BPMN 流程图。

Process Mining 分析真实流程，并可以和 reference model 对比，判断流程是否符合预期。

考试记忆：

- Process Modeling = expected / designed process
- Process Mining = actual / discovered process
- Conformance = compare actual process with reference model

## 5. IBM Process Mining 能发现什么

- 实际流程路径
- 高频变体
- 瓶颈活动
- 等待时间
- 返工和循环
- 不合规路径
- 资源使用情况
- 成本和耗时
- 自动化候选点

## 6. IBM Process Mining 和 Task Mining

Process Mining 看系统事件日志，偏业务流程。

Task Mining 看用户桌面操作，偏人工操作细节。

| 类型 | 关注点 | 数据来源 |
|---|---|---|
| Process Mining | 端到端业务流程 | ERP、CRM、Maximo、工单系统等日志 |
| Task Mining | 用户桌面操作 | 点击、选择、键盘、应用切换等 |

## 7. IBM Process Mining 常见业务场景

- Procure to Pay
- Order to Cash
- Insurance claims
- Medical claims
- Compliance and regulations
- Vehicle checks and reporting
- Data collection and reporting
- Intelligent automation
- Maximo Work Order Management

## 8. 认证重点句

IBM Process Mining discovers and monitors event logs and activities from enterprise systems to generate insights that help optimize business processes.

中文：IBM Process Mining 发现并监控企业系统中的事件日志和活动，生成洞察以优化业务流程。
