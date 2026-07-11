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

使用系统的百分比类型时，如果 SQL 本身只保留较少小数，页面就只会显示对应精度，因此多项显示值相加时可能出现 99.9% 或 99.998% 的情况。

当前稳定写法：

```sql
RTRIM(
    ROUND(
        COUNT(DISTINCT comments_detail_tbl.UUID)
        * 100.0
        / total.TotalCount,
        1
    ),
    0
) || '%' AS Percent
```

### 提高计算与展示精度

已验证可以通过增加乘数的小数位并提高 `ROUND` 精度，让查询结果直接保留并显示更多小数：

```sql
ROUND(
    COUNT(DISTINCT comments_detail_tbl.UUID)
    * 100.000000
    / total.TotalCount,
    4
) AS Percent
```

说明：

- `100.000000` 用于提高表达式的数值精度。
- `ROUND(..., 4)` 保留并显示 4 位小数。
- IPM 展示层本身不会额外限制小数位；最终显示精度主要由 SQL 返回值和度量格式决定。
- 如果需要带 `%`，可以使用 `|| '%'` 拼接。

注意：

- 拼接 `%` 后字段会成为文本。
- 文本百分比不能再作为数值排序或图表计算字段。
- 饼图最好只使用分类列和数值列，不要同时加入百分比文本列。

## 3. System 占比查询示例

```sql
SELECT
  case_attributes_tbl.System AS "SYSTEM",
  COUNT(DISTINCT comments_category_detail.UUID) AS CaseCount,
  RTRIM(
    ROUND(
      COUNT(DISTINCT comments_category_detail.UUID)
      * 100.0
      / total.TotalCount,
      1
    ),
    0
  ) || '%' AS Percent
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
- 如果需要更多小数位，应直接提高 SQL 中的数值精度和 `ROUND` 位数。
- `100.000000` 配合 `ROUND(..., 4)` 可以同时提高计算精度和显示精度。
- 对于需要严格合计 100% 的场景，先确认各行原始精度，再决定是否保留更多小数或做显示层校正。
