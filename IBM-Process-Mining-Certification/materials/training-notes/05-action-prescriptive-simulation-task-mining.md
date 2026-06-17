# 05. Action Hub, Prescriptive, Simulation and Task Mining

## 1. Action Hub

Action Hub 用来把流程洞察转化为可执行行动。

它不是单纯展示 dashboard，而是偏运营监控和行动触发。

Action Hub 相关能力包括：

- Creating and managing a service
- Setting a monitor for Process KPI
- Setting a monitor for Activity KPI
- Setting a monitor for Analytics widgets
- Setting a monitor for Activities
- Setting a monitor for Transitions
- Managing monitors

## 2. Monitor

Monitor 用来监控流程指标、活动或转移关系，并在满足条件时触发通知或行动。

Maximo 工单例子：

### 高优先级工单超时

```text
Condition:
Priority = High AND Cycle Time > 2 days

Action:
Notify maintenance manager
```

### 审批等待超时

```text
Condition:
Approval Waiting Time > 4 hours

Action:
Send approval reminder
```

### 返工率异常

```text
Condition:
Rework Rate > 5%

Action:
Create investigation report
```

## 3. Prescriptive Process Mining

Prescriptive Process Mining 用来创建 investigative reports，帮助用户聚焦问题、分析根因、查看推荐行动并评估收益。

典型流程：

1. Building investigative reports
2. Configuring reports
3. Scheduling reports
4. Focusing the investigation
5. Interpreting the reports
6. Checking KPI conformance
7. Analyzing root causes
8. Exploring recommended actions
9. Assessing the benefits
10. Checking correlations between KPIs

## 4. Prescriptive 适合解决什么问题

- 为什么某个 KPI 不达标？
- 哪些属性导致流程异常？
- 哪些路径最影响成本和时间？
- 哪些行动可以改善指标？
- 改进方案可能带来多少收益？

## 5. What-if

What-if 用来评估假设性变化。

例子：

- 如果审批时间减少 50%，整体周期能缩短多少？
- 如果自动发送超时提醒，SLA breach 能降低多少？
- 如果增加维修人员，瓶颈是否缓解？

## 6. Simulation

Simulation 用来模拟流程变化后的影响。

可以用于：

- To-be scenario
- Automation impact assessment
- Resource change impact
- Bottleneck improvement analysis
- Cost/time comparison

注意：Simulation 是模拟，不是直接修改真实流程。

## 7. RPA Candidates

RPA Candidates 用来识别适合自动化的活动。

适合自动化的活动通常具有：

- 高频重复
- 规则明确
- 人工操作多
- 判断复杂度低
- 系统之间复制粘贴多
- 业务价值较高

## 8. Generating an RPA bot

IBM Process Mining 支持生成 RPA bot，尤其是结合 Task Mining 后，可以基于用户操作行为识别更具体的自动化机会。

常见 RPA 场景：

- 自动发送提醒
- 自动生成报告
- 自动同步系统字段
- 自动创建工单后续任务
- 自动检查缺失信息

## 9. IBM Task Mining

IBM Task Mining 是屏幕活动分析工具，用来记录、分析并生成用户桌面交互洞察。

它可以帮助分析：

- Productivity
- Working patterns
- Context switches
- Manual rework
- Idle time
- Productive time
- Automation potential

## 10. Task Mining 的三个重点

### Productivity

衡量用户完成每个事件所需时间，发现人工活动中的低效，例如上下文切换和返工。

### Working Patterns

发现执行任务的不同模式，识别最有效的操作方式，并把它作为推荐实践。

### Automation

识别和模拟可自动化的工作模式，评估自动化带来的性能和成本收益。

## 11. Process Mining + Task Mining

Process Mining 看端到端流程。

Task Mining 看用户桌面操作细节。

组合后可以回答：

- 哪个业务环节慢？
- 这个环节里人工到底做了什么？
- 是否存在大量复制粘贴？
- 是否可以用 RPA 自动化？
- 自动化能节省多少时间和成本？

## 12. 考试易错点

| 问题 | 正确理解 |
|---|---|
| Action Hub 是 dashboard 吗？ | 不是，偏监控和行动 |
| Monitor 只能监控 KPI 吗？ | 不只 KPI，也可监控 activities、transitions、analytics widgets |
| Prescriptive 是看图吗？ | 不只是看图，重点是调查、根因、推荐行动和收益评估 |
| Simulation 会直接改变生产流程吗？ | 不会，它用于模拟影响 |
| Task Mining 和 Process Mining 一样吗？ | 不一样，Task Mining 分析桌面操作，Process Mining 分析系统事件日志 |

## 13. 一句话背诵

Action Hub operationalizes insights through monitors, while Prescriptive Process Mining helps investigate root causes and recommended actions.

中文：Action Hub 通过 monitor 把洞察转化为行动，而 Prescriptive Process Mining 帮助调查根因和推荐行动。
