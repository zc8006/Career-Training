# IBM Process Mining Phase2 Simulation Handoff & Growth Log

更新时间：2026-08-21 12:43 (+08:00)

> 本文用于新聊天窗口继续工作。重点记录 2026-08-20～2026-08-21 已确认的数据口径、EBS/JDE 拆分、IPM Simulation 成本/时间机制测试、当前正确的业务参数，以及下一步建议。

---

## 1. Phase2 当前核心口径

Phase2 总审批结束 Case：`21,578`。

当前按最终处理结果：

- RPA_PROCESS：`11,520`
- MANUAL_PROCESS：`9,735`
- 其他/未归入当前 RPA/MANUAL Role 分类：`323`

当前 Role 明细：

- `RPA_无人工介入`：`8,751`
- `RPA_人工介入`：`2,769`
- `MANUAL_直接录入`：`7,554`
- `MANUAL_有额外人工介入`：`2,181`

校验：

```text
8,751 + 2,769 = 11,520
7,554 + 2,181 = 9,735
11,520 + 9,735 = 21,255
21,578 - 21,255 = 323
```

对外建议用语：

- `RPA_人工介入`：建议说“RPA 中有人工介入的 Case”，不要直接等同全部严格意义上的 Re-run。
- `MANUAL_直接录入`：更准确解释为“人工无额外处理”，并不代表 Case 只有“录入完成 → 审批结束”两个 Activity。

---

## 2. EBS / JDE System 拆分结果

System 来源：`case_attributes_tbl_all.System`。

Eventlog 通过：

```text
eventlog.CASEID = case_attributes_tbl_all.UUID
```

进行关联。

已验证同一个 UUID 不存在多个不同 System：

```sql
SELECT UUID, COUNT(DISTINCT TRIM(System)) AS SYSTEM_COUNT
FROM case_attributes_tbl_all
WHERE System IS NOT NULL
  AND TRIM(System) <> ''
GROUP BY UUID
HAVING COUNT(DISTINCT TRIM(System)) > 1;
```

结果无数据，因此按 UUID 去重后取一个 System 是安全的。

当前 Role 口径下 System 分布：

| System | Total Case | RPA Case | RPA with Human Intervention | Manual Case |
|---|---:|---:|---:|---:|
| EBS | 11,214 | 3,997 | 931 | 7,217 |
| JDE | 9,724 | 7,523 | 1,838 | 2,201 |
| BLANK | 317 | 0 | 0 | 317 |
| Total | 21,255 | 11,520 | 2,769 | 9,735 |

校验：

```text
EBS: 3,997 + 7,217 = 11,214
JDE: 7,523 + 2,201 = 9,724
RPA: 3,997 + 7,523 = 11,520
RPA Human Intervention: 931 + 1,838 = 2,769
Manual: 7,217 + 2,201 + 317 = 9,735
```

注意：这张表覆盖的是当前 Role 已分类的 `21,255` Case，因此不是 Phase2 全部 `21,578`。

---

## 3. IPM Custom Widget 当前方向

已确认可以在 IPM Custom Widget 中使用 ECharts `graphic` 模拟表格样式。

当前两类表：

### 3.1 RPA / MANUAL 汇总表

目标结构：

```text
处理方式          Case总数      处理明细              明细件数
RPA_PROCESS       11,520       RPA_无人工介入          8,751
                               RPA_有人工介入          2,769
MANUAL_PROCESS     9,735       人工无额外处理           7,554
                               人工含额外处理           2,181
```

### 3.2 EBS / JDE System 表

目标结构：

```text
System | Case总数 | RPA Case数 | RPA人工介入 | 人工Case数
EBS      11,214      3,997        931          7,217
JDE       9,724      7,523      1,838          2,201
BLANK       317          0          0            317
合计      21,255     11,520      2,769          9,735
```

当前结论：System 表使用 5 列 JS，不应复用 RPA/MANUAL 4 列合并行 JS，否则会发生字段错位。

---

## 4. Sara 已确认的业务时间与成本参数

Sara 于 2026-08-20 / 2026-08-21 确认：

1. RPA 平均处理一个 Case：`1.5 分钟`，**包含 Rerun/人工介入后的平均值**。
2. Manual 平均处理一个 Case：
   - EBS：`11.9 分钟`
   - JDE：`7.4 分钟`
3. 平均人工成本：`80 CNY/hour`
4. 这些时间是 **平均操作时间，不包含等待时间**。

Sara 原意已经明确：

> 平均的时间，不包含等待时间，就是平均的操作时间。

因此：

- 不能把 11.9 / 7.4 / 1.5 当成整个端到端 Process Lead Time。
- Simulation 中应重点解释为 Working/Handling Time 和 Cost Saving。
- `Avg Process Time` 中大量小时/天级时间主要来自等待、队列、审批间隔等，不应拿它与 11.9 分钟直接比较。

---

## 5. EBS 50% Automation 的合理业务模型

EBS 人工对象：`7,217` Case。

As-Is：

