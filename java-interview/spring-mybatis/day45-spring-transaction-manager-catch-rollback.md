# Day 45 - Spring 事务管理器、异常捕获与手动回滚

日期：2026-07-03

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 主线：事务隔离级别、事务传播行为、事务管理器、多事务管理器指定、private 方法事务失效、异常 catch 后回滚、`setRollbackOnly()`

---

## 一、旧题回炉

### 1. `REPEATABLE_READ` 拼写与作用

**题目：** `REPEATABLE_READ` 怎么拼？它是什么隔离级别？能避免什么问题？

**作答：** `REPEATABLE_READ` 是可重复读，能避免不可重复读。

**评分：** 9 / 10

**标准答案：**

`REPEATABLE_READ` 是可重复读隔离级别，可以避免不可重复读，也就是同一个事务中多次读取同一行数据，结果保持一致。

**保命句：**

`REPEATABLE_READ` = 可重复读 = 防不可重复读。

---

### 2. `@Around` 里的 `proceed()`

**题目：** `@Around` 里的 `proceed()` 是干什么的？如果不调用它会怎么样？

**作答：** `proceed` 是继续执行指定的方法。

**评分：** 8 / 10

**修正点：**

不要说“指定的方法”，更准确是“继续执行原来的目标方法”。

**标准答案：**

`@Around` 环绕通知里的 `proceed()` 用来继续执行目标方法。如果不调用 `proceed()`，目标方法不会执行，业务代码也不会往下走。

**保命句：**

`proceed()` = 放行并执行目标方法；不调用，目标方法不执行。

---

### 3. `NESTED` 和 `REQUIRES_NEW`

**题目：** `NESTED` 和 `REQUIRES_NEW` 的最大区别是什么？

**作答：** `NESTED` 是在外层事务设定一个保存点，嵌套的事务异常时可以回滚到这个保存点，外层事务继续执行，`REQUIRES_NEW` 是每次都创建事务。

**评分：** 8.5 / 10

**修正点：**

`REQUIRES_NEW` 不只是“每次都创建事务”，还要强调会挂起外层事务，开启一个独立的新事务。

**标准答案：**

`NESTED` 是基于保存点的嵌套事务，内层失败可以回滚到保存点，外层事务可以继续；`REQUIRES_NEW` 是挂起外层事务，开启一个独立的新事务。

**保命句：**

`NESTED` 是保存点，`REQUIRES_NEW` 是独立新事务。

---

### 4. `MANDATORY` 和 `NEVER`

**题目：** `MANDATORY` 和 `NEVER` 分别是什么意思？

**初答：** `MANDATORY` 是每次都使用事务，`NEVER` 都不使用事务。

**评分：** 4 / 10

**问题：**

少了最关键的“没有事务 / 有事务就报错”。

**标准答案：**

`MANDATORY` 表示必须在已有事务中执行，如果当前没有事务就报错；`NEVER` 表示不能在事务中执行，如果当前有事务就报错。

**保命句：**

`MANDATORY` = 必须有事务；`NEVER` = 不能有事务。

**复述结果：** 通过。

> Day 46 轻回炉。

---

### 5. 默认传播行为 `REQUIRED`

**题目：** Spring 事务默认传播行为是什么？怎么拼？是什么意思？

**作答：** 默认传播是 `REQUIRES`，有事务就加入，没有事务就创建事务。

**评分：** 8 / 10

**问题：**

拼写错误，不是 `REQUIRES`，而是 `REQUIRED`。

**标准答案：**

Spring 事务默认传播行为是 `REQUIRED`。它表示当前有事务就加入当前事务，没有事务就新建一个事务。

**保命句：**

`REQUIRED` = 有事务就加入，没有事务就新建。

> Day 46 轻回炉，重点卡拼写。

---

### 6. 默认回滚异常

**题目：** `@Transactional` 默认遇到哪些异常会回滚？普通 `Exception` 默认会不会回滚？

**作答：** 遇到 `RuntimeException` 和 `Error` 会回滚，普通 `Exception` 不会回滚。

**评分：** 10 / 10

**标准答案：**

`@Transactional` 默认遇到 `RuntimeException` 和 `Error` 会回滚，普通 `Exception` 默认不会回滚。如果希望普通 `Exception` 也回滚，需要配置 `rollbackFor = Exception.class`。

**保命句：**

默认 `RuntimeException` 和 `Error` 回滚；普通 `Exception` 不回滚，要配 `rollbackFor`。

---

### 7. 隔离级别和传播行为的区别

**题目：** 事务隔离级别和事务传播行为有什么区别？分别解决什么问题？

**作答：** 事务隔离级别是针对单个事务里面 SQL 之间，解决脏读、不可重复读和幻读；事务传播行为是多个事务之间，创建、加入。

**评分：** 7.5 / 10

**修正点：**

隔离级别不是主要讲“单个事务里面 SQL 之间”，而是讲多个并发事务之间互相影响的问题。传播行为要说清楚是事务方法互相调用时事务怎么传递。

