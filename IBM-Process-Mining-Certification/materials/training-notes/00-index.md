# IBM Process Mining 2.0.3 学习笔记索引

> Source: `materials/official-docs/process-mining-2.0.3-documentation.pdf`

这个目录用于把官方 PDF 整理成更容易备考、做 demo 和复习的 Markdown 笔记。

## 学习顺序

1. [01-overview.md](01-overview.md)  
   IBM Process Mining 是什么、能解决什么问题、和 Task Mining 的关系。

2. [02-data-project-event-log.md](02-data-project-event-log.md)  
   Project、Data source、Event log、Object table、Data cleansing。

3. [03-process-analysis.md](03-process-analysis.md)  
   Process model、Variants、Reference model、Model conformance、BPMN。

4. [04-kpi-analytics.md](04-kpi-analytics.md)  
   KPI、Custom metrics、Analytics widgets、Filters。

5. [05-action-prescriptive-simulation-task-mining.md](05-action-prescriptive-simulation-task-mining.md)  
   Action Hub、Monitor、Prescriptive、What-if、Simulation、RPA Candidates、Task Mining。

6. [06-install-admin-troubleshooting.md](06-install-admin-troubleshooting.md)  
   安装、权限、系统要求、日志、Troubleshooting。内部认证如果偏产品使用，这部分先简单看。

## 复习策略

### 第一轮：能听懂会议

只看：

- 01-overview.md
- 02-data-project-event-log.md
- demo-maximo-work-order/README.md

目标：能说明 event log 怎么建、Process Mining 怎么分析 Maximo 工单。

### 第二轮：准备认证

重点看：

- 03-process-analysis.md
- 04-kpi-analytics.md
- 05-action-prescriptive-simulation-task-mining.md
- 06-internal-cert-cheatsheet.md
- 07-practice-questions.md

目标：能做题，能区分核心概念。

### 第三轮：准备 demo

重点看：

- demo-maximo-work-order/README.md
- 02-data-project-event-log.md
- 04-kpi-analytics.md
- 05-action-prescriptive-simulation-task-mining.md

目标：能做出一个可讲解的 IBM Process Mining + Maximo 工单 demo。

## 最重要的主线

```text
Enterprise system data
-> Event log
-> Process model
-> Variants / Conformance / KPI
-> Analytics
-> Monitor / Action / Prescriptive / Simulation
-> Automation opportunity
```

中文记忆：

```text
系统数据
-> 事件日志
-> 真实流程图
-> 变体/合规/KPI
-> 分析看板
-> 监控/行动/根因/模拟
-> 自动化机会
```
