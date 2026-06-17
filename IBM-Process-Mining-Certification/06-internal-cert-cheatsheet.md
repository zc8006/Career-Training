# 06. Internal certification cheat sheet

## 1. 一句话定义

IBM Process Mining is a process mining solution that discovers, visualizes, monitors, analyzes and improves real business processes based on event logs from enterprise systems.

中文：IBM Process Mining 基于企业系统事件日志，发现、可视化、监控、分析并改进真实业务流程。

## 2. 三个基础字段

| 字段 | 作用 |
|---|---|
| Case ID | 标识一个流程实例 |
| Activity | 标识流程中的一个动作 |
| Timestamp | 标识动作发生时间 |

## 3. 主要模块

| 模块 | 作用 |
|---|---|
| Home page | 入口和项目概览 |
| Project | 流程挖掘项目 |
| Data & Settings | 数据、事件日志、对象表、KPI 等配置 |
| Process | 流程模型、变体、conformance |
| Analytics | Dashboard、widgets、filters、自定义分析 |
| Action Hub | Service、monitor、行动触发 |
| Prescriptive | 调查报告、根因、推荐行动 |
| What-if / Simulation | 模拟流程优化方案 |
| RPA Candidates | 识别自动化候选活动 |
| Task Mining | 用户桌面操作分析 |

## 4. 高频概念

| 概念 | 解释 |
|---|---|
| Event log | 流程挖掘的核心输入 |
| Process model | 从日志发现的真实流程模型 |
| Variant | 实际案例走过的路径组合 |
| Reference model | 标准流程或期望流程 |
| Conformance | 真实流程与标准流程的符合度 |
| KPI | 衡量流程表现的指标 |
| Custom metric | 自定义指标 |
| Benchmark | KPI 目标或阈值 |
| Monitor | 持续监控流程条件 |
| Simulation | 模拟改进方案影响 |
| RPA candidate | 适合自动化的任务候选 |

## 5. Process Mining 可以看到什么

- 流程实际怎么走
- 哪些路径最常见
- 哪些活动最慢
- 哪些步骤成本最高
- 哪些案例不符合标准
- 哪些地方有返工
- 哪些部门或资源造成瓶颈
- 哪些任务适合自动化

## 6. Conformance 记忆

```text
Actual process + Reference model = Conformance check
```

用于识别：

- 符合标准的案例
- 不符合标准的案例
- 多余活动
- 缺失活动
- 顺序错误

## 7. Analytics 记忆

Analytics = dashboard + widgets + filters + metrics.

用于回答业务问题：

- 多少案例超时？
- 哪个团队最慢？
- 哪类资产成本最高？
- 哪些活动最容易返工？

## 8. Action Hub 记忆

Action Hub = monitor + alert + action.

例子：

```text
If SLA breach rate > 10%, notify process owner.
```

## 9. Prescriptive 记忆

Prescriptive = investigate + root cause + recommended action + benefits.

它不是简单看图，而是帮助你调查问题和决定行动。

## 10. Task Mining 记忆

Task Mining = desktop activity analytics.

它分析用户桌面操作，例如点击、选择、应用切换、人工操作耗时。

## 11. Process Mining 和 Task Mining 区别

Process Mining 回答：业务流程实际怎么走？

Task Mining 回答：人在电脑上具体怎么操作？

## 12. Maximo 工单一句话 demo

We can use IBM Process Mining to analyze Maximo work orders by using Work Order ID as the case ID, work order status changes as activities, and status change time as timestamps. Then we can discover bottlenecks, rework, SLA breaches and automation opportunities.

## 13. 考前 10 句背诵

1. IBM Process Mining analyzes event logs to discover real business processes.
2. An event log requires case ID, activity and timestamp.
3. A process model visualizes the actual process paths discovered from data.
4. A variant represents a specific sequence of activities followed by cases.
5. Model conformance compares the actual process with a reference model.
6. Analytics provides dashboards, widgets, filters and metrics for process analysis.
7. Custom metrics allow users to define process-specific KPIs.
8. Action Hub monitors KPIs, activities and transitions to trigger actions.
9. Prescriptive Process Mining helps investigate root causes and recommended actions.
10. Task Mining analyzes user desktop interactions and supports automation discovery.
