# IBM Process Mining 项目阶段总结：从数据口径到 Simulation 与业务价值

更新时间：2026-08-20

> 本文整理从读取 GitHub / IBM Process Mining 学习资料开始，到当前 Phase2 数据分析、RPA/人工分类、意见征询、Simulation、System 拆分、IPM Custom Widget 以及业务沟通的完整阶段成果，并补充个人能力成长总结。

---

## 1. 项目目标的变化

最开始的工作重点主要是：

- 读取并理解 IBM Process Mining 相关 GitHub 内容；
- 熟悉 IPM 数据导入、Event Log、Case Attribute、Dashboard、Widget；
- 将 Excel / Tracker / Event Log 中的数据对齐；
- 复现业务已有统计结果。

随着分析深入，目标逐渐从“把数字算对”升级为：

```text
Data Quality
    ↓
Business Definition
    ↓
Process Route
    ↓
Human Intervention
    ↓
Root Cause
    ↓
Simulation
    ↓
Potential Saving / Business Case
```

这也是当前 Showcase 最重要的主线。

---

# 2. 数据与口径基础

## 2.1 核心数据对象

当前分析主要涉及：

- `eventlog`：事件表；
- `case_attributes_tbl_all`：Case 属性表，来自 Tracker 清洗数据；
- Comments / 分类辅助表；
- BOT Tracker / status 等 Excel、CSV 数据。

核心 Join：

```sql
EVENTLOG.CASEID = CASE_ATTRIBUTES_TBL_ALL.UUID
```

`System`、`OCRFeedback`、`TrackerStatus` 等属性来自 Case Attribute，而不是 Event Log 本身。

---

## 2.2 Phase2 基准口径

Phase2 当前业务基准总数：

```text
21,578 Cases
```

主要条件包括：

- 排除 `System = DDD`；
- status 数据中仅统计已经出现“审批结束”的 Case；
- 对 Case 进行 UUID 去重。

项目过程中使用过不同时间区间的数据抽取版本，例如 2025/08～2026/05 的 Showcase 数据，以及后续 2026/01～2026/06-10 的抽取数据。因此在对比历史截图或 Excel 时，需要先确认当前使用的数据版本和统计期间，不能只看总数直接比较。

---

# 3. RPA / Manual 分类体系

## 3.1 最终处理方式

当前 Phase2 基础结果：

| 分类 | Case 数 | 占比 |
|---|---:|---:|
| RPA_PROCESS | 11,520 | 53.388% |
| MANUAL_PROCESS | 9,735 | 45.115% |
| 其他 / 未纳入当前 Role 分类 | 323 | 1.497% |
| 合计 | 21,578 | 100% |

其中当前 Role 分析覆盖：

```text
11,520 + 9,735 = 21,255 Cases
```

因此后续如果某张表只基于 RPA / Manual Role，合计为 21,255 是正常的，并不是少算；剩余 323 件属于原 Phase2 总体中的第三类。

---

## 3.2 Role 进一步拆分

RPA：

```text
RPA_无人工介入       8,751
RPA_人工介入         2,769
--------------------------------
RPA 合计            11,520
```

人工：

```text
MANUAL_直接录入             7,554
MANUAL_有额外人工介入       2,181
--------------------------------
MANUAL 合计                 9,735
```

因此：

```text
RPA 中有人工介入比例
= 2,769 / 11,520
≈ 24.04%
```

业务沟通中可以简称“RPA 中有人工介入”，但不建议直接把它完全等同于严格意义上的所有 `Re-Run`。

---

## 3.3 Manual 分类定义

当前 Excel 判定逻辑的核心是：

```excel
=IF(
    G2<>"MANUAL",
    "",
    IF(
        COUNTIFS(
            $A:$A,A2,
            $B:$B,"<>审批结束",
            $B:$B,"<>审批拒绝",
            $B:$B,"<>录入完成",
            $D:$D,"<>",
            $D:$D,"<>ChinaBot",
            $D:$D,"<>ChinaBOT"
        )>0,
        "MANUAL_有额外人工介入",
        "MANUAL_直接录入"
    )
)
```

