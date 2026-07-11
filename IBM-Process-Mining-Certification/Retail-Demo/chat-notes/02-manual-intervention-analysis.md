# 人工介入分析

## 1. 业务真正关心的问题

业务已知“BOT 完成的 Case 中可能存在人工介入”。因此分析不能停留在验证这一事实，而要继续回答：

- 表面 BOT 完成但中间人工介入的比例是多少？
- 这些人工介入主要发生在哪些环节？
- 哪些介入属于可避免、可规则化或可自动化？
- 哪些介入会带来更多 RERUN、等待或返工？
- Phase1、过渡期、Phase2 是否有改善？

## 2. 会议结论整理

2026-07-03 会议中的关键认识：

1. RPA 范围外的 Case 可能先转人工，补充信息后重新回到 RPA，由 BOT 完成最终录入。
2. 因此不能只看最终 `IBMProcessor = ChinaBot`，还要检查中间是否存在人工 Comment 或人工操作记录。
3. `comments_detail_tbl` 可以反映人工介入痕迹，特别是 `Processor <> 'ChinaBot'` 的记录。
4. `Comment_Clean` 或原始 Comment 不为空，也可作为人工参与的证据。
5. 业务希望知道：
   - BOT 完成 Case 中隐性人工介入的数量和比例
   - 所有完成 Case 中隐性人工介入的数量和比例
   - 中间曾经是 RPA 范围外、最终又由 BOT 完成的 Case
6. `OCRFeedback` 用于反映机器人基于规则对系统和录入方式的判断结果。
7. DDD 通常不由 BOT 入账，JDE/EBS 使用不同技术路径。
8. 只看最终状态会掩盖中间人工修复过程。

## 3. 人工介入识别口径

### 明确人工操作

```sql
comments_detail_tbl.Processor IS NOT NULL
AND comments_detail_tbl.Processor <> 'ChinaBot'
```

### 隐性人工介入

可以组合以下条件：

```text
最终 IBMProcessor = ChinaBot
AND
comments_detail_tbl 中存在非 ChinaBot 操作
```

或：

```text
最终 IBMProcessor = ChinaBot
AND
Comment_Clean 不为空
```

推荐以 `comments_detail_tbl` 明细为主，`Comment_Clean` 作为补充验证。

## 4. 当前已完成

- 已确认 `comments_detail_tbl` 与 `case_attributes_tbl` 通过 UUID 关联。
- 已能筛选 `Processor <> 'ChinaBot'` 的人工记录。
- 已能按 Comment 内容用 `LIKE` 或 `CASE WHEN` 分类。
- 已完成 PO、QA、SYSTEM 三大类的基础分布分析。
- 已能使用 Phase2 过滤器联动 Dashboard。

## 5. 后续高价值分析

### 5.1 人工介入时间

目标：计算人工介入前后流程等待时长，包括：

- 最短时间
- 最长时间
- 平均时间
- Phase1 / 过渡期 / Phase2 对比

### 5.2 多次人工介入

识别：

- 同一个人对同一 Case 多次操作
- 多个人对同一 Case 多次操作
- Comment 为空但存在人工操作的 Case

### 5.3 人工介入优化优先级

建议指标：

- 受影响 Case 数
- Comment 数
- 每 Case Comment 数
- RERUN Case 数
- RERUN Rate
- 平均等待时长

最终形成：

```text
高频 + 高影响：优先优化
高频 + 低影响：规则化处理
低频 + 高影响：专项治理
低频 + 低影响：暂缓处理
```
