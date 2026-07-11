# 当前进展与持续演进

本文用于记录截至 2026-07-11 的项目状态、已经掌握的能力、仍未解决的问题，以及后续学习如何继续沉淀到仓库中。

## 1. 已完成的基础建设

### 数据模型

已完成：

- `case_attributes_tbl` 作为 Case 主表
- `comments_detail_tbl` 作为原始 Comment 明细表
- `comments_category_detail` 作为分类明细表
- 通过 `UUID` 建立关联
- 已验证跨表过滤可以生效

### 日期与 Phase

已完成：

- 确认 `InputDate` 为 13 位毫秒时间戳
- 找到 MonetDB 环境中的日期转换方式
- 可以按日期过滤 Phase2
- 已形成 Phase1、过渡期、Phase2 的分析思路

### Comment 分类

已完成：

- 从人工维护的 `type` 分类逐步演进为原始 Comment 实时分类
- 使用 `CASE WHEN + LIKE` 实现互斥分类
- 支持 BLANK、PO、QA、SYSTEM、RECEIVING、ESIGN、BANK、RERUN、PREPAYMENT、ACCEPTANCE、CONTRACT、OTHER
- 已能区分 `#Comment` 与 `#Case`
- 已能筛选 `Processor <> 'ChinaBot'` 的人工操作

### Dashboard

已完成：

- Comment 分类统计表
- Comment 分类饼图
- Top Comment Status
- PO 根因分析页
- QA 根因分析页
- SYSTEM 根因分析页
- System、OCRFeedback、POCompareResult、ApplyType、ESignResult、PrepaymentResult 等维度分析

### 高级 SQL

已掌握：

- 子查询
- CTE 基础能力验证
- `COUNT(DISTINCT UUID)`
- `CASE WHEN`
- `LIKE`
- `ROUND`
- `RTRIM`
- `||` 拼接
- Dashboard Filter 联动
- 饼图查询需要简化为 Category + Value 两列

## 2. 已经澄清的重要认识

### 认识一：最终 BOT 完成不等于全程无人参与

最终 `IBMProcessor = ChinaBot` 只能说明最终执行者，不能说明中间没有人工修复。

因此分析必须同时检查：

- `comments_detail_tbl.Processor`
- Comment 是否为空
- 同一 UUID 是否存在多条人工记录
- 是否存在 RERUN 或状态切换

### 认识二：字段分布不等于业务洞察

仅仅展示：

- JDE 占多少
- OCRFeedback 哪个最多
- POCompareResult 哪个最多

只能验证数据分布，无法指导优化。

真正有价值的问题是：

- 为什么需要人工介入？
- 哪些介入可避免？
- 哪些问题频率高但成本低？
- 哪些问题频率低但等待时间长？
- 哪类问题应该优先自动化？

### 认识三：Comment 分类只是入口

PO、QA、SYSTEM 只是一级分类。后续必须继续拆分二级原因并结合：

- Phase
- 操作者
- System
- OCRFeedback
- ApplyType
- POCompareResult
- 发票类型
- RERUN
- 等待时间

## 3. 当前最值得推进的分析

### PO 号更改分析

计划包括：

1. Phase1 与 Phase2 数量对比
2. 高频操作者排名
3. DDD/JDE/EBS 最终流向
4. OCRFeedback 对比
5. 发票类型分布
6. POCompareResult 分布
7. 更改 PO 所需时间
8. 更改后一次成功率
9. 再次更改 PO 的比例
10. RERUN 率

### 人工介入时间分析

计划包括：

- 第一次人工介入到流程恢复的时间
- 最短、最长、平均和中位数
- Phase1、过渡期、Phase2 对比
- PO、QA、SYSTEM 分类对比

### 多次人工介入流程分析

计划识别：

- 同一个人多次操作
- 多个人先后操作
- Comment 为空但有人工操作
- 多次 RERUN
- 人工修复后 BOT 完成

## 4. 当前未完成的问题

- Phase1 Comment 明细覆盖不足，不能直接与 Phase2 做同口径比较
- 尚未确定最可靠的人工介入等待时间起止事件
- 尚未建立完整的二级分类字典
- 尚未完成多次人工介入 Case 的流程还原
- 尚未形成最终优化优先级矩阵
- 现有 PO/QA/SYSTEM 页面仍有部分“字段分布多、结论少”的问题

## 5. 后续演进原则

今后的每次分析都遵循下面的顺序：

```text
业务问题
  ↓
数据口径
  ↓
SQL/过滤条件
  ↓
Dashboard 组件
  ↓
验证结果
  ↓
业务解释
  ↓
可执行建议
```

避免：

```text
先做图
  ↓
再想这个图能说明什么
```

## 6. 对话沉淀规则

后续与 IBM Process Mining 相关的重要讨论，应持续更新到本目录：

- 新的数据口径 → `01-data-model-and-scope.md`
- 新的人工介入结论 → `02-manual-intervention-analysis.md`
- 新的分类规则 → `03-comment-classification-and-root-cause.md`
- 新的 SQL 写法或踩坑 → `04-advanced-sql-notes.md`
- 新的 Dashboard/PPT 结构 → `05-dashboard-and-presentation.md`
- 阶段性总结 → 本文件

目标不是简单保存聊天记录，而是把反复试错转化为：

- 可复用的方法
- 可验证的 SQL
- 清晰的数据口径
- 可以继续迭代的项目知识库