因此：

### MANUAL_有额外人工介入

表示最终人工入账，而且 Case 中存在：

- 非审批结束；
- 非审批拒绝；
- 非录入完成；
- Processor 非空；
- Processor 不是 ChinaBot / ChinaBOT；

的额外人工 Activity。

### MANUAL_直接录入

更准确的业务说法是：

> **人工无额外处理**

它表示没有上述额外人工 Activity，**并不代表 Variant 一定只有“录入完成 → 审批结束”两个节点**。Case 中仍可能存在系统活动、自动活动或 Processor 为空的活动。

这是当前分类里非常重要的边界定义。

---

# 4. 意见征询：从“人工原因”升级为 Human Intervention Point

早期很容易把“意见征询”直接归类为人工入账原因。

后续业务确认后发现：

> 意见征询既可能发生在最终人工入账 Case，也可能发生在最终 RPA 入账 Case。

因此更合理的定义是：

```text
意见征询 = 流程中的人工确认 / 业务确认行为
```

而不是：

```text
意见征询 = 人工最终入账原因
```

推荐分析结构：

```text
全部 Case
   ↓
是否发生意见征询
   ↓
├─ 最终 RPA
└─ 最终 Manual
   ↓
再分析意见征询 Type
PO / 合同 / 收货 / 电子签章 / QA / 付款期限 / 其他
```

这一步让分析从字段分类真正转向了 Process Mining 的“流程偏离与人工介入点”。

---

# 5. TOP1～TOP3 Root Cause 分析

前期人工 Case 主要从 OCR Feedback TOP 类别向下 Drill-down。

包括：

- `EBS_大于阈值需检查`；
- EBS；
- JDE；
- PO 对比；
- Comments；
- Tracker 留言；
- PO / 合同 / 其他；
- QA；
- 电子签章；
- 收货；
- 付款期限；
- 发票关联等。

通过多轮 Excel / SQL 清洗，逐步完成：

- TOP1～TOP3 外 Comments 的识别；
- 相似分类合并；
- PO / 合同 / 其他的映射；
- UUID 去重；
- 正向、反向校验；
- 业务无法判断内容单独整理并向 Sara 确认。

现在对 TOP1～TOP3 的定位也发生变化：

> 它们仍然是有价值的 Drill-down Evidence，但不再应该成为整个 Process Mining Showcase 的唯一主线。

---

# 6. Process Mining Showcase 的重新定位

当前 Showcase 主故事线建议为：

```text
Process Overview
      ↓
RPA vs Manual Route
      ↓
Human Intervention
      ↓
Root Cause Drill-down
      ↓
Automation Opportunity
      ↓
Simulation
      ↓
Potential Saving / Business Case
```

核心变化：

从：

> “我做了很多分类和图表。”

升级为：

> “Process Mining 帮我们发现流程在哪里偏离理想自动化路径、人工为什么介入、改善后可能产生什么效果。”

---

# 7. Simulation 实践

Simulation 是本阶段最大的能力突破之一。

## 7.1 Direct Manual Entry 场景

一个典型 Variant：

```text
录入完成
   ↓
审批结束
```

Simulation 基准：

```text
Cases：4,762
Avg Process Time：约 17h18m
Avg Process Cost：约 €3.33
Total Cost：约 €15,875
```

当前成本假设：

```text
人工成本：€5 / hour
人工录入：20 min
意见征询：30 min
```

因此：

```text
20 min × €5/hour ≈ €1.67
30 min × €5/hour = €2.50
```

需要注意：如果默认 Manual Working Time 仍设置为 20 分钟，那么其他没有单独配置的 Manual Activity 也可能产生费用。

---

## 7.2 50% 录入自动化场景

曾模拟：

```text
录入完成自动化比例 = 50%
```

结果约为：

```text
Cases：4,762
Avg Process Cost：€2.50
Total Cost：€11,905
```

