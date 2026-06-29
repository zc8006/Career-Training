# Day 42 - Spring 声明式事务、异常回滚与 AOP 代理

日期：2026-06-29

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 主线：AOP 通知、事务代理、隔离级别、只读事务、声明式事务、事务注解优先级、异常 catch 后回滚

---

## 一、旧题回炉

### 1. AOP 常见通知类型

**题目：** AOP 里常见的通知类型有哪些？比如方法执行前、正常返回后、异常时分别对应什么？

**初答：** `@before`，方法执行前；`@afterReturn`，正常返回后。

**评分：** 4 / 10

**问题：**

- 不是 `@before`，是 `@Before`
- 不是 `@afterReturn`，是 `@AfterReturning`
- 漏了 `@AfterThrowing`、`@Around`、`@After`

**标准答案：**

AOP 常见通知有 `@Before`、`@After`、`@AfterReturning`、`@AfterThrowing`、`@Around`。其中 `@Before` 在方法执行前，`@AfterReturning` 在正常返回后，`@AfterThrowing` 在异常后，`@Around` 可以包住整个方法执行过程。

**保命句：**

AOP 常见通知有 `@Before`、`@AfterReturning`、`@AfterThrowing` 和 `@Around`，分别对应执行前、正常返回后、异常后和环绕增强。

**复述结果：** 通过。

**补充：**

`@Around` 是环绕增强，可以在方法执行前后都加逻辑，并且可以通过 `proceed()` 控制目标方法是否执行。

---

### 2. 同类内部调用事务为什么不生效

**题目：** 为什么同一个类里，一个方法直接调用另一个带 `@Transactional` 的方法，事务可能不生效？

**作答：** 类的内部方法调用用的是 `this.xxx()`，没有经过对象代理，所以不能生效。

**评分：** 9 / 10

**标准答案：**

因为 `@Transactional` 是通过 Spring AOP 代理实现的。同一个类里用 `this.xxx()` 直接调用方法时，没有经过 Spring 代理对象，所以事务拦截器不会执行，事务可能不生效。

---

### 3. 普通 `Exception` 回滚配置

**题目：** 如果希望普通 `Exception` 也触发事务回滚，应该怎么配置？

**作答：** `@Transactional(rollbackFor=Exception.class)`。

**评分：** 9 / 10

**标准写法：**

```java
@Transactional(rollbackFor = Exception.class)
```

**标准答案：**

如果希望普通 `Exception` 也触发事务回滚，可以配置 `@Transactional(rollbackFor = Exception.class)`。

---

### 4. Spring 三级缓存与循环依赖

**题目：** Spring 为什么能解决部分字段注入的循环依赖？大概靠什么机制？

**作答：** 通过三级缓存，提前暴露其中一个 Bean，这样就可以注入的时候拿到这个 Bean 从而创建。

**评分：** 8 / 10

**修正点：**

不是“提前暴露其中一个 Bean”，更标准说法是：提前暴露单例 Bean 的引用。

**标准答案：**

Spring 能解决部分字段注入的循环依赖，主要靠三级缓存。它会提前暴露单例 Bean 的引用，让其他 Bean 在属性注入时可以先拿到这个对象，从而完成后续的属性填充和初始化。

**保命句：**

Spring 通过三级缓存提前暴露单例 Bean 的引用，所以字段注入时可以先拿到对象，解决部分循环依赖。

---

### 5. JDK 动态代理和 CGLIB 区别

**题目：** JDK 动态代理和 CGLIB 有什么区别？

**作答：** JDK 动态代理是有接口的时候生成对象代理，CGLIB 是没有接口的时候对类的子类生成对象代理。

**评分：** 7.5 / 10

**修正点：**

不要说“生成对象代理”。更标准是：JDK 动态代理基于接口，CGLIB 通过生成目标类的子类实现代理。

**标准答案：**

JDK 动态代理要求目标类实现接口，它生成的是接口代理对象；CGLIB 不要求接口，它通过生成目标类的子类来实现代理。简单说，JDK 动态代理基于接口，CGLIB 基于继承。

**保命句：**

JDK 动态代理基于接口，CGLIB 基于继承，通过生成目标类的子类来实现代理。

---

### 6. 脏读、不可重复读、幻读

**题目：** 脏读、不可重复读、幻读分别是什么意思？

**作答：** 脏读是读取了未提交的数据，不可重复读是读取的结果和前一次不一致，幻读是读取的件数和之前的不一致。

**评分：** 8.5 / 10

**修正点：**

- 不可重复读重点是“同一行数据”的值变了
- 幻读重点是“同一条件查询”的行数变了

**标准答案：**

脏读是读到了其他事务未提交的数据；不可重复读是同一个事务中两次读取同一行数据，结果不一致；幻读是同一个事务中两次按条件查询，查到的记录数量不一致。

---

### 7. 常见事务隔离级别

**题目：** Spring 事务常见隔离级别有哪些？`READ_COMMITTED` 和 `REPEATABLE_READ` 有什么区别？

