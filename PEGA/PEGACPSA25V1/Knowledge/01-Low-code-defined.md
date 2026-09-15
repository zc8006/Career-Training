# Low-code defined — Zhou Knowledge Base

> Certification: **Certified Pega System Architect '25**  
> Exam: **PEGACPSA25V1**  
> Source: Pega Academy — System Architect Mission / Low-code defined  
> Status: **已完成模块学习 + 官方 5 题 + 两轮复盘 + 考试风格巩固**

---

## 1. 本模块学习目标

这一模块的重点不是背定义，而是理解以下几个问题：

1. Pega 为什么叫 **low-code**。
2. **App Studio / Dev Studio / Admin Studio / Prediction Studio** 分别做什么。
3. 什么场景优先使用 App Studio，什么场景需要进入 Dev Studio。
4. Pega 如何通过可视化方式支持流程、复用、集成和数据映射。
5. 如何从英文题干中识别关键动作和角色。

---

## 2. 核心知识点

### 2.1 Low-code 的本质

Pega low-code 的核心不是“完全不写代码”，而是：

> 尽量通过可视化和声明式配置表达业务逻辑，由平台生成和管理大量底层实现。

典型价值：

- 减少手写代码。
- 更快构建业务应用。
- 让业务人员和技术人员使用共同的可视化方式协作。
- 更关注业务逻辑，而不是底层实现。
- 支持多渠道、通知、流程跟踪、数据映射等能力。
- 平台可以为开发人员生成底层代码。

### 2.2 Traditional development 与 Pega low-code

**Pega low-code 常见提示词：**

- visual / graphical
- collaborate
- business logic
- omni-channel
- reusable / reuse
- graphical mapping
- notifications
- deadline tracking
- create the code for you

**Traditional development 常见提示词：**

- large teams of developers
- proprietary solutions
- one-size-fits-all
- 大量自定义开发

判断原则：

> 题目强调“可视化、业务协作、统一渠道、复用、配置化”时，优先考虑 Pega low-code。  
> 题目强调“大型开发团队、专有实现、重度定制”时，更接近 Traditional development。

---

## 3. 四个 Studio

### 3.1 App Studio

定位：**低代码应用开发的主要入口。**

典型任务：

- Case lifecycle
- Process / workflow
- Data model
- UI / View
- 常规业务配置

典型用户：

- Business Analyst
- Citizen Developer
- Front-end Designer
- System Architect 也应优先使用 App Studio

最佳实践：

> 即使是 System Architect，也应先使用 App Studio；只有 App Studio 无法完成时，再进入 Dev Studio。

### 3.2 Dev Studio

定位：**高级技术配置和底层 Rule 配置。**

典型任务：

- advanced rule settings
- security configuration
- database class mapping
- Flow Rule 的高级配置
- 修改 Rule scope
- 更深入的技术配置

典型用户：

- System Architect
- Full-Stack Developer
- Database Administrator
- Security Administrator

判断关键词：

- advanced
- underlying rule
- not available in App Studio
- increase / extend scope
- security
- database mapping

### 3.3 Admin Studio

定位：**系统运行、运维和监控。**

典型任务：

- system health monitoring
- background processing
- operational health
- technical administration
- queue processors / 后台处理器监控

典型用户：

- System Administrator

判断关键词：

- monitor
- background processing
- administration
- operational health
- system health

### 3.4 Prediction Studio

定位：**预测分析、AI、机器学习和业务决策支持。**

典型任务：

- predictive models
- analytics
- customer behavior analysis
- business decision support

典型用户：

- Data Scientist
- Business decision-maker

判断关键词：

- data scientist
- predictive model
- analytics
- business decisions

当前仍需强化：

> **Prediction Studio = 分析 / 预测 / 数据科学**，不要和 Dev Studio 或 App Studio 混淆。

---

## 4. App Studio 与 Dev Studio 的关系

两者不是两个完全独立的世界，而是在不同层次上操作同一个 Pega 应用。

常见名称对应：