成本逻辑能够解释：

```text
审批人工成本约 €1.67
+
50% Manual Entry 成本约 €0.83
≈ €2.50 / Case
```

这说明 Simulation 不只是“点几个参数”，而是可以用业务假设对模拟结果做反向验证。

---

# 8. 意见征询 Simulation

重点 Variant：

```text
意见征询
   ↓
录入完成
   ↓
审批结束
```

基准：

```text
Cases：1,016
占相关 Variant：56.82%
Avg Duration：12d4h
意见征询 Event：1,177
意见征询 Self-loop：161
```

路径概率：

```text
意见征询 → 意见征询     10.8%
意见征询 → 录入完成     89.2%
```

这说明意见征询存在重复发生 / Rework。

---

## 8.1 减少重复意见征询

模拟将路径概率调整为：

```text
重复意见征询：10.8% → 5%
进入录入完成：89.2% → 95%
```

结果约为：

```text
Avg Time：12d4h → 11d17h
Avg Cost：€6.19 → €6.03
Total Cost：€6,284.17 → €6,129.17
Saving：约 €155
```

单纯减少重复意见征询有改善，但收益有限。

---

## 8.2 减少 Rework + 50% 自动录入

组合场景：

```text
意见征询重复率下降
+
录入完成 50% 自动化
```

结果约为：

```text
Cases：1,016
Avg Time：12d4h → 6d16h
Avg Cost：€6.19 → €4.37
Total Cost：€6,284.17 → €4,435.83
Saving：约 €1,848.34
```

这给出了更完整的业务故事：

> 不是简单“自动化意见征询”，而是先减少上游 Rework，再把下游标准化录入尽量交给自动化。

即：

```text
Reduce Rework at Source
        +
Automate Standardized Downstream Work
```

---

# 9. 对 IPM 指标理解的深化

## 9.1 Frequency

`Frequency` 是 Activity Event 出现次数，不是 Case 数。

因此一个 Activity 如果在同一 Case 中重复出现，Frequency 会大于 Case Count。

---

## 9.2 自动化实例比率

IPM 中 Activity 显示的某些百分比是：

> Automation Instance Ratio

即这个 Activity 的实例中，有多少被 Automation Attribute 判定为自动处理。

不是 Rework 比例，也不是 Case Coverage。

当前 Automation Attribute 主要通过 Processor / Resource 中的：

```text
ChinaBot
ChinaBOT
```

识别自动活动。

---

## 9.3 Model Coverage

Model Coverage 表示当前 Process Map 显示了某个 Activity 多少可能的流程关系，而不是该 Activity 覆盖了多少 Case。

这一步修正了早期对 IPM 图中百分比的误读，也让后续 Dashboard 解读更准确。

---

# 10. System（EBS / JDE）拆分

2026-08-20 为 Simulation 时间估算进一步按 System 拆分 RPA / Manual。

`System` 来源：

```text
case_attributes_tbl_all.System
```

先验证一个 UUID 是否对应多个 System：

```sql
SELECT
    UUID,
    COUNT(DISTINCT TRIM(System)) AS SYSTEM_COUNT
FROM case_attributes_tbl_all
WHERE System IS NOT NULL
  AND TRIM(System) <> ''
GROUP BY UUID
HAVING COUNT(DISTINCT TRIM(System)) > 1;
```

结果无记录。

因此当前数据中：

> 一个 UUID 没有同时对应多个不同 System。

所以使用：

```sql
SELECT
    UUID,
    MAX(System) AS System
FROM case_attributes_tbl_all
GROUP BY UUID
```

作为 Join 前去重是安全的；`MAX(System)` 在这里并不是业务上“取最大 System”，只是从唯一 System 值中取出一个值，防止 Case Attribute 多行导致 Event Log Join 放大。

---

## 10.1 当前 System 结果

