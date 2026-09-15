---
tags:
  - area/pega
  - certification/pegacpsa25v1
  - module/low-code-defined
status: reviewed
---

# Low-code defined

[[../PEGA_MOC|← PEGA Knowledge Map]] · [[STUDY_RULES|学习规则]]

> Certification: **Certified Pega System Architect '25**  
> Exam: **PEGACPSA25V1**  
> Source: Pega Academy — System Architect Mission / Low-code defined  
> Status: **已完成模块学习 + 官方 5 题 + 多轮复盘 + 考试风格巩固**

## 核心结论

Pega low-code 的本质不是“完全不写代码”，而是尽量通过**可视化和声明式配置**表达业务逻辑，由平台生成和管理大量底层实现。

判断 Pega low-code 的常见提示词：visual / graphical、collaborate、business logic、omni-channel、reuse、graphical mapping、notifications、deadline tracking。

Traditional development 常见提示词：large teams of developers、proprietary solutions、one-size-fits-all、大量自定义实现。

## 四个 Studio

### App Studio

定位：**常规 low-code 应用开发的主要入口**。

典型任务：Case lifecycle、Process / workflow、Data model、UI / View、常规业务配置。

典型角色：Business Analyst、Citizen Developer、Front-end Designer；System Architect 也应优先使用 App Studio。

考试反射：

> **业务流程、数据、界面、普通配置 → App Studio**

### Dev Studio

定位：**高级技术配置和底层 Rule 配置**。

典型任务：advanced rule settings、security、database class mapping、Flow Rule 高级配置、修改 Rule scope。

判断关键词：advanced、underlying rule、not available / not exposed in App Studio、increase / extend scope、security、database mapping。

考试反射：

> **高级规则、底层配置、Rule scope → Dev Studio**

### Admin Studio

定位：**系统运行、运维和监控**。

关键词：monitor、background processing、queue processors、operational health、system health、technical administration。

考试反射：

> **监控、后台任务、系统健康 → Admin Studio**

### Prediction Studio

定位：**分析、预测模型、AI / ML、业务决策支持**。

关键词：data scientist、predictive model、analytics、customer behavior、business decision support。

考试反射：

> **分析 / 预测 / data scientist → Prediction Studio**

## App Studio 与 Dev Studio 的关系

两者不是两个独立应用，而是在不同层次上操作同一个 Pega 应用。

| App Studio | Dev Studio |
|---|---|
| Field | Property |
| Goal and Deadline | Service-Level Agreement (SLA) |
| User | Operator |
| Team | Work Group |

核心原则：

> **能在 App Studio 完成，就优先 App Studio；只有高级/底层配置才进入 Dev Studio。**

## Rule reuse 与 scope

### reuse

`reuse = 复用 / 再次使用`，**不是 copy**。

多个 Case Type 需要使用同一个 Process 时，应该考虑复用，而不是复制出多个重复流程。

### scope

`scope = 作用范围 / 可用范围`。

典型流程：

1. Business Analyst 在 App Studio 创建 Process。
2. System Architect 在 Dev Studio 扩大底层 Flow Rule 的 scope。
3. Business Analyst 回到 App Studio，在其他 Case Type 中复用 Process。

考试反射：

> **reuse + more Case Types + no duplicate copies → increase / extend scope**

## Integration 基础

- **有 API → Connector / Integration**
- **没有 API 的 legacy system → RPA**

不要看到 integration 就条件反射选 REST connector；先看题干是否明确说 `does not provide / expose an API`。

Pega 也可以通过 graphical mapping 把 external system 的数据映射进应用，形成 holistic view。

## 英文高频词

| English | 中文 |
|---|---|
| stakeholder | 项目相关人员 / 利益相关者 |
| collaborate | 协作 |
| omni-channel | 全渠道 / 多渠道 |
| unify | 统一 |
| proprietary solution | 专有解决方案 |
| one-size-fits-all | 一刀切 / 一套方案适用所有场景 |
| obtain | 获取 |
| graphically map | 图形化映射 |
| holistic view | 整体视图 |
| scope | 作用范围 |
| extend / increase the scope | 扩大作用范围 |
| reuse | 复用 |
| duplicate copy | 重复副本 |
| underlying rule | 底层规则 |
| analytics | 分析 |
| decision-maker | 决策者 |
| monitoring | 监控 |
| deal with | 处理 / 应对 / 与……打交道 |
| without dealing with | 无需处理 / 不需要接触 |
| background processing | 后台处理 |
| operational health | 运行健康状态 |
| predictive model | 预测模型 |
| expose | 提供 / 暴露功能、API、设置 |
| legacy system | 旧系统 |

## 本模块主要错题与误区

### 1. Prediction Studio 混淆

出现过把 Prediction Studio 误选成 Admin / Dev / App Studio。

固定判断：

> `data scientist + analytics + predictive model + business decisions` → **Prediction Studio**

### 2. 无 API 场景误选 REST Connector

题干：`legacy application does not provide an API`

正确判断：

> 有 API → Connector；无 API → RPA

### 3. `without dealing with` 理解错误

`deal with = 处理 / 应对`，所以：

> `without dealing with advanced technical rules` = 不需要接触或处理高级技术规则

这种场景通常提示优先使用 App Studio。

### 4. reuse 误解成 copy

`reuse = 复用`，`copy = 复制`。

多个 Case Type 使用同一 Process 时，优先考虑扩大 Rule scope，而不是复制流程。

### 5. 系统监控误选 App Studio

`monitor queue processors / operational status / system health` → **Admin Studio**。

## 英文做题方法

当前主要问题不是 Pega 概念完全不会，而是英文长句和个别关键动词会影响判断。

固定流程：

> **先拆英文 → 找关键词 → 中文还原场景 → 再判断 Pega 知识点**

特别注意限制条件：without、not available、does not provide、not exposed、only、advanced。

## 2026-09-15 巩固结果

- 第一轮基础复盘：**5 / 5**
- 英文词汇专项：**4 / 5**，`reuse` 误选为“复制”
- 考试风格题：主要错误集中在 Prediction Studio、Admin Studio、reuse / scope

### 当前已基本掌握

- App Studio 与 Dev Studio 区别
- App Studio 优先原则
- Dev Studio 高级配置定位
- Admin Studio 基本定位
- Prediction Studio 基本定位
- low-code 与 traditional development 区别
- API vs RPA
- scope / underlying Rule 基础含义

### 后续随机复习重点

1. Prediction Studio 场景识别
2. Admin Studio 场景识别
3. reuse ≠ copy
4. scope / underlying Rule
5. 英文长句限制条件

## 一句话总结

> **App 做业务，Dev 做高级技术，Admin 管运行，Prediction 做分析预测；先看懂英文限制条件，再判断 Studio。**
