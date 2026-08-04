# Phase2 统一口径与人工/BOT路径拆解

## 一、正式母口径

所有 Phase2 面板组件必须复用同一 Case 范围和分类规则。

### Case 范围

- 数据来源：`eventlog`
- 排除 `case_attributes_tbl_all.System = 'DDD'`
- 只统计 `eventlog` 中存在 `审批结束` 的 Case
- 按 `CASEID` 去重，所有最终分类合计必须回到 21,578

### 最终分类

- `RPA_PROCESS`：
  1. `eventlog` 中存在 `ACTIVITY = '录入完成'` 且 `RESOURCE IN ('ChinaBot','ChinaBOT')`；或
  2. Tracker 补充条件满足：`System <> 'DDD'`、`TrackerStatus = '审批结束'`、`IBMProcessor IN ('ChinaBot','ChinaBOT')`
- `MANUAL_PROCESS`：不满足 RPA 条件，但存在审批外人工 Activity
- 其他：既不满足 RPA 条件，也没有审批外人工 Activity

正式结果：

- 总 Case：21,578
- `RPA_PROCESS`：11,520
- `MANUAL_PROCESS`：9,735
- 其他：323

## 二、为什么人工介入总数是 12,504

交叉验证结果：

| 最终分类 | 曾人工介入 | Case数 |
|---|---|---:|
| MANUAL_PROCESS | YES | 9,735 |
| RPA_PROCESS | YES | 2,769 |
| RPA_PROCESS | NO | 8,751 |
| 其他 | NO | 323 |

因此：

```text
曾发生审批外人工介入
= 9,735 + 2,769
= 12,504
```

`9,735` 是最终归类为人工的 Case；`12,504` 是流程中曾经发生过人工介入的 Case。两者不是同一个指标。

## 三、2,769 件的正确业务解释

已确认事实：

```text
2,769 = RPA_PROCESS 且曾发生审批外人工介入
```

这说明这些 Case：

- 流程中出现过人工处理；
- 最终仍满足当前 RPA 分类条件；
- 是“人工介入后仍具备完成 RPA 能力”的重要机会池。

但 2,769 不能在未校验时间顺序前直接等同于：

```text
人工介入后实际重新回到 BOT
```

严格的时间路径应验证：

```text
存在某次审批外人工事件时间
<
某次 ChinaBot 录入完成事件时间
```

中间可以存在：

- OCR待处理
- OCR完成
- 意见征询
- 其他系统/BOT活动

不应要求“最后一次人工活动时间 < BOT录入完成时间”，因为人工后经过 OCR 等中间节点再由 BOT 完成是合理流程。

## 四、337 与 2,769 不矛盾

- `2,769`：最终归为 RPA，且流程中曾有人工介入；当前分类本身不校验人工与 BOT 的先后顺序。
- `337`：`bot_recovery_case_tbl.HAS_MANUAL_TO_BOT = 1`，明确验证了人工事件之后又出现 BOT。

因此：

```text
2,769 = RPA人工介入机会池
337   = 已验证人工后重新出现BOT的路径子集
```

还应进一步区分：

```text
人工后出现BOT
≠ BOT最终录入完成
≠ RPA稳定成功
```

## 五、9,735 件不能理解为“没有机器人参与”

`MANUAL_PROCESS` 只代表：

```text
不满足当前 RPA_PROCESS 判定
且存在审批外人工 Activity
```

其中仍可能存在 BOT 参与，例如：

1. 纯人工：没有任何 ChinaBot 活动；
2. BOT先参与后转人工；
3. 人工之后仍有 BOT 活动，但 BOT 没有完成录入；
4. BOT → 人工 → BOT 反复交替，最终仍未满足 RPA 条件；
5. BOT只执行 OCR、意见征询或报错活动，最终由人工录入完成。

因此 9,735 应继续按路径类型、Activity、System、OCR Feedback、PO结果、Comments 等维度拆解。

## 六、下一步分析框架

### 对 2,769 件

分析目标：为什么这些 Case 虽有人工介入，最终仍能满足 RPA 条件？

重点看：

- 人工 Activity 类型
- 人工与 BOT 的时间顺序
- 是否最终由 ChinaBot 录入完成
- 中间是否经过 OCR待处理/OCR完成/意见征询
- 哪些人工修复动作可以标准化并自动回流

### 对 9,735 件

分析目标：为什么这些 Case 最终没有满足 RPA 条件？

重点拆分：

- 纯人工
- BOT转人工
- 人工后BOT未完成
- BOT/人工反复交替
- 最终人工录入完成
- 最终废弃删除/RPA范围外/其他终点

### 对照分析

将 2,769 与 9,735 对比：

- Activity 分布
- System
- OCR Feedback
- Request Type
- PO Result / PO Compare Result
- ESign Result
- Prepayment Result
- Comments 原因分类
- 重试次数与最终 BOT 状态

目标是找到：

```text
哪些人工处理动作能让Case重新具备RPA条件
哪些问题会让Case永久停留在人工流程
```

## 七、口径使用原则

1. 最终分类、人工介入、人工后BOT、BOT最终完成必须拆成不同指标。
2. 所有组件使用相同的 DDD、审批结束和 Case 基数。
3. 分类合计必须回到 21,578。
4. Activity 分组中的 Case 数不能直接相加，因为同一 UUID 可出现多个 Activity。
5. Tracker 的 `IBMProcessor = ChinaBot` 只能补充最终归属，不能证明事件时间先后。
6. 时间路径必须使用真实事件时间验证。
7. 2,769 是机会池，不直接等于已验证的回BOT成功数。
8. 9,735 是最终人工分类，不等于全程无BOT参与。