**初答：** 常见的有 `READ_COMMITTED`，读已提交，防止幻读；`REPEATABLE_READ` 可重复读，解决不可重复读。

**评分：** 5 / 10

**错误点：**

`READ_COMMITTED` 不是防止幻读，而是防止脏读。

**标准答案：**

Spring 常见事务隔离级别有 `READ_UNCOMMITTED`、`READ_COMMITTED`、`REPEATABLE_READ`、`SERIALIZABLE`。`READ_COMMITTED` 表示只能读取已经提交的数据，可以避免脏读；`REPEATABLE_READ` 表示同一个事务中多次读取同一行数据结果一致，可以避免不可重复读。

**保命句：**

`READ_COMMITTED` 避免脏读，`REPEATABLE_READ` 避免不可重复读。

**复述结果：** 通过。

---

### 8. Spring 默认事务隔离级别

**题目：** Spring 默认事务隔离级别是什么？如果是 MySQL InnoDB，一般默认是什么？

**作答：** 默认是使用数据库的隔离级别，MySQL InnoDB 是可重复读。

**评分：** 9 / 10

**标准答案：**

Spring 默认事务隔离级别是 `DEFAULT`，表示使用数据库默认隔离级别。如果是 MySQL InnoDB，一般默认是 `REPEATABLE_READ`，也就是可重复读。

---

### 9. `@Transactional(readOnly = true)`

**题目：** `@Transactional(readOnly = true)` 是什么意思？一般用在什么场景？

**作答：** 表示这个事务里只是用查询，一般没有更新和插入需求的时候用这个。

**评分：** 8 / 10

**补充点：**

它也可以作为优化提示，并且表达这个方法不应该做增删改。

**标准答案：**

`@Transactional(readOnly = true)` 表示当前事务是只读事务，一般用于查询场景。它可以作为优化提示，也能表达这个方法只做查询，不应该执行新增、修改、删除操作。

---

### 10. `@Transactional` 建议加在哪一层

**题目：** `@Transactional` 一般建议加在 Controller 层还是 Service 层？为什么？

**作答：** 一般加在 Service 中，Controller 是参数的验证和返回相应，Service 是处理业务和数据。

**评分：** 8.5 / 10

**修正点：**

不是“返回相应”，是“返回响应”。

**标准答案：**

`@Transactional` 一般建议加在 Service 层，因为 Service 层负责业务逻辑，一个业务方法可能包含多次数据库操作，事务应该控制完整的业务流程。Controller 主要负责接收请求、参数校验和返回响应，不建议承担事务控制。

---

## 二、新题：声明式事务与异常回滚

### 1. 什么是声明式事务

**题目：** 什么是 Spring 的声明式事务？它和编程式事务有什么区别？

**初答：** 就是不需要自己创建对象，这部分交给 Spring 来管理。

**评分：** 3 / 10

**问题：**

这题答偏了。这个答案更像 IOC / Bean 管理，不是声明式事务。

**标准答案：**

Spring 声明式事务就是通过 `@Transactional` 或 XML 配置来声明事务规则，由 Spring AOP 在方法执行前后自动开启、提交或回滚事务。编程式事务则是开发者在代码里手动使用 `TransactionTemplate` 或 `PlatformTransactionManager` 来控制事务。

**保命句：**

声明式事务是通过 `@Transactional` 让 Spring 自动管理事务；编程式事务是自己写代码手动控制事务。

**复述结果：** 通过。

---

### 2. `@Transactional` 加在类上和方法上的区别

**题目：** `@Transactional` 加在类上和加在方法上有什么区别？如果类和方法上都加了，以哪个为准？

**初答：** 事务的作用位置不一样，两个方法都加了就看事务用哪种传播了。

**评分：** 4 / 10

**问题：**

关键不是看传播行为，而是方法上的事务配置优先级更高。

**标准答案：**

`@Transactional` 加在类上，表示这个类里的 public 方法默认都使用这个事务配置；加在方法上，只对当前方法生效。如果类和方法上都加了，一般方法上的配置优先级更高，会覆盖类上的配置。

**保命句：**

类上的 `@Transactional` 是默认配置，方法上的 `@Transactional` 更具体，优先级更高。

**复述结果：** 通过。

---

### 3. 异常被 catch 后事务是否回滚

**题目：** 如果在 `@Transactional` 方法里把异常 `catch` 住了，没有再抛出，事务会回滚吗？为什么？

**作答：** 不会回滚，因为 Spring 接收不到异常。

**评分：** 9 / 10

**标准答案：**

不会回滚。因为 `@Transactional` 是通过 Spring AOP 拦截方法执行结果来判断是否回滚的，如果异常被 `catch` 住没有抛出去，Spring 感知不到异常，就会认为方法正常结束，事务会提交。

---

### 4. catch 异常后如何让事务回滚

**题目：** 如果在事务方法里确实需要 `catch` 异常，但又想让事务回滚，应该怎么做？

**作答：** 手动再一次抛出异常。

**评分：** 8.5 / 10

