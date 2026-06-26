# IBM Process Mining：Retail Status Phase2 FullBot Ratio 下降原因分析

日期：2026-06-25

项目：`Retail_Status_Process_Test (IBM_Retail_Demo)`

分析目标：解释为什么 Phase2 的「审批状态以外全是机器人 Case / FullBot Ratio」低于 Phase1，并整理当前在 IBM Process Mining 里的复现口径、过滤器、SQL 条件、Dashboard 结果和后续排查方向。

---

## 1. 核心业务口径

业务预期：

> 审批状态以外，理论上应该由机器人处理。

因此分析中的关键概念是：

| 概念 | 含义 |
|---|---|
| 审批状态 | `审批结束`、`审批拒绝` |
| 非审批状态 | 除 `审批结束`、`审批拒绝` 以外的活动 |
| 人工参与 | `resource` 属于人工账号清单 |
| 非审批人工参与 | `resource IN (人工账号清单)` 且 `ACTIVITY NOT IN ('审批结束','审批拒绝')` |
| FullBot Case | 审批状态以外没有人工参与的 case |

关键 SQL 逻辑：

```sql
resource IN (
  'CNVITA05',
  'AIUQMU5',
  'CNVISX26',
  'CNVISY83',
  'CNVISP97',
  'CNVISQ00',
  'CNVISX63',
  'CNVISP93',
  'CNVRAB54',
  'cnvisx92'
)
AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
```

这段表示：

> 找出审批状态以外，由人工账号参与过的事件 / case。

如果要算 FullBot，则是它的补集：

```sql
caseid NOT IN (
  SELECT caseid
  FROM eventlog
  WHERE resource IN (
    'CNVITA05',
    'AIUQMU5',
    'CNVISX26',
    'CNVISY83',
    'CNVISP97',
    'CNVISQ00',
    'CNVISX63',
    'CNVISP93',
    'CNVRAB54',
    'cnvisx92'
  )
  AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
)
```

含义：

> 排除所有“审批状态以外有人参与”的 case，剩下就是“审批状态以外全是机器人”的 case。

---

## 2. Phase 过滤口径

### 2.1 Phase1

已复现目标：

| 指标 | 数值 |
|---|---:|
| Phase1 Total Cases | 19,610 |
| Avg Process Time | 4d 14h |

口径：

```text
LAST_EVENT_TIME >= 2024-11-11T00:00:00.000Z
LAST_EVENT_TIME < 2025-08-01T00:00:00.000Z
不排除 running cases
```

注意：Phase1 Total 不是按普通 eventDate 过滤得到，而是按 case 的最后事件时间 `LAST_EVENT_TIME` 归属 Phase。

### 2.2 Phase2

旧资料目标：

| 指标 | 旧资料 |
|---|---:|
| Phase2 Total Cases | 24,706 |
| Phase2 FullBot Cases | 8,526 |
| Phase2 FullBot Ratio | 34.51% |

当前 IPM 使用口径：

```text
LAST_EVENT_TIME >= 2025-10-01T00:00:00.000Z
LAST_EVENT_TIME < 2026-06-01T00:00:00.000Z
```

当前 Not DDD 后的 Total：

| 指标 | 当前值 |
|---|---:|
| Phase2 Not DDD Total Cases | 21,715 |

---

## 3. Case 属性表导入与连接

新增导入表：`tracker_case_attributes`

主要字段：

| 字段 | 用途 |
|---|---|
| UUID | 与 `eventlog.caseid` 对应的 case key |
| System | 系统来源，例如 EBS / JDE / DDD |
| OCRFeedback | OCR 反馈 / 业务反馈类型 |
| TrackerStatus | tracker 状态 |
| Message | 留言 |
| MailUID | 邮件 UID |
| MailSubject | 邮件主题 |
| ApplyStatus | 申请状态 |
| ApplyType | 申请类型 |
| PrepaymentResult | 预付款结果 |
| ESignResult | 电子签章结果 |
| POResult | PO 结果 |
| POCompareResult | PO 对比结果 |
| ManualReviewResult | 人工审核结果 |
| ContractOrPO | 合同号或采购订单 |
| IBMProcessor | IBM Processor |
| IBMSupervisor | IBM Supervisor |
| Term | TERM 日期 |

