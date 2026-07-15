# Comment 与 Tracker 留言分析（2026-07-15）

本文整理 2026-07-15 的分析过程，重点包括：Phase2 未确认 Case 明细、人工 Activity 与 Comment 的关联口径、Comments detail 分类、NO_COMMENT/BLANK 区分、Excel 对账，以及 Tracker `Comment_Clean` 的分类与合并展示。

## 1. Phase2 未确认 Case（323 件）

Phase2 总体分类结果：

```text
RPA_PROCESS       11,520
MANUAL_PROCESS     9,735
执行方式未确认       323
合计              21,578
```

323 件的定义：

- 非 DDD；
- 有 `审批结束`；
- 没有 ChinaBot 执行 `录入完成`；
- Tracker 不满足补充 RPA 条件；
- 没有明确审批外人工 Activity。

列出 323 个 Case 的完整 Event 明细时，`IN (...)` 子查询内部不能写 `ORDER BY`，排序只保留在最外层。

## 2. Activity 与 Comment 的正确口径

不能仅凭 UUID 关联就说某一条 Comment 是某一个 Activity 的直接原因。

当前可确认的是 Case 级关联：

```text
人工 Case
+ Activity = 录入完成 / OCR完成 / 意见征询
+ 查看同一个 UUID 在 Comments detail 中出现过的 Comment
```

因此表名建议写成：

```text
人工 Activity 与 Comment 分类关联分布
```

而不是直接写成“Activity 原因分布”。若后续要建立更强的对应关系，需要利用：

```text
eventlog.STARTTIME
comments_detail_tbl.Data
```

寻找 Activity 前后最近的 Comment。

## 3. Comments detail 分类规则

当前分类基于 `comments_detail_tbl.Status`，并保持 `CASE WHEN` 顺序互斥：

```sql
CASE
    WHEN Status IS NULL
      OR TRIM(Status) = ''
      OR TRIM(Status) = '-'
        THEN 'BLANK'

    WHEN Status LIKE '%QA%'
        THEN 'QA'

    WHEN Status LIKE '%RERUN%'
      OR Status LIKE '%rerun%'
        THEN 'RERUN'

    WHEN Status LIKE '%PO号%'
      OR Status LIKE '%PO对比%'
      OR Status LIKE '%PO结果%'
      OR Status LIKE '%单价匹配%'
      OR Status LIKE '%金额匹配%'
        THEN 'PO'

    WHEN Status LIKE '%收货%'
      OR Status LIKE '%Receiving%'
      OR Status LIKE '%receiving%'
        THEN 'RECEIVING'

    WHEN Status LIKE '%验收%'
        THEN 'ACCEPTANCE'

    WHEN Status LIKE '%预付款%'
      OR Status LIKE '%核销%'
        THEN 'PREPAYMENT'

    WHEN Status LIKE '%电子签章%'
      OR Status LIKE '%签章%'
        THEN 'ESIGN'

    WHEN Status LIKE '%银行账号%'
      OR Status LIKE '%收款账号%'
        THEN 'BANK'

    WHEN Status LIKE '%合同%'
        THEN 'CONTRACT'

    WHEN Status LIKE '%系统%'
        THEN 'SYSTEM'

    ELSE 'OTHER'
END
```

### PO 分类扩展原因

原来只匹配 `%PO号%`，导致大量内容落入 OTHER，例如：

```text
PO对比-
PO结果-
PO对比-金额匹配
```

因此扩展为：

```text
PO号
PO对比
PO结果
单价匹配
金额匹配
```

## 4. BLANK 与 NO_COMMENT 的区别

### BLANK

Comments detail 中存在这个 UUID，但该 Case 的所有 Status 都是：

```text
NULL
空字符串
-
```

### NO_COMMENT

Comments detail 中完全不存在这个 UUID。

这两个分类必须分开：

```text
NO_COMMENT：根本没有 Comments detail 记录
BLANK：有记录，但没有有效文字 Comment
```

### 空白处理优化

