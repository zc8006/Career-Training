# Dashboard 与汇报设计

## 1. 当前 Dashboard 页面

已完成或正在使用的页面包括：

- Comment 分类分析
- Top3 Comment 根因分析_PO
- Top3 Comment 根因分析_QA
- Top3 Comment 根因分析_SYSTEM
- 人工确认/人工介入分析测试页

## 2. Comment 分类分析页

推荐组件：

1. Breakdown Statistics 表格
   - CATEGORY
   - COMMENTCOUNT
   - PERCENT
2. 分类饼图
   - Category：TYPE
   - Value：CNT
3. Top Comment Status
4. Type 过滤器，用于下钻原始 Comment

### 展示口径

- BLANK：存在人工记录，但 Comment/Status 为空
- PO：采购订单相关修改或错误
- QA：QA 校验、确认或未通过
- SYSTEM：目标系统、系统判断或系统异常
- RECEIVING：收货相关
- ESIGN：电子签章相关
- BANK：银行账号相关
- RERUN：机器人重新执行
- PREPAYMENT：预付款相关
- ACCEPTANCE：验收相关
- CONTRACT：合同相关
- OTHER：未命中当前规则

## 3. PO 页面

当前已完成的维度分析包括：

- PO 问题 × System
- PO 问题 × OCRFeedback
- PO 问题 × ESignResult
- PO 问题 × PrepaymentResult
- PO 问题 × POCompareResult
- PO 问题 × ApplyType

这些字段分布适合作为明细，但不能作为最终业务结论。

高价值方向：

- PO 号更改 Phase 对比
- 按操作者统计更改 PO 次数
- 更改 PO 后最终流向 DDD/JDE/EBS
- 更改 PO 与 OCR 反馈的关系
- 发票类型与更改 PO 的关系
- PO 对比结果与更改 PO 的关系
- 更改 PO 所需时间
- 更改后一次成功率、再次更改率和 RERUN 率

## 4. QA 页面

建议重点展示：

- QA 子原因分布
- POCompareResult 分布
- QA × OCRFeedback
- QA × ApplyType
- QA × System
- QA 月度趋势
- QA 后再次人工介入或 RERUN 的比例

## 5. SYSTEM 页面

建议重点展示：

- 更改系统
- 原系统错误
- 系统卡住
- JDE/EBS/DDD 分布
- 系统问题 × OCRFeedback
- 系统问题 × RERUN
- 系统问题导致的等待时间

## 6. 推荐汇报顺序

### 第 1 页：背景与目标

说明为什么做这次分析：

- 识别表面 BOT 完成但实际存在人工介入的 Case
- 找到人工介入的主要原因
- 评估可优化和可自动化机会

### 第 2 页：总体分类

展示 Breakdown Statistics：

- BLANK
- PO
- QA
- SYSTEM
- 其他分类

### 第 3 页：分类定义

用中文解释每一类包含哪些 Comment。

### 第 4 页：PO 深挖

先讲数量和占比，再讲 System/OCR/Invoice Type/POCompareResult。

### 第 5 页：QA 深挖

讲 QA 的主要结果与高频组合。

### 第 6 页：SYSTEM 深挖

讲系统修改、系统路由与异常。

### 第 7 页：人工介入流程

展示同一 Case 多次人工介入、不同操作者参与、空白 Comment 记录。

### 第 8 页：优化优先级

按频率、等待时间、RERUN 率和人工复杂度排序。

## 7. 分类说明页设计

推荐标题：

```text
Comment 分类定义
```

左侧：Breakdown Statistics 截图。

右侧：分类字典。

| 分类 | 说明 |
|---|---|
| PO | 修改 PO 号、原 PO 号错误、PO 信息不一致 |
| QA | QA 未通过、重新确认、人工校验 |
| SYSTEM | 更改系统、原系统错误、系统卡住 |
| RECEIVING | 收货状态或收货信息问题 |
| ESIGN | 电子签章问题 |
| BANK | 银行账号或收款账号问题 |
| RERUN | BOT 重新执行 |
| PREPAYMENT | 预付款或核销问题 |
| ACCEPTANCE | 验收问题 |
| CONTRACT | 合同问题 |
| BLANK | 有人工操作但 Comment 为空 |
| OTHER | 未命中当前分类规则 |

底部注明：

```text
每条 Comment 根据关键词规则只归入一个分类；同时命中多个条件时，以规则顺序中最先匹配的分类为准。
```

## 8. 演示注意点

- 不要把字段分布当成业务结论。
- 每页都要回答“所以呢”。
- 所有百分比、Case 数和 Comment 数口径要保持一致。
- 分类表和饼图可以使用不同 SQL：表格输出百分比，饼图只输出分类和数量。
- Phase1 没有完整 Comment 数据时，不应展示为 0 后直接解释为没有问题。