表连接：

```text
eventlog.caseid = tracker_case_attributes.UUID
```

注意事项：

- `CleanApplyDate` 不作为正式分析字段，因为它是后处理生成字段。
- IPM CSV 上传要求 UTF-8；Excel 的“CSV UTF-8”有时仍可能导致解析问题，需要检查分隔符、引号、换行和特殊字符。
- `tracker_case_attributes` 作为 case 属性表时，部分 dashboard 过滤器可能不能稳定传递，因此深挖表中建议用表内 SQL 明确写 `System != 'DDD'`。

---

## 4. Dashboard 与组件设计

当前已拆成三个层级：

| Dashboard | 作用 |
|---|---|
| `Template - Compare Dashboard` | 总览对比 Phase1 / Phase2 |
| `Phase2比例下降原因拆解` | Activity + 来源拆解 |
| `AIUQMU5账号影响分析` | 账号维度深挖 |

---

## 5. Phase1 vs Phase2 Not DDD：Activity 维度结果

修正账号清单后，当前对比结果：

| Activity | Phase1 Cases | Phase1 % | Phase2 Not DDD Cases | Phase2 Not DDD % | 变化 |
|---|---:|---:|---:|---:|---:|
| 录入完成 | 6,802 | 34.69% | 8,868 | 40.84% | +2,066 / +6.15pt |
| 意见征询 | 0 | 0% | 3,562 | 16.40% | 新增 +16.40pt |
| OCR完成 | 2,560 | 13.05% | 1,828 | 8.42% | -732 / -4.63pt |
| 废弃删除 | 0 | 0% | 1,827 | 8.41% | 新增 +8.41pt |
| OCR待处理 | 126 | 0.64% | 5 | 0.02% | 下降 |
| RPA范围外 | 81 | 0.41% | 1 | 0.00% | 下降 |

阶段性结论：

> Phase2 FullBot Ratio 下降，主要不是 DDD 本身造成的，而是 Phase2 Not DDD 中，审批状态以外的人工参与显著增加。增加最明显的活动是：`录入完成`、`意见征询`、`废弃删除`。

需要注意：不同 Activity 之间可能存在 case 重叠，因此各项百分比不能简单相加作为独立贡献，但方向非常明确。

---

## 6. 重点活动来源拆解

### 6.1 意见征询来源

组件设置：

```text
From = tracker_case_attributes
维度 = OCRFeedback, System
度量 = COUNT(DISTINCT UUID)
表头过滤器 = Phase2 2025/10...
表内过滤器 = AIUQMU5/人工账号 + ACTIVITY = '意见征询' + System != DDD
```

过滤器示例：

```sql
UUID IN (
  SELECT caseid
  FROM eventlog
  WHERE resource IN (
    'CNVITA05','AIUQMU5','CNVISX26','CNVISY83','CNVISP97',
    'CNVISQ00','CNVISX63','CNVISP93','CNVRAB54','cnvisx92'
  )
  AND ACTIVITY = '意见征询'
)
AND System != 'DDD'
AND OCRFeedback NOT LIKE 'DDD%'
```

可见 Top 来源：

| OCRFeedback | System | Cases |
|---|---|---:|
| JDE | JDE | 1,551 |
| EBS_大于阈值需检查 | EBS | 591 |
| EBS | EBS | 187 |
| JDE_重试3此均不可录入 | JDE | 115 |

结论：

> 意见征询主要来自 JDE，其次是 EBS_大于阈值需检查。

### 6.2 废弃删除来源

可见 Top 来源：

