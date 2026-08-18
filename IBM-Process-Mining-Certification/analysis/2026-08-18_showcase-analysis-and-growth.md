# IBM Process Mining Showcase 分析与自我成长记录

更新时间：2026-08-18

## 1. 当前 Showcase 背景

Phase2 当前分析对象为审批结束 Case，主要条件：

- 数据区间：2025/08/01 ～ 2026/05/31
- 排除 `System = DDD`
- `status-0601` 中仅统计出现“审批结束”的 Case
- 总 Case 数：`21,578`

当前按最终入账结果划分：

- RPA_PROCESS：`11,520`，约 `53.388%`
- MANUAL_PROCESS：`9,735`，约 `45.115%`
- 其他/未完全归类：`323`，约 `1.497%`

针对 9,735 件最终人工入账 Case，目前已从 OCR Feedback 维度进行分析，并重点拆解：

- TOP1：`EBS_大于阈值需检查`，人工 `2,341`
- TOP2：`EBS`，人工 `782`
- TOP3：`JDE`，人工 `764`

当前 dashboard 已进一步对 TOP1～TOP3 的 Status、Comments、留言、PO 对比结果、PO/合同/其他原因等进行拆分。

---

## 2. 近期业务反馈与方向调整

### 2.1 意见征询不能简单等同于“人工入账原因”

2026-08-18 与业务确认：

> 意见征询在人工入账和 RPA 入账中都会存在。

因此，意见征询更适合被定义为：

**流程中的人工确认/业务确认行为，而不是只属于人工最终入账的根因。**

后续如果目标是分析“意见征询的比例和可能的 Type”，建议基于全部 Case 做整体分析，而不是只在 MANUAL_PROCESS 中拆。

推荐分析方式：

```text
全部 21,578 Cases
        ↓
是否存在意见征询
        ↓
├─ 最终 RPA 入账
└─ 最终人工入账
        ↓
再看意见征询 Type
PO / 合同 / 收货 / 电子签章 / 付款期限 / 其他
```

这样既能保留 Process Mining 的过程视角，也能避免把“意见征询”和“最终人工入账”错误地绑定为同一概念。

---

### 2.2 Showcase 不能只停留在普通数据分析

Sara 的核心反馈是：

目前 detail dashboard 可以帮助发掘问题，但整体呈现方式仍然比较像普通的数据分析。

如果是 Process Mining Showcase，需要更明确体现 Process Mining 本身的差异化能力：

1. 先展示流程路径；
2. 对比 RPA 入账路线与人工入账路线；
3. 再进入人工原因分析；
4. 最后量化改善机会和 Potential Saving。

因此当前 Showcase 的故事线应该从：

```text
分类 → TOP1/TOP2/TOP3 → 饼图 → 根因
```

升级为：

```text
Process Route
    ↓
RPA vs Manual
    ↓
Where Human Intervention Happens
    ↓
Root Cause Drill-down
    ↓
Automation Opportunity
    ↓
Potential Saving / Business Case
```

这是当前最重要的方向调整。

---

## 3. 推荐的 Showcase 三层结构

## 第一层：Process Overview

### 目标

先回答客户最关心的问题：

> 这些 Case 实际上是怎么走的？

建议增加两类主路径。

### RPA 典型路线

```text
OCR / 前置处理
→ 自动检查
→ 可能出现意见征询或异常处理
→ ChinaBot 录入完成
→ 审批结束
```

### 人工典型路线

```text
OCR / 前置处理
→ 可能出现人工确认
→ 人工录入完成
→ 审批结束
```

页面同时展示：

- 21,578 Total Cases
- 11,520 RPA Final Entry
- 9,735 Manual Final Entry
- RPA Rate / Manual Rate

这里优先使用 Process Map / Process Variant / Path View，而不是先放大量分类饼图。

### 价值

这样客户第一眼看到的是：

**业务实际流程怎么跑、理想自动化路径是什么、偏离自动化路径的 Case 在哪里发生。**

这才是 Process Mining 区别于传统 BI 的核心价值。

---

## 第二层：Manual Root Cause & Human Intervention

9,735 件人工入账建议先分为两种逻辑，而不是直接 TOP1/TOP2/TOP3。

### A. 有明确业务介入理由

例如：

- 意见征询
- PO / 收货问题
- 合同问题
- 电子签章
- 付款期限
- 发票问题
- QA
- 其他有明确线索的异常

这部分更偏：

**Business / Customer Dependency**

即人工介入有业务理由，不能简单认为是 RPA 失败。

### B. 没有明显异常，但最终由人工完成

这是目前最值得继续挖掘的一类。

重点条件：

- Event 中主要只有“录入完成 → 审批结束”；
- 最终录入完成由人工 Processor 执行；
- Comments 无明显异常；
- Tracker 留言无明显异常；
- 没有明显 PO / 合同 / 业务 exception 可以解释为什么必须人工录入。

这类 Case 可能隐藏：