**标准答案：**

事务隔离级别解决并发事务之间的数据一致性问题，比如脏读、不可重复读、幻读；事务传播行为解决事务方法之间相互调用时，事务应该加入当前事务、新建事务、挂起事务、非事务执行还是报错。

**保命句：**

隔离级别解决并发读写问题，传播行为解决事务方法调用时事务怎么传递。

> Day 46 轻回炉。

---

### 8. Spring Boot 自动配置事务管理器

**题目：** Spring Boot 里为什么一般不需要手动配置事务管理器？什么时候需要手动配置？

**作答：** Spring Boot 自动配置事务管理器，一般多个数据源或者需要手动设定的时候。

**评分：** 8.5 / 10

**标准答案：**

Spring Boot 一般不需要手动配置事务管理器，因为它会根据数据源和相关依赖自动配置。比如使用 JDBC 或 MyBatis 时，会自动配置 `DataSourceTransactionManager`。只有多数据源、多个事务管理器，或者需要自定义事务管理器时，才需要手动配置。

**保命句：**

Spring Boot 会自动配置事务管理器；多数据源或自定义事务管理器时才需要手动配置。

---

### 9. 多事务管理器指定方式

**题目：** 如果项目里有多个事务管理器，`@Transactional` 怎么指定使用哪一个？

**作答：** `transactionMagager` 来指定。

**评分：** 7 / 10

**问题：**

拼写错误，不是 `transactionMagager`，而是 `transactionManager`。

**标准写法：**

```java
@Transactional(transactionManager = "orderTransactionManager")
```

也可以简写：

```java
@Transactional("orderTransactionManager")
```

**保命句：**

多个事务管理器，用 `@Transactional(transactionManager = "xxxTransactionManager")` 指定。

> Day 46 轻回炉，重点卡拼写。

---

### 10. `private` 方法事务为什么不生效

**题目：** `@Transactional` 加在 `private` 方法上为什么通常不生效？

**作答：** `private` 是类内部调用，`this.xxx` 这种没经过 Spring，就不会被代理对象调用。

**评分：** 9 / 10

**标准答案：**

`@Transactional` 加在 `private` 方法上通常不生效，因为 Spring 事务是基于 AOP 代理实现的，`private` 方法不能被代理对象正常拦截，而且通常是类内部 `this.xxx()` 调用，没有经过 Spring 代理对象。

**保命句：**

`private` 方法事务不生效：代理拦不到 + 内部调用没走代理。

---

## 二、新题

### 1. Spring 事务底层为什么需要事务管理器

**题目：** Spring 事务底层为什么需要事务管理器？事务管理器主要负责什么？

**初答：** `transcationMangager`，指定数据源设定连接池之类的。

**评分：** 4 / 10

**问题：**

1. 拼写错误，正确是 `TransactionManager`。
2. 把事务管理器和数据源 / 连接池混在一起了。数据源负责提供连接，连接池负责连接复用，事务管理器负责控制事务开始、提交、回滚。

**标准答案：**

Spring 事务底层需要事务管理器，因为事务管理器负责真正控制事务流程，比如获取数据库连接、开启事务、提交事务和回滚事务。在 JDBC / MyBatis 场景下，常见事务管理器是 `DataSourceTransactionManager`。

**保命句：**

数据源管连接来源，事务管理器管事务开启、提交、回滚。

**复述结果：** 通过。

> Day 46 必回炉。

---

### 2. `DataSourceTransactionManager` 和 `JpaTransactionManager`

**题目：** `DataSourceTransactionManager` 和 `JpaTransactionManager` 有什么区别？分别适合什么场景？

**作答：** `DataSourceTransactionManager` 是 MyBatis，`JpaTransactionManager` 这个是 JPA。

**评分：** 7 / 10

**标准答案：**

`DataSourceTransactionManager` 主要用于 JDBC、MyBatis 这类基于 `DataSource` 的场景，它管理的是数据库连接上的事务。`JpaTransactionManager` 主要用于 JPA / Hibernate 场景，它管理的是 JPA 的 `EntityManager` 相关事务。

**保命句：**

MyBatis / JDBC 用 `DataSourceTransactionManager`，JPA / Hibernate 用 `JpaTransactionManager`。

---

### 3. 为什么事务一般加在 Service 层

**题目：** 为什么 Spring 事务一般建议加在 Service 层，而不是 Controller 或 Mapper 层？

**作答：** Controller 是负责参数验证和响应返回，Service 是负责业务处理，会调用多个 Mapper。

**评分：** 8.5 / 10

**标准答案：**

Spring 事务一般加在 Service 层，因为 Service 层负责业务逻辑，一个业务操作可能会调用多个 Mapper 或多个数据库操作。事务放在 Service 层，可以保证整个业务流程要么一起成功，要么一起失败。Controller 主要负责接收请求和返回结果，Mapper 主要负责执行 SQL，不适合控制完整业务事务。