| OCRFeedback | System | Cases |
|---|---|---:|
| JDE_初始化读取_其他_疑_税额/发票... | JDE | 87 |
| EBS_初始化读取_其他_疑_税额/发票... | EBS | 37 |
| EBS | EBS | 35 |
| EBS_多PO_税额/发票日期_大于阈值... | EBS | 34 |

注意：此表有滚动条，截图中的 Top 行不能代表全部来源。

结论：

> 从当前可见行看，废弃删除与 EBS/JDE 初始化读取异常、税额/发票信息异常、多 PO 等场景有关，但需要用汇总层级进一步验证。

### 6.3 录入完成来源

可见 Top 来源：

| OCRFeedback | System | Cases |
|---|---|---:|
| EBS_大于阈值需检查 | EBS | 2,308 |
| JDE | JDE | 730 |
| EBS | EBS | 665 |
| EBS_初始化读取_电子发票 | EBS | 501 |

结论：

> 录入完成的人工参与主要来自 EBS_大于阈值需检查，其次是 JDE、普通 EBS、EBS 初始化读取电子发票。

---

## 7. 人工账号贡献拆解

组件：`人工账号贡献拆解`

口径：

```sql
resource IN ('CNVITA05','AIUQMU5','CNVISX26','CNVISY83','CNVISP97','CNVISQ00','CNVISX63','CNVISP93','CNVRAB54','cnvisx92')
AND ACTIVITY IN ('录入完成','意见征询','废弃删除')
```

表头过滤器：`not DDD Phase2 2025/10...`

结果：

| Activity | Resource | Cases | % of Total |
|---|---|---:|---:|
| 录入完成 | AIUQMU5 | 4,722 | 21.75% |
| 录入完成 | CNVISP97 | 4,064 | 18.72% |
| 意见征询 | AIUQMU5 | 2,015 / 2,016 | 9.28% |
| 废弃删除 | AIUQMU5 | 1,093 | 5.03% |

结论：

> Phase2 Not DDD 的关键非审批人工参与主要集中在 AIUQMU5 和 CNVISP97。其中 AIUQMU5 在多个关键活动中都占比较高，是 Phase2 FullBot Ratio 下降的核心账号来源之一。

关键待确认：

> AIUQMU5 到底是不是人工账号？

如果 AIUQMU5 是人工账号，则 Phase2 Ratio 下降结论成立；如果 AIUQMU5 是系统/机器人账号，则需从人工账号清单中移除并重新计算 FullBot Ratio。

---

## 8. AIUQMU5 账号影响分析

### 8.1 AIUQMU5 Activity 分布

口径：

```sql
resource = 'AIUQMU5'
AND ACTIVITY NOT IN ('审批结束','审批拒绝')
```

表头过滤器：`not DDD Phase2 2025/10...`

结果：

| Activity | Cases | % of Total |
|---|---:|---:|
| 录入完成 | 4,722 | 21.75% |
| 意见征询 | 2,016 | 9.28% |
| 废弃删除 | 1,093 | 5.03% |
| OCR完成 | 906 | 4.17% |

结论：

> AIUQMU5 是 Phase2 Not DDD 中非审批人工参与的最大来源之一，尤其集中在录入完成、意见征询、废弃删除和 OCR完成。

### 8.2 AIUQMU5 来源拆解 by System + OCRFeedback + POCompareResult

口径：

```sql
UUID IN (
  SELECT caseid
  FROM eventlog
  WHERE resource = 'AIUQMU5'
  AND ACTIVITY NOT IN ('审批结束','审批拒绝')
)
AND System != 'DDD'
AND OCRFeedback NOT LIKE 'DDD%'
```

表头过滤器：`Phase2 2025/10...`

可见 Top 来源：