- 员工主动人工处理；
- RPA 等待时间过长；
- RPA Performance 问题；
- 高峰期人为绕过机器人；
- User Behavior / 操作习惯；
- 其他未被 Event Log 捕捉的原因。

因此这部分更应该被定义为：

**Potential Automation Opportunity**

而不是简单的“未分类”。

---

## 4. TOP1 / TOP2 / TOP3 的正确定位

目前 TOP1～TOP3 的分析仍然有价值，但更适合作为：

**Drill-down Evidence，而不是整个 Showcase 的主故事线。**

### TOP1：EBS_大于阈值需检查

人工 Case：`2,341`

当前已发现：

- 大量 Case 的流程信息很少；
- 有意见征询的 Case 中，可以从 Comments 等信息进一步分为 PO、合同、其他原因；
- PO 可匹配但仍然出现意见征询的 Case 值得抽样调查；
- PO 对比结果大量 BLANK 时，不宜把 BLANK 本身作为业务结论，需要结合 Comments / Tracker 判断。

因此 TOP1 页面建议重点保留：

1. 总人工件数；
2. 有意见征询件数；
3. 无明显异常但人工录入件数；
4. 意见征询 Comments 分类；
5. PO / 合同 / 其他原因大类。

不建议为了“图多”继续保留大量信息价值较低的小饼图。

---

### TOP2：EBS

TOP2 的逻辑与 TOP1 类似。

目前可以继续使用相同框架进行对比：

- 总人工件数；
- 意见征询比例；
- 无明显异常人工完成比例；
- PO / 合同 / 其他原因；
- 是否存在与 TOP1 相同的人工绕过自动化现象。

如果两者得出相近模式，则可以进一步从单个 OCR Feedback 的分析上升为：

> 人工最终入账并不完全由 OCR Feedback 类别决定，其中可能存在跨分类的 User Behavior / RPA Performance 共性问题。

---

### TOP3：JDE

JDE 与 TOP1/TOP2 有一个明显不同点：

JDE 的人工 Case 中，可分析的流程/业务信息比例更高，因此它可能比“人工绝对件数最高”更具有实际分析价值。

这提示后续定义 TOP 时不能只看：

```text
Manual Case Count
```

还应该看：

```text
Analyzable Case Count
Analyzable Rate
Potential Opportunity Count
```

也就是说，真正值得优先投入分析的类别，不一定是人工量最大的类别，而可能是：

**信息完整、能够明确找到根因和改善动作的类别。**

---

## 5. 下一步优先分析任务

### Priority 1：重建 Process Mining 主故事线

增加：

- RPA 入账 Process Route
- Manual 入账 Process Route
- 两者主要 Variant 对比
- 人工介入发生在哪个节点

目标：让 Showcase 第一页就体现 Process Mining，而不是 BI Dashboard。

---

### Priority 2：找出“只有人工录入完成 + 审批结束”的 Case

建议条件：

1. 最终是人工录入；
2. Event 主要只有录入完成和审批结束；
3. Comments 为空或没有明确异常信息；
4. Tracker 留言为空或没有明确异常信息。

然后输出：

- Case Count
- 占 9,735 人工 Case 的比例
- 占 21,578 全部 Case 的比例
- 月度 Trend
- Processor 分布
- OCR Feedback 分布
- 高峰月份与总业务量的关系

重点验证假设：

> 这些 Case 是否集中出现在业务高峰期，从而反映 RPA 等待时间、性能或员工主动绕过自动化的问题。

如果月度分布很平均，则需要进一步向业务确认实际操作原因。

---

### Priority 3：意见征询整体分析

不再只按 TOP1/TOP2/TOP3 分开看。

建议对所有存在意见征询的 Case 统一分析：

- 总意见征询 Case 数
- 最终 RPA / Manual 分布
- Comments 分类
- PO / 合同 / 收货 / 签章 / 付款期限等 Type
- 哪些意见征询最终可以 rerun 并回到 RPA
- 哪些必须人工完成

这样可以把意见征询定义为：

**Human Intervention Point**

而不是 Manual Root Cause。

---

### Priority 4：Potential Saving

如果确认一部分人工 Case 实际可以交由 RPA 完成，则可以建立简单 Saving Model：

```text
Potential Automation Cases
× Average Manual Handling Time
= Potential Hours Saved
```

进一步：

```text
Potential Hours Saved
× Labor Cost
= Potential Cost Saving
```

最终再与 Process Mining 的实施周期、部署成本、运营成本对比，形成 ROI。

这会让 Showcase 从“发现问题”走到：

**Discover → Quantify → Improve → Business Case**

---

## 6. 对当前 Dashboard 的调整建议

### phase2_人工原因分析汇总

保留：

- Total Cases
- RPA / Manual Rate
- OCR Feedback 人工分布

增加：

- RPA Route vs Manual Route
- RPA Process 中有人工介入的比例
- 全量意见征询比例
- Potential Automation Opportunity 件数

