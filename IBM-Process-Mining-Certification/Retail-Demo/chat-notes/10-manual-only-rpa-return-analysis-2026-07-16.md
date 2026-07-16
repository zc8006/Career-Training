# Phase2 纯人工 Case 未回流 RPA 分析（2026-07-16）

本文整理 2026-07-16 在 IBM Process Mining 中围绕以下问题完成的分析：

> 为什么部分 Case 最终由人工完成，而没有在人工修正后重新交回 RPA？

本轮分析不再仅依靠 Comment 语义猜测，而是采用 **RPA 与纯人工对照、流程前后路径、业务属性差异** 三类证据。

---

## 1. 分析口径

### 1.1 Phase2 RPA_PROCESS

满足以下任一条件：

1. Eventlog 中存在：
   - `ACTIVITY = '录入完成'`
   - `RESOURCE IN ('ChinaBot', 'ChinaBOT')`
2. Eventlog 未直接认定为机器人完成，但 Tracker 补充满足：
   - `TrackerStatus = '审批结束'`
   - `IBMProcessor IN ('ChinaBot', 'ChinaBOT')`
   - `System <> 'DDD'`

Eventlog RPA 优先，Tracker 仅作为补充，避免重复计数。

已验证：

```text
RPA_PROCESS = 11,520
```

### 1.2 Phase2 MANUAL_ONLY

满足：

- 存在人工执行的 `录入完成`
- Eventlog 中不存在 ChinaBot/ChinaBOT 的 `录入完成`
- Tracker 未补充认定为 ChinaBOT
- 排除 `System = 'DDD'`
- Case 中存在 `审批结束`

已验证：

```text
MANUAL_ONLY = 9,648
```

更严谨的含义是：

> 数据中没有记录到 RPA 成功完成“录入完成”，且最终存在人工“录入完成”。

不能据此百分之百证明机器人从未尝试，因为失败尝试可能没有生成“录入完成”事件。

---

## 2. Tracker 覆盖问题

以 `case_attributes_tbl_all` 为主表统计时，只得到：

```text
MANUAL_ONLY = 9,407
```

与完整口径相差：

```text
9,648 - 9,407 = 241
```

核对后确认：

```text
HAS_TRACKER_RECORD = 9,407
NO_TRACKER_RECORD  =   241
```

因此后续分析 Tracker 字段时必须：

```sql
以 eventlog Case 为主
LEFT JOIN case_attributes_tbl_all
```

不能直接从 `case_attributes_tbl_all` 出发，否则会漏掉 241 个纯人工 Case。

建议区分：

```text
NO_TRACKER_RECORD：整个 Tracker 表中没有 UUID
FIELD_BLANK：有 Tracker 记录，但目标字段为空
```

---

## 3. 为什么不能直接使用 HIGH / MEDIUM 恢复潜力

曾尝试根据 Comment 分类将 Case 标记为：

```text
HIGH
MEDIUM
LOW
REVIEW
```

例如把 `PO`、`RECEIVING`、`ACCEPTANCE`、`RERUN` 暂归为 HIGH。

但该规则只是基于 Comment 含义做出的业务假设，不能证明：

- Case 确实满足 RPA 输入条件；
- 人工修正后能够重新投递；
- 系统中存在回流机制；
- 某类 Comment 就是未回流的直接原因。

因此该结果不应作为正式结论。正确方法是：

```text
先做 RPA 与人工的大样本字段和流程对照
再用 Comment 解释已经发现的高人工率场景
```

---

## 4. POCompareResult：RPA 与人工对照

分析维度字段：

```text
case_attributes_tbl_all.POCompareResult
```

输出：

```text
PO_MATCH_RESULT
RPA_CASE_COUNT
MANUAL_CASE_COUNT
TOTAL_CASE_COUNT
MANUAL_RATE
```

核心指标：

```text
MANUAL_RATE = MANUAL_CASE_COUNT / TOTAL_CASE_COUNT
```

主要发现：

| POCompareResult | RPA | Manual | Total | Manual Rate |
|---|---:|---:|---:|---:|
| 金额匹配失败 | 0 | 383 | 383 | 100% |
| PO未收货或收货不足-单条 | 0 | 85 | 85 | 100% |
| 收货不足 | 0 | 59 | 59 | 100% |
| 供应商不匹配 | 0 | 40 | 40 | 100% |
| PO未收货或OU不一致 | 1 | 799 | 800 | 99.88% |
| BLANK（未拆分版本） | 7 | 3,218 | 3,225 | 99.78% |
| PO收货不足-单条 | 1 | 153 | 154 | 99.35% |
| PO下单不足 | 23 | 272 | 295 | 92.20% |
| PO可匹配-多条 | 138 | 559 | 697 | 80.20% |
| PO可匹配-等于多条其中一条 | 233 | 384 | 617 | 62.24% |
| PO可匹配-单条 | 3,589 | 2,193 | 5,782 | 37.93% |
| 金额匹配 | 1,523 | 292 | 1,815 | 16.09% |
| 类型匹配 | 3,080 | 347 | 3,427 | 10.13% |