| System | OCRFeedback | POCompareResult | Cases |
|---|---|---|---:|
| EBS | EBS_大于阈值需检查 | PO可匹配-单条 | 543 |
| EBS | EBS_大于阈值需检查 | - | 469 |
| EBS | EBS_大于阈值需检查_... | PO可匹配-单条 | 426 |
| JDE | JDE | 单价匹配 | 392 |
| EBS | EBS_初始化读取_其他_疑... | - | 329 |
| JDE | JDE | 类型匹配 | 257 |
| JDE | JDE OU未定义_税额 | PO未收货或OU不一致 | 254 |
| JDE | JDE | 金额匹配失败 | 251 |

注意：该表有滚动条，截图只代表可见 Top 行，不能直接当作全量排名。

阶段性结论：

> 从当前可见结果看，AIUQMU5 的大量参与集中在 EBS_大于阈值需检查、JDE、EBS 初始化读取异常、JDE PO/金额/OU 匹配异常等类型。它不像随机分布，更像是进入了特定业务规则或异常处理分支。

---

## 9. 重要字段与后续可挖因素

从 case 属性文档中，后续还可以继续挖：

| 字段 | 可回答的问题 |
|---|---|
| System | 是 EBS / JDE 哪个系统拉低 FullBot Ratio？ |
| OCRFeedback | 哪类 OCR/业务反馈导致人工参与？ |
| POCompareResult | 是单价匹配、类型匹配、金额匹配失败、OU 不一致等哪类 PO 条件导致？ |
| POResult | QA已通过等结果是否仍然出现人工参与？ |
| ApplyType | 电子发票、DD 等申请类型是否不同？ |
| PrepaymentResult | 是否预付款场景更容易触发人工？ |
| ESignResult | 电子签章已完成 / 无需签章是否有差异？ |
| IBMProcessor | Processor 是 ChinaBOT 还是人工账号？ |
| IBMSupervisor | Supervisor 是否集中在某些人工账号？ |
| 入账时间 / 审批时间 | 是否存在人工参与导致周期变长？ |
| Message | 是否有留言导致人工介入？ |
| MailSubject | 邮件主题能否归类出系统/业务异常？ |

样本提示：

```text
申请类型 = 电子发票（增值税专用发票）
预付款结果 = 非预付款供应商
电子签章结果 = 电子签章已完成
PO结果 = QA已通过
OCR反馈 = JDE
PO对比结果 = 单价匹配
IBM Processor = ChinaBOT
IBM Supervisor = CNVISY83
Status = 审批结束
System = JDE
```

该样本说明：

> 即使 Processor 是 ChinaBOT、最终审批由人工 Supervisor 完成，仍需检查该 case 在审批前是否有 AIUQMU5 / CNVISP97 等账号参与了录入完成、意见征询、OCR完成、废弃删除等非审批活动。

---

## 10. 推荐下一步分析

### 10.1 先做汇总层，不要直接看滚动明细表

建议新增两张汇总表：

#### AIUQMU5 by System

```text
System | # Cases | % of Total
```

#### AIUQMU5 by OCRFeedback

```text
OCRFeedback | # Cases
```

这样先判断 AIUQMU5 主要来自 EBS 还是 JDE，以及 Top OCRFeedback。

### 10.2 按 Activity 分别拆 AIUQMU5 来源

复制 `AIUQMU5 来源拆解 by System + OCRFeedback + POCompareResult`，分别做：

| 表 | 子查询条件 |
|---|---|
| AIUQMU5 录入完成来源 | `AND ACTIVITY = '录入完成'` |
| AIUQMU5 意见征询来源 | `AND ACTIVITY = '意见征询'` |
| AIUQMU5 废弃删除来源 | `AND ACTIVITY = '废弃删除'` |
| AIUQMU5 OCR完成来源 | `AND ACTIVITY = 'OCR完成'` |

目标是验证：

```text
AIUQMU5 在录入完成上主要处理 EBS_大于阈值需检查？
AIUQMU5 在意见征询上主要处理 JDE？
AIUQMU5 在废弃删除上主要处理 EBS/JDE 初始化读取异常？
```

### 10.3 确认 AIUQMU5 账号性质

这是当前最关键的业务确认点：