**标准答案：**

如果事务方法里需要 `catch` 异常，但又希望事务回滚，可以在 `catch` 里重新抛出异常，或者手动调用 `TransactionAspectSupport.currentTransactionStatus().setRollbackOnly()` 标记事务回滚。

**代码示例：**

```java
TransactionAspectSupport.currentTransactionStatus().setRollbackOnly();
```

**保命句：**

异常被 catch 后如果还想回滚，要么重新抛出异常，要么手动设置事务回滚。

---

## 三、追问

### 1. 声明式事务为什么和 Spring AOP 有关

**题目：** 声明式事务为什么底层和 Spring AOP 有关？

**作答：** 声明式事务是事务的提交、回滚和开启都是通过 Spring 来管理的，这完全符合 AOP 的作用。

**评分：** 7.5 / 10

**补充点：**

要说出“通过代理对象在方法执行前后织入事务逻辑”。

**标准答案：**

声明式事务底层和 Spring AOP 有关，因为 `@Transactional` 不是在业务代码里手动开启事务，而是 Spring 通过代理对象拦截方法调用，在方法执行前开启事务，方法正常结束后提交事务，方法抛异常时回滚事务。

**保命句：**

声明式事务是通过 Spring AOP 代理实现的，在方法执行前后自动加入事务开启、提交和回滚逻辑。

---

### 2. 一个事务方法调用多个 Mapper，中间异常怎么办

**题目：** `@Transactional` 方法里调用多个 Mapper，如果中间一个 Mapper 抛异常，前面已经执行的数据库操作会怎么样？

**作答：** 会一起回滚，只有这个方法结束才会执行提交操作。

**评分：** 9 / 10

**标准答案：**

如果多个 Mapper 操作在同一个 `@Transactional` 方法中，它们属于同一个事务。只要中间抛出会触发回滚的异常，整个事务都会回滚，前面已经执行的数据库操作也不会最终生效。

---

### 3. 普通 `Exception` 默认是否回滚

**题目：** `@Transactional` 默认遇到普通 `Exception` 会不会回滚？如果想让它回滚，怎么配置？

**作答：** `@Transaction(rollbackFor=Exception.class)`。

**评分：** 6 / 10

**问题：**

- 漏说：普通 `Exception` 默认不会回滚
- 注解写错：不是 `@Transaction`，而是 `@Transactional`

**标准答案：**

`@Transactional` 默认遇到普通 `Exception` 不会回滚，只会对 `RuntimeException` 和 `Error` 回滚。如果希望普通 `Exception` 也回滚，需要配置 `@Transactional(rollbackFor = Exception.class)`。

**标准写法：**

```java
@Transactional(rollbackFor = Exception.class)
```

---

## 四、Day 42 背诵清单

1. AOP 常见通知有 `@Before`、`@AfterReturning`、`@AfterThrowing` 和 `@Around`。
2. `@Around` 是环绕增强，可以在方法执行前后加逻辑，并通过 `proceed()` 控制目标方法是否执行。
3. 同类内部 `this.xxx()` 调用没有经过 Spring 代理对象，所以事务可能不生效。
4. JDK 动态代理基于接口，CGLIB 基于继承，通过生成目标类的子类来实现代理。
5. 脏读是读到未提交数据，不可重复读是同一行前后值不一样，幻读是同一条件前后行数不一样。
6. `READ_COMMITTED` 避免脏读，`REPEATABLE_READ` 避免不可重复读。
7. Spring 默认事务隔离级别是 `DEFAULT`；MySQL InnoDB 默认一般是 `REPEATABLE_READ`。
8. 声明式事务是通过 `@Transactional` 让 Spring 自动管理事务；编程式事务是自己写代码手动控制事务。
9. 类上的 `@Transactional` 是默认配置，方法上的 `@Transactional` 更具体，优先级更高。
10. 异常被 `catch` 后如果还想回滚，要么重新抛出异常，要么手动设置事务回滚。
11. `@Transactional` 默认对 `RuntimeException` 和 `Error` 回滚，对普通 `Exception` 默认不回滚。
12. 普通 `Exception` 想回滚，要写 `@Transactional(rollbackFor = Exception.class)`。

---

## 五、Day 43 回炉安排

### 必回炉

1. AOP 五种通知类型，尤其 `@AfterReturning`、`@AfterThrowing`
2. `@Around` 与 `proceed()`
3. `READ_COMMITTED` 避免脏读，不是避免幻读
4. 声明式事务和编程式事务区别
5. 类上和方法上 `@Transactional` 的优先级
6. 异常被 `catch` 后为什么事务不回滚
7. catch 后想回滚的两种办法
8. `@Transactional` 拼写
9. `rollbackFor = Exception.class`
10. Spring AOP 代理和事务的关系

### 轻回炉

1. 三级缓存提前暴露单例 Bean 引用
2. JDK 动态代理和 CGLIB
3. Spring 默认隔离级别 `DEFAULT`
4. MySQL InnoDB 默认 `REPEATABLE_READ`
