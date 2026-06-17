# 03. KPI, custom metrics and analytics

## 1. KPI 是什么

KPI 是用来衡量流程表现的指标。

IBM Process Mining 中的 KPI 可以用于：

- 衡量流程效率
- 发现瓶颈
- 监控业务目标
- 触发 Action Hub monitor
- 支持 Prescriptive report
- 做 What-if / Simulation 对比

## 2. 常见 KPI

| KPI | 含义 | 工单例子 |
|---|---|---|
| Case count | 案例数量 | 工单数量 |
| Average lead time | 平均端到端耗时 | 从创建到关闭平均几天 |
| Activity duration | 活动耗时 | 执行维修用了多久 |
| Waiting time | 等待时间 | 审批前等待多久 |
| Cost | 成本 | 人工成本、资源成本 |
| Rework rate | 返工率 | Complete 后又 Reopen |
| Automation rate | 自动化率 | 自动活动占比 |
| SLA breach rate | SLA 超时率 | 超过目标完成时间的工单比例 |

## 3. KPI benchmarks

KPI benchmark 是 KPI 的目标或阈值。

例子：

- Work order cycle time <= 3 days
- Approval waiting time <= 4 hours
- Rework rate <= 5%
- SLA breach rate <= 10%

用途：

- 判断流程是否健康
- 配合 monitor 做告警
- 配合 Prescriptive 做调查

## 4. Custom metrics

Custom metrics 用于定义标准 KPI 以外的自定义指标。

IBM Process Mining 2.0.3 提供 guided custom metrics，能不用写复杂代码创建自定义 KPI。

示例：

### SLA Breach

```text
If cycle time > target cycle time, then breach = true.
```

### Rework Count

```text
Count cases where activity sequence contains Reopen after Complete.
```

### High Priority Delay

```text
Cases where priority = High and cycle time > 2 days.
```

## 5. Analytics page

Analytics 是做 dashboard 和图表分析的地方。

常见 widget 类型：

- Card
- Table
- Bar chart
- Line chart
- Pie chart
- Process-related widgets
- Custom widgets

## 6. Analytics 和 Process 页面的区别

| 页面 | 作用 |
|---|---|
| Process | 看流程图、路径、变体、conformance |
| Analytics | 看 KPI、图表、表格、筛选、业务分析 |
| Action Hub | 监控并触发动作 |
| Prescriptive | 系统化调查原因和建议行动 |

## 7. Filters in Analytics

Analytics 中的 filters 影响表记录和 widget。

注意两种影响范围：

1. Entire dashboard
2. Single widgets

认证记忆：

- Process / Action Hub / Prescriptive / What-if 的 filters 多数影响 cases。
- Analytics 的 filters 影响 records / widgets。

## 8. Maximo 工单 dashboard 设计

建议做这些 KPI：

- Total Work Orders
- Average Cycle Time
- Open Work Orders
- Completed Work Orders
- SLA Breach Rate
- Rework Count
- Average Waiting Time before Approval
- Cost by Asset Type
- Delay by Priority
- Top 10 Bottleneck Activities

建议图表：

- KPI cards at top
- Bar chart: Work orders by status
- Line chart: Monthly work order volume
- Table: Delayed high-priority work orders
- Bar chart: Average cycle time by asset/location
- Process model: actual work order flow

## 9. 认证重点句

Analytics helps users explore process data through dashboards, widgets, filters, standard formulas, and custom metrics.

中文：Analytics 通过 dashboard、widget、filter、标准公式和自定义指标帮助用户分析流程数据。
