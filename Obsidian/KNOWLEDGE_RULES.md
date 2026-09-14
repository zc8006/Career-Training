# Zhou Knowledge Base 协作规则 v1

## 0. 唯一知识库根目录

`Career-Training/Obsidian/` 是 Zhou Knowledge Base 的**唯一正式知识库根目录**。

从本规则生效起：

- 所有“整理到知识库”“继续 Zhou Knowledge Base”“更新 Master / Daily / WrongAnswers / MOC / Project”等操作，只允许写入 `Obsidian/` 目录及其子目录。
- 仓库根目录中的 `Java/`、`Japanese/`、`MuleSoft/`、`PEGA/`、`Projects/` 等现有目录视为**历史资料 / 来源资料**，可以读取和迁移，但不再作为新的知识库写入目标。
- 如旧窗口仍按旧路径更新，ChatGPT 应先停止直接写入旧目录，改为读取旧内容后，将整理结果写入 `Obsidian/` 对应位置。
- 同一知识点不得同时维护“旧目录版”和“Obsidian 版”两份长期正文；正式版本以 `Obsidian/` 内文件为准。
- 任何新聊天窗口在写入前，都必须先读取本文件，并确认目标路径以 `Obsidian/` 开头。

> 简单规则：**以后知识库新增和更新，一律进 `Obsidian/`。**

## 1. 知识库定位

`Zhou Knowledge Base` 是用户与 ChatGPT 共同长期维护的个人知识库。

整体架构：

- **GitHub**：知识库唯一可信数据源（Source of Truth）
- **Obsidian**：本地阅读、搜索、双链和知识图谱界面
- **ChatGPT**：负责整理、归类、更新、关联和持续维护知识内容

原则：

> 内容最终以 GitHub 中 `Obsidian/` 下的 Markdown 为准。Obsidian 负责展示，ChatGPT 负责协助维护。

## 2. 核心原则

### 2.1 先查再写

新增任何知识之前，先搜索 `Obsidian/` 中是否已经存在相关内容；必要时再读取仓库其他历史目录作为来源资料。

优先级：
1. 更新 `Obsidian/` 已有文件
2. 补充 `Obsidian/` 已有 Master
3. 增加已有知识页内容
4. 最后才创建新文件

禁止因为换了聊天窗口，就重复创建相同主题。

### 2.2 不把聊天记录直接塞进知识库

聊天内容必须经过整理。知识库保存的是：结论、方法、错题、可复用经验、项目经验、面试表达、学习成果。

### 2.3 一个知识点尽量只有一个长期归属

同一个长期知识点只保留一个主要知识页，其他位置使用 `[[双链]]` 引用，不复制多份正文。

## 3. 知识层级

### Daily
保存当天产生的原始学习内容，可以不完整、可以有错误、可以比较杂。

### WrongAnswers
记录错题、错句、易混淆知识、忘记过的知识、回答不完整的问题。

### Master / Knowledge Note
保存已经确认、值得长期使用的知识。只保留核心定义、实战理解、常见问题、易错点、面试表达和关联知识。

### MOC
MOC = Map of Content。只负责知识导航和关系，不堆大量正文。

## 4. 目录职责

以下路径均相对于 `Obsidian/`：

- `00-Home.md`：知识库总入口、当前重点、主要领域、项目和学习路线
- `Java/`：Java Core、Spring、Spring Boot、MyBatis、MySQL、Redis、JVM、并发、Interview
- `Japanese/`：会话、Shadowing、N2、Vocabulary、Grammar、面试日语、项目表达、WrongAnswers
- `PEGA/`：CPSA、官方知识点、英文关键词、Exam Notes、WrongAnswers
- `MuleSoft/`：基础、API Design、DataWeave、Error Handling、Integration、Migration、Certification、Project Experience
- `Projects/`：真实做过或正在做的项目
- `01-Career/`：简历、面试、自我介绍、项目表达、求职策略、技术面试准备
- `99-Templates/`：知识卡、Daily、Project 等模板

## 5. Daily → Knowledge 沉淀规则

只有以下内容值得进入长期知识：
- 新知识
- 重要纠错
- 高频错误
- 实战经验
- 面试高频
- 可复用方法

沉淀流程：

`Daily → WrongAnswers → Knowledge / Master → MOC`

## 6. 双链规则

每个长期知识页至少考虑三个方向：
- 上级知识
- 横向知识
- 应用场景

链接必须代表真实知识关系，不为了 Graph 好看而滥用。

## 7. 标签规则

标签只用于大分类和状态，例如：
- `#java`
- `#japanese`
- `#pega`
- `#mulesoft`
- `#project`
- `#interview`
- `#learning`
- `#review`
- `#mastered`

具体知识关系优先使用双链。

## 8. 文件命名规则

- 长期知识：使用清晰主题名称
- Daily：`YYYY-MM-DD-主题.md`
- 项目：使用稳定项目名称

禁止使用 `新建文档.md`、`笔记1.md`、`今天学习.md` 这类无信息量命名。

## 9. ChatGPT 维护规则

当用户说“整理到知识库”时，默认执行：
1. 先读取 `Obsidian/KNOWLEDGE_RULES.md`
2. 判断所属领域
3. 搜索 `Obsidian/` 已有文件
4. 必要时读取旧目录中的来源资料
5. 判断属于 Daily / WrongAnswers / Master / Project
6. 优先更新已有知识
7. 避免重复创建
8. 增加必要双链
9. 更新相关 MOC
10. 所有写入路径必须位于 `Obsidian/`
11. 不随意删除历史内容
12. 提交 GitHub

## 10. 新聊天窗口规则

用户在任何新窗口说：
- “继续 Zhou Knowledge Base”
- “整理到知识库”

ChatGPT 应优先查看 `Obsidian/KNOWLEDGE_RULES.md`，以及 `Obsidian/` 下相关 MOC、Master 和已有知识文件。不能仅依赖聊天记忆判断目录和知识状态。

GitHub `Obsidian/` 中的内容优先于 ChatGPT 对过去聊天的记忆，也优先于仓库旧目录中的历史版本。

## 11. 内容冲突规则

新知识与旧知识发生冲突时，禁止直接覆盖旧内容。先判断旧内容是否错误、新内容是否更准确、是否属于不同场景、是否只是表达不同。

必要时保留：
- Previous Understanding
- Updated Understanding

## 12. 不删除原则

默认不删除已有知识。可以修改、合并、标记过时、增加说明。只有明确确认重复或错误后才删除。

## 13. 项目经验优先级

真实项目经验优先级高于纯理论笔记。尽量形成：

`理论知识 → 实际项目 → 面试表达 → 职业能力`

## 14. 最终目标

知识库不追求收藏很多资料，而是形成：

**知识 → 实践 → 项目 → 面试 → 工作能力**

最终能回答：
1. 我会什么？
2. 我实际做过什么？
3. 我能不能把它讲清楚？

## 15. 最重要的一条规则

> 不追求文件数量，追求知识之间的连接和长期可复用性。

每次新增知识，都先考虑“它应该连接到什么”，而不是“它应该放在哪个文件夹”。