```text
Manual handling time = 11.9 min / Case
Manual labor cost = 80 CNY / hour
```

单 Case 人工成本：

```text
11.9 / 60 × 80 ≈ 15.87 CNY / Case
```

如果模拟 50% 人工 Case 转为 RPA：

```text
50% Manual + 50% RPA
```

平均操作时间：

```text
0.5 × 11.9 + 0.5 × 1.5
= 6.7 min / Case
= 6 min 42 sec
```

平均人工成本：

```text
0.5 × 11.9 / 60 × 80
≈ 7.93 CNY / Case
```

因此，业务上合理的目标展示应是：

| Metric | As-Is | 50% Automation |
|---|---:|---:|
| Avg Handling Time | 11.9 min | 6.7 min |
| Avg Manual Cost | CNY 15.87 | CNY 7.93 |

RPA 自动资源成本当前按 `0 CNY/hour` 处理。

---

## 6. JDE 同类模型

JDE 人工对象：`2,201` Case。

参数：

```text
Manual handling time = 7.4 min / Case
RPA handling time = 1.5 min / Case
Manual labor cost = 80 CNY / hour
```

如果后续做 50% Automation：

```text
Avg Handling Time
= 0.5 × 7.4 + 0.5 × 1.5
= 4.45 min / Case
```

人工成本：

```text
0.5 × 7.4 / 60 × 80
≈ 4.93 CNY / Case
```

但 JDE 暂不继续，先把 EBS 做通。

---

## 7. IPM Simulation：已经实际验证出来的机制

这是本轮最重要的技术发现。

### 7.1 项目 Cost Settings 与 Simulation 右侧 To-Be 不是完全同一套计算状态

测试发现：

- 项目 Cost Settings 改动后，历史 Simulation 的 As-Is 左侧会跟随变化。
- 已创建的 Simulation 右侧结果可能保留其场景自身的执行时间/演变参数。
- 新建“什么都不改”的 Simulation，To-Be 成本曾直接显示 `0`。

这说明 Simulation 的 Future Scenario 对 Working Time / Execution Time 有自己的场景计算逻辑，不能简单认为它会原样继承 As-Is。

### 7.2 关键验证：Execution Time 会直接驱动成本

在新 Simulation 中：

- To-Be 原本 Cost = `0`
- 将 Activity Execution Time / Working Time 设置为 `1 minute`
- Manual Resource Cost = `80 CNY/hour`

结果：

```text
Avg Process Cost ≈ CNY 1.33
```

正好满足：

```text
1 / 60 × 80 = 1.33
```

因此已经明确：

> Simulation 右侧的成本与场景中的 Activity Working/Execution Time 直接相关。

### 7.3 Default Working Time 会作用于多个 Manual Activities

另一轮机制测试：

```text
Default Manual Working Time = 20 min
Default Automatic Working Time = 1 min
Manual Resource Cost = 80 CNY/hour
Automatic Resource Cost = 0
```

主 Variant 是两步：

```text
录入完成 → 审批结束
```

As-Is Avg Cost 约 `53.68 CNY`。

理论：

```text
20 min + 20 min = 40 min
40 / 60 × 80 = 53.33 CNY
```

与实际几乎完全一致。

结论：

> Default Manual Working Time 是“每个 Manual Activity”的默认时间，不是“每个 Case 总时间”。

所以不能把 Sara 的 `11.9 min / Case` 直接设成 Default Manual Working Time，否则一个 Case 有多个 Manual Activities 时会重复累计。

---

## 8. 关于 Avg Process Time 为什么不一定下降

Sara 给出的 11.9 / 7.4 / 1.5 分钟都是操作时间，不含等待。

IPM 页面上的：

```text
Avg Process Time = 16h / 17h / 1d ...
```

主要包含：

- Activity 之间的等待
- 审批等待
- 队列
- 服务时间
- 资源等待
- 其他端到端 elapsed time

因此：

```text
11.9 min → 1.5 min
```

即使是 50% 自动化，也只减少约：

```text
0.5 × (11.9 - 1.5)
= 5.2 min / Case
```

相对于十几个小时的端到端流程时间，页面上可能几乎看不出来。

所以当前 Showcase 更合理的重点是：

- Handling / Working Time Saving
- Manual Hours Saved
- Cost Saving
- Automation Opportunity

而不是强行要求端到端 Avg Process Time 大幅下降。

---

## 9. 当前 EBS Simulation 应该怎么继续

推荐新 Simulation 名称：

`EBS Manual-to-RPA Simulation - Updated`

或：

`EBS Manual-to-RPA Optimization Simulation`

Baseline：

```text
case_attributes_tbl_all.System = EBS
AND
Eventlog.Role IN (
  MANUAL_直接录入,
  MANUAL_有额外人工介入
)
```

如果只做主 Variant 展示，可先选最高频 2-step Variant：

```text
录入完成 → 审批结束
```

目前该 Variant 历史上出现过：

- 4,568 Case（某次 EBS baseline）
- 4,762 Case（另一版项目/过滤范围）

