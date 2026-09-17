# PEGACPSA25V1 学习方式调整（2026-09-17）

## 一、这次学习暴露出的两个核心问题

### 1. Pega 概念“听懂了”，但没有形成稳定的判断链

目前的问题不是完全不知道知识点，而是很多概念停留在“看解释觉得懂”的层面。

例如 Center-out：

```text
Application layer = business logic
```

这句话会背并不等于真正掌握。

真正掌握应该能够继续推出：

```text
业务逻辑在中心
→ 不应该由 Channel 驱动
→ 多个 Channel 可以复用同一套业务逻辑
→ 修改中央业务规则后，各 Channel 可以共同受益
→ 新增 Channel 时不应复制一套业务逻辑
```

以后学习每个知识点，都必须形成这样的“概念判断链”，不能只记一个定义或答案。

---

### 2. 英文不是完全看不懂，而是不会快速抓“决定答案的词”

目前容易出现两个问题：

- 想逐字翻译整句，导致阅读慢、容易乱。
- 没抓到真正决定答案的关键词，被背景信息干扰。

例如：

> Updates to the central business logic automatically apply across all Channel interfaces.

考试不需要逐词翻译，只需抓：

```text
central business logic
automatically apply
across all Channel interfaces
```

即可还原成：

> 中央业务逻辑更新 → 所有 Channel 一起生效

以后英文训练重点不是泛英语，而是“Pega 考试拆题能力”。

---

## 二、今后的固定学习流程（升级版）

每一个 Pega Topic 固定按下面流程学习。

### Step 1：先确定“这页在整个模块里是干什么的”

不要上来就总结知识点。

先回答：

- 这一页为什么出现在这里？
- 它和前一页是什么关系？
- 它是在讲新概念，还是在讲前一个概念的应用？

例如：

`Accessibility in Center-out Development` 不是突然单独讲 accessibility，而是在解释：

> Center-out 思想如何应用到 accessibility。

---

### Step 2：深层理解正文，不只看表面文字

学习资料必须同时看：

```text
正文
+ 页面截图
+ Note
+ 图示
+ 例子
+ 交互题
+ Pega 配置逻辑
+ Best Practice
+ 隐含考试信息
```

不能只照正文翻译，也不能只根据题目猜答案。

重点回答：

- 为什么这样设计？
- 如果不这样做会有什么问题？
- 这个规则能推出什么结果？
- 和相似概念有什么区别？

---

### Step 3：为每个核心概念建立“判断链”

每个概念至少建立一条：

```text
原因 → 核心规则 → 结果 → 场景判断
```

例如 Center-out：

```text
业务逻辑集中在中心
→ 与 Channel / 数据源解耦
→ 可以跨 Channel 复用
→ 修改中央规则后不必逐个 Channel 修改
```

掌握标准：

> 不是能背定义，而是能从核心规则推出考试场景的结果。

---

### Step 4：建立“概念对比表”

容易混淆的概念必须放在一起比较。

例如：

```text
Presentation layer → Channels / UI
Application layer → Business logic
Data access layer → Systems of record
```

或者：

```text
Persona → 一类人
User → 具体的人
Role → Channel + Permissions
Channel → 使用入口 / UI
```

不单独背孤立定义。

---

### Step 5：英文只训练“考试拆题”

每道题固定拆成：

```text
① 题目问什么？
② 决定答案的关键词是什么？
③ 哪些背景信息可以忽略？
④ 转成一句简单中文业务需求
⑤ 映射到哪个 Pega 概念？
```

例如：

```text
visual impairments + navigate
→ 视觉障碍用户如何导航页面结构？
→ screen reader 需要 heading structure
→ headings and heading levels
```

不要求全文逐字翻译。

---

### Step 6：题目训练默认 5 道，一次一道

固定规则：

