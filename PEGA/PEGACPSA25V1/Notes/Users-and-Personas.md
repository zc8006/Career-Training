# Users and Personas

> PEGACPSA25V1 / System Architect
> 学习日期：2026-09-16

## 1. 核心概念

### Persona

Persona 表示**一类业务用户（type of user）**，不是某一个具体的人。

例：
- Customer
- Manager
- Network Technician
- Auditor

当出现新的用户类型，而且该类型需要不同的界面、职责、权限或工作路由时，应考虑创建新的 Persona。

### User

User 表示**一个具体的人**，例如 Kamilka。

每个用户都应该有自己的独立账号，不应共用其他人的用户名和密码。

### Channel interface

Channel interface 是用户与应用交互的界面或入口，例如 Web Channel。

不同用户类型可能需要不同的 Channel interface。

### Role

Role 表示一组访问能力，核心可理解为：

**Channel interface + permissions 的组合**

如果现有 Role 无法提供所需的 Channel 和权限组合，则需要创建新的 Role。

---

## 2. Persona / User / Role / Channel 的关系

```text
Channel
   ↓
Role = Channel + permissions
   ↓
User ← assign Role
```

对于 Persona 场景：

```text
新的用户类型
   ↓
Create Persona
   ↓
Create User
   ↓
Assign Persona to User
```

### 一句话记忆

- Persona = 一类人
- User = 具体的人
- Channel = 从哪里/通过什么界面工作
- Role = 通过什么 Channel + 能做什么

---

## 3. 本单元重要考试规律

### 场景 1：公司第一次出现一种新的用户类型

例如：

> Kamilka is hired as the company's first Network Technician.

如果 Network Technician Persona 还不存在：

1. Create a new Persona named Network Technician.
2. Create a user account for Kamilka.
3. Assign the new Persona to Kamilka.

关键点：

**first/new type of worker → 先判断是否需要新的 Persona**

不要只看到具体人名就只创建 User。

---

### 场景 2：什么时候创建新的 Role

典型题干：

> An additional combination of Channel interface and permissions is necessary.

这意味着现有 Role 的 Channel + permissions 组合不满足要求，应创建新的 Role。

注意：

- 只是新增一个人 → 通常创建 User
- 只是某个已有 Role 权限不足 → 不一定必须创建新 Role，也可能调整现有 Role
- 明确需要新的 Channel + permissions 组合 → 新 Role

---

## 4. Create a role 与 Create a user 需要的信息

### Create a role

需要：

- Supply a name
- Supply a Channel

记忆：

**Role = name + Channel**

### Create a user

需要：

- Supply an email address
- Supply a role

记忆：

**User = email + role**

---

## 5. Supply 的含义

在 Pega 配置题中，Supply 通常不是“供应”，而是：

**提供 / 填写 / 指定**

例如：

| English | 中文理解 |
|---|---|
| Supply a name | 填写名称 |
| Supply a Channel | 指定 Channel |
| Supply an email address | 填写邮箱地址 |
| Supply a role | 指定 Role |

特别注意：

**Supply a role ≠ Create a role**

Supply a role 表示给对象指定一个已经存在的 Role。

---

## 6. 配置顺序题

如果题目要求按顺序创建 Auditor 用户，并且 Auditor 需要新的 Web Channel 和新的 Role：

```text
1. Create the Auditor web Channel
2. Create the Auditor role
3. Add the email address for the auditor
4. Assign the Auditor role to the new user
```

依赖关系：

```text
Channel → Role → User → Assign Role
```

为什么：

- 创建 Role 时要引用 Channel，所以 Channel 先存在
- 给 User 指定 Role 时，Role 要先存在

---

## 7. 容易混淆的题干表达

### where they are needed

表示：

**分类 / 判断某项信息属于哪个操作**

不是排序题。

例如：

- Create a role → name + Channel
- Create a user → email + role

### in the order required

表示：

**按执行顺序排列**

例如：

Channel → Role → User → Assign Role

---

## 8. 高频英文关键词

| English | 中文理解 |
|---|---|
| Persona | 一类业务用户 |
| User | 具体用户 |
| Role | 角色 / 权限与 Channel 组合 |
| Channel interface | 用户交互界面 / 入口 |
| permissions | 权限 |
| assign | 分配 |
| supply | 提供 / 填写 / 指定 |
| additional | 额外的 / 新增的 |
| combination | 组合 |
| interact with | 与……交互 |
| system administration features | 系统管理功能 |
| first Network Technician | 第一个网络技术员；提示可能是新的用户类型 |
| where they are needed | 放到需要它们的位置，考分类 |
| in the order required | 按要求顺序排列，考顺序 |

---

## 9. 本单元易错点

1. 不要记“第几个选项”，要记配置逻辑；考试选项顺序会变化。
2. Persona 和 User 不同：Persona 是一类人，User 是具体的人。
3. 新增 User 不等于一定需要新 Role。
4. 新的 Channel + permissions 组合才是创建新 Role 的强提示。
5. Create a role 需要 name + Channel；Create a user 需要 email + role。
6. `Supply a role` 的意思是指定已有 Role，不是创建 Role。
7. `where they are needed` 与 `in the order required` 是两种完全不同的题型。

---

## 10. 考试速记

```text
新的一类人 → Persona
具体某个人 → User
新的 Channel + permissions 组合 → Role

Create Role = name + Channel
Create User = email + role

顺序题：Channel → Role → User → Assign Role
```

---

## 11. Role 专项记忆法

Role 是本单元最容易和 Persona 混淆的概念，固定记住：

> **Role = Channel + Permissions**

中文可以记成：

> **从哪里进去 + 能做什么**

例如 Auditor Role：

```text
Auditor Role
= Auditor 使用哪个 Channel
+ Auditor 拥有哪些 permissions
```

### 看到什么题干要想到 Role？

如果题目同时强调：

- different / new Channel interface
- different / unique permissions

优先想到：

> **Create a new Role**

### 和 Persona / User 对照记忆

```text
Persona = 哪一类人
User    = 具体哪个人
Role    = 通过什么入口 + 能做什么
Channel = 从哪里进入系统
```

再记两组配置关系：

```text
Create Role = name + Channel
Create User = email + Role
```

---

## 12. 本次练习记录（2026-09-16）

5 道复习题结果：**4 / 5**。

唯一错题类型：

> 公司招聘了第一个 Claims Reviewer，并且需要不同于现有用户的专用 UI。第一步做什么？

错误选择：先创建 User。

正确判断：

> **first + 新用户类型 + specialized/different UI → 先创建 Persona**

### 本次需要重点复习

```text
只是多一个人 → User
第一次出现一种新用户类型 → Persona
新的 Channel + permissions 组合 → Role
```

这三个判断以后随机混入复习题。

## 相关

- [[STUDY_RULES]]
