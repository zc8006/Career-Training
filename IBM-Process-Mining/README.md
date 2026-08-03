# IBM Process Mining

用于沉淀 IBM Process Mining 项目的分析方法、SQL、面板设计、问题验证与复盘。

## 目录

```text
IBM-Process-Mining
├── IBM_Process_Mining_Master.md
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
- 原因分类、Comments、OCR Feedback、处理时长、Rework、RPA恢复率联动分析

## BOT 与人工路径转化分析

### 业务问题

不能只回答“人工占比是多少”，还要回答：

1. BOT 在哪里转为人工？
2. 人工介入后是否重新回到 BOT？
3. 回到 BOT 后是否真正完成录入，还是再次报错、待查或进入意见征询？
4. 哪些 Comments 原因、OCR Feedback、System、PO/QA/电子签章问题最容易导致永久转人工？
5. 哪些人工操作属于可自动化修复，哪些属于流程终点或业务例外？

### Phase2 当前验证结果

- 人工介入 Case：12,504
- 排除人工录入完成、废弃删除、RPA范围外等终点活动后的可回归人工 Case：4,902
- 人工后重新出现任意 BOT 活动：328，约 6.691%
- 全部人工后重新出现 BOT：337
- 337 件人工后回 BOT Case 的最终 BOT 状态：
  - 录入中发生错误：116，34.421%
  - 录入完成：92，27.299%
  - 意见征询：84，24.925%
  - 其他 OCR 异常、待查、RPA 范围外等：45
- 真正实现“人工处理后由 BOT 录入完成”：92 / 4,902，约 1.877%

### 当前解释

“人工后重新出现 BOT”不等于“恢复自动化成功”。应至少区分三层：

```text
人工介入
→ 后续再次出现任意 BOT 活动
→ 最终 BOT 状态
→ 是否达到 BOT 录入完成
```

337 件中只有 92 件最终到达 BOT 录入完成，其余多数停留在录入错误、意见征询、OCR 待查或其他异常状态。

## 数据口径

- 事件表：`eventlog`
- 属性表：`case_attributes_tbl_all`
- 原因表：`manual_reason_tbl`
- BOT/人工路径辅助表：`bot_recovery_case_tbl`
- 分类字段：`UUID`、`Status`
- EBS 筛选：`TRIM(OCR_FEEDBACK) = 'EBS_大于阈值需检查'`
- 角色字段：`Role = BOT / MANUAL`
- 审批类活动：`审批结束`、`审批拒绝`
- 同一条 `UUID + Status` 只保留一个分类
- 同一 UUID 的不同 Status 可以进入不同分类
- IBM Process Mining 2.0.3 中避免使用 `WITH`，采用嵌套子查询或预计算辅助表

## Comments 与 OCR Feedback 的定位

Comments 和 OCR Feedback 必须看，但不能只做词频表。

- `Comments / Status`：解释人工为什么介入、为什么修改 PO、为什么 QA 未通过、为什么电子签章或收货异常。
- `OCR Feedback`：解释 OCR 识别、阈值、票据类型和系统差异是否导致人工介入。
- `eventlog` 路径：说明问题发生在流程什么位置、人工后是否回到 BOT、最终停在哪里。
- `case_attributes_tbl_all`：补充 System、TrackerStatus、IBMProcessor、Reworks 等 Case 级背景。

推荐分析链路：

```text
路径结果
→ 锁定失败或成功 Case
→ 关联 Comments 原因分类
→ 关联 OCR Feedback
→ 按 System / Request Type / PO Result / Rework 拆分
→ 提出规则、系统和流程改造建议
```

## 分析意义

本项目不只是展示 RPA 率，而是建立一条从现象到改善的证据链：

```text
总体 RPA / 人工结果
→ 找到人工介入节点
→ 判断是否重新回 BOT
→ 判断 BOT 是否最终成功
→ 用 Comments 和 OCR Feedback 解释原因
→ 识别可修复规则与永久人工场景
→ 估算 RPA 提升机会
```

最终输出应回答：

- 哪些问题数量大？
- 哪些问题最容易导致 BOT 失败？
- 哪些问题人工处理后仍能恢复 BOT？
- 哪些问题几乎不会恢复，应优化规则或调整 RPA 范围？
- 修复某类问题预计能提升多少 RPA Case？

## 使用原则

1. 临时验证先写入 `Notes`。
2. 错误口径、失败 SQL 和修正原因写入 `WrongAnswers.md`。
3. 稳定结论再同步到 `IBM_Process_Mining_Master.md`。
4. 每次分析按 `Self_Growth_Mode.md` 复盘，形成可复用的方法。
5. 面板组件必须使用相同的 Phase、DDD 和 Case 基数口径。
6. 先区分“回到 BOT”和“BOT 最终成功”，再解释恢复率。
