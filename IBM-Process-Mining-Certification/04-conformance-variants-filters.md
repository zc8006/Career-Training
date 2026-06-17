# 04. Process model, variants, conformance and filters

## 1. Process model

Process model 是 IBM Process Mining 根据 event log 自动发现出来的真实流程图。

它展示：

- 活动节点
- 活动之间的流转关系
- 路径频率
- 耗时
- 成本
- 变体
- 异常路径

## 2. View modes

IBM Process Mining 中 Process Model 支持不同 view modes，用来从不同角度查看流程。

常见目的：

- 看整体流程
- 看高频路径
- 看瓶颈路径
- 看异常路径
- 看多流程 / 多事件日志的关系

IBM Process Mining 2.0.3 引入 Organization Mining 技术预览，可以把多个 event logs 合并到一个视图中，用来看流程、人员、资产之间的关系。

## 3. Process variants

Process variant 是案例实际走过的路径组合。

例子：

Variant 1:

```text
Create -> Approve -> Start -> Complete -> Close
```

Variant 2:

```text
Create -> Approve -> Start -> Complete -> Reopen -> Complete -> Close
```

Variant 3:

```text
Create -> Cancel
```

用途：

- 找主流程路径
- 找异常路径
- 找返工路径
- 找流程复杂度
- 找自动化机会

## 4. Reference model

Reference model 是期望流程或标准流程。

它可以来自：

- BPMN
- 手工建模
- 业务标准流程
- 历史最佳路径

## 5. Model conformance

Model conformance 是把真实流程和 reference model 对比。

它可以识别：

- Conformant cases：符合标准流程的案例
- Non-conformant cases：不符合标准流程的案例
- Missing activities：标准中有但实际没发生
- Unexpected activities：实际发生但标准中没有
- Wrong order：活动顺序不符合标准

## 6. Conformance 适合回答的问题

- 流程是否按照标准执行？
- 哪些案例偏离了标准流程？
- 哪些活动经常被跳过？
- 哪些异常活动经常出现？
- 哪些部门/供应商/资产更容易不合规？

## 7. Filters

Filter 用于缩小分析范围。

常见 filter 类型：

- Process flow filter
- Data filter
- Performance filter
- Time filter
- Attribute filter

## 8. Process / Action Hub / Prescriptive / What-if 中的 filter

这些组件中的 filter 通常影响 cases。

意思是：如果一个 case 被保留，这个 case 的所有 events 通常会一起保留；如果一个 case 被排除，它的所有 events 通常会一起排除。

## 9. Analytics 中的 filter

Analytics 中的 filter 更偏向影响 records 和 widgets。

两种范围：

| Filter impact | 含义 |
|---|---|
| Entire dashboard | 影响整个 dashboard 和相关 cases |
| Single widgets | 只影响选择了对应表的 widget |

## 10. Maximo 工单 conformance 例子

标准流程：

```text
Create Work Order -> Approve Work Order -> Start Work -> Complete Work -> Close Work Order
```

异常流程：

```text
Create Work Order -> Start Work -> Complete Work -> Close Work Order
```

问题：跳过了 Approve Work Order。

业务解释：可能存在紧急维修、流程违规，或系统记录缺失。

## 11. 考试易错点

| 问题 | 正确理解 |
|---|---|
| Variant 是什么？ | 同一流程中案例实际走过的不同路径 |
| Conformance 是什么？ | 真实流程和参考模型的符合度检查 |
| Reference model 是什么？ | 期望流程或标准流程 |
| Process filter 和 Analytics filter 一样吗？ | 不完全一样，Process 类组件通常按 case 影响，Analytics 更多按 record/widget 影响 |

## 12. 认证重点句

Model conformance compares the discovered process with a reference model to identify conformant and non-conformant cases.

中文：Model conformance 将发现出的真实流程与参考模型对比，用于识别符合和不符合标准流程的案例。
