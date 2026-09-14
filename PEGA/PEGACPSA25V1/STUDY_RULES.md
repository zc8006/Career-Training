# PEGACPSA25V1 学习与认证训练规则

## 目标

目标认证：**Certified Pega System Architect '25**  
考试代码：**PEGACPSA25V1**

学习目标不是单纯刷题或背答案，而是做到：

1. 真正理解 Pega 的核心概念和业务场景。
2. 能看懂 PEGACPSA25V1 英文考试题干。
3. 能根据场景判断正确的 Pega 配置或最佳实践。
4. 通过持续练习建立自己的错题库、英文词库和考试知识体系。

官方主教材：
- Pega Academy - System Architect Mission v8
- https://academy.pega.com/mission/system-architect/v8

---

## 一、总体学习原则

### 1. 理解优先，不死记答案

每个知识点先回答三个问题：

- 这个功能是解决什么问题的？
- 在实际项目中什么时候使用？
- Pega 为什么要这样设计？

只有理解以后再进入考试题。

不采用“看到题目 → 直接记答案”的方式。

---

### 2. 官方教程是知识来源，考试题是检验手段

学习顺序：

**官方 Mission → 中文理解 → 实际业务例子 → 英文关键词 → 考试场景题 → 错题复习**

不要求一次性把整个 Mission 看完再刷题。

每学习一个小知识点，就立即做对应的题进行验证。

---

### 3. 一次只学习一个小主题

避免一次塞入大量概念。

例如学习 Case Lifecycle 时，按以下顺序逐步学习：

- Case
- Stage
- Process
- Step
- Case Lifecycle

基础概念没有掌握之前，不随意扩展到复杂内容。

---

## 二、固定学习流程

以后每个 Pega Topic 按下面的固定结构训练。

### Step 1：中文理解

先用中文解释知识点，不直接照搬官方英文教材。

重点讲清楚：

- 是什么
- 为什么存在
- 什么时候使用
- 和相似功能有什么区别

---

### Step 2：结合真实业务场景

尽量用简单的实际系统场景理解 Pega。

例如报销流程：

```text
Expense Case
  ↓
Submit Stage
  ↓
Approval Stage
  ↓
Payment Stage
```

进一步拆分：

```text
Case
 └─ Stage
     └─ Process
         └─ Step
```

通过业务场景理解，而不是单纯背定义。

---

### Step 3：学习考试必备英文关键词

不进行泛英语学习，只积累 PEGACPSA25V1 高频英文。

例如：

| English | 中文理解 |
|---|---|
| Case | 一个完整业务事项 |
| Stage | 业务阶段 |
| Process | 阶段中的处理流程 |
| Step | 具体处理步骤 |
| Assignment | 待某人完成的任务 |
| Route | 分配任务 |
| Work Queue | 工作队列 |
| Approval | 审批 |
| Validation | 校验 |
| Configure | 配置 |
| Requirement | 需求 |
| Appropriate | 合适的 / 最适合的 |
| Ensure | 确保 |
| Best practice | 最佳实践 |

做题过程中遇到新的高频词，持续追加到词库。

---

### Step 4：训练英文题干拆解

考试时不要求逐词翻译。

固定使用以下方法：

**英文题干 → 找关键词 → 还原业务需求 → 定位 Pega 知识点 → 选择答案**

例如：

> A company wants to route high-value loan applications to a group of senior underwriters.

抓关键词：

```text
route
high-value loan applications
group of senior underwriters
```

转换为中文业务需求：

> 高额贷款申请需要分配给一组高级审核人员。

然后再判断应该使用什么 Pega 功能。

重点不是翻译所有单词，而是读懂“谁、要做什么、有什么条件”。

---

### Step 5：考试题训练

每次默认 **一道题**。

规则：

