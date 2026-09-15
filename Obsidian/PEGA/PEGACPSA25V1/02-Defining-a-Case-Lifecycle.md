---
tags:
  - area/pega
  - certification/pegacpsa25v1
  - module/defining-case-lifecycle
status: reviewed
---

# Defining a Case Lifecycle

[[../PEGA_MOC|← PEGA Knowledge Map]] · [[STUDY_RULES|学习规则]] · [[01-Low-code-defined|上一模块]]

> Certification: **Certified Pega System Architect '25**  
> Exam: **PEGACPSA25V1**  
> Source: Pega Academy — System Architect Mission / Defining a Case Lifecycle  
> Status: **已完成 Case Lifecycle design、Multi-step Forms、Draft mode、官方交互题与 Module Quiz 练习**

## 1. Case Lifecycle 核心结构

一个 Case Lifecycle 描述一个 Case 从开始到业务结果的完整处理路径。

```text
Case Type
  └─ Stage
      └─ Process
          └─ Step
```

- **Case Type**：可重复业务事务的抽象模型 / 模板。
- **Case**：Case Type 的一个具体实例。
- **Stage**：生命周期中的主要业务阶段。
- **Process**：Stage 内的一组相关工作。
- **Step**：用户或系统执行的具体动作。

Java 类比：`Case Type ≈ class`，`Case ≈ object instance`。

## 2. Stage 类型

官方练习题明确考查四种 Stage 类型。

| Stage type | 作用 | 考试判断词 |
|---|---|---|
| **Create Stage** | 用户录入创建 Case 所需的初始数据 | initial data / first stage |
| **Primary Stage** | 正常业务处理路径 | usual Case processing / primary path |
| **Alternate Stage** | 处理偏离正常主路径的情况 | deviation from the primary path / exception |
| **Resolution Stage** | 定义 Case Lifecycle 结束时的处理 | end of the Case Lifecycle / resolve |

快速判断：

> **Create = 开始录数据；Primary = 正常主流程；Alternate = 偏离主流程；Resolution = 生命周期结束。**

重要英文：`deviation = 偏离 / 偏差`。

## 3. Case Lifecycle design

Case Lifecycle 设计不是只看某一个 Step，而是设计 Case 如何从开始到结束分阶段推进。

典型结构：

```text
Booking Case Type
  Reservation request
      ↓
  Validation
      ↓
  Confirmation
```

考试反射：

> **Case Type + multiple Stages → Case Lifecycle design**

## 4. Process 顺序与并行

一个 Stage 可以包含多个 Processes。

Processes 可以按顺序执行，也可以并行执行。

员工入职例子：

```text
Setup Stage
├─ Create Facilities Setup
└─ Create IT Setup
```

Facilities 和 IT 可以同时准备，因此配置为 **Parallel Processes**。

关键词：

- `at the same time`
- `simultaneously`
- `parallel`

看到“同时进行”优先想到 **Parallel Processes**。

## 5. Stage transitions

当一个 Stage 中的所有 Processes 完成后，可以配置下一步行为。

### Automatically move to next stage

自动进入下一个 Stage。

适合正常顺序推进：

```text
Stage A → Stage B
```

### Wait for a user action

当前 Stage 完成后先停住，等待用户决定下一步。

### Resolve the case

当前 Stage 完成后直接结束 / 结案整个 Case。

### Create Stage 限制

官方正文指出：

> **You cannot configure Stage transitions on the Create Stage.**

即 Create Stage 不能配置上述普通 Stage transition。

## 6. Change Stage Automation

**Change Stage** 是 Automation Step，用来把 Case 自动切换到一个指定 Stage。

```text
当前 Stage → specific Stage
```

它与 `Automatically move to next stage` 的区别：

- **Automatically move to next stage**：按正常顺序去“下一个” Stage。
- **Change Stage**：显式跳到“指定” Stage。

官方 Quiz 也确认两种推进 Stage 的配置方式：

1. **Add a Change Stage Step**
2. **Configure automatic Stage transitioning**

`Resolve the Case` 是结案，不是推进到下一 Stage。

## 7. Step transitions

默认情况下，用户完成当前 Step 后通过 **Submit** 推进处理。

如果希望用户能返回上一步修改信息，可配置：

> **Allow users to go back to the previous step**

启用后出现 **Previous** 按钮。

需要区分：

- `Previous`：返回前一个 Step / View。
- `Submit`：提交当前 Assignment / 表单；具体 UI 语境要结合题目判断。
- `Resolve`：结束整个 Case。

本模块曾出现一次 `Submit` 与 `Resolve` 混淆，后续需要随机复习。

## 8. Multi-step Forms

### 核心定义

> **A Multi-step Form represents a single Assignment completed by a single user.**

本质：

> **one Assignment + one user + multiple related Views**

Multi-step Form 用来把 long / complex form 拆成多个 focused and concise Views，让用户按逻辑顺序完成复杂输入。

### 典型适用场景

适合：

- 一个用户
- 一个 Assignment
- 多组相关信息
- 多个 View
- 按逻辑顺序填写
- 提交前可以前后返回修改

例如 Job Application：

```text
Personal information
→ Job history
→ Cover letter
```

不典型适合：

- 多个角色分别处理
- 多用户审批链
- 多个独立 Process
- 多团队并行工作