若一个 Case 同时有空白 Comment 和有效 Comment：

```text
忽略空白，只保留有效 Comment 分类
```

只有全部 Comment 都为空时，才归入 BLANK。

SQL 核心逻辑：

```sql
AND (
    (
        Status IS NOT NULL
        AND TRIM(Status) <> ''
        AND TRIM(Status) <> '-'
    )
    OR
    (
        (
            Status IS NULL
            OR TRIM(Status) = ''
            OR TRIM(Status) = '-'
        )
        AND NOT EXISTS (
            SELECT 1
            FROM comments_detail_tbl c2
            WHERE c2.UUID = comments_detail_tbl.UUID
              AND c2.Status IS NOT NULL
              AND TRIM(c2.Status) <> ''
              AND TRIM(c2.Status) <> '-'
        )
    )
)
```

要把 NO_COMMENT 放进同一张表，必须：

```text
先建立 Activity Case 母体
LEFT JOIN comments_detail_tbl
```

不能从 `comments_detail_tbl` 直接作为主表开始，否则没有 Comment 的 Case 会直接消失。

## 5. Phase2 人工录入完成 Comment 分布

Phase2 人工 `录入完成` Case 总数：

```text
9,648
```

当前分类覆盖结果：

```text
PO          3,810   39.49%
BLANK       3,553   36.83%
ESIGN       2,197   22.77%
SYSTEM      1,929   19.99%
OTHER         733    7.60%
RECEIVING     484    5.02%
PREPAYMENT    422    4.37%
QA            330    3.42%
ACCEPTANCE    229    2.37%
CONTRACT      173    1.79%
RERUN         102    1.06%
BANK           44    0.46%
```

这些是 Case 覆盖率：

```text
COUNT(DISTINCT UUID) / 人工录入完成总 Case
```

同一个 Case 可同时属于多个有效分类，所以各分类比例合计可能超过 100%。

## 6. 一个 Activity 一张表

为了减少误解，决定不把所有 Activity 混在一张表，而是分别建立：

```text
Phase2 人工录入完成 Comment 分类
Phase2 人工 OCR完成 Comment 分类
Phase2 人工意见征询 Comment 分类
```

切换 Activity 时，分子和分母中的两处条件必须同时修改：

```sql
TRIM(eventlog.ACTIVITY) = '录入完成'
```

改为：

```sql
TRIM(eventlog.ACTIVITY) = 'OCR完成'
```

或：

```sql
TRIM(eventlog.ACTIVITY) = '意见征询'
```

分母必须使用当前 Activity 的人工去重 Case 数，不能除以全部 Phase2 Case。

## 7. Excel 验证方法

### 7.1 Phase1 人工录入完成验证

Excel 筛选与去重结果：

```text
IPM：6,875
Excel：6,872
差异：3
差异率约：0.04%
```

判定为基本一致。

### 7.2 Excel 必须使用 Case 粒度

筛选后的事件行数不能直接与 IPM Case 数对比：

```text
7,082 = 人工录入完成事件行数
约 6,872 = 去重 UUID 数
```

必须按 UUID 去重。

### 7.3 Comment 存在状态

对去重 UUID 建立：

```text
COMMENT_RECORD_COUNT
VALID_COMMENT_COUNT
COMMENT_STATUS
```

Excel 公式：

```excel
=COUNTIF('Comments detail'!$A:$A,A2)
```

有效 Comment 数：

```excel
=SUMPRODUCT(
 ('Comments detail'!$A$2:$A$100000=A2)*
 (LEN(TRIM('Comments detail'!$B$2:$B$100000))>0)*
 (TRIM('Comments detail'!$B$2:$B$100000)<>"-")
)
```

状态：

```excel
=IF(E2=0,"NO_COMMENT",IF(F2=0,"BLANK","HAS_COMMENT"))
```

### 7.4 分类验证

建立 `Comments分类` Sheet：

```text
A：UUID
B：Status
C：分类
```

