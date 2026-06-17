# 05. Action Hub, Prescriptive, Simulation, RPA and Task Mining

## 1. Action Hub

Action Hub 用于把流程洞察变成可跟踪、可执行的行动。

它可以创建和管理 service，并设置 monitors。

可监控对象包括：

- Process KPI
- Activity KPI
- Analytics widgets
- Activities
- Transitions

## 2. Monitors

Monitor 用于根据条件持续监控流程，并在满足条件时触发提醒或行动。

例子：

- 高优先级工单超过 2 天没有完成
- 审批等待时间超过 4 小时
- 返工率超过 5%
- 某个关键活动出现异常激增

认证记忆：

> Monitor turns process insights into operational alerts.

## 3. Prescriptive Process Mining

Prescriptive Process Mining 用于构建 investigative reports，帮助用户聚焦调查、分析根因、查看推荐行动并评估收益。

典型流程：

1. Build investigative reports
2. Configure reports
3. Focus the investigation
4. Interpret reports
5. Check KPI conformance
6. Analyze root causes
7. Explore recommended actions
8. Assess benefits
9. Check correlations between KPIs

## 4. What-if and Simulation

What-if / Simulation 用于模拟流程改进方案。

它可以回答：

- 如果自动化某个活动，会减少多少耗时？
- 如果减少审批等待，会提升多少 SLA？
- 如果去掉返工路径，成本能降低多少？
- 如果增加资源，瓶颈是否缓解？

## 5. RPA Candidates

RPA Candidates 用于识别适合自动化的活动。

适合 RPA 的活动一般有这些特征：

- 规则明确
- 重复频率高
- 手工操作多
- 系统间复制粘贴多
- 判断复杂度低
- 业务价值高

## 6. Generating an RPA bot

IBM Process Mining 支持基于流程洞察生成 RPA bot。实际使用时通常需要结合 Task Mining 数据，因为 Task Mining 更了解用户桌面操作细节。

## 7. IBM Task Mining

Task Mining 是 IBM Process Mining 的重要组成部分。

它记录、分析用户桌面交互，生成关于人工操作的洞察。

它能分析：

- Productivity
- Working patterns
- Context switches
- Rework
- Idle time
- Manual activity inefficiency
- Automation potential

## 8. Process Mining vs Task Mining

| 对比 | Process Mining | Task Mining |
|---|---|---|
| 分析层级 | 业务流程 | 用户任务 |
| 数据来源 | 企业系统事件日志 | 用户桌面操作 |
| 目标 | 看端到端流程 | 看人工操作细节 |
| 典型输出 | 流程图、变体、KPI | 操作模式、生产时间、RPA 脚本候选 |

## 9. Maximo 工单行动设计

### Monitor 例子

```text
If Priority = High and Cycle Time > 2 days, create alert.
```

### Prescriptive 例子

调查高优先级工单超时原因：

- 是否卡在审批？
- 是否卡在等待备件？
- 是否某个资产类型更容易超时？
- 是否某个团队处理时间更长？

### RPA 例子

适合自动化：

- 自动发送工单超时通知
- 自动创建审批提醒
- 自动生成每日工单报告
- 自动把完成信息同步到其他系统

## 10. 考试易错点

| 问题 | 正确理解 |
|---|---|
| Action Hub 只是 dashboard 吗？ | 不是，它偏行动和监控 |
| Prescriptive 只是展示图表吗？ | 不是，它偏调查、根因和推荐行动 |
| Simulation 是真实改变流程吗？ | 不是，它先模拟方案影响 |
| Task Mining 和 Process Mining 一样吗？ | 不一样，Task Mining 看桌面操作，Process Mining 看系统事件日志 |

## 11. 认证重点句

Action Hub and monitors help operationalize process insights by tracking KPIs, activities, transitions, and analytics widgets.

中文：Action Hub 和 monitors 可以把流程洞察转化为运营层面的监控和行动。
