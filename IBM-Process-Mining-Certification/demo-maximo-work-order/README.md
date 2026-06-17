# Maximo Work Order Demo Story

## 1. Demo 目标

使用 IBM Process Mining 分析 Maximo 工单流程，发现工单从创建到关闭过程中的瓶颈、返工、超时和自动化机会。

## 2. Business story

Maintenance teams use IBM Maximo to manage work orders. However, process owners often do not know where delays occur, which work orders are reworked, and which activities can be automated.

With IBM Process Mining, we can discover the actual work order process from event logs, compare it with the expected process, monitor SLA breaches, and identify automation opportunities.

中文：维修团队使用 IBM Maximo 管理工单，但流程负责人不一定知道延迟发生在哪里，哪些工单发生返工，哪些活动可以自动化。通过 IBM Process Mining，可以从事件日志还原真实工单流程，对比标准流程，监控 SLA 超时，并识别自动化机会。

## 3. Event log design

| 字段 | 说明 | 示例 |
|---|---|---|
| WORK_ORDER_ID | Case ID | WO1001 |
| ACTIVITY | Activity | Approve Work Order |
| TIMESTAMP | Timestamp | 2026-06-01 10:30 |
| RESOURCE | Resource | Supervisor B |
| PRIORITY | Priority | High |
| STATUS | Status | APPR |
| ASSET_ID | Asset | A100 |
| LOCATION | Location | Plant 1 |
| WORK_TYPE | Work type | Corrective Maintenance |

## 4. 标准流程 Reference model

```text
Create Work Order
-> Approve Work Order
-> Schedule Work
-> Start Work
-> Complete Work
-> Close Work Order
```

## 5. 常见异常流程

### 跳过审批

```text
Create Work Order -> Start Work -> Complete Work -> Close Work Order
```

风险：流程不合规，可能是紧急维修，也可能是审批缺失。

### 返工

```text
Create -> Approve -> Start -> Complete -> Reopen -> Complete -> Close
```

风险：维修质量、备件、问题诊断不准确。

### 长时间等待

```text
Create -> Wait for Approval -> Approve -> Wait for Parts -> Start -> Complete
```

风险：审批瓶颈、备件供应问题。

## 6. KPI 设计

| KPI | 说明 |
|---|---|
| Total Work Orders | 工单总数 |
| Average Cycle Time | 从创建到关闭平均耗时 |
| Approval Waiting Time | 创建到审批等待时间 |
| Execution Time | 开始到完成耗时 |
| SLA Breach Rate | 超出 SLA 的工单比例 |
| Rework Rate | 返工工单比例 |
| Open Work Orders | 未完成工单数 |
| Cost by Asset | 按资产统计成本 |
| Delay by Priority | 按优先级统计延迟 |

## 7. Dashboard 设计

顶部 KPI cards：

- Total Work Orders
- Average Cycle Time
- SLA Breach Rate
- Rework Rate

中间图表：

- Process model
- Work Orders by Status
- Average Cycle Time by Priority
- Bottleneck Activities

底部明细表：

- Delayed High Priority Work Orders
- Reopened Work Orders
- Cases Skipping Approval

## 8. Action Hub monitor 例子

### Monitor 1: 高优先级工单超时

```text
Condition:
Priority = High AND Cycle Time > 2 days

Action:
Notify maintenance manager.
```

### Monitor 2: 审批等待超时

```text
Condition:
Approval Waiting Time > 4 hours

Action:
Send approval reminder.
```

### Monitor 3: 返工率异常

```text
Condition:
Rework Rate > 5%

Action:
Create investigation report.
```

## 9. Prescriptive investigation

问题：为什么高优先级工单经常超时？

调查方向：

- 是否集中在某些资产？
- 是否集中在某些地点？
- 是否卡在审批？
- 是否卡在备件等待？
- 是否某个团队处理时间过长？
- 是否返工导致周期变长？

推荐行动：

- 自动提醒审批人
- 对关键资产设置快速通道
- 对高返工资产做根因分析
- 自动生成每日超时工单报告

## 10. 英文讲解稿

This demo analyzes the Maximo work order process with IBM Process Mining. We use Work Order ID as the case ID, work order status changes as activities, and status change time as the timestamp. After importing the event log, IBM Process Mining can discover the actual process flow, show the most frequent variants, identify bottlenecks, check conformance against the expected process, and monitor SLA breaches. Based on these insights, we can create monitors in Action Hub and identify automation opportunities such as overdue work order alerts or approval reminders.

## 11. 中文讲解稿

这个 demo 使用 IBM Process Mining 分析 Maximo 工单流程。我们用工单号作为 Case ID，用工单状态变化作为 Activity，用状态变更时间作为 Timestamp。导入事件日志后，IBM Process Mining 可以还原真实流程路径，展示高频变体，识别瓶颈，对比标准流程检查合规性，并监控 SLA 超时。基于这些洞察，我们可以在 Action Hub 中创建监控，并识别自动化机会，例如超时工单提醒和审批提醒。
