# IBM Process Mining 对话整理

本目录整理了与 IBM Process Mining Retail Demo 相关的讨论、数据口径、Dashboard 设计、SQL 试验与业务结论。

## 文档目录

1. [01-data-model-and-scope.md](./01-data-model-and-scope.md)  
   数据表、关联关系、Phase 范围和统计口径。

2. [02-manual-intervention-analysis.md](./02-manual-intervention-analysis.md)  
   隐性人工介入、BOT 完成 Case、会议关注点与后续分析方向。

3. [03-comment-classification-and-root-cause.md](./03-comment-classification-and-root-cause.md)  
   Comment 分类、PO/QA/SYSTEM 三大原因、分类规则和 Dashboard 页面结构。

4. [04-advanced-sql-notes.md](./04-advanced-sql-notes.md)  
   IBM Process Mining 高级 SQL、MonetDB 日期转换、百分比和饼图查询注意点。

5. [05-dashboard-and-presentation.md](./05-dashboard-and-presentation.md)  
   Dashboard 页面规划、PPT 讲解顺序、分类说明页和演示注意点。

6. [06-current-progress-and-evolution.md](./06-current-progress-and-evolution.md)  
   当前进展、重要认识、Event 级分析路线和后续演进原则。

7. [07-phase1-phase2-rpa-analysis-2026-07-13-14.md](./07-phase1-phase2-rpa-analysis-2026-07-13-14.md)  
   2026-07-13～2026-07-14 的 Phase1/Phase2 RPA 判断规则、Excel 验证、Tracker 补充认定、DDD 排除、人工 Activity 分类、百分比及 Dashboard 口径。

8. [08-comment-and-tracker-analysis-2026-07-15.md](./08-comment-and-tracker-analysis-2026-07-15.md)  
   2026-07-15 的 Comments detail 与 Tracker `Comment_Clean` 分析、NO_COMMENT/BLANK 口径、Activity 分类、Excel 对账及合并展示方法。

9. [09-comment-count-and-visualization-2026-07-16.md](./09-comment-count-and-visualization-2026-07-16.md)  
   2026-07-16 的 Comment 条数与 Case 数口径、`DISTINCT` 修正、`COMMENT_COUNT`、三类饼图设计、图表命名及排除 `SYSTEM` 分类。

## 当前主线

Retail Demo 当前最重要的分析主线是：

```text
表面 BOT 完成
    ↓
识别中间是否存在人工介入
    ↓
分析人工介入原因
    ↓
聚焦 PO / QA / 业务类原因
    ↓
比较频率、影响范围、时间、返工和 Phase 变化
    ↓
形成优化优先级
```

当前 Phase 分析还需要特别区分：

```text
Phase1：判断过程中是否出现人工介入
Phase2：判断最终是否由 RPA 完成
```

Comment 分析当前采用两层证据：

```text
Comments detail：多条明细 Comment
Tracker Comment_Clean：Case 级补充留言
```

两类来源可以合并展示，但必须保留 `COMMENT_SOURCE`，不能混成同一数据口径。

当前 Comment 统计同时保留：

```text
COMMENT_COUNT：实际留言条数
CASE_COUNT：涉及的去重 Case 数
CASE_PERCENT：涉及 Case 占对应人工 Activity 总 Case 的比例
```

## 重要提醒

- `#Comment` 与 `#Case` 必须严格区分。
- 同一个 UUID 可以对应多条 Comment。
- Comments Detail 统计真实留言条数时不能提前按 `UUID + 分类` 使用 `DISTINCT`。
- Tracker `Comment_Clean` 是 Case 级字段，关联 Eventlog 时需要去重，避免事件行放大。
- Comment 分类使用 `CASE WHEN` 时，应保证分类互斥并明确优先级。
- `NO_COMMENT` 表示完全没有 Comments detail 记录；`BLANK` 表示有记录但没有有效文字内容。
- Activity 与 Comment 通过 UUID 关联时属于 Case 级共现，不能直接证明某条 Comment 是该 Activity 的直接原因。
- Phase1、过渡期和 Phase2 的数据覆盖范围不同，展示时必须说明。
- Phase1 与 Phase2 的 RPA 判断规则不同，不能直接套用同一口径。
- Phase2 的 Tracker 规则只补充 Eventlog 未直接认定的 RPA Case，不能重复计数。
- Activity 分布使用 `COUNT(DISTINCT CASEID)`，同一 Case 可出现在多个 Activity 中，因此覆盖率合计可能超过 100%。
- Tracker 留言字段为 `case_attributes_tbl_all.Comment_Clean`。
- `SYSTEM` 当前作为状态说明从根因分析中排除，不并入 `OTHER`。
- 高级 Analytics 查询遵循 MonetDB 风格，不应直接假设完整 PostgreSQL 语法可用。
