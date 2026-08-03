# IBM Process Mining

用于沉淀 IBM Process Mining 项目的分析方法、SQL、面板设计、问题验证与复盘。

## 目录

```text
IBM-Process-Mining
├── Self_Growth_Mode.md
├── Notes
├── WrongAnswers.md
└── SQL
    └── EBS_Threshold
```

## 当前分析主线

- Phase1 / Phase2 人工与 RPA 对比
- DDD 范围排除
- 人工介入原因分类
- EBS 大于阈值需检查的原因分析
- BOT 与人工路径转化分析
- RPA 提升机会分析

## 两条必须分开的因果链

### 1. 为什么一开始不能直接走 RPA

用于解释初始进入人工或非 RPA 的原因，重点看：

- `OCR_FEEDBACK`
- `System`
- `Request Type`
- `PO Result`
- `PO Match Result`
- 票据类型、阈值、格式与系统差异

`OCR Feedback` 的定位是“初始不能直接 RPA 的原因”，不是“人工处理后 rerun 失败的原因”。属性表中的 OCR Feedback 没有空值；`BLANK` 是人工设定的有效分类，不应当作 NULL 或缺失值处理。

### 2. 人工处理后为什么能或不能 rerun 成功

用于解释人工介入后的流程结果，重点看：

- 人工做了什么 Activity
- Comments / Status 原因分类
- 是否更改 PO、补收货、完成电子签章、通过 QA
- 是否重新触发 BOT
- BOT 最终 Activity
- Reworks、最后一次人工动作、最后一次 BOT 动作

这条链路回答：

```text
人工做了什么
→ 是否重新回到 BOT
→ BOT 最终成功、失败还是停滞
```

## Phase2 当前验证结果

### 正式结果口径

- Phase2 总 Case：21,578
- RPA_PROCESS：11,520，53.388%
- MANUAL_PROCESS：9,735，45.115%
- 未明确归类：323，1.497%

### 路径转化口径

- 发生审批外人工介入：12,504
- 排除人工录入完成、废弃删除、RPA范围外等终点活动后的可回归人工 Case：4,902
- 可回归人工 Case 中人工后重新出现 BOT：328，6.691%
- 全部人工后重新出现 BOT：337
- 真正人工处理后由 BOT 完成录入：92 / 4,902，约 1.877%

### 337 件人工后回 BOT 的最终状态

- 录入中发生错误：116，34.421%
- 录入完成：92，27.299%
- 意见征询：84，24.925%
- 其他 OCR 异常、待查、RPA 范围外等：45

结论：

```text
人工后再次出现 BOT
≠ rerun 成功
≠ 最终 BOT 录入完成
```

人工后回 BOT 的 337 件中，只有 92 件最终录入完成。提升机会不在“让 BOT 再出现”本身，而在“让人工处理后的 Case 能被正确重触发，并最终完成录入”。

## 当前已形成的有价值发现

### 1. 大量人工介入发生在流程终点

Phase2 人工 Activity 中：

- 录入完成：9,716
- 意见征询：3,182
- OCR完成：2,064
- 废弃删除：59
- OCR待处理：7
- RPA范围外：3

人工“录入完成”属于终点动作，不应放入 BOT 回归率分母。把终点动作纳入分母会显著压低回归率并误导分析。

### 2. 可回归场景主要集中在意见征询和 OCR完成

- 意见征询：3,182 件，228 件后续回 BOT，7.165%
- OCR完成：2,064 件，220 件后续回 BOT，10.658%
- 两种 Activity 同时出现且回 BOT：120 件
- 仅意见征询后回 BOT：108 件
- 仅 OCR完成后回 BOT：100 件

Phase2 回 BOT 的 337 件中，328 件与“意见征询”或“OCR完成”有关，说明 rerun 机制应优先围绕这两个节点设计。

### 3. 回到 BOT 后大部分仍未成功

人工后最终 BOT 状态中：

- 录入中发生错误：116
- 录入完成：92
- 意见征询：84

这说明当前主要缺口不是“人工之后完全没有 BOT”，而是：

- BOT 重启后仍报错
- BOT 重启后停在意见征询
- 人工修复动作没有转化为稳定的重新执行条件

### 4. Comments 更适合解释失败与停滞

在 SUCCESS / FAILED / STALLED 横向比较中：

- SUCCESS 92 件全部没有匹配到 `manual_reason_tbl`
- FAILED 中大量命中 PO、QA、收货、电子签章等 Comments 原因
- STALLED 中电子签章、金额/单价匹配、类型匹配、其他问题占比更高

因此：

- Comments 不是全量 Case 属性表
- Comments 主要解释失败和停滞，不适合单独解释成功
- 成功组应更多通过人工 Activity、结构化业务字段和最后状态解释

### 5. 初步失败与停滞特征

- `PO号码/OU问题`：明显偏向 FAILED
- `PO对比/结果`、`QA问题`、`收货/验收问题`：FAILED 与 STALLED 都较高
- `电子签章问题`：更偏向 STALLED
- `金额/单价匹配`、`类型匹配`：更容易停留在意见征询

这些结论仍需结合样本量、PO Result、PO Match Result、Reworks 和人工动作继续验证，不能只依据 Comments 单表下结论。

## 分析意义

本项目不只是回答“人工比例是多少”，而是建立一条可落地的改善证据链：

```text
初始不能 RPA 的原因
→ 人工介入节点
→ 人工修复动作
→ 是否重新触发 BOT
→ BOT 最终状态
→ 失败 / 停滞的业务原因
→ 可改规则、可改系统、可改流程
→ 估算可提升 Case 数
```

最终输出必须回答：

- 哪些场景一开始不能 RPA？
- 哪些人工动作有机会让 Case 回到 BOT？
- 哪些场景回 BOT 后仍然失败？
- 哪些场景停在意见征询，缺少自动回流机制？
- 哪些规则或字段修复后，预计能增加多少 BOT 成功 Case？

## 数据口径

- 事件表：`eventlog`
- 属性表：`case_attributes_tbl_all`
- 人工原因表：`manual_reason_tbl`
- 属性扩展表：`manual_entry_classification1`
- 路径辅助表：`bot_recovery_case_tbl`
- 角色字段：`Role = BOT / MANUAL`
- 审批类活动：`审批结束`、`审批拒绝`
- 同一条 `UUID + Status` 只保留一个分类
- 同一 UUID 的不同 Status 可以进入不同分类
- IBM Process Mining 2.0.3 中避免使用 `WITH`
- 大型时间先后分析优先使用 Power Query 或数据源端预计算 Case 级辅助表

## 使用原则

1. 初始不能 RPA 与 rerun 失败必须分开分析。
2. OCR Feedback 用于解释初始不能 RPA，不直接解释 rerun 失败。
3. Comments 用于解释人工处理、失败与停滞，不应假定覆盖所有 Case。
4. 人工终点 Activity 不进入“可回归”分母。
5. “重新出现 BOT”和“最终 BOT 成功”必须拆成两个指标。
6. 面板组件必须使用相同的 Phase、DDD 和 Case 基数口径。
7. 所有最终状态分类合计必须回到总 Case 数。
8. 稳定结论写入 README，过程验证写入 Notes，错误口径写入 WrongAnswers，自我成长写入 Self_Growth_Mode.md。
