# 04. KPI, Custom Metrics and Analytics

## 1. KPI 是什么

KPI 是用来衡量流程表现的关键指标。

在 IBM Process Mining 中，KPI 可以用于：

- 分析流程绩效
- 发现瓶颈
- 判断是否符合目标
- 配置 benchmark
- 触发 monitor
- 支持 Prescriptive investigation
- 支持 Simulation / What-if 分析

## 2. 常见 KPI

| KPI | 含义 | Maximo 工单例子 |
|---|---|---|
| Case count | 案例数量 | 工单数量 |
| Average lead time | 平均端到端耗时 | 创建到关闭平均时间 |
| Throughput time | 流程吞吐时间 | 工单完整周期 |
| Activity duration | 活动耗时 | 维修执行耗时 |
| Waiting time | 等待时间 | 等待审批或备件时间 |
| Cost | 成本 | 人工成本、材料成本 |
| Rework rate | 返工率 | Reopen 工单比例 |
| SLA breach rate | SLA 超时率 | 超过目标时间的工单比例 |
| Automation rate | 自动化率 | 自动执行活动比例 |

## 3. Custom metrics

Custom metrics 用于创建标准指标以外的自定义指标。

IBM Process Mining 2.0.3 支持 guided custom metrics 和 editor mode。

### Guided mode

适合业务用户或初学者，不需要写复杂代码。

### Editor mode

适合高级用户，可以更灵活地定义指标逻辑。

## 4. Custom metrics 例子

### 高优先级超时工单

```text
Priority = High AND Cycle Time > 2 days
```

### 返工工单

```text
Case contains Reopen Work Order after Complete Work
```

### 审批等待超时

```text
Time between Create Work Order and Approve Work Order > 4 hours
```

## 5. KPI benchmark

KPI benchmark 是 KPI 的目标或阈值。

例子：

| KPI | Benchmark |
|---|---|
| Average cycle time | <= 3 days |
| Approval waiting time | <= 4 hours |
| Rework rate | <= 5% |
| SLA breach rate | <= 10% |

## 6. Analytics page

Analytics page 用来通过 dashboards、widgets、filters 和 metrics 分析流程数据。

它适合回答业务分析问题：

- 哪些工单超时？
- 哪类资产最容易返工？
- 哪个地点处理时间最长？
- 哪个团队工作负载最高？
- 哪些活动是瓶颈？

## 7. Widget types

常见 widget：

- Card
- Table
- Bar chart
- Line chart
- Pie chart
- Custom widget
- Legacy widget
- Elastic widget

## 8. Dashboard 设计建议

一个清晰的 Process Mining dashboard 可以这样设计：

```text
Top: KPI Cards
Middle: Process model + trend charts
Bottom: Exception table + root cause tables
```

Maximo 工单例子：

### Top cards

- Total Work Orders
- Average Cycle Time
- SLA Breach Rate
- Rework Rate

### Middle charts

- Work Orders by Status
- Average Cycle Time by Priority
- Bottleneck Activities
- Work Orders by Location

### Bottom tables

- Delayed High Priority Work Orders
- Reopened Work Orders
- Cases Skipping Approval

## 9. Filters

Filter 是一组条件，用来排除部分数据，聚焦分析子集。

常见 filter：

- Time filter
- Attribute filter
- Activity filter
- Case filter
- Variant filter
- Performance filter

## 10. Filter 使用注意

不同页面的 filter 影响范围可能不同。

| 场景 | 影响 |
|---|---|
| Process / Conformance | 通常影响 case 范围 |
| Analytics dashboard | 可能影响整个 dashboard 或单个 widget |
| Monitor | 影响监控对象 |
| Prescriptive | 影响调查范围 |

## 11. Download event logs from Analytics

IBM Process Mining 2.0.3 增加了从 Analytics 下载 event logs 的能力。

用途：

- 数据检查
- 复盘分析
- 与他人共享样例
- 用于 demo 或调试

## 12. 考试易错点

| 问题 | 正确理解 |
|---|---|
| KPI 只是展示数字吗？ | 不只是展示，也能用于监控、benchmark、行动触发 |
| Custom metric 只能写代码吗？ | 2.0.3 支持 guided custom metrics |
| Analytics 和 Process model 一样吗？ | 不一样，Analytics 偏 dashboard 分析，Process model 偏流程路径 |
| Filter 总是影响所有数据吗？ | 不一定，要看 filter 配置和使用场景 |

## 13. 一句话背诵

Analytics helps users explore process data by using dashboards, widgets, filters, standard metrics and custom metrics.

中文：Analytics 通过 dashboard、widget、filter、标准指标和自定义指标帮助用户分析流程数据。