| System | 总数 | RPA | RPA 中人工介入 | 人工 |
|---|---:|---:|---:|---:|
| EBS | 11,214 | 3,997 | 931 | 7,217 |
| JDE | 9,724 | 7,523 | 1,838 | 2,201 |
| BLANK | 317 | 0 | 0 | 317 |
| 合计 | 21,255 | 11,520 | 2,769 | 9,735 |

交叉校验：

```text
EBS：3,997 + 7,217 = 11,214
JDE：7,523 + 2,201 = 9,724
BLANK：0 + 317 = 317

RPA：3,997 + 7,523 = 11,520
人工：7,217 + 2,201 + 317 = 9,735
RPA人工介入：931 + 1,838 = 2,769
```

这张表只覆盖当前 RPA / Manual Role 的 21,255 件，和 Phase2 总数 21,578 的差 323 件属于当前 Role 分类外对象。

---

## 10.2 BLANK 处理

SQL 中：

```sql
COALESCE(TRIM(attr.System), 'BLANK')
```

表示：

```text
System 有值 → 使用 System
System = NULL → BLANK
```

如果需要同时覆盖空字符串 `''`，更严谨的写法是：

```sql
CASE
    WHEN attr.System IS NULL
      OR TRIM(attr.System) = ''
    THEN 'BLANK'
    ELSE TRIM(attr.System)
END
```

这是本阶段又一个典型例子：不仅关心 SQL 能否运行，还要验证 NULL / 空字符串等边界是否影响业务统计。

---

# 11. Custom Widget 能力

由于 IPM 基础组件在展示行数、布局、分页等方面有一定限制，本阶段逐步使用 Custom Widget + ECharts `graphic` 自定义业务表格。

已实现/验证的方向包括：

- RPA / Manual 汇总表；
- 合并单元格效果；
- 处理方式 / Case 总数 / 明细 / 明细件数；
- EBS / JDE / BLANK 五列表；
- 自动计算合计行；
- IBM 风格浅灰蓝表头；
- 数字右对齐；
- RPA 蓝色强调；
- 保存图片按钮。

这说明对 IPM 的使用已经从：

> 只使用标准 Dashboard 控件

扩展到：

> 根据业务表达需要自行构建 Widget。

---

# 12. 业务沟通能力的提升

本阶段不只是技术分析，也持续与 Sara、团队成员沟通数据定义。

例如对外给出的 System 数据不再只扔一张 SQL 结果，而是整理为：

```text
EBS
总数：11,214
RPA：3,997
其中 RPA 有人工介入：931
人工：7,217

JDE
总数：9,724
RPA：7,523
其中 RPA 有人工介入：1,838
人工：2,201

System 为空
总数：317
RPA：0
人工：317
```

同时能够提前准备回答：

- 为什么合计不是 21,578？
- RPA 人工介入是不是等于 Re-Run？
- System 为什么可以 Group By？
- 一个 UUID 会不会同时属于 EBS 和 JDE？
- BLANK 是 NULL 还是空字符串？

这说明工作方式已经从“给数字”升级到：

> **给出可解释、可追溯、经得起追问的数字。**

---

# 13. 自我成长总结

## 13.1 从开发者思维走向 Process Analyst 思维

以前面对数据问题，更自然的关注点是：

```text
SQL 对不对？
程序能不能跑？
Excel 能不能匹配？
```

现在开始主动追问：

```text
这个 Case 为什么应该算人工？
这个指标代表 Event 还是 Case？
最终人工和过程中人工介入是不是一个概念？
这个 BLANK 到底是什么业务含义？
这个统计能不能向业务解释？
```

这是一种明显的角色升级。

---

## 13.2 从“对数”走向“建立可信口径”

前期大量时间花在：

- Excel 与 SQL 差 1 件、37 件、410 件；
- UUID 去重；
- DDD 排除；
- Tracker / Event Log 对齐；
- ChinaBot / ChinaBOT；
- 空格；
- NULL；
- 审批结束状态；
- 是否包含废弃删除；
- 一个 UUID 是否有多个 System。

这些并不是低价值工作。