**保命句：**

Controller 管请求响应，Mapper 管 SQL，Service 管业务和事务。

---

### 4. 两个 Mapper 操作如何保证一致性

**题目：** 如果一个 Service 方法里调用了两个 Mapper，第一个 insert 成功，第二个 insert 失败，事务应该怎么保证数据一致？

**作答：** 同时回滚。

**评分：** 7 / 10

**标准答案：**

在 Service 方法上加 `@Transactional`，让两个 Mapper 操作处在同一个事务里。第一个 insert 成功后，如果第二个 insert 失败并抛出运行时异常，Spring 会回滚整个事务，这样第一个 insert 也会回滚，保证数据一致。

**保命句：**

多个数据库操作放在同一个 Service 事务里，一个失败，整体回滚。

---

## 三、追问

### 1. 异常被 catch 后事务是否回滚

**题目：** 如果第二个 insert 失败了，但是代码里把异常 `catch` 住了，没有继续抛出，事务还会回滚吗？为什么？

**作答：** 不会，事务接收不到异常。

**评分：** 9 / 10

**标准答案：**

不会回滚。因为 Spring 事务是基于 AOP 代理实现的，只有方法向外抛出符合回滚规则的异常时，事务代理才会触发回滚。如果异常被 catch 住，没有继续抛出，代理会认为方法正常结束，就会提交事务。

**保命句：**

异常被 catch 不抛出，事务感知不到异常，就不会自动回滚。

---

### 2. catch 异常后还想回滚怎么办

**题目：** 如果业务上必须 catch 异常，但又想让事务回滚，应该怎么做？

**作答：** 一个是手动抛出异常，一个是加回滚的代码。

**评分：** 8 / 10

**标准答案：**

如果业务上必须 catch 异常，但又想让事务回滚，可以有两种方式：第一种是 catch 后重新抛出运行时异常，或者抛出普通异常并配置 `rollbackFor = Exception.class`；第二种是在 catch 里手动标记事务回滚：

```java
TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
```

**保命句：**

catch 后想回滚，要么继续抛异常，要么手动 `setRollbackOnly()`。

---

### 3. `setRollbackOnly()` 是否立即回滚

**题目：** `setRollbackOnly()` 是什么意思？它会立刻回滚吗？

**初答：** 手动回滚，会吧。

**评分：** 5 / 10

**问题：**

`setRollbackOnly()` 不是马上手动回滚，而是把当前事务标记为只能回滚。

**标准答案：**

`setRollbackOnly()` 是把当前事务标记为回滚状态。它不会立刻回滚，而是在事务结束时，Spring 发现事务已经被标记为 rollback-only，就会回滚而不是提交。

**保命句：**

`setRollbackOnly()` 不是立即回滚，而是标记当前事务最终必须回滚。

**复述结果：** 通过。

> Day 46 必回炉。

---

## 四、Day 45 背诵清单

1. `REPEATABLE_READ` 是可重复读，可以避免不可重复读。
2. `proceed()` 是继续执行目标方法，不调用它，目标方法不会执行。
3. `NESTED` 是基于保存点的嵌套事务，`REQUIRES_NEW` 是独立新事务。
4. `MANDATORY` 是必须有事务，没有就报错；`NEVER` 是不能有事务，有事务就报错。
5. `REQUIRED` 是默认传播行为，有事务就加入，没有事务就新建。
6. `@Transactional` 默认遇到 `RuntimeException` 和 `Error` 回滚，普通 `Exception` 默认不回滚。
7. 隔离级别解决并发读写问题，传播行为解决事务方法调用时事务怎么传递。
8. Spring Boot 会自动配置事务管理器，多数据源或自定义事务管理器时才需要手动配置。
9. 多个事务管理器时，用 `@Transactional(transactionManager = "xxxTransactionManager")` 指定。
10. `private` 方法事务不生效：代理拦不到，内部调用没走代理。
11. 数据源管连接来源，事务管理器管事务开启、提交、回滚。
12. 异常被 catch 不抛出，事务感知不到异常，就不会自动回滚。
13. catch 后想回滚，要么继续抛异常，要么手动 `setRollbackOnly()`。
14. `setRollbackOnly()` 不是立即回滚，而是标记当前事务最终必须回滚。

---

## 五、Day 46 回炉安排

### 必回炉

1. `TransactionManager` 作用：事务开启、提交、回滚，不要和数据源 / 连接池混淆。
2. `setRollbackOnly()` 是否立即回滚：不是立即回滚，是标记当前事务最终必须回滚。

### 轻回炉

1. `MANDATORY` / `NEVER`
2. `REQUIRED` 拼写
3. 隔离级别和传播行为的区别
4. 多事务管理器 `transactionManager` 拼写
5. `DataSourceTransactionManager` 和 `JpaTransactionManager`
6. 多 Mapper 操作如何通过 Service 层事务保证一致性