阶段结论：

> PO、收货、供应商匹配失败与纯人工处理高度相关；匹配成功状态的人工率明显下降。

但只能说明高度相关，不能直接证明是流程规则阻止回流。

---

## 5. POResult：QA 结果对照

分析字段：

```text
case_attributes_tbl_all.POResult
```

主要结果：

| POResult | RPA | Manual | Total | Manual Rate |
|---|---:|---:|---:|---:|
| NO_TRACKER_RECORD | 0 | 241 | 241 | 100% |
| QA未通过:U | 0 | 2 | 2 | 100% |
| QA未通过:S | 2 | 9 | 11 | 81.82% |
| QA未通过:I | 71 | 195 | 266 | 73.31% |
| QA未通过:R | 9 | 24 | 33 | 72.73% |
| FIELD_BLANK | 3,997 | 8,057 | 12,054 | 66.84% |
| QA未通过:Q | 8 | 6 | 14 | 42.86% |
| QA未通过:E | 3 | 1 | 4 | 25% |
| QA已通过 | 7,430 | 1,113 | 8,543 | 13.03% |

阶段结论：

> QA 未通过或 POResult 缺失与人工处理高度相关；QA 已通过时，大多数 Case 由 RPA 完成。

---

## 6. OCRFeedback 的正确用法

字段：

```text
case_attributes_tbl_all.OCRFeedback
```

验证结果：

```text
HAS_VALUE = 23,955
```

在有 Tracker 记录的范围内没有 `FIELD_BLANK`。

原始 OCRFeedback 细分后，大量类别只出现在人工 Case 中，因此经常表现为：

```text
RPA_CASE_COUNT = 0
MANUAL_RATE = 100%
```

但这不一定说明 OCRFeedback 是前置阻断规则，因为它很可能是：

```text
发生异常 → 转人工 → 写入 OCRFeedback
正常 RPA → 不写该异常文本
```

所以 OCRFeedback 更适合回答：

> 纯人工 Case 的异常主要集中在哪些类型？

不适合单独用来证明：

> 人工修正后为什么没有回流 RPA？

### 6.1 OCRFeedback 归并方向

曾归并为：

```text
初始化读取
大于阈值/阈值
OU 配置错误
预付款场景
匹配失败
值或格式错误
EBS_OTHER
JDE_OTHER
NO_TRACKER_RECORD
OTHER
```

注意：OCRFeedback 可能是多个标签拼接形成的长字符串，`初始化读取` 可能只是基础标签，不一定代表错误。

---

## 7. 人工录入完成后的下一个 Activity

使用 `starttime` 和窗口函数 `LEAD()` 分析每个 Case 最后一次人工“录入完成”后的下一活动。

结果：

| NEXT_ACTIVITY | CASE_COUNT |
|---|---:|
| 审批结束 | 9,620 |
| 意见征询 | 13 |
| NO_NEXT_ACTIVITY | 4 |
| OCR待处理 | 4 |

主体占比：

```text
9,620 / 9,648 ≈ 99.7%
```

这是目前最关键的流程证据：

> 纯人工 Case 在人工完成“录入完成”后，几乎全部直接进入“审批结束”，没有出现重新投递或再次由 ChinaBot 完成“录入完成”的回流路径。

因此当前流程更像：

```text
异常或直接分配人工
→ 人工录入完成
→ 审批结束
```

而不是：

```text
异常
→ 人工修正
→ 重新投递 RPA
→ RPA录入完成
→ 审批结束
```

---

## 8. 人工录入完成前的上一个 Activity

使用 `LAG()` 分析最后一次人工“录入完成”之前的紧邻 Activity。

主要结果：

| PREVIOUS_ACTIVITY | CASE_COUNT |
|---|---:|
| NO_PREVIOUS_ACTIVITY | 4,791 |
| 意见征询 | 1,599 |
| OCR结果待查 | 659 |
| 录入中发生错误 | 489 |

最初怀疑 `NO_PREVIOUS_ACTIVITY` 可能由相同时间戳造成，但核对同一人工录入时间的事件数：

```text
同一时间只有 1 条事件：9,625 Case
同一时间有 2 条事件：23 Case
```