- 每个小 Topic 默认 5 道题。
- 一次只出 1 道。
- 用户先答，助手不提前提示。
- 第 5 道做完必须停止。
- 不自动继续第 6 道。
- 只有用户明确说“继续”“再来几道”才追加。

5 道题的作用不是刷数量，而是验证：

```text
概念是否理解
英文是否看懂
场景是否能映射
易混点是否稳定
```

---

### Step 7：每道错题必须做“双诊断”

以后错题不能只说“正确答案是什么”。

必须判断到底错在：

#### A. Pega 理解问题

例如：

- 概念没理解
- 概念混淆
- 只会背定义，不会推导
- Best Practice 判断错误

#### B. 英文问题

例如：

- 关键词没认识
- 句型没看懂
- 漏看限定词
- 被背景信息干扰
- Choose Two / Choose Three 看漏

每个错题都要明确属于哪一种，必要时两种都有。

---

### Step 8：做完 5 道题后必须总结，不立即进入下一题

每轮结束固定输出：

```text
成绩：X/5
概念问题：
英文问题：
本轮最容易混淆点：
需要进入错题库的题：
是否可以进入下一 Topic：Yes / Need Review
```

如果概念还没形成判断链，不因为“4/5”就机械进入下一章。

---

### Step 9：整理到 GitHub 的内容也升级

每个 Topic 的 GitHub 笔记以后至少包含：

```text
1. Topic 在模块中的位置
2. 核心概念
3. 为什么这样设计
4. 概念判断链
5. 易混概念对比
6. 官方页面隐藏信息 / Note / 图示含义
7. 考试高频英文
8. 题干拆解示例
9. 错题与错因
10. 速记结论
```

GitHub 不是只保存答案，而是保存以后可以直接复习的“理解体系”。

---

## 三、Center-out 当前暴露出的具体问题

### 概念方面

已经知道三层：

```text
Presentation layer → Channels / UI
Application layer → Business logic
Data access layer → Systems of record
```

但对下面的推导还不够稳定：

```text
Business logic central
→ Channel 不驱动业务逻辑
→ 业务规则可以跨 Channel 复用
→ central logic update 可以作用于多个 Channel
```

后续复习重点应从“层叫什么”升级到“为什么这样设计、会产生什么结果”。

### 英文方面

本次需要强化的表达：

| English | 快速理解 |
|---|---|
| business rules require updates | 业务规则需要修改 |
| central business logic | 中央业务逻辑 |
| apply across all Channel interfaces | 应用于所有 Channel |
| propagate changes | 传播 / 扩散变更 |
| visual impairments | 视觉障碍 |
| navigate the application | 在应用中导航 |
| identify three principles | 选出三个原则 |
| manage intelligence centrally | 集中管理智能 / 决策 |
| manage variations to be scale-ready | 管理差异以便扩展 |
| focus on outcomes | 关注业务结果 |

---

## 四、以后判断“学会了”的标准

不能再用下面标准：

> 看解释觉得明白。

真正学会必须同时满足：

1. 能用自己的话解释概念。
2. 能说出为什么这样设计。
3. 能从核心规则推出一个新的场景结果。
4. 能和相似概念区分。
5. 英文题干不逐字翻译也能抓到决定答案的关键词。
6. 同类题变换说法后仍能做对。

---

## 五、今后的核心学习主线

以后每一个 Topic 都按照：

```text
看懂页面在讲什么
        ↓
理解设计原因
        ↓
建立概念判断链
        ↓
整理易混概念
        ↓
提取考试英文关键词
        ↓
做 5 道题（一次一道）
        ↓
概念 + 英文双诊断
        ↓
错题回炉
        ↓
整理 GitHub
        ↓
再进入下一 Topic
```

最终目标不是“把 Pega Academy 看完”，而是：

> **真正理解 Pega + 能读懂认证题 + 能稳定做场景判断。**

## 相关

- [[STUDY_RULES]]
- [[Notes/Users-and-Personas]]