注意：不同项目版本/过滤器导致 Case 数略有变化，做正式结果时需固定一个项目和 baseline，不要跨版本混用。

### 建议的最终 Simulation 逻辑

1. 固定项目成本：Manual = `80 CNY/hour`，Automatic = `0`。
2. 不使用 Default Manual 11.9，因为会按 Activity 重复。
3. 如果 Simulation 无法直接表达 Case-level 50% 加权时间，可把 Future Scenario 的代表性 Working Time 设为：
   - `6 min 42 sec`（EBS 50% 加权后平均操作时间）
4. 对外解释：这是基于业务提供的 Case-level average handling time 做的 weighted simulation。
5. 不把等待时间变化作为本次主要收益。

如果使用 Automation Activity 的 Robot quota，则需要谨慎验证它是否引入额外容量/队列机制。若出现 Process Time 异常增加，不要直接作为业务结论，应优先核对场景内部资源容量和 execution time。

---

## 10. 本轮沟通成果

对 Sara 的数据请求已完成 EBS/JDE 拆分，并建议用以下方式回复：

```text
EBS
Total: 11,214
RPA: 3,997
RPA with human intervention: 931
Manual: 7,217

JDE
Total: 9,724
RPA: 7,523
RPA with human intervention: 1,838
Manual: 2,201

System BLANK
Total: 317
RPA: 0
Manual: 317
```

业务时间参数也已进一步确认，避免 Simulation 使用错误口径。

---

# 11. 自我成长总结

## 11.1 从“会做 Simulation”到“理解 Simulation 的计算机制”

本轮并不是简单把参数填进去，而是通过多轮对照实验逐步确认：

- Cost Settings 改动如何影响 As-Is；
- Future Scenario 为什么可能出现 0 成本；
- Working Time 如何影响 Cost；
- Default Working Time 是 Activity-level 而不是 Case-level；
- 为什么一个 2-step Manual Variant 会出现接近 `40 min × 80/hour` 的成本；
- 为什么端到端 Process Time 与人工操作时间不是一个概念。

这说明分析能力已经从“配置功能”进化到“验证系统机制”。

## 11.2 开始主动做反向校验，而不是接受系统输出

典型例子：

```text
Simulation Avg Cost = CNY 1.33
```

主动反推：

```text
1.33 / 80 × 60 ≈ 1 min
```

再如：

```text
Avg Cost ≈ 53.68
```

反推：

```text
53.68 / 80 × 60 ≈ 40 min
```

结合 2-step Variant，发现正好对应 `20 min + 20 min`。

这类反向校验非常重要，因为 Process Mining / Simulation 的输出很多时候“看起来合理”，但真正可信需要回到业务公式和数据定义。

## 11.3 从“想让结果好看”转向“结果必须能解释”

最初容易期待：

```text
自动化 → Process Time 一定大幅下降
```

但本轮已经意识到：

- Sara 给的是操作时间，不含等待；
- 自动化 11.9 → 1.5 min 主要改善的是 Working Time；
- 十几个小时的端到端 Lead Time 可能主要由等待/审批组成；
- 所以 Cost / Manual Hours 的改善比 Process Time 更可信。

这比为了 Showcase 强行制造漂亮数字更成熟。

## 11.4 从技术人员视角逐步走向 Process Analyst / Consultant 视角

目前已经开始同时考虑：

```text
技术口径
+ 数据质量
+ 业务定义
+ Simulation 假设
+ 结果验证
+ 对外解释
```

尤其是对 `11.9 min` 主动向 Sara 确认“是录入完成单步，还是整个 Case”，最终确认是“平均操作时间、不含等待”，这是一个非常典型的咨询/分析动作：

> 先确认业务定义，再建模型，而不是先建模型再硬解释结果。

---

## 12. 下一窗口直接从这里继续

新聊天窗口建议直接说：

> 继续 GitHub 里 `2026-08-21_simulation-handoff-and-growth.md` 的 EBS Simulation。现在要正式做 EBS 50% Manual-to-RPA Simulation，Sara 已确认人工 11.9 min/case、RPA 1.5 min/case、人工 80 CNY/hour，且时间不包含等待。

下一步优先任务：

1. 固定 EBS baseline / Variant；
2. 确认 Future Scenario 如何正确表达 50% weighted handling time；
3. 让 To-Be Cost 接近理论 `7.93 CNY/Case`；
4. 验证结果后，再做 JDE；
5. 最后把 EBS/JDE Potential Saving 做成 Showcase 可展示的业务结论。

---

## 13. 当前一句话总结

> 当前最重要的进展，不只是拿到了 Sara 的 EBS/JDE 时间与成本参数，而是已经通过实际试验摸清了 IPM Simulation 中 Working Time、Resource Cost、Activity-level 默认值与 Future Scenario 成本之间的关系；下一步要做的是把这些机制映射成一个可信、可解释、能经得起业务追问的 50% Manual-to-RPA 模拟结果。