| App Studio | Dev Studio |
|---|---|
| Field | Property |
| Goal and Deadline | Service-Level Agreement (SLA) |
| User | Operator |
| Team | Work Group |

理解方式：

> App Studio 使用更业务化、更易懂的名称。  
> Dev Studio 暴露更底层、更技术化的 Rule 和配置。

固定判断：

> **能在 App Studio 完成，就优先 App Studio；只有高级/底层配置才进入 Dev Studio。**

---

## 5. Rule reuse 与 scope

### 5.1 reuse

**reuse = 复用 / 再次使用。**

一个 Process 不必只服务一个 Case Type，可以通过配置扩大使用范围，在更多 Case Type 或整个应用中复用。

重要区分：

> **reuse ≠ copy**

复制意味着产生重复 Process；复用表示多个 Case Type 共享同一个已有 Process。

### 5.2 scope

**scope = 作用范围 / 可用范围。**

典型题型：

- Business Analyst 在 App Studio 创建一个业务 Process。
- System Architect 在 Dev Studio 扩大底层 Flow Rule 的 scope。
- Business Analyst 再回到 App Studio，在其他 Case Type 中复用这个 Process。

固定判断：

> 创建普通业务流程 → App Studio  
> 修改底层 Rule 的 scope → Dev Studio

考试反射：

> **reuse + more Case Types + no duplicate copies → increase / extend scope**

---

## 6. Integration 基础理解

### 6.1 有 API

如果外部系统提供 API，优先考虑：

> Connector / Integration

### 6.2 没有 API 的 legacy system

如果旧系统没有 API，可以考虑：

> RPA（Robotic Process Automation）

记忆：

> **有 API → Connector**  
> **无 API 的旧系统 → RPA**

### 6.3 graphical mapping

Pega 可以通过图形化方式将外部数据映射到应用中。

典型关键词：

- external systems
- obtain the data
- graphically map
- holistic view

---

## 7. 本模块英文词库

| English | 中文 |
|---|---|
| stakeholder | 利益相关者 / 项目相关人员 |
| collaborate | 协作 |
| common visual language | 共同的可视化语言 |
| focus on business logic | 专注于业务逻辑 |
| omni-channel | 全渠道 / 多渠道 |
| unify | 统一 |
| proprietary solution | 专有解决方案 |
| one-size-fits-all | 一套方案适用于所有场景 / 一刀切 |
| external system | 外部系统 |
| obtain | 获取 |
| graphically map | 图形化映射 |
| holistic view | 整体视图 |
| scope | 作用范围 |
| extend / increase the scope | 扩大作用范围 |
| reuse | 复用 |
| duplicate copy | 重复副本 |
| entire | 整个 |
| underlying rule | 底层规则 |
| analytics | 分析 |
| decision-maker | 决策者 |
| monitoring | 监控 |
| involvement | 参与 |
| deal with | 处理 / 应对 / 与……打交道 |
| without dealing with | 无需处理 / 不需要接触 |
| background processing | 后台处理 |
| operational health | 运行健康状态 |
| predictive model | 预测模型 |
| expose | 提供 / 暴露（功能、API、设置） |
| not exposed in App Studio | App Studio 中没有开放出来 |
| legacy system | 旧系统 |

---

## 8. 错题与误区记录

### 错误 1：Prediction Studio 与 Admin Studio 混淆

题型：

> A data scientist wants to build and manage predictive models...

错误原因：

- 没有把 `data scientist`、`predictive models` 与 Prediction Studio 建立稳定联系。

正确判断：

> Data Scientist + Predictive Model → Prediction Studio

### 错误 2：无 API 场景误选 REST Connector

题型：

> legacy application does not provide an API

错误原因：

- 看到 integration 就条件反射想到 REST Connector。
- 忽略了 `does not provide an API`。

正确判断：

> 有 API → Connector  
> 无 API → RPA

### 错误 3：`without dealing with advanced technical rules` 理解错误

原误解：

- 误以为 `dealing with` 是“设置规则”。