### TOP1 / TOP2 / TOP3

建议减少：

- 大量 BLANK 占主导但无法解释业务意义的饼图；
- 多个高度类似的中间结果图。

建议突出：

- 有效信息覆盖率；
- Comments 根因；
- PO / 合同 / 其他大类；
- 可以采取什么 Action。

Dashboard 的目标应该从：

> 展示我们分析了很多字段

转变为：

> 展示 Process Mining 帮我们发现了哪些可操作的机会。

---

# 7. 本阶段自我成长总结

这次工作最大的成长，不只是会写更多 SQL 或做更多图，而是分析思维正在发生变化。

## 7.1 从“数据对数”到“建立可信分析口径”

早期工作大量集中在：

- UUID 去重；
- Event / Tracker / Comments 对齐；
- DDD 排除；
- RPA / Manual 判定；
- 9,xxx 件数据为什么 Excel 和 IPM 对不上；
- 空值、状态、机器人名称等边界问题。

这些工作看起来基础，但它实际上训练的是 Process Mining 中最核心的能力之一：

**Data Quality + Business Definition。**

现在已经不再只是“SQL 能不能跑”，而是会主动问：

- 这个 Case 为什么应该算人工？
- 最终入账和过程中人工介入是不是同一个概念？
- 一个字段的 BLANK 到底代表业务为空，还是系统没有记录？
- 统计口径是否会影响业务结论？

这是从开发者视角向 Data / Process Analyst 视角的明显变化。

---

## 7.2 从“字段分析”到“流程分析”

前期很容易自然进入传统数据分析思路：

```text
字段 → 分类 → COUNT → 饼图
```

现在开始意识到 Process Mining 更应该先问：

```text
Case 从哪里来？
经过什么 Activity？
在哪个节点发生偏离？
人工为什么介入？
介入之后是否重新回到自动化？
最终走到哪里？
```

这意味着已经开始从：

**Table Thinking**

转向：

**Process Thinking**。

这是本阶段最重要的专业成长之一。

---

## 7.3 从“给数字”到“解释数字”

例如：

- 2,341 件本身不是结论；
- 517 件意见征询本身也不是结论；
- PO 可匹配 33 件本身也不是结论。

真正有价值的问题变成：

- 为什么 PO 已经可匹配还需要意见征询？
- 为什么没有明显异常仍然由人工录入？
- 这些人工 Case 是业务必需，还是自动化机会？
- 如果改善，可以节省多少？

也就是说，分析开始从：

**What happened**

进入：

**Why it happened / What can we improve**。

---

## 7.4 从“做 Dashboard”到“讲 Business Story”

本轮 Sara 的反馈非常关键。

Dashboard 做得完整，并不等于 Showcase 有说服力。

真正面向客户时，需要一条清晰故事：

```text
这是现在的流程
    ↓
这里发生了人工介入
    ↓
我们发现主要有两类原因
    ↓
一部分是业务必须
另一部分可能是不必要人工操作
    ↓
这里存在 Automation Opportunity
    ↓
预计可以带来多少 Saving
    ↓
Process Mining 是否值得长期投入
```

这实际上是在训练：

- Stakeholder Communication
- Consulting Storyline
- Business Case Thinking
- Executive Presentation

这已经超出了单纯 SQL / IPM 工具使用层面。

---

## 7.5 从“工具使用者”到“机会发现者”

最开始关注的是：

> IPM 这个图怎么做？SQL 怎么写？Custom Widget 怎么配置？

现在越来越多的问题变成：

> 这个流程里到底哪里有机会？

> 哪些数据可以支持客户改善？

> 这个发现值不值得客户投入资源？

这是角色上的变化：

```text
Developer / Tool User
        ↓
Process Analyst
        ↓
Automation Opportunity Analyst
        ↓
Business-oriented Process Mining Consultant
```

目前仍然在成长过程中，但方向已经越来越清楚。

---

# 8. 下一阶段个人能力目标

## Process Mining

继续加强：

- Process Variant 分析
- Path / Transition 分析
- Conformance Thinking
- Human Intervention Detection
- Root Cause Analysis
- Automation Opportunity Identification

## 数据分析

继续强化：

- 数据口径设计
- Case-level 去重与关联
- 异常数据解释
- 分类规则可复现性
- 从 Count 升级到 Rate / Trend / Impact

## Business / Consulting

下一阶段尤其需要补：

- 用一句话解释一个图的业务意义；
- 每个分析结果都对应一个 Action；
- 从 Process Insight 推导 Saving；
- 建立 ROI / Business Case；
- 能把复杂分析压缩成 2～3 页客户能理解的故事。

---

# 9. 当前阶段一句话总结

> 这次 IBM Process Mining 项目最大的收获，是从“把数据算对、把图做出来”，逐渐走向“理解流程为什么这样运行、识别真正的自动化机会，并把它讲成客户愿意接受的 Business Case”。
