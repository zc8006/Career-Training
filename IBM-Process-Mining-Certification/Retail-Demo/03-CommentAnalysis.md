# IBM Retail Demo - Comment 分类分析

## 目标

本页用于分析 BOT 完成流程中，人工备注/人工介入的主要原因。重点回答：

- 人工备注主要集中在哪些分类？
- 哪些 Comment 类型占比最高？
- 哪些原始 Status / Comment 最常出现？
- 后续如何结合 Case、System、OCR Feedback、RERUN 做根因分析？

---

## 当前数据表设计

### 1. `case_attributes_tbl`

Case 属性表。

关键字段：

- `UUID`：主键 / Case ID
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

用途：

- Case 级别分析
- 人工介入判断
- 与流程、系统、OCR、PO、RERUN 等维度结合

---

### 2. `comments_detail_tbl`

原始 Comment 明细表。

关键字段：

- `UUID`
- `Status`
- `Data`
- `Processor`

用途：

- 保存全量 Comment / Status 明细
- 一个 UUID 可以对应多条 Comment 记录
- 用于判断明细侧人工参与

---

### 3. `comment_category_tbl`

去重后的分类字典表。

字段：

- `Status`：清洗后的备注/状态内容，主键
- `Type`：人工分类

用途：

- 作为分类字典
- 维护 `Status -> Type` 的分类映射
- 适合后续人工补充、修正分类规则

---

### 4. `comment_category_detail_tbl`

不去重的分类明细表。

字段：

- `ID`：唯一主键，必须有
- `Status`
- `type`

用途：

- Comment 分类件数统计
- 分类占比分析
- LIKE / 模糊分类探索
- Top Status 分析

注意：这张表必须保留不去重明细，因为它代表真实出现次数。

---

## 推荐数据模型关系

```text
comment_category_detail_tbl.ID        主键
comment_category_detail_tbl.Status
        ↓
comment_category_tbl.Status           主键
        ↓
comments_detail_tbl.Status
        ↓
comments_detail_tbl.UUID
        ↓
case_attributes_tbl.UUID              主键
```

说明：

- `comment_category_detail_tbl` 用于分类出现次数分析。
- `comment_category_tbl` 用于字典维护。
- `comments_detail_tbl` 用于原始 Comment 明细。
- `case_attributes_tbl` 用于 Case 级别业务分析。

---

## Dashboard 页面：Comment分类分析

### 页面名称

```text
Comment分类分析
```

---

## 已完成组件

### 1. Type 分类统计表

组件类型：表 / Table

配置：

```text
From: comments_category_detail
Dimension: type
Measure 1: COUNT(ID)
Measure 2: COUNT(ID) / (SELECT COUNT(ID) FROM comments_category_detail)
Sort: COUNT(ID) DESC
```

展示示例：

| Type | #Case | % |
|---|---:|---:|
| PO号 | 1,909 | 33.61% |
| QA | 1,724 | 30.35% |
| 系统 | 1,236 | 21.76% |
| 收货 | 295 | 5.19% |
| 签章 | 149 | 2.62% |

说明：

- 这里的 `#Case` 当前实际是 Comment 分类明细数，不是严格 Case 数。
- 如果要统计影响 Case 数，需要关联 UUID 后使用 `COUNT(DISTINCT UUID)`。

---

### 2. Type 分类占比图

组件类型：弹性组件 / Flexible Chart

配置：

```text
From: comments_category_detail
Dimension: type
Measure: COUNT(ID)
Style: Pie Chart
```

说明：

- 饼图建议只放 `COUNT(ID)`。
- 百分比在左侧表格中展示即可。
- 饼图主要用于视觉展示分类占比。

---

### 3. LIKE 分类统计

当前做法：多个 Measure 横向展示。

示例：

```sql
COUNT(CASE
  WHEN Status LIKE '%QA%'
  THEN ID
END)
```

```sql
COUNT(CASE
  WHEN Status LIKE '%PO%'
  THEN ID
END)
```

```sql
COUNT(CASE
  WHEN Status LIKE '%系统%' OR Status LIKE '%JDE%' OR Status LIKE '%EBS%'
  THEN ID
END)
```

说明：

- LIKE 统计适合探索分析。
- LIKE 会有重叠，例如 `PO无预付款` 可能同时命中 PO 与预付款。
- 正式汇报建议以 `type` 分类为准，LIKE 只作为补充验证。

---

## IPM 操作注意点

### 1. 不要用遗留矩阵图做 Type × Status

如果配置：

```text
Dimension 1: type
Dimension 2: Status
```

容易报错：

```text
维度 Status 具有过多不同值
```

原因：Status 唯一值太多，遗留矩阵组件限制较严格。

建议改为：

- 单独做 Type 分类统计表
- 单独做 Top Status 明细表
- 使用 Type 过滤器做钻取

---

### 2. 柱状图/饼图要用“弹性”组件

不要选：

- 表（遗留）
- 矩阵图（遗留）

应选择：

```text
弹性组件
```

然后在样式中选择：

- Pie Chart
- Bar Chart
- Column Chart

---

### 3. `comment_category_detail_tbl` 必须有唯一主键

如果没有 ID 主键，IPM 可能报：

```text
标识符未知
```

解决方式：

```text
新增 ID 字段
每行唯一
设为主键
重新保存数据模型
重新更新流程分析
```

---

## 下一步建议组件

### 1. Top Status 明细表

组件类型：表

配置：

```text
From: comments_category_detail
Dimension: Status
Measure: COUNT(ID)
Sort: COUNT(ID) DESC
```

标题：

```text
Top Comment Status
```

用途：

- 查看最常见的原始 Comment / Status
- 支持业务钻取分析

---

### 2. Type 过滤器 + Top Status 钻取

增加过滤器：

```text
Filter field: type
```

效果：

- 点击 QA，只看 QA 下的 Top Status
- 点击 PO号，只看 PO 相关 Status
- 点击 系统，只看系统相关 Status

---

### 3. Type × System 分析

后续结合 `case_attributes_tbl.System`：

```text
Type × System
```

回答：

- QA 问题主要集中在哪个系统？
- PO 问题主要集中在哪个系统？
- 系统类问题是否集中在 EBS / JDE？

---

### 4. Comment 分类 × Manual Intervention

后续结合人工介入逻辑：

```text
Manual Intervention = comments_detail 有人工记录 OR case_attributes_tbl.Comment_Clean 不为空
```

用于分析：

- 哪些 Comment 分类最容易导致人工介入？
- 哪些分类对 BOT 完成率影响最大？

---

## 当前结论

目前 Comment 分类分析页已经完成核心框架：

- Type 分类统计表
- Type 分类占比图
- LIKE 探索指标

下一步优先补充：

1. Top Comment Status
2. Type 过滤钻取
3. Type × System / OCRFeedback 根因分析

这页的业务价值是从“有多少人工介入”进一步回答“为什么需要人工介入”。
