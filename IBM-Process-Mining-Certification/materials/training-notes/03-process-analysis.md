# 03. Process Analysis

## 1. Process model

Process model 是 IBM Process Mining 根据 event log 自动发现出来的真实流程模型。

它可以展示：

- 活动节点
- 活动之间的直接流转关系
- 路径频率
- 活动耗时
- 等待时间
- 成本
- 异常路径
- 返工路径

## 2. Process model 的价值

Process model 不是为了画一张好看的图，而是为了发现真实流程：

- 哪条路径最常见？
- 哪些路径很少见但风险高？
- 哪些活动经常重复？
- 哪些步骤造成等待？
- 哪些活动不应该发生？
- 哪些流程和标准流程不一致？

## 3. Process variants

Variant 是流程实例实际走过的路径组合。

例子：

### 标准路径

```text
Create Work Order
-> Approve Work Order
-> Start Work
-> Complete Work
-> Close Work Order
```

### 跳过审批

```text
Create Work Order
-> Start Work
-> Complete Work
-> Close Work Order
```

### 返工路径

```text
Create Work Order
-> Approve Work Order
-> Start Work
-> Complete Work
-> Reopen Work Order
-> Complete Work
-> Close Work Order
```

## 4. Variant 分析能回答什么

- 主流程路径是什么？
- 异常路径有哪些？
- 哪些路径导致耗时变长？
- 哪些路径成本更高？
- 哪些路径代表返工？
- 哪些路径可以通过自动化减少？

## 5. Reference model

Reference model 是标准流程或期望流程。

来源可以是：

- BPMN model
- 标准操作流程 SOP
- 业务专家定义的理想流程
- 历史最佳实践流程
- 从工具中手工建模

## 6. Model conformance

Model conformance 是把真实流程和 reference model 做对比。

它可以识别：

- Conformant cases：符合标准流程的案例
- Non-conformant cases：不符合标准流程的案例
- Unexpected activities：标准流程中没有但实际发生的活动
- Missing activities：标准流程中要求但实际缺失的活动
- Unexpected initial activities：异常开始活动
- Unexpected process flows：异常流程流转

## 7. Deviation

Deviation 指 reference model 和 data-derived model 之间的差异。

常见 deviation：

- Unexpected activities
- Unexpected initial activities
- Unexpected process flows
- Missing required steps
- Wrong order

## 8. BPMN

BPMN 是 Business Process Modeling Notation，用于业务流程建模。

在 IBM Process Mining 中，BPMN / reference model 可用于 conformance 分析。

记忆：

```text
BPMN / Reference model = expected process
Event log / Process model = actual process
Conformance = compare expected with actual
```

## 9. Process comparison

Process comparison 用于比较不同范围的流程表现。

例子：

- High priority vs Low priority work orders
- Plant A vs Plant B
- Before automation vs After automation
- Region 1 vs Region 2
- Standard path vs Rework path

## 10. Attribute statistics

Attribute statistics 用于从属性角度分析流程。

Maximo 例子：

- 按 Priority 看平均周期
- 按 Asset Type 看返工率
- 按 Location 看超时率
- 按 Resource 看处理时间
- 按 Work Type 看成本

## 11. 考试易错点

| 问题 | 正确理解 |
|---|---|
| Process model 是人工画的吗？ | 通常由 event log 自动发现 |
| Variant 是什么？ | 案例实际经过的一组活动序列 |
| Reference model 是什么？ | 标准或期望流程 |
| Conformance 是什么？ | 真实流程和标准流程的符合度检查 |
| Deviation 是什么？ | 真实流程与参考模型之间的差异 |

## 12. 一句话背诵

Model conformance compares the discovered process model with a reference model to identify conformant and non-conformant cases.

中文：Model conformance 将发现出的真实流程模型和参考模型对比，用于识别符合与不符合标准流程的案例。