### Create Stage 默认行为

官方正文：

> **The default Create Process in the Create Stage is a Multi-step Form.**

### Navigation styles

Multi-step Forms 支持：

- **Standard navigation**
- **Vertical navigation**
- **Horizontal navigation**

### Navigation buttons

- **Next**：下一个 View
- **Previous**：上一个 View
- **Submit**：最后提交 Multi-step Form

关键词：`navigate back and forth = 前后移动`。

## 9. Draft mode

### 作用

在 App Studio 创建 Case Type 时，Processes 默认以 **draft mode** 创建。

Draft mode 的核心价值：

> **配置还不完整、甚至存在错误时，也可以先运行 Case Type，检查 run-time behavior。**

### Production 前必须关闭

应用发布到 production 之前，必须关闭 draft mode。

如果没有关闭，会产生 **guardrail violation**。

### Guardrails

Guardrails 是 Pega 的应用设计最佳实践约束 / 检查。

开发期间某些 violation 可以暂时存在，但 production release 前必须解决。

### App Studio 自动关闭

在 App Studio 保存 Case Type 时，对**没有 configuration issues 的 Process**，Pega 会自动关闭 draft mode。

### Dev Studio 手动关闭

> **You can only manually turn off draft mode from Dev Studio.**

因此：

- App Studio：保存时可自动关闭无错误 Process 的 draft mode。
- Dev Studio：手动关闭 draft mode。

## 10. 官方题暴露出的深层考点

本模块的重要经验：**认证知识不只存在于正文。**

例如正文没有完整展开四种 Stage type，但官方交互题 / Module Quiz 明确考查：

- Create Stage
- Primary Stage
- Alternate Stage
- Resolution Stage

因此后续学习必须同时覆盖：

> **正文 + 页面图示 + 交互练习 + Module Quiz + 官方反馈**

不能只根据正文表面内容判断考试范围。

## 11. 英文高频词

| English | 中文 / 判断 |
|---|---|
| lifecycle | 生命周期 |
| stage | 阶段 |
| process | 流程 |
| step | 步骤 / 动作 |
| instance | 实例 |
| outcome | 业务结果 |
| transition | 流转 / 转换 |
| advance | 推进 |
| automatically | 自动地 |
| resolve the case | 结案 / 结束 Case |
| specific Stage | 指定 Stage |
| previous | 上一个 / 前一个 |
| parallel | 并行 |
| at the same time | 同时 |
| deviation | 偏离 / 偏差 |
| primary path | 主路径 / 正常路径 |
| initial data | 初始数据 |
| usual Case processing | 正常 Case 处理 |
| single Assignment | 单个 Assignment |
| single user | 单个用户 |
| logical sequence | 逻辑顺序 |
| concise | 简洁的 |
| navigate back and forth | 前后导航 / 前后移动 |
| draft mode | 草稿模式 |
| run-time behavior | 运行时行为 |
| configuration issues | 配置问题 |
| guardrail violation | Guardrail 违规 / 最佳实践违规 |
| production release | 生产发布 |

## 12. 本模块错题与易混点

### Stage 类型最初混淆

曾将“第一个收集初始信息”的 Stage 选为 Alternate Stage。

正确：

> `initial data / first stage` → **Create Stage**

曾将“拒绝后补材料、之后继续正常流程”的 Stage 选为 Resolution Stage。

正确：

> `deviation / exception / return to normal flow` → **Alternate Stage**

### Parallel 不熟

最初没有把 `at the same time` 与 Parallel Processes 建立直接联系。

固定反射：

> `at the same time / simultaneously` → **Parallel Processes**

### Submit vs Resolve

曾将“继续处理”误选为 Resolve。

固定判断：

> **Resolve = 结束整个 Case**，不是普通推进。

### Draft mode 目的

最初误选成“阻止测试”。

正确：

> **Draft mode 恰恰允许配置未完成时先运行 / 测试 Case Type。**

## 13. 当前掌握情况

- Case Type / Case / Stage / Process / Step：已掌握基础结构。
- Case Lifecycle design：已掌握基本判断。
- Stage type：已补齐 Create / Primary / Alternate / Resolution。
- Stage transitions：基本掌握。
- Change Stage：基本掌握。
- Parallel Process：已理解，需随机复习英文关键词。
- Multi-step Forms：5 题基础练习 **5/5**，官方场景题判断正确。
- Draft mode：5 题练习 **4/5**，错误点为 draft mode 目的。

## 14. 后续随机复习重点

1. Create vs Alternate vs Resolution Stage。
2. `deviation from the primary path` → Alternate Stage。
3. `at the same time` → Parallel Processes。
4. Submit vs Resolve。
5. automatic Stage transition vs Change Stage。
6. Multi-step Form：single user + single Assignment + multiple Views。
7. Draft mode 的目的、Production 前关闭、Dev Studio 手动关闭。

## 15. 一句话总结

> **Case Lifecycle 决定 Case 怎么从开始走到结束；Stage 定大阶段，Process 组织工作，Step 执行动作；Multi-step Form 用一个用户的多个 View 拆复杂 Assignment；Draft mode 让未完成配置先跑起来，但上线前必须清掉问题并关闭。**

Related: [[01-Low-code-defined]] · [[STUDY_RULES]]