因此 `NO_PREVIOUS_ACTIVITY` 基本不是时间并列导致。

---

## 9. 只有两条事件的“直接人工”Case

对 `NO_PREVIOUS_ACTIVITY = 4,791` 的 Case 再统计整个 Case 的事件条数：

| EVENT_COUNT | CASE_COUNT |
|---:|---:|
| 2 | 4,761 |
| 3 | 8 |
| 4 | 17 |
| 5 | 2 |
| 6 | 3 |

合计：

```text
4,761 + 8 + 17 + 2 + 3 = 4,791
```

其中 4,761 个 Case 的完整日志只有两条事件，典型路径就是：

```text
人工录入完成 → 审批结束
```

这说明当前 Eventlog 中：

- 没有可见 OCR 前置活动；
- 没有可见 RPA 尝试；
- 没有异常处理过程；
- 没有回流机器人节点。

可能原因包括：

1. 业务规则在进入当前日志前已决定直接人工；
2. 上游直接分配给人工；
3. 自动化范围外，但没有记录对应 Activity；
4. 前置系统或机器人失败日志未被采集。

---

## 10. 直接人工 Case 的 ApplyType 分布

针对 4,761 个只有两条事件的直接人工 Case：

| ApplyType | Case Count | Case Percent |
|---|---:|---:|
| 电子发票（增值税专用发票） | 3,348 | 70.32% |
| 电子发票（普通发票） | 819 | 17.20% |
| FIELD_BLANK | 240 | 5.04% |
| 国外发票 | 124 | 2.60% |

仅看构成不能说明某类型天然容易人工，因为还需考虑该类型整体业务量。

---

## 11. ApplyType：RPA 与直接人工对照

对比 `RPA_PROCESS` 与 4,761 个“直接人工”Case：

| ApplyType | RPA | Direct Manual | Total | Direct Manual Rate |
|---|---:|---:|---:|---:|
| 电子发票（普通发票） | 8 | 819 | 827 | 99.03% |
| 数电纸票（样本很小） | 1 | 6 | 7 | 85.71% |
| FIELD_BLANK | 153 | 240 | 393 | 61.07% |
| 电子发票（增值税专用发票） | 11,348 | 3,348 | 14,696 | 22.78% |

重要结论：

> 电子普通发票几乎全部直接人工；电子增值税专用发票虽然直接人工数量最多，但主要是因为总体业务量大，其直接人工率只有 22.78%。

因此必须看“率”，不能只看数量。

---

## 12. 电子普通发票进一步核对

电子普通发票的 System 对照：

```text
System = EBS
RPA = 8
Direct Manual = 819
Direct Manual Rate = 99.03%
```

说明该场景集中在 EBS。

### 12.1 POCompareResult 对照

电子普通发票中：

| POCompareResult | RPA | Direct Manual | Direct Manual Rate |
|---|---:|---:|---:|
| FIELD_BLANK | 2 | 427 | 99.53% |
| PO可匹配-单条 | 6 | 186 | 96.88% |
| PO可匹配-多条 | 0 | 92 | 100% |
| PO可匹配-等于多条其中一条 | 0 | 58 | 100% |
| 服务PO多条等其他细分 | 0 | 45 | 100% |

这说明：

> 对电子普通发票来说，即使 PO 已经可匹配，仍几乎全部直接人工。

所以问题不主要是 PO 匹配失败，更可能与发票类型的自动化范围、EBS 流程配置或后续触发逻辑有关。

### 12.2 OCRFeedback 归并

819 个 EBS 电子普通发票直接人工 Case：

| OCR Category | Case Count | Percent |
|---|---:|---:|
| 初始化读取 | 504 | 61.54% |
| 大于阈值/阈值 | 300 | 36.63% |
| EBS_OTHER | 14 | 1.71% |
| 匹配失败/不匹配/异常 | 1 | 0.12% |

原始文本主要包括：

| OCRFeedback Detail | Case Count |
|---|---:|
| EBS_初始化读取_电子发票 | 487 |
| EBS_初始化读取_电子发票_大于阈值需检查 | 230 |
| 初始化读取 + 阈值 + 预付款相关 | 50 |
| 初始化读取 + 两种发票合并入账 + 阈值 | 9 |
| 初始化读取 + 预付款相关 | 7 |
| 初始化读取 + 两种发票合并入账 | 7 |
| 初始化读取 + 阈值 + 负数发票 | 4 |
| 初始化读取 + 负数发票 | 3 |

注意：

- `初始化读取_电子发票` 很可能是基础标签，不一定是异常；
- 真正需要业务确认的是阈值、预付款、合并入账、负数发票等附加标签；
- 不能把整个 OCRFeedback 字符串直接当成单一错误原因。

