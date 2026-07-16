# 2026-07-16 Comment Count 与可视化整理

## 1. 本次讨论重点

今天继续完善了 Phase2 人工 Activity 的 Comment 分析，重点解决以下问题：

- 区分 Comment 条数与涉及 Case 数
- 修正 `DISTINCT` 对 Comment 条数的影响
- 为表格增加 `COMMENT_COUNT`
- 将 Comments Detail 与 Tracker Comment 分开统计
- 设计三个饼图分别展示不同口径
- 优化图表标题，使业务用户可以一眼看懂
- 将 `SYSTEM` 分类从根因统计中排除

---

## 2. `DISTINCT` 的影响

原查询中使用：

```sql
SELECT DISTINCT
    UUID,
    COMMENT_SOURCE,
    COMMENT_CATEGORY
```

这会把同一个 UUID 下、同一分类的多条 Comment 压缩成一条。

例如：

```text
UUID=A, PO
UUID=A, PO
UUID=A, PO
UUID=A, PO
UUID=A, PO
```

使用 `DISTINCT` 后只剩一条，因此无法统计真实 Comment 条数。

正确口径应区分：

```text
COMMENT_COUNT = 5
CASE_COUNT    = 1
```

因此：

- `COMMENTS_DETAIL` 部分不使用 `DISTINCT`
- 外层使用 `COUNT(*)` 统计 Comment 条数
- 外层使用 `COUNT(DISTINCT UUID)` 统计涉及 Case 数
- `TRACKER_COMMENT` 部分继续保留 `DISTINCT`，避免 Eventlog 多行把 Case 级留言重复放大

---

## 3. 统一输出字段

当前表格建议输出：

```text
COMMENT_SOURCE
COMMENT_CATEGORY
COMMENT_COUNT
CASE_COUNT
CASE_PERCENT
```

含义如下：

- `COMMENT_COUNT`：该分类实际出现的留言条数
- `CASE_COUNT`：该分类涉及的去重 Case 数
- `CASE_PERCENT`：该分类涉及 Case 数 ÷ 对应人工 Activity 总 Case 数

其中：

```sql
COUNT(*) AS COMMENT_COUNT
```

```sql
COUNT(DISTINCT combined.UUID) AS CASE_COUNT
```

```sql
ROUND(
    COUNT(DISTINCT combined.UUID) * 100.0000
    / total.TOTAL_CASE_COUNT,
    2
)
```

---

## 4. Phase2 人工 Activity 范围

今天继续沿用现有 Phase2 人工判断口径：

1. 排除 `System = DDD`
2. Case 必须存在 `审批结束`
3. 排除 Eventlog RPA：
   - `ACTIVITY = 录入完成`
   - `RESOURCE IN ('ChinaBot', 'ChinaBOT')`
4. 排除 Tracker 补充 RPA：
   - `System <> DDD`
   - `TrackerStatus = 审批结束`
   - `IBMProcessor IN ('ChinaBot', 'ChinaBOT')`
5. 当前 Activity 必须由非空、非 ChinaBot 资源执行

同一套逻辑分别应用到：

- `录入完成`
- `意见征询`
- `OCR完成`

只需替换：

```sql
TRIM(eventlog.ACTIVITY) = '录入完成'
```

为对应 Activity 名称。

---

## 5. Comments Detail 分类

当前 Comments Detail 分类包括：

```text
BLANK
QA
RERUN
PO
RECEIVING
ACCEPTANCE
PREPAYMENT
ESIGN
BANK
CONTRACT
SYSTEM
OTHER
```

其中 `BLANK` 采用特殊逻辑：

- 如果某 Case 存在有效 Comment，则忽略同一 Case 的空白记录
- 只有该 Case 的 Comment 全部为空、空字符串或 `-` 时，才保留 `BLANK`

---

## 6. Tracker Comment 分类

Tracker 使用：

```text
case_attributes_tbl_all.Comment_Clean
```

当前英文分类包括：

```text
PREPAYMENT_CLEARED
NO_CLEARING_REQUIRED
SYSTEM_STATUS_HANDLING
INVOICE_REVERSAL_OR_VOID
SUPPLIER
RECEIVING_OR_ACCEPTANCE
PO_AMOUNT_OR_TAX
RETENTION_OR_FINAL_PAYMENT
INVOICE_POSTING
OTHER
```

分类顺序需要特别注意：

```text
SYSTEM_STATUS_HANDLING
```

必须放在普通 `作废` 分类之前，否则 `tracker点击作废` 会被归到：

```text
INVOICE_REVERSAL_OR_VOID
```

---

## 7. 三个饼图设计

为了让用户快速识别占比最高的分类，决定拆成三个饼图。

### 7.1 明细留言：留言条数分布

统计口径：

```text
COMMENTS_DETAIL
COMMENT_COUNT
```

推荐标题：

```text
明细留言：留言条数分布
```

说明：同一 Case 的多条留言会分别计数。

### 7.2 明细留言：涉及 Case 分布

统计口径：

```text
COMMENTS_DETAIL
CASE_COUNT
```

推荐标题：

```text
明细留言：涉及 Case 分布
```

说明：同一 Case 在同一分类中只计算一次，但同一 Case 可以同时属于多个分类。

### 7.3 Tracker 留言：涉及 Case 分布

统计口径：

```text
TRACKER_COMMENT
CASE_COUNT
```

推荐标题：

```text
Tracker 留言：涉及 Case 分布
```

Tracker `Comment_Clean` 是 Case 级字段，因此该图最接近互斥分类构成。

---

## 8. 图表展示注意点

不建议把以下三个指标同时放入一个柱状图：

```text
COMMENT_COUNT
CASE_COUNT
CASE_PERCENT
```

因为单位不同，用户不容易理解。

推荐做法：

- 表格保留全部指标
- 饼图只使用一个数值字段
- Comments Detail 与 Tracker Comment 分开显示
- 图表标题必须明确“留言条数”还是“涉及 Case 数”

---

## 9. 排除 `SYSTEM` 分类

业务判断认为 `SYSTEM` 更像状态说明，而不是人工介入根因，因此不再纳入根因统计。

建议在外层结果中排除：

```sql
WHERE combined.COMMENT_CATEGORY <> 'SYSTEM'
```

位置：

```sql
) combined

CROSS JOIN (
    ...
) total

WHERE combined.COMMENT_CATEGORY <> 'SYSTEM'

GROUP BY
    combined.COMMENT_SOURCE,
    combined.COMMENT_CATEGORY,
    total.TOTAL_CASE_COUNT
```

这样做的效果：

- `SYSTEM` 不再出现在表格和图表中
- 其他分类的 `COMMENT_COUNT`、`CASE_COUNT` 不变
- `CASE_PERCENT` 分母仍然保持全部对应人工 Activity Case 数

如果后续也不希望统计 Tracker 的系统状态说明，可以进一步排除：

```sql
WHERE combined.COMMENT_CATEGORY NOT IN (
    'SYSTEM',
    'SYSTEM_STATUS_HANDLING'
)
```

当前先只排除 Comments Detail 的 `SYSTEM`。

---

## 10. 当前分析解释口径

需要继续强调：

- Activity 与 Comment 是通过 UUID 做 Case 级关联
- 只能说明“该人工 Activity Case 中出现了哪些 Comment”
- 不能直接证明某一条 Comment 就是某次 Activity 的直接原因
- `COMMENT_COUNT` 用于看问题出现频率
- `CASE_COUNT` 用于看问题影响范围
- 根因优先级判断时，应优先参考 `CASE_COUNT`，同时辅以 `COMMENT_COUNT`
