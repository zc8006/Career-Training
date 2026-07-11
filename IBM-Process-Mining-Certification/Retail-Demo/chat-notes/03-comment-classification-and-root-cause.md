# Comment 分类与根因分析

## 1. 当前分类结果

Phase2 的人工 Comment 分类目前主要集中在：

- BLANK
- PO
- QA
- SYSTEM
- RECEIVING
- ESIGN
- BANK
- RERUN
- PREPAYMENT
- ACCEPTANCE
- OTHER
- CONTRACT

其中 PO、QA、SYSTEM 是当前重点分析的三大原因。

## 2. 分类方式演进

### 初始方式

使用人工整理的 `comments_category_detail.type` 做统计。

优点：

- 结果稳定
- 方便业务修正
- 适合正式汇报

缺点：

- 需要预先维护分类表
- 不够实时

### 当前方式

直接使用 `comments_detail_tbl.Status`，通过 `CASE WHEN + LIKE` 实时分类。

优点：

- 不依赖额外分类表
- 可直接展示分类规则
- 便于继续拆分二级原因

缺点：

- 需要维护关键词优先级
- 同一 Comment 可能同时命中多个分类

## 3. 互斥分类原则

`CASE WHEN` 从上到下执行，第一条命中的规则决定最终分类。

例如：

```text
PO未过QA
```

如果 QA 规则放在 PO 前面，则最终归入 QA，不会重复计数。

推荐优先级：

1. BLANK
2. QA
3. RERUN
4. PO
5. RECEIVING
6. ACCEPTANCE
7. PREPAYMENT
8. ESIGN
9. BANK
10. CONTRACT
11. SYSTEM
12. OTHER

## 4. 基础分类 SQL

```sql
SELECT
    classified.CommentType AS "CATEGORY",
    COUNT(*) AS "COMMENTCOUNT"
FROM (
    SELECT
        CASE
            WHEN comments_detail_tbl.Status IS NULL
              OR TRIM(comments_detail_tbl.Status) = ''
                THEN 'BLANK'
            WHEN comments_detail_tbl.Status LIKE '%QA%'
                THEN 'QA'
            WHEN comments_detail_tbl.Status LIKE '%RERUN%'
              OR comments_detail_tbl.Status LIKE '%rerun%'
                THEN 'RERUN'
            WHEN comments_detail_tbl.Status LIKE '%更改PO%'
              OR comments_detail_tbl.Status LIKE '%原PO号%'
                THEN 'PO'
            WHEN comments_detail_tbl.Status LIKE '%收货%'
              OR comments_detail_tbl.Status LIKE '%Receiving%'
              OR comments_detail_tbl.Status LIKE '%receiving%'
                THEN 'RECEIVING'
            WHEN comments_detail_tbl.Status LIKE '%验收%'
                THEN 'ACCEPTANCE'
            WHEN comments_detail_tbl.Status LIKE '%预付款%'
              OR comments_detail_tbl.Status LIKE '%核销%'
                THEN 'PREPAYMENT'
            WHEN comments_detail_tbl.Status LIKE '%电子签章%'
              OR comments_detail_tbl.Status LIKE '%签章%'
                THEN 'ESIGN'
            WHEN comments_detail_tbl.Status LIKE '%银行账号%'
              OR comments_detail_tbl.Status LIKE '%收款账号%'
                THEN 'BANK'
            WHEN comments_detail_tbl.Status LIKE '%合同%'
                THEN 'CONTRACT'
            WHEN comments_detail_tbl.Status LIKE '%更系统%'
              OR comments_detail_tbl.Status LIKE '%原系统%'
              OR comments_detail_tbl.Status LIKE '%系统卡住%'
              OR comments_detail_tbl.Status LIKE '%系统不一致%'
                THEN 'SYSTEM'
            ELSE 'OTHER'
        END AS CommentType
    FROM comments_detail_tbl
    JOIN case_attributes_tbl
        ON comments_detail_tbl.UUID = case_attributes_tbl.UUID
    WHERE comments_detail_tbl.Processor IS NOT NULL
      AND comments_detail_tbl.Processor <> 'ChinaBot'
) classified
GROUP BY classified.CommentType
ORDER BY COUNT(*) DESC
```

## 5. PO、QA、SYSTEM 的业务含义

### PO

采购订单相关问题，例如：

- 更改 PO 号
- 原 PO 号错误
- PO 信息与发票不一致
- 需要人工修改 PO 后重新执行

### QA

质量校验或人工确认相关问题，例如：

- QA 未通过
- 需要人工确认
- 修改后重新 QA

### SYSTEM

目标系统或系统路由相关问题，例如：

- 更改目标系统
- 原系统错误
- 系统卡住
- 系统无法自动判断

## 6. 根因分析方向

不能只回答“PO 最多、QA 第二、SYSTEM 第三”，还要继续拆分：

### PO 二级原因

- 更改 PO
- 原 PO 号错误
- PO 未收货
- PO 无预付款
- PO 行项目
- PO 金额
- PO 类型
- PO 合同

### QA 二级原因

- 未过 QA
- QA 未通过
- PO 未过 QA
- 重复扫描
- 其他校验失败

### SYSTEM 二级原因

- 更改系统
- 原系统错误
- 系统卡住
- 供应商不一致
- 银行账号问题
- RERUN

## 7. OTHER 的处理

不要长期保留大量 OTHER。

先查询 OTHER 原始内容，再补充高频规则。建议关注：

- DUPLICATE
- VENDOR
- INVOICE_ERROR
- CANCELLED
- PENDING_POSTING
- FOREIGN_INVOICE
- EXCEPTION

OTHER 很少时可保留，作为未匹配规则的兜底分类。