再建立 Case 级分类验证表，每个分类一列，公式：

```excel
=IF(COUNTIFS(Comments分类!$A:$A,$A2,Comments分类!$C:$C,E$1)>0,1,0)
```

注意分类标题必须引用当前列，例如 E 列应使用 `E$1`，不能误写成 `B$1`。

Phase1 PO 验证：

```text
Excel：232
IPM：231
```

差异 1 件，基本一致。

## 8. Phase2 Excel 验证必须关联 Tracker

Phase2 不能仅筛：

```text
Processor 非 ChinaBot
Has_Approval_End = 1
```

还必须：

- 关联 Tracker；
- 排除 `System = DDD`；
- 排除 Eventlog RPA；
- 排除 Tracker 补充 RPA。

建议新增：

```text
System
TrackerStatus
IBMProcessor
TRACKER_RPA
EVENT_RPA
PHASE2_MANUAL
```

Tracker RPA 规则：

```excel
=IF(
 AND(
  TRIM(System)<>"DDD",
  TRIM(TrackerStatus)="审批结束",
  OR(TRIM(IBMProcessor)="ChinaBot",TRIM(IBMProcessor)="ChinaBOT")
 ),
 1,
 0
)
```

最终筛选：

```text
System <> DDD
Has_Approval_End = 1
EVENT_RPA = 0
TRACKER_RPA = 0
Status = 录入完成
Processor 非空且非 ChinaBot
```

再按 UUID 去重，目标接近 9,648。

## 9. Tracker Comment_Clean 分析

Tracker 留言字段确认是：

```text
case_attributes_tbl_all.Comment_Clean
```

只看有效留言：

```sql
Comment_Clean IS NOT NULL
AND TRIM(Comment_Clean) <> ''
AND TRIM(Comment_Clean) <> '-'
```

对当前导出的有效留言：

```text
原始 150 行
去重 UUID 144 件
重复 6 行
```

建议分类英文：

```text
预付款已核销        PREPAYMENT_CLEARED
无需核销/无预付款   NO_CLEARING_REQUIRED
发票红冲/作废       INVOICE_REVERSAL_OR_VOID
供应商              SUPPLIER
收货/验收           RECEIVING_OR_ACCEPTANCE
PO/金额/税率        PO_AMOUNT_OR_TAX
质保金/尾款         RETENTION_OR_FINAL_PAYMENT
发票入账            INVOICE_POSTING
系统状态处理        SYSTEM_STATUS_HANDLING
其他                OTHER
```

## 10. Comments detail 与 Tracker 留言合并展示

两个来源可以放在同一张表，但必须保留来源列：

```text
COMMENT_SOURCE
COMMENT_CATEGORY
CASE_COUNT
CASE_PERCENT
```

来源：

```text
COMMENTS_DETAIL
TRACKER_COMMENT
```

SQL 使用：

```sql
UNION ALL
```

统一分母使用当前 Activity 的全部人工 Case，例如：

```text
Phase2 人工录入完成：9,648
Phase2 人工意见征询：1,788
```

不要让 Tracker 部分单独使用 144 作为分母，否则无法与 Comments detail 横向比较。

示例结果：

```text
COMMENTS_DETAIL | PO                    | 3,810 | 39.49%
TRACKER_COMMENT | PREPAYMENT_CLEARED    |    77 | 0.80%
TRACKER_COMMENT | NO_CLEARING_REQUIRED  |    42 | 0.44%
```

## 11. 当前业务发现

- Phase2 人工录入完成 Case 中，PO 类 Comment 覆盖率最高，接近 40%。
- 仍有较高比例 Case 没有有效 Comments detail 内容，BLANK 约 36.83%。
- Tracker 有效留言数量不多，但内容高度集中于预付款核销相关问题。
- Tracker 留言可以作为 Comments detail 的补充证据，但必须保留来源，不能直接混成同一字段口径。
- 当前分析属于 Case 级共现分析；若要说明 Activity 的直接原因，下一步应增加时间邻近匹配。
