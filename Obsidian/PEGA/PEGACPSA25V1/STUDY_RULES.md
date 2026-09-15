---
tags:
  - area/pega
  - certification/pegacpsa25v1
  - study-rules
---

# PEGACPSA25V1 学习与认证训练规则

[[../PEGA_MOC|← PEGA Knowledge Map]]

## 目标

目标认证：**Certified Pega System Architect '25**  
考试代码：**PEGACPSA25V1**

学习目标不是单纯刷题或背答案，而是做到：

1. 真正理解 Pega 的核心概念和业务场景。
2. 能看懂 PEGACPSA25V1 英文考试题干。
3. 能根据场景判断正确的 Pega 配置或最佳实践。
4. 通过持续练习建立自己的错题库、英文词库和考试知识体系。

官方主教材：Pega Academy — System Architect Mission v8。

## 总体学习原则

### 理解优先，不死记答案

每个知识点先回答：这个功能解决什么问题、什么时候使用、Pega 为什么这样设计。理解以后再进入考试题。

### 官方教程是知识来源，考试题是检验手段

固定顺序：

**官方 Mission → 中文理解 → 实际业务例子 → 英文关键词 → 考试场景题 → 错题复习**

不要求一次性把整个 Mission 看完再刷题。每学一个小知识点就立即做对应题验证。

### 一次只学习一个小主题

基础概念未掌握前不随意扩展复杂内容。例如 Case Lifecycle 按 Case → Stage → Process → Step → Case Lifecycle 逐层学习。

## 固定学习流程

### Step 1：中文理解

先用中文讲清楚是什么、为什么存在、什么时候使用、与相似功能有什么区别。

### Step 2：结合真实业务场景

尽量用简单业务流程理解 Pega，而不是单纯背定义。

```text
Case
 └─ Stage
     └─ Process
         └─ Step
```

### Step 3：学习考试必备英文关键词

不做泛英语学习，只积累 PEGACPSA25V1 高频词。做题过程中遇到新的高频词持续追加。

### Step 4：训练英文题干拆解

固定方法：

**英文题干 → 找关键词 → 还原业务需求 → 定位 Pega 知识点 → 选择答案**

重点不是逐词翻译，而是读懂“谁、要做什么、有什么条件”。

### Step 5：考试题训练

默认一次一道题：

1. 只显示英文原题和选项。
2. 先独立作答。
3. 回答前不提示答案。
4. 回答后公布答案并用中文解释。
5. 提取关键英文词。
6. 对应到官方 Pega 知识点。
7. 必要时解释错误选项。

## 题目难度

- **Level 1 基础概念题**：Case、Stage、Process、Step、Assignment、Data Object、View 等。
- **Level 2 简单场景题**：根据实际需求判断功能。
- **Level 3 考试风格场景题**：most appropriate、best practice、which configuration 等。
- **Level 4 综合题**：多个知识点混合。

基础正确率稳定后再升难度。

## 错题规则

每道错题至少记录：

```text
Topic:
Question:
My Answer:
Correct Answer:
Why I was wrong:
Correct concept:
English keywords:
Review date:
```

错误类型：知识点不会、概念混淆、英文题干没看懂、关键词漏看、多选少选/多选、Best Practice 判断错误。

## 英文专项规则

英语跟着 Pega 题目学，不单独学泛英语。

重点识别：

- 动作：configure / route / assign / validate / create / update
- 条件：when / if / based on / depending on
- 对象：case / assignment / data / view / process
- 题目要求：best / most appropriate / should / ensure / two actions

每道题提取：关键词、固定搭配、真正影响答案的句子、可忽略背景信息。

## 复习规则

- 当天：新知识 + 立即练习
- 第 2 天：快速复习前一天错题
- 第 4～7 天：再次抽查
- 后续：随机混入旧题

掌握标准：**在没有提示的情况下可以独立判断。**

## 官方教程学习原则

每个 Module 都按：

```text
看懂 → 解释出来 → 做题 → 发现问题 → 回教程 → 再做题
```

连续出错就暂停推进新内容。

## 助手训练规则

1. 一次默认只出一道题。
2. 用户回答前不泄露答案。
3. 先保证基础理解，再扩展难题。
4. 不加入超出 CPSA 范围的源码级内容。
5. 解释优先使用中文，保留关键 Pega 英文术语。
6. 英文没看懂时先拆题，而不是只给整句翻译。
7. 错题必须解释为什么错。
8. 高频错误自动进入后续复习。
9. 训练目标是考试能力 + 实际理解，不是背题库。

## 阶段目标

1. 建立基础概念。
2. 按模块学习并练习。
3. 混合场景题。
4. Mock Exam：检查正确率、英文阅读速度、场景判断速度、易混点和多选题稳定性。

## 核心原则

> **理解 Pega → 看懂英文需求 → 判断正确配置 → 用题目验证理解。**

Related: [[01-Low-code-defined]]