```text
AIUQMU5 是人工账号、系统账号、机器人账号，还是自动化 fallback 账号？
```

结论分支：

| 判断 | 后续动作 |
|---|---|
| AIUQMU5 是人工账号 | Phase2 Ratio 下降主要由 AIUQMU5 非审批状态参与造成 |
| AIUQMU5 是机器人/系统账号 | 当前人工账号清单错误，需要移除 AIUQMU5 并重新计算 FullBot Ratio |
| AIUQMU5 是半自动/fallback 账号 | 需要单独定义为特殊类别，不应简单归入人工或机器人 |

---

## 11. 可直接放 Dashboard 的结论文案

```html
<center><h4>Phase2 FullBot Ratio 下降原因总结</h4></center>

<p><b>结论：</b>排除 DDD 后，Phase2 的 FullBot Ratio 仍明显低于 Phase1。主要原因不是 DDD 本身，而是 Phase2 非 DDD case 中，审批状态以外出现了更多人工账号参与。</p>

<p><b>主要变化点：</b></p>

<ol>
  <li><b>录入完成</b>：8,868 cases，占 Phase2 Not DDD 的 <b>40.84%</b>。</li>
  <li><b>意见征询</b>：3,562 cases，占 Phase2 Not DDD 的 <b>16.40%</b>。</li>
  <li><b>废弃删除</b>：1,827 cases，占 Phase2 Not DDD 的 <b>8.41%</b>。</li>
</ol>

<p><b>账号层面：</b>AIUQMU5 是 Phase2 非审批人工参与的核心来源之一，尤其集中在录入完成、意见征询、废弃删除和 OCR完成。</p>

<p><b>最终判断：</b>如果 AIUQMU5 确认为人工账号，则 Phase2 FullBot Ratio 下降主要由该账号在非审批状态下的大量参与造成。若 AIUQMU5 实际为系统/机器人账号，则需要调整人工账号清单并重新计算 FullBot Ratio。</p>
```

---

## 12. 关键风险与注意事项

1. `AIUQMU5` 拼写必须统一，不能写成 `AIQMU5`、`AIQU5` 或 `AIUQU5`。
2. `tracker_case_attributes` 表上的 dashboard filter 传递不一定稳定，必要时在表内 SQL 明确写 `System != 'DDD'`。
3. 日期过滤不建议写进组件 SQL；Phase 仍通过 dashboard / component filter 使用已验证的 `LAST_EVENT_TIME` 口径。
4. 滚动表的截图只能代表可见 Top 行，不能代表全量结论。
5. 多 Activity 之间可能存在 case 重叠，百分比不能简单相加作为独立贡献。
6. 最终结论依赖 AIUQMU5 账号属性确认。

---

## 13. 关键账号对比 Dashboard 最新进展

### 13.1 分析目的与页面结构

新增 Dashboard：`关键账号对比`。

分析目的：

> 验证 Phase2 FullBot Ratio 下降过程中，AIUQMU5 和 CNVISP97 是否处理同一类业务场景，还是分别集中在不同系统、活动和 OCRFeedback。

当前页面保留三类组件：

| 组件 | 作用 |
|---|---|
| 关键账号 Activity + System 对比 | 判断两个账号分别集中在哪个系统和活动 |
| 关键账号 OCRFeedback 对比 | 判断两个账号分别集中在哪类业务反馈 |
| 录入完成 × EBS大于阈值账号对比 | 验证特定交叉场景的账号 Case 数 |

页面过滤口径：

```text
Phase2：LAST_EVENT_TIME >= 2025-10-01T00:00:00.000Z
        LAST_EVENT_TIME < 2026-06-01T00:00:00.000Z
排除 DDD
非审批活动：ACTIVITY NOT IN ('审批结束','审批拒绝')
```

### 13.2 Activity + System 对比结果

当前可见主要结果：