1. 先只显示英文原题和选项。
2. 学员先独立作答。
3. 不提前提示正确答案。
4. 回答后再公布答案。
5. 用中文解释原因。
6. 指出题目的关键英文词。
7. 说明对应的官方 Pega 知识点。
8. 必要时解释错误选项为什么错。

---

## 三、题目难度规则

### Level 1：基础概念题

确认基本概念理解。

例如：

- Case / Stage / Process / Step
- Assignment
- Data Object
- View

### Level 2：简单场景题

给出一个实际需求，判断应该使用哪个功能。

### Level 3：考试风格场景题

加入类似 PEGACPSA25V1 的表达，例如：

- Which configuration should you use?
- Which option is most appropriate?
- How should you configure the application?
- Which two actions should you take?
- What is the best practice?

### Level 4：综合题

一个题目同时涉及多个 Pega 知识点。

只有基础正确率稳定后再进入更高难度。

---

## 四、错题规则

出现错误时，不只是记录 A/B/C/D。

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

错题原因分为：

1. **知识点不会**
2. **概念混淆**
3. **英文题干没看懂**
4. **关键词漏看**
5. **多选题少选 / 多选**
6. **Best Practice 判断错误**

不同原因采用不同复习方式。

---

## 五、英文专项规则

英语不是单独学，而是跟着 Pega 题目学习。

### 不要求

- 不要求全文逐字翻译。
- 不要求背大量普通英语单词。
- 不要求学习复杂英语语法。

### 必须掌握

重点识别：

- 动作：configure / route / assign / validate / create / update
- 条件：when / if / based on / depending on
- 对象：case / assignment / data / view / process
- 题目要求：best / most appropriate / should / ensure / two actions

### 每道题增加英语训练

题目讲解时提取：

```text
关键词
固定搭配
真正影响答案的句子
可以忽略的背景信息
```

逐渐建立 PEGACPSA25V1 专用英语词库，而不是泛英语词库。

---

## 六、复习规则

学习新知识的同时持续回顾旧内容。

建议复习节奏：

- 当天：新知识 + 立即练习
- 第 2 天：快速复习前一天错题
- 第 4～7 天：再次抽查
- 后续：随机混入旧题

掌握标准不是“看答案觉得会”，而是：

> 在没有提示的情况下可以独立判断。

---

## 七、官方教程学习原则

官方 System Architect Mission v8 是主教材，但不机械追求学习进度。

每个 Module 要做到：

```text
看懂 → 解释出来 → 做题 → 发现问题 → 回教程 → 再做题
```

如果某一节已经理解并能稳定做对题，可以加快。

如果某一节题目连续出错，则暂停推进新内容。

---

## 八、训练过程中的助手规则

ChatGPT 在训练过程中遵守以下规则：

1. 一次默认只出一道题。
2. 不在用户回答前泄露答案。
3. 先保证基础理解，再扩展难题。
4. 不为了增加难度而加入超出 CPSA 范围的深层内容。
5. 解释优先使用中文。
6. 保留关键 Pega 英文术语。
7. 用户英文没看懂时，先教拆题方法，而不是简单给整句翻译。
8. 错题必须解释“为什么错”。
9. 高频错误自动进入后续复习。
10. 训练目标是考试能力 + 实际理解，而不是单纯记题库。

---

## 九、阶段目标

### 阶段 1：建立基础

能够解释常见 Pega 核心概念。

### 阶段 2：模块练习

每学习一个官方模块，完成对应题目。

### 阶段 3：混合场景题

不同模块混合，不提示所属知识点。

### 阶段 4：Mock Exam

按照 PEGACPSA25V1 的实际考试节奏进行模拟。

重点检查：

- 正确率
- 英文阅读速度
- 场景判断速度
- 易混知识点
- 多选题稳定性

---

## 核心原则

最终坚持一条主线：

> **理解 Pega → 看懂英文需求 → 判断正确配置 → 用题目验证理解。**

不是为了刷题而刷题，也不是为了学完教程而学教程。