它训练的是 Process Mining 最重要的底层能力之一：

> **Data Quality + Business Definition + Reconciliation**

只有底层口径可信，后面的 Simulation 和 Business Case 才有意义。

---

## 13.3 从 BI Dashboard 思维走向流程思维

早期分析很容易变成：

```text
饼图
柱图
TOP10
占比
分类
```

现在开始更重视：

```text
Case 怎么走？
在哪里绕路？
在哪里等待？
哪里发生 Rework？
哪里出现 Human Intervention？
理想路径和实际路径差在哪里？
```

这才是 Process Mining 相比传统 BI 更有价值的地方。

---

## 13.4 从“发现问题”走向“验证改善方案”

Simulation 带来的最大变化是：

以前只能说：

> 这里有问题。

现在可以继续说：

> 如果把重复意见征询降低到 5%，会怎么样？

> 如果 50% 的录入可以自动化，会怎么样？

> 如果两者同时做，会节省多少时间和成本？

这让分析链条变成：

```text
Discover
  ↓
Explain
  ↓
Quantify
  ↓
Simulate
  ↓
Recommend
```

这是一次非常实质的能力升级。

---

## 13.5 从“技术结果”走向“业务表达”

现在越来越关注：

- 给 Sara 的数字怎么写更容易理解；
- `MANUAL_直接录入` 是否需要换成“人工无额外处理”；
- `RPA_人工介入` 是否会被误解成严格 Re-Run；
- Showcase 第一页应该讲 Process，而不是堆分类；
- Simulation 的假设是否真实，而不是为了制造漂亮结果把执行时间设成 0。

这种变化意味着目标已经不只是“做出东西”，而是：

> **让业务相信这个分析，并愿意基于它采取行动。**

---

# 14. 当前已经形成的能力栈

经过这一阶段，已经形成一套比较完整的 IBM Process Mining 实战能力：

### 数据层

- Event Log / Case Attribute 建模；
- Excel / CSV 清洗；
- UUID 去重与 Join；
- SQL 统计与交叉验证；
- NULL / 空字符串 / 状态 /重复数据处理。

### Process Mining 层

- Process Map；
- Variant；
- Frequency；
- Model Coverage；
- Automation Attribute；
- Human Intervention 分析；
- Rework / Self-loop；
- Process Route 对比。

### 分析层

- RPA / Manual 分类；
- OCR Feedback Root Cause；
- Comments Mapping；
- PO / 合同 / 其他分类；
- EBS / JDE System 对比；
- Drill-down 分析。

### 改善层

- Simulation；
- Labor Availability；
- Activity Automation；
- Path Probability；
- Working Time；
- Cost Simulation；
- Potential Saving。

### 展示层

- IPM Dashboard；
- Custom Widget；
- ECharts Graphic；
- 自定义表格；
- 面向业务的 Storyline。

---

# 15. 下一阶段建议

下一阶段不建议继续无限增加分类图，而应该围绕三个问题推进：

1. **Where does human intervention happen?**  
   把 RPA 无人工介入、RPA 有人工介入、人工无额外处理、人工有额外处理放到同一 Process Story 中。

2. **Why does it happen?**  
   用 Comments / PO / Contract / QA / Inquiry 等作为 Drill-down 证据，而不是主故事本身。

3. **What happens if we improve it?**  
   用 Simulation 对减少 Rework、增加自动化、调整资源等场景做量化比较，并最终形成 Potential Saving。

最终希望 Showcase 能完整回答：

```text
现状是什么？
为什么会这样？
哪里值得改善？
改善后会发生什么？
价值有多大？
```

---

# 16. 当前阶段一句话总结

> 从最初读取 GitHub 文档、对齐 Excel 与 SQL，到现在能够定义 RPA/Manual/Human Intervention、理解 Process Map 指标、构建 Custom Widget，并通过 Simulation 量化改善方案，这个项目已经从“工具学习”进入了“用 Process Mining 解决真实业务问题”的阶段。