| Resource | System | Activity | Cases |
|---|---|---|---:|
| AIUQMU5 | EBS | 录入完成 | 3,802 |
| CNVISP97 | EBS | 录入完成 | 3,021 |
| CNVISP97 | JDE | 录入完成 | 1,043 |
| AIUQMU5 | JDE | 意见征询 | 1,023 |
| AIUQMU5 | EBS | 意见征询 | 991 |
| AIUQMU5 | JDE | 录入完成 | 920 |
| CNVISP97 | JDE | 意见征询 | 588 |
| CNVISP97 | EBS | 意见征询 | 415 |
| CNVISP97 | EBS | 废弃删除 | 393 |
| AIUQMU5 | JDE | 废弃删除 | 231 |
| CNVISP97 | EBS | OCR完成 | 154 |
| AIUQMU5 | JDE | OCR完成 | 151 |
| CNVISP97 | JDE | 废弃删除 | 89 |
| CNVISP97 | JDE | OCR完成 | 77 |
| CNVISP97 | JDE | OCR待处理 | 1 |

阶段性判断：

- 两个账号都大量参与 `EBS + 录入完成`，AIUQMU5 数量更高。
- AIUQMU5 在意见征询中的参与更明显，且同时覆盖 JDE 和 EBS。
- CNVISP97 更集中于录入完成，但也参与意见征询、废弃删除和 OCR完成。
- 当前结果支持“两个账号均对非审批人工参与有明显贡献”，但尚不能把不同 Activity 的 Case 数直接相加，因为同一 Case 可能出现在多个 Activity 中。

### 13.3 OCRFeedback 对比结果

当前可见主要结果：

| Resource | OCRFeedback | Cases |
|---|---|---:|
| AIUQMU5 | EBS_大于阈值需检查 | 1,327 |
| AIUQMU5 | JDE | 1,213 |
| CNVISP97 | EBS_大于阈值需检查 | 1,059 |
| CNVISP97 | JDE | 870 |
| AIUQMU5 | EBS_大于阈值需检查_凭证抵扣Y | 431 |
| AIUQMU5 | EBS | 428 |
| AIUQMU5 | EBS_初始化读取_其他_疑_税额/发票... | 323 |
| CNVISP97 | EBS_初始化读取_电子发票 | 275 |
| CNVISP97 | EBS | 273 |
| CNVISP97 | JDE_JDE OU未定义_税额 | 263 |
| AIUQMU5 | JDE_JDE OU未定义_税额 | 259 |
| AIUQMU5 | EBS_初始化读取_电子发票 | 247 |

阶段性判断：

> 两个账号的主要业务来源高度重合，均集中于 `EBS_大于阈值需检查` 和 `JDE`。这更像是特定业务规则或异常处理分支导致账号参与，而不是随机出现。

### 13.4 三组数字的口径关系

当前 Dashboard 中存在三组容易混淆的数字：

| Resource | EBS + 录入完成（全部反馈） | EBS_大于阈值需检查（全部非审批活动） | 两条件交集：录入完成 + EBS_大于阈值需检查 |
|---|---:|---:|---:|
| AIUQMU5 | 3,802 | 1,327 | 1,250 |
| CNVISP97 | 3,021 | 1,059 | 1,020 |

正确解释：

- `3,802 / 3,021`：EBS 系统中“录入完成”的全部 Case，不限定 OCRFeedback。
- `1,327 / 1,059`：OCRFeedback 为“EBS_大于阈值需检查”的全部非审批活动 Case，不限定 Activity。
- `1,250 / 1,020`：同时满足“录入完成 + EBS_大于阈值需检查”的交集 Case。

差额：

```text
AIUQMU5：1,327 - 1,250 = 77
CNVISP97：1,059 - 1,020 = 39
```

这些差额 Case 属于 `EBS_大于阈值需检查`，但未落入对应账号的“录入完成”交集。

底部组件建议使用准确标题：

```text
录入完成 × EBS大于阈值账号对比
```

不要使用“最大来源账号验证”，因为该组件验证的是一个特定交叉场景，并非全局最大来源。

