# Phase1 / Phase2 RPA 判断与验证（2026-07-13～2026-07-14）

本文整理 2026-07-13（周一）至 2026-07-14（周二）的分析过程，包括 Excel 验证、Phase 切分、Phase1/Phase2 不同的 RPA 判断规则、Tracker 补充认定、DDD 排除、人工 Activity 分类、百分比计算及 Dashboard 展示口径。

## 1. 数据与 Phase 切分

### 1.1 Phase1 日期范围

Phase1 按 Case 的最早事件时间判断：

```text
Case_First_Date < 2025-08-01
```

即 Phase1 截止到 2025-07-31 23:59:59，不包含 2025-08-01。

完整 eventlog 需先按：

```text
UUID 升序
Data 升序
```

排序，再用 Excel 递推公式取得 Case 最早时间：

```excel
E2 = C2
E3 = IF(A3=A2,E2,C3)
```

Phase 判断：

```excel
=IF(E2<DATE(2025,8,1),"PHASE1","PHASE2")
```

### 1.2 Excel 验证方法

为避免几十万行使用整列 `COUNTIFS/SUMIFS` 导致 Excel 卡死，采用多 Sheet 分步验证：

```text
Raw_Data
Phase1_All_Events
Phase1_Flag
Case_Approval
Approved_Case_Events
Approved_Case_List
Summary
```

关键原则：

- 原始数据只保留为值，不重复修改。
- Phase 数据复制到新 Sheet 时使用“选择性粘贴 → 值”。
- Event 明细统计与 Case 去重统计必须分开。
- 每个 UUID 最终只在 Case 级清单中统计一次。

Phase1 最终 Excel 与 IPM 验证一致：

```text
BOT_PROCESS             9,142
MANUAL_INTERVENTION     9,099
合计                   18,241
```

## 2. Phase1 RPA 判断规则

### 2.1 分析母体

只统计 Case 中存在：

```text
ACTIVITY = 审批结束
```

### 2.2 RPA 与人工判断

Phase1 关注“整个流程过程中是否出现人工介入”。

正常审批活动：

```text
审批结束
审批拒绝
```

不纳入人工介入判断。

#### BOT_PROCESS

除审批活动外，所有 Activity 均由：

```text
ChinaBot / ChinaBOT
```

执行。

#### MANUAL_INTERVENTION

除审批活动外，只要存在一条：

```text
RESOURCE 非空
AND RESOURCE NOT IN ('ChinaBot','ChinaBOT')
```

即认定为人工介入。

即使最后“录入完成”由 ChinaBot 执行，只要中间出现人工 Activity，仍归类为 `MANUAL_INTERVENTION`。

### 2.3 Phase1 总体 SQL

```sql
SELECT
    result.ACCOUNT_TYPE,
    COUNT(*) AS CASE_COUNT
FROM (
    SELECT
        eventlog.CASEID,
        CASE
            WHEN SUM(
                CASE
                    WHEN eventlog.ACTIVITY NOT IN (
                        '审批结束',
                        '审批拒绝'
                    )
                    AND eventlog.RESOURCE IS NOT NULL
                    AND eventlog.RESOURCE NOT IN (
                        'ChinaBot',
                        'ChinaBOT'
                    )
                    THEN 1
                    ELSE 0
                END
            ) = 0
            THEN 'BOT_PROCESS'
            ELSE 'MANUAL_INTERVENTION'
        END AS ACCOUNT_TYPE
    FROM eventlog
    WHERE eventlog.CASEID IN (
        SELECT DISTINCT CASEID
        FROM eventlog
        WHERE ACTIVITY = '审批结束'
    )
    GROUP BY eventlog.CASEID
) result
GROUP BY result.ACCOUNT_TYPE
ORDER BY CASE_COUNT DESC
```

## 3. Phase2 RPA 判断规则

Phase2 与 Phase1 的业务判断不同。Phase2 关注“最终是否由 RPA 完成”。

### 3.1 分析母体

Phase2 只统计：

- Case 中存在 `审批结束`；
- 排除 `System = DDD`；
- 当前 Phase2 时间范围内的 Case。

### 3.2 Eventlog 直接认定 RPA

Case 中存在：

```text
ACTIVITY = 录入完成
RESOURCE IN ('ChinaBot','ChinaBOT')
```

即认定为 `RPA_PROCESS`。

即使中途曾有人工作业，只要最终回到 RPA，由 ChinaBot 执行“录入完成”，仍算 RPA。

### 3.3 Tracker 补充认定 RPA

在 `case_attributes_tbl_all` 中同时满足：

```text
System <> DDD
TrackerStatus = 审批结束
IBMProcessor IN ('ChinaBOT','ChinaBot')
```

则补充认定为 `RPA_PROCESS`。

总表中的 `CASE WHEN` 按顺序判断：

1. 先判断 Eventlog RPA；
2. 再判断 Tracker RPA；
3. 再判断人工；
4. 最后进入未确认。