正确理解：

> deal with = 处理 / 应对  
> without dealing with advanced technical rules = 不需要接触或处理高级技术规则

因此该场景应优先使用 App Studio。

### 错误 4：Prediction Studio 与 Dev Studio 再次混淆

题型：

> analyze customer behavior and create predictive models to support business decisions

正确判断：

> analytics + predictive models + business decisions → Prediction Studio

### 错误 5：`reuse` 误选为“复制”

正确理解：

> reuse = 复用 / 再次使用  
> copy = 复制

考试中看到多个 Case Type 需要使用同一个 Process，应优先考虑复用，而不是复制。

### 错误 6：复用场景误选 Copy Process

题型：

> reuse the same Process in train and bus Case Types

错误原因：

- 从“能实现”的角度选了 copy，没有从 Pega 的 reuse / scope 设计思想判断。

正确判断：

> Increase the scope of the underlying Flow Rule in Dev Studio.

### 错误 7：Prediction Studio 场景误选 App Studio

题型：

> analytics, predictive modeling, business decision support

正确判断：

> Prediction Studio

### 错误 8：系统监控场景误选 App Studio

题型：

> monitor queue processors and review the operational status of the Pega environment

正确判断：

> Admin Studio

---

## 9. 英文做题方法

本模块暴露出的主要问题不是 Pega 概念完全不会，而是：

> 英文长句和个别关键动词会影响知识点判断。

后续固定采用：

**先拆英文 → 找关键词 → 中文还原场景 → 再判断 Pega 知识点**

例如：

> A business user wants to create and modify a case workflow without dealing with advanced technical rules.

拆解：

- business user = 业务用户
- create and modify a case workflow = 创建和修改 Case 流程
- without dealing with = 无需处理
- advanced technical rules = 高级技术规则

还原：

> 业务用户希望配置 Case 流程，但不想接触高级技术规则。

结论：

> App Studio

---

## 10. 2026-09-15 巩固结果

### 第一轮 5 题

结果：**5 / 5**

说明：

- App Studio 已较稳定。
- Dev Studio 已较稳定。
- Prediction Studio 本轮答对。
- Admin Studio 本轮答对。
- Pega low-code 基本概念稳定。

### 英文词汇专项 5 题

结果：**4 / 5**

错误：

- `reuse` 误选为“复制”。

结论：

> `reuse = 复用` 需要继续随机复习。

### 考试风格场景题 10 题

主要错误：

1. `reuse the same Process` 场景误选 Copy Process。
2. `analytics / predictive modeling / business decision support` 误选 App Studio。
3. `monitor queue processors / operational status` 误选 App Studio。

后续重点：

- Prediction Studio
- Admin Studio
- reuse ≠ copy
- scope / underlying Rule

---

## 11. 当前掌握状态

### 已基本掌握

- App Studio 与 Dev Studio 的区别
- App Studio 优先原则
- Dev Studio 的高级配置定位
- Admin Studio 基本定位
- Prediction Studio 基本定位
- low-code 与 traditional development 的区别
- 有 API → Connector；无 API → RPA
- scope / underlying Rule 的基本含义

### 仍需随机复习

1. Prediction Studio 场景识别
2. Admin Studio 场景识别
3. reuse 与 copy 的区别
4. 英文长句中的限制条件
5. Pega 高频英文词快速识别

重点限制词：

- without
- not available
- does not provide
- not exposed
- only
- advanced

---

## 12. 后续复习策略

进入第二模块后，不再连续大量复习本模块，但会在新模块训练中随机插入旧题。

优先随机抽查：

- Prediction Studio
- Admin Studio
- reuse / scope
- App Studio vs Dev Studio
- API vs RPA

目标：

> 在没有提示、没有完整中文翻译的情况下，仍能通过关键词稳定判断。

---

## 13. 一句话总结

> **App 做业务，Dev 做高级技术，Admin 管运行，Prediction 做分析预测；reuse 是复用不是复制，跨 Case Type 共享 Process 要想到 scope。**