---

## 14. 下一步：计算两个关键账号的去重 Case 与重叠

### 14.1 为什么必须做去重

Activity 表中的 Case 可能重复。例如，同一个 Case 可能同时经历：

```text
录入完成
意见征询
废弃删除
OCR完成
```

因此不能把各 Activity 的 Cases 简单相加。下一步需要新增四个单值 KPI，计算两个账号影响的去重 Case 及交集。

所有 KPI：

```text
From = eventlog
度量 = COUNT(DISTINCT caseid)
表头过滤器 = Phase2 Not DDD（2025/10—2026/05）
```

### 14.2 KPI 1：至少一个关键账号参与

标题：

```text
至少一个关键账号参与
```

过滤器：

```sql
resource IN ('AIUQMU5', 'CNVISP97')
AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
```

### 14.3 KPI 2：两个账号共同参与

标题：

```text
两个账号共同参与
```

过滤器：

```sql
caseid IN (
  SELECT caseid
  FROM eventlog
  WHERE resource = 'AIUQMU5'
    AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
)
AND caseid IN (
  SELECT caseid
  FROM eventlog
  WHERE resource = 'CNVISP97'
    AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
)
```

### 14.4 KPI 3：仅 AIUQMU5 参与

标题：

```text
仅 AIUQMU5 参与（两个关键账号中）
```

过滤器：

```sql
caseid IN (
  SELECT caseid
  FROM eventlog
  WHERE resource = 'AIUQMU5'
    AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
)
AND caseid NOT IN (
  SELECT caseid
  FROM eventlog
  WHERE resource = 'CNVISP97'
    AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
)
```

### 14.5 KPI 4：仅 CNVISP97 参与

标题：

```text
仅 CNVISP97 参与（两个关键账号中）
```

过滤器：

```sql
caseid IN (
  SELECT caseid
  FROM eventlog
  WHERE resource = 'CNVISP97'
    AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
)
AND caseid NOT IN (
  SELECT caseid
  FROM eventlog
  WHERE resource = 'AIUQMU5'
    AND ACTIVITY NOT IN ('审批结束', '审批拒绝')
)
```

### 14.6 校验公式

四个 KPI 完成后必须满足：

```text
仅 AIUQMU5
+ 仅 CNVISP97
+ 两个账号共同参与
= 至少一个关键账号参与
```

注意：

> 这里的“仅 AIUQMU5 / 仅 CNVISP97”只表示两个关键账号中只有一个出现，不代表 Case 中没有其他人工账号。

---

## 15. 最终结论前仍需完成的判断

### 15.1 确认账号性质

必须向业务方确认：

```text
AIUQMU5 是人工账号、机器人账号、系统账号，还是半自动/fallback 账号？
CNVISP97 是人工账号、机器人账号、系统账号，还是半自动/fallback 账号？
```

### 15.2 去重账号参与不等于可恢复的 FullBot Case

“至少一个关键账号参与”的 Case 数表示两个账号的覆盖范围，但不能直接当作：

```text
移除两个账号后新增的 FullBot Cases
```

因为部分 Case 还可能存在其他人工账号的非审批活动。

若两个账号被确认是机器人/系统账号，最终还需要重算：

> 将 AIUQMU5 / CNVISP97 从人工账号清单中移除后，仍无任何其他人工账号参与的去重 Case 数，以及新的 FullBot Cases / FullBot Ratio。

### 15.3 新窗口续接顺序

新窗口应按以下顺序继续：

1. 先创建“至少一个关键账号参与”KPI并确认数字。
2. 再创建“两个账号共同参与”“仅 AIUQMU5”“仅 CNVISP97”三个 KPI。
3. 使用校验公式确认四个 KPI 口径一致。
4. 确认 AIUQMU5、CNVISP97 的真实账号属性。
5. 根据账号属性决定是否调整人工账号清单并重新计算 FullBot Ratio。