因此同一 Case 同时满足 Eventlog 和 Tracker 时，只会命中第一条，不会重复计数。Tracker 只补充 Eventlog 未认定的 Case。

### 3.4 Phase2 最终结果

```text
Event RPA               2,652
Tracker 补充 RPA        8,868
RPA_PROCESS 合计       11,520
MANUAL_PROCESS          9,735
执行方式未确认            323
总 Case                21,578
```

校验：

```text
2,652 + 8,868 = 11,520
11,520 + 9,735 + 323 = 21,578
```

### 3.5 323 个未确认 Case

这些 Case 同时满足：

- 非 DDD；
- 有审批结束；
- 没有 ChinaBot 执行“录入完成”；
- Tracker 不满足补充 RPA 条件；
- 没有明确审批外人工 Activity。

因此不能直接判为人工，也不能直接判为 RPA，保留为“执行方式未确认”。

## 4. Phase1 与 Phase2 的主要差异

| 项目 | Phase1 | Phase2 |
|---|---|---|
| 判断重点 | 是否全流程由 RPA 执行 | 是否最终由 RPA 完成 |
| 中途出现人工 | 直接判人工介入 | 仍可能最终判为 RPA |
| Event RPA 条件 | 审批外所有 Activity 均为 ChinaBot | ChinaBot 执行“录入完成” |
| Tracker 补充规则 | 无 | TrackerStatus=审批结束 且 IBMProcessor=ChinaBOT |
| DDD | 当前规则不排除 | 整个 Case 排除 |
| 最终分类 | BOT_PROCESS / MANUAL_INTERVENTION | RPA_PROCESS / MANUAL_PROCESS / 未确认 |

一句话总结：

```text
Phase1 看过程中有没有人工；Phase2 看最终是不是 RPA 完成。
```

## 5. 人工 Activity 分类

### 5.1 Phase1 人工 Activity 分布

母体为全部 `MANUAL_INTERVENTION` Case（9,099 件），按人工执行的 Activity 统计涉及的去重 Case 数：

```text
录入完成      6,875
OCR完成       2,576
OCR待处理       126
RPA范围外        78
意见征询          4
```

### 5.2 Phase2 人工 Activity 分布

母体为明确人工 Case（9,735 件），排除 DDD、Event RPA、Tracker RPA 后，按人工 Activity 统计：

```text
录入完成      9,648
意见征询      1,788
OCR完成         510
废弃删除         54
OCR待处理         6
RPA范围外         2
```

注意：

- 同一 Case 可能包含多个 Activity；
- 每个 Activity 行使用 `COUNT(DISTINCT CASEID)`；
- 各 Activity 的 Case 数不能直接相加作为去重 Case 总数；
- Activity 百分比应解释为“人工 Case 覆盖率”，合计可能超过 100%。

## 6. 百分比计算

### 6.1 SQL 返回普通数字百分比

```sql
ROUND(
    COUNT(*) * 100.0000 / total.TOTAL_COUNT,
    2
) AS CASE_PERCENT
```

返回：

```text
50.12
49.88
```

此时 IPM 展示格式应设置为普通数字；若再设置为百分比，界面会显示为 5,012%。

### 6.2 SQL 返回小数比例

若 IPM 展示层使用百分比格式，应返回：

```sql
ROUND(
    COUNT(*) * 1.0000 / total.TOTAL_COUNT,
    4
) AS CASE_PERCENT
```

返回：

```text
0.5012
0.4988
```

界面显示为：

```text
50.12%
49.88%
```

### 6.3 动态分母

Activity 覆盖率使用动态分母：

```sql
total.TOTAL_MANUAL_CASE_COUNT
```

Phase1 分母为全部 `MANUAL_INTERVENTION` Case；Phase2 分母为明确的 `MANUAL_PROCESS` Case，不包含 323 个未确认 Case。

## 7. Dashboard 建议标题

```text
Phase1 RPA 全流程执行情况
Phase2 RPA 完成情况
Phase1 人工参与 Activity 分布
Phase2 人工参与 Activity 分布
```

说明文本建议强调：

- Phase1 与 Phase2 使用不同判断口径；
- Phase1 看是否出现人工介入；
- Phase2 看最终是否由 RPA 完成；
- Phase2 中 Tracker 只承担补充认定作用；
- Activity 覆盖率允许超过 100%。

## 8. 已确认的 SQL / IPM 注意点

- Analytics 高级 SQL 为 MonetDB 风格。
- 多层 CTE 在当前环境中可能报通用错误，必要时拆成多个卡片或简化子查询。
- `CASE WHEN` 从上到下匹配，首个命中条件生效。
- `GROUP BY CASEID` 后每个 Case 只统计一次。
- `NOT IN` 可用于排除 DDD；当前 UUID 为主键且两侧不为空，不存在 NULL 风险。
- 字段可能有尾部空格时使用 `TRIM()`。
- `COUNT(DISTINCT CASEID)` 用于 Case 数，`COUNT(*)` 常对应事件行数。
- Excel 与 IPM 对账时必须保持 Phase、审批结束、DDD、RPA 判定母体完全一致。
