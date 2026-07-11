# IBM Process Mining 高级 SQL 记录

## 1. 数据库与查询引擎

IBM Process Mining 2.0.3 同时使用 PostgreSQL 和 MonetDB，但 Analytics 高级查询更接近 MonetDB 语法。不要默认完整 PostgreSQL 语法都可用。

已确认：

- CTE `WITH` 可以使用
- `SELECT *` 不允许，必须明确列名
- `CAST(... AS VARCHAR)` 在当前高级查询环境中不可用
- `ROUND()` 可用
- `||` 字符串拼接可用
- `RTRIM()` 可用
- Dashboard Filter 可继续应用到高级查询

## 2. 百分比计算

基础写法：

```sql
COUNT(DISTINCT comments_detail_tbl.UUID)
* 1.0
/ total.TotalCount
```

百分比最终保留和显示多少位小数，取决于 `ROUND` 的第二个参数。

例如：

```sql
ROUND(
    COUNT(DISTINCT comments_detail_tbl.UUID)
    * 100.000000
    / total.TotalCount,
    4
) AS Percent
```

这里：

- `ROUND(..., 4)` 表示保留并显示 4 位小数。
- `ROUND(..., 1)` 表示保留并显示 1 位小数。
- 小数位限制只与 `ROUND` 的位数参数有关，与 IPM 展示层无关。
- `100.000000` 可保证百分比表达式按小数参与计算，但不会决定最终显示几位；最终位数仍由 `ROUND` 控制。

如果需要带 `%`，可以使用：

```sql
ROUND(
    COUNT(DISTINCT comments_detail_tbl.UUID)
    * 100.000000
    / total.TotalCount,
    4
) || '%' AS Percent
```

注意：

- 拼接 `%` 后字段会成为文本。
- 文本百分比不能再作为数值排序或图表计算字段。
- 饼图最好只使用分类列和数值列，不要同时加入百分比文本列。

## 3. System 占比查询示例

```sql
SELECT
  case_attributes_tbl.System AS "SYSTEM",
  COUNT(DISTINCT comments_category_detail.UUID) AS CaseCount,
  ROUND(
      COUNT(DISTINCT comments_category_detail.UUID)
      * 100.000000
      / total.TotalCount,
      4
  ) AS Percent
FROM comments_category_detail
JOIN case_attributes_tbl
  ON comments_category_detail.UUID = case_attributes_tbl.UUID
JOIN (
  SELECT
    COUNT(DISTINCT comments_category_detail.UUID) AS TotalCount
  FROM comments_category_detail
  JOIN case_attributes_tbl
    ON comments_category_detail.UUID = case_attributes_tbl.UUID
  WHERE comments_category_detail.type = 'PO号'
) total
  ON 1 = 1
WHERE comments_category_detail.type = 'PO号'
GROUP BY
  case_attributes_tbl.System,
  total.TotalCount
ORDER BY
  CaseCount DESC
```

## 4. LIKE 分类与人工筛选

只统计人工操作：

```sql
comments_detail_tbl.Processor IS NOT NULL
AND comments_detail_tbl.Processor <> 'ChinaBot'
```

更改 PO 号的严格匹配可使用：

```sql
comments_detail_tbl.Status LIKE '更改PO,原PO号:%'
```

比 `LIKE '%PO%'` 更安全，因为后者会误匹配：

- PO 未收货
- PO 未过 QA
- PO 无预付款
- PO 对比结果

## 5. 饼图字段识别问题

高级查询返回多个字段时，IPM 有时无法正确识别分类字段。

最稳做法：外面再包一层，只输出两列：

```sql
SELECT TYPE, CNT
FROM (
    SELECT
        classified.CommentType AS TYPE,
        COUNT(*) AS CNT
    FROM (...分类逻辑...) classified
    GROUP BY classified.CommentType
) result
ORDER BY CNT DESC
```

饼图映射：

```text
TYPE = Category
CNT  = Value
```

## 6. 时间戳转换

`InputDate` 为毫秒时间戳。

转换日期：

```sql
sys.epoch(case_attributes_tbl.InputDate / 1000)
```

按月可使用：

```sql
EXTRACT(YEAR FROM sys.epoch(case_attributes_tbl.InputDate / 1000))
```

和：

```sql
EXTRACT(MONTH FROM sys.epoch(case_attributes_tbl.InputDate / 1000))
```

## 7. 已踩过的坑

- 不要假设 `TO_TIMESTAMP()`、`TO_CHAR()`、`CAST()` 一定可用。
- 不要用 `SUBSTRING()` 直接处理毫秒时间戳。
- 小数位只由 `ROUND(..., n)` 中的 `n` 决定。
- `100.000000` 不负责限制或增加显示位数；它只参与数值计算。
- 需要更高精度时，直接提高 `ROUND` 的位数，例如从 `ROUND(..., 1)` 改为 `ROUND(..., 4)`。
- 对于需要严格合计 100% 的场景，优先保留更多小数位，避免过早舍入造成显示合计偏差。
