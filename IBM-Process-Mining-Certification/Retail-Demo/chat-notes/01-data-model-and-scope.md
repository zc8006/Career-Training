# 数据模型与分析范围

## 1. 核心数据表

### `case_attributes_tbl`

Case 级属性表，`UUID` 为主键。

主要字段：

- `UUID`
- `System`
- `OCRFeedback`
- `TrackerStatus`
- `ApplyStatus`
- `ApplyType`
- `PrepaymentResult`
- `ESignResult`
- `POResult`
- `POCompareResult`
- `ManualReviewResult`
- `ContractOrPO`
- `Comment_Clean`
- `IBMProcessor`
- `IBMSupervisor`
- `InputDate`

用途：

- 判断 Case 最终执行者和最终状态
- 结合 System、OCR、PO、签章、预付款等字段做业务分析
- 作为日期过滤和 Phase 划分依据

### `comments_detail_tbl`

Comment 明细表，一个 UUID 可以有多条记录。

主要字段：

- `UUID`
- `Status`
- `Data`
- `Processor`

用途：

- 保存人工或 BOT 产生的 Comment/Status 明细
- 识别中间人工介入痕迹
- 统计同一 Case 的多次人工操作
- 使用 `LIKE` 或 `CASE WHEN` 进行实时分类

### `comments_category_detail`

人工整理后的分类明细表。

主要字段：

- `UUID`
- `Status`
- `type`

用途：

- 分类统计与占比分析
- Top Status 分析
- 与 `case_attributes_tbl` 通过 UUID 关联

## 2. 推荐关系

```text
comments_category_detail.UUID
            ↓
case_attributes_tbl.UUID

comments_detail_tbl.UUID
            ↓
case_attributes_tbl.UUID
```

关系方向应确保 `case_attributes_tbl` 作为 Case 主表，其他表通过 UUID 关联。

## 3. 时间范围

当前数据主要存在两个阶段：

- Phase1：2024-07 至 2025-07
- Phase2：2025-10 至 2026-06-01
- 2025-08 至 2025-09 可作为过渡期单独分析

Comment 分类数据当前主要覆盖 Phase2，因此不要强行做 Phase1 与 Phase2 的 Comment 分类对比，除非确认 Phase1 明细完整。

## 4. 日期字段

`InputDate` 实际存储为 13 位毫秒时间戳，例如：

```text
1767779940000
```

在 IBM Process Mining 高级查询中，可用：

```sql
sys.epoch(case_attributes_tbl.InputDate / 1000)
```

按月统计示例：

```sql
EXTRACT(YEAR FROM sys.epoch(case_attributes_tbl.InputDate / 1000))
|| '-'
|| EXTRACT(MONTH FROM sys.epoch(case_attributes_tbl.InputDate / 1000))
```

## 5. 统计口径

### Comment 数

```sql
COUNT(*)
```

表示 Comment 明细记录数。

### Case 数

```sql
COUNT(DISTINCT UUID)
```

表示受影响的唯一 Case 数。

### 注意

- 一个 Case 可以有多个 Comment。
- 同一个 Case 也可能命中多个关键词。
- Dashboard 标题中不要把 `#Comment` 写成 `#Case`。
- 需要做互斥分类时，使用顺序明确的 `CASE WHEN`。