### 12.3 487 个初始化读取 Case

仅 `OCRFeedback = 'EBS_初始化读取_电子发票'` 的 487 个直接人工 Case，其 POCompareResult：

| POCompareResult | Case Count |
|---|---:|
| FIELD_BLANK | 364 |
| PO可匹配-单条 | 86 |
| PO可匹配-等于多条其中一条 | 26 |
| PO可匹配-多条 | 8 |
| 服务PO多条等其他 | 3 |

其中明确 PO 可匹配：

```text
86 + 26 + 8 = 120
```

但 487 属于较小样本，并且继续拆分容易进入死胡同。因此该组保留为业务会议中的案例，不再作为主分析线。

---

## 13. 当前最可靠的结论

### 13.1 流程事实

```text
纯人工总 Case：9,648
人工录入后直接审批结束：9,620（约 99.7%）
完整日志仅“人工录入完成 → 审批结束”：4,761
```

所以：

> 当前流程数据中几乎不存在“人工修正后重新交还 RPA”的回流路径。

### 13.2 业务属性差异

- PO、收货、供应商匹配失败与人工高度相关；
- QA 未通过或 POResult 缺失与人工高度相关；
- 电子普通发票在 EBS 中几乎全部直接人工；
- 电子增值税专票总体量大，但多数仍由 RPA 完成；
- 同一普通发票场景下，即使 PO 可匹配，仍几乎全部人工。

### 13.3 当前尚不能直接证明的内容

不能仅凭现有数据断言：

- 人工修正后一定可以重新进入 RPA；
- 某条 Comment 就是阻断回流的原因；
- `初始化读取` 就是错误；
- 电子普通发票一定不在 RPA 范围；
- 系统一定缺少回流机制。

更准确的表述是：

> 当前日志表现为人工接管后直接完成，未观察到回流节点；部分高人工率场景与 ApplyType、POCompareResult、POResult 强相关，需要业务确认其自动化范围与重新触发规则。

---

## 14. 后续主线

不要继续围绕 487、120 等小样本无限拆分。主线应回到大样本：

```text
整体流程事实
→ 人工后 99.7% 直接审批结束

大样本字段对照
→ ApplyType
→ POCompareResult
→ POResult

组合维度
→ ApplyType + POCompareResult
→ ApplyType + POResult
→ 仅保留 TOTAL_CASE_COUNT >= 50 的组合
```

推荐下一步输出：

```text
APPLY_TYPE
PO_COMPARE_RESULT
RPA_CASE_COUNT
DIRECT_MANUAL_CASE_COUNT
TOTAL_CASE_COUNT
DIRECT_MANUAL_RATE
```

并过滤：

```sql
HAVING COUNT(*) >= 50
```

这样可以识别“样本量大且直接人工率高”的真实业务场景，避免被少量个案误导。

---

## 15. 业务会议建议问题

1. 人工完成“录入完成”后，流程是否设计了重新提交 RPA 的入口？
2. 为什么 9,620 个 Case 人工录入后直接进入审批结束？
3. 4,761 个只有两条事件的 Case，是从一开始就直接分配人工，还是前置日志未采集？
4. 电子普通发票在 EBS 中是否属于 RPA 范围？
5. 为什么电子普通发票 PO 可匹配后仍几乎全部人工？
6. `POResult = FIELD_BLANK` 是否代表未执行校验、未写回结果，还是该场景不适用？
7. OCRFeedback 中的“初始化读取”是正常基础标签还是异常状态？
8. 阈值触发后，人工修正是否可以重新投递 RPA？

---

## 16. SQL 与实现注意事项

- IBM Process Mining Analytics 当前环境对 `WITH ... AS` 兼容性不稳定，优先使用嵌套子查询。
- 百分比尽量返回数值，不要在 SQL 中拼接 `%`。
- 最后一个 SELECT 字段后不要保留多余逗号。
- 事件顺序分析使用：
  - `LEAD()`：下一个 Activity
  - `LAG()`：上一个 Activity
  - `ROW_NUMBER()`：每个 Case 选择最后一次人工“录入完成”
- 仅按 `starttime` 排序时要检查同时间事件；本次只有 23 个 Case 存在同一人工录入时间多事件，不影响主体结论。
- 直接人工 Case 定义为：
  - 属于 MANUAL_ONLY
  - 整个 Case `COUNT(*) = 2`
- Tracker 属性分析必须从 eventlog Case 出发 `LEFT JOIN`，防止漏掉 241 个无 Tracker 记录的人工 Case。
