# Day 41 - Spring 事务隔离级别、只读事务与事务分层

日期：2026-06-28

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 主线：MyBatis XML、AOP 通知、事务失效、回滚规则、传播行为、隔离级别、只读事务、事务放在哪一层

---

## 一、旧题回炉

### 1. MyBatis XML 位置与配置项

**题目：** Spring Boot 整合 MyBatis 时，XML 文件一般放在哪里？配置项一般叫什么？

**作答：** `resources/mapper`，配置项叫 `mybatis.mapper-locations`。

**评分：** 9 / 10

**标准答案：**

XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。

---

### 2. AOP 常见通知类型

**题目：** AOP 里常见的通知类型有哪些？比如方法执行前、正常返回后、异常时分别对应什么？

**初答：** 忘记。

**评分：** 0 / 10

**复述：** `@Before` 在方法执行前，`@AfterReturning` 在方法正常返回后，`@AfterThrowing` 在方法抛异常后，`@Around` 是环绕增强，可以控制方法执行前后。

**复述评分：** 9 / 10

**标准答案：**

AOP 常见通知有 `@Before`、`@After`、`@AfterReturning`、`@AfterThrowing`、`@Around`。其中 `@Before` 在方法执行前，`@AfterReturning` 在正常返回后，`@AfterThrowing` 在异常后，`@Around` 可以包住整个方法执行过程。

**补充：**

`@After` 是方法执行后，不管成功还是异常都会执行。

---

### 3. 同类内部调用事务为什么不生效

**题目：** 为什么同一个类里，一个方法直接调用另一个带 `@Transactional` 的方法，事务可能不生效？

**作答：** 同类方法使用 `this.xxx()`，没有使用接口，Spring 就不能进行代理增强。

**评分：** 7 / 10

**修正点：**

不是因为“没有使用接口”，而是因为没有经过 Spring 代理对象调用。即使使用 CGLIB，`this.xxx()` 这种当前对象内部直接调用也会绕过代理。

**标准答案：**

因为 `@Transactional` 是通过 Spring AOP 代理实现的。同一个类里用 `this.xxx()` 直接调用方法时，没有经过 Spring 代理对象，所以事务拦截器不会执行，事务可能不生效。

---

### 4. `@Transactional` 常见失效场景

**题目：** `@Transactional` 常见的失效场景有哪些？说几个。

**作答：** 类的内部方法调用，`private`，被 `catch` 住，异常类型不对，自己创建的 Bean。

**评分：** 9 / 10

**标准答案：**

`@Transactional` 常见失效场景包括：同类内部方法调用、方法不是 public、异常被 catch 没有抛出、抛出的是默认不回滚的 checked exception、对象不是 Spring 容器管理的 Bean。核心原因是没有走 Spring 代理，或者事务拦截器没有机会感知异常。

---

### 5. `@Transactional` 默认回滚异常规则

**题目：** `@Transactional` 默认遇到什么异常会回滚？遇到什么异常默认不会回滚？

**作答：** 默认遇到 `RuntimeException` 会回滚，遇到 `Exception` 默认不会回滚。

**评分：** 8 / 10

**补充点：**

`Error` 默认也会回滚。

**标准答案：**

`@Transactional` 默认遇到 `RuntimeException` 和 `Error` 会回滚，遇到普通的 checked exception，比如 `Exception`，默认不会回滚。需要时可以用 `rollbackFor = Exception.class` 指定回滚。

---

### 6. 如何让普通 `Exception` 也回滚

**题目：** 如果希望普通 `Exception` 也触发事务回滚，应该怎么配置？

**作答：** 使用 `rollbackFor=Excepiton.class`。

**评分：** 7 / 10

**修正点：**

拼写错误，不是 `Excepiton.class`，而是 `Exception.class`。

**标准写法：**

```java
@Transactional(rollbackFor = Exception.class)
```

**标准答案：**

如果希望普通 `Exception` 也触发事务回滚，可以配置 `@Transactional(rollbackFor = Exception.class)`。

---

### 7. `REQUIRED` 与 `REQUIRES_NEW`

**题目：** 事务传播行为里，`REQUIRED` 和 `REQUIRES_NEW` 有什么区别？

**作答：** 事务传播就是调用方法都有事务的时候，应该怎么处理。`REQUIRED` 如果有事务就用调用方法的事务，`REQUIRES_NEW` 每次都会创建事务。

**评分：** 8.5 / 10

**补充点：**

`REQUIRES_NEW` 如果外层已经有事务，会先挂起外层事务。

**标准答案：**

事务传播行为表示一个事务方法调用另一个事务方法时，事务应该如何传播。`REQUIRED` 是默认传播行为，有事务就加入，没有事务就新建；`REQUIRES_NEW` 是每次都新建一个事务，如果外层已有事务，会先挂起外层事务。

---

### 8. `@CrossOrigin`

**题目：** `@CrossOrigin` 是干什么的？一般用在什么场景？

**作答：** `@CrossOrigin` 是跨域的时候，可以解决跨域的问题，一般加在单个 controll。

**评分：** 8 / 10

**修正点：**

不是 `controll`，正式说法是 `Controller`。

**标准答案：**

`@CrossOrigin` 用来解决跨域问题，一般可以加在 Controller 类上，也可以加在具体接口方法上，适合做局部跨域配置。

---

### 9. 三级缓存提前暴露 Bean 引用

**题目：** Spring 为什么能解决部分字段注入的循环依赖？大概靠什么机制？

**作答：** 使用三级缓存，暴露其中的某一个 Bean。

**评分：** 8 / 10

**修正点：**

面试里要说得更准确：提前暴露单例 Bean 的引用。

**标准答案：**

Spring 能解决部分字段注入的循环依赖，主要靠三级缓存。它会提前暴露单例 Bean 的引用，让其他 Bean 在属性注入时可以先拿到这个对象。

---

### 10. JDK 动态代理和 CGLIB 区别

**题目：** Spring AOP 底层有 JDK 动态代理和 CGLIB，两者有什么区别？

**作答：** JDK 动态代理是有接口的时候使用，CGLIB 是没有接口对类的子类进行对象代理。

**评分：** 8 / 10

**修正点：**

不要说“对子类进行对象代理”，标准说法是：CGLIB 通过生成目标类的子类来实现代理。

**标准答案：**

JDK 动态代理要求目标类实现接口，它生成的是接口代理对象；CGLIB 不要求接口，它通过生成目标类的子类来实现代理。简单说，JDK 动态代理基于接口，CGLIB 基于继承。

---

## 二、新题：事务隔离级别、只读事务与事务分层

### 1. 事务隔离级别解决什么问题

**题目：** Spring 事务的隔离级别是用来解决什么问题的？常见的脏读、不可重复读、幻读分别是什么意思？

**初答：** 主要用来解决脏读、幻读、不可重复读。脏读就是读取了被更新前的数据，不可重复读是不能读取前一个 SQL 执行的结果，幻读就是更新插入后读取的件数是更新插入前的。

**评分：** 5 / 10

**修正点：**

- 脏读：不是读取更新前的数据，而是读到了其他事务未提交的数据
- 不可重复读：不是不能读取前一个 SQL 结果，而是同一个事务中两次读取同一行数据结果不一致
- 幻读：同一个事务中两次按条件查询，记录数量不一致

**标准答案：**

事务隔离级别主要用来解决并发事务带来的脏读、不可重复读和幻读问题。脏读是读到了其他事务未提交的数据；不可重复读是同一个事务中两次读取同一行数据，结果不一致；幻读是同一个事务中两次按条件查询，查到的记录数量不一致。

**保命句：**

脏读是读到未提交数据，不可重复读是同一行前后读到的值不一样，幻读是同一条件前后查到的行数不一样。

**复述结果：** 通过。

---

### 2. 常见事务隔离级别

**题目：** Spring 事务隔离级别常见有哪些？`READ_COMMITTED` 和 `REPEATABLE_READ` 有什么区别？

**初答：** 忘记。

**复述：** `READ_UNCOMMITTED`：读未提交，`READ_COMMITTED`：读已提交，`REPEATABLE_READ`：可重复读，`SERIALIZABLE`：串行化。`READ_COMMITTED` 能避免脏读，`REPEATABLE_READ` 能避免不可重复读。默认是 `REPEATABLE_READ`。

**评分：** 8.5 / 10

**修正点：**

Spring 事务默认隔离级别不是直接写死 `REPEATABLE_READ`，而是 `DEFAULT`，表示使用数据库默认隔离级别。MySQL InnoDB 默认一般是 `REPEATABLE_READ`。

**标准答案：**

Spring 事务常见隔离级别有 `READ_UNCOMMITTED`、`READ_COMMITTED`、`REPEATABLE_READ`、`SERIALIZABLE`。`READ_COMMITTED` 表示只能读取已提交的数据，可以避免脏读；`REPEATABLE_READ` 表示同一个事务中多次读取同一行数据结果一致，可以避免不可重复读。

**默认隔离级别：**

Spring 默认使用数据库的默认隔离级别。如果是 MySQL InnoDB，默认通常是 `REPEATABLE_READ`。

---

### 3. `@Transactional(readOnly = true)`

**题目：** `@Transactional(readOnly = true)` 是什么意思？一般用在什么场景？

**初答：** 不知道。

**评分：** 0 / 10

**标准答案：**

`@Transactional(readOnly = true)` 表示当前事务是只读事务，一般用于查询场景。它可以作为优化提示，也能表达这个方法只做查询，不应该执行新增、修改、删除操作。

**保命句：**

`readOnly = true` 表示只读事务，一般用于查询方法，不建议在里面做增删改。

**复述结果：** 通过。

---

### 4. `@Transactional` 加在哪一层

**题目：** `@Transactional` 一般建议加在 Controller 层还是 Service 层？为什么？

**作答：** Service 层，Service 是负责处理业务数据和 Mapper 的。

**评分：** 8 / 10

**补充点：**

事务应该包住一个完整的业务操作，而不是只包住单条 SQL。

**标准答案：**

`@Transactional` 一般建议加在 Service 层，因为 Service 层负责业务逻辑，一个业务方法可能包含多次数据库操作，事务应该控制完整的业务流程。Controller 主要负责接收请求和返回响应，不建议承担事务控制。

---

## 三、追问

### 1. 为什么不建议把 `@Transactional` 加在 Controller 层

**题目：** 为什么不建议把 `@Transactional` 加在 Controller 层？

**初答：** Controller 主要负责参数的验证。

**评分：** 6 / 10

**标准答案：**

不建议把 `@Transactional` 加在 Controller 层，因为 Controller 主要负责接收请求、参数校验和返回响应，业务逻辑应该放在 Service 层。事务应该控制一个完整的业务操作，所以一般加在 Service 层更清晰。

**保命句：**

Controller 负责接收请求和返回响应，事务应该控制 Service 层的完整业务流程。

**复述结果：** 通过。

---

### 2. 查询方法是否要加 `readOnly = true`

**题目：** 如果一个方法只是查询数据，要不要加 `@Transactional(readOnly = true)`？为什么？

**作答：** 需要加，这样可以明确。

**评分：** 7 / 10

**修正点：**

不是所有查询都必须加。加上 `readOnly = true` 可以作为优化提示，也能表达方法不应该做增删改。

**标准答案：**

如果方法只是查询数据，可以加 `@Transactional(readOnly = true)`。它可以明确这是只读事务，作为优化提示，也表示这个方法不应该执行新增、修改、删除操作。但不是每个简单查询都必须加。

**保命句：**

查询方法可以加 `readOnly = true`，表示只读事务，也提醒这个方法不应该做增删改。

---

### 3. Spring 默认事务隔离级别

**题目：** Spring 默认事务隔离级别是什么？如果是 MySQL InnoDB，一般默认是什么？

**作答：** 默认是 `DEFAULT`，默认是不可重复读。

**评分：** 6 / 10

**修正点：**

Spring 默认是 `DEFAULT` 说对了。MySQL InnoDB 默认一般是 `REPEATABLE_READ`，也就是可重复读，不是“不可重复读”。

**标准答案：**

Spring 事务默认隔离级别是 `DEFAULT`，表示使用数据库默认隔离级别。如果是 MySQL InnoDB，一般默认是 `REPEATABLE_READ`，也就是可重复读。

---

## 四、Day 41 背诵清单

1. XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。
2. AOP 常见通知有 `@Before`、`@AfterReturning`、`@AfterThrowing` 和 `@Around`。
3. 同类内部 `this.xxx()` 调用没有经过 Spring 代理对象，所以事务可能不生效。
4. `@Transactional` 常见失效场景包括同类内部调用、非 public 方法、异常被 catch、异常类型不对、对象不是 Spring Bean。
5. 事务默认对 `RuntimeException` 和 `Error` 回滚，对普通 `Exception` 默认不回滚。
6. 普通 `Exception` 默认不回滚，需要用 `rollbackFor = Exception.class` 指定回滚。
7. `REQUIRED` 是有事务就加入，没有就新建；`REQUIRES_NEW` 是总是新建事务。
8. 脏读是读到未提交数据，不可重复读是同一行前后读到的值不一样，幻读是同一条件前后查到的行数不一样。
9. `READ_COMMITTED` 能避免脏读，`REPEATABLE_READ` 能避免不可重复读。
10. `readOnly = true` 表示只读事务，一般用于查询方法，不建议在里面做增删改。
11. `@Transactional` 一般建议加在 Service 层，因为事务应该控制完整业务流程。
12. Spring 默认事务隔离级别是 `DEFAULT`；MySQL InnoDB 默认一般是 `REPEATABLE_READ`。

---

## 五、Day 42 回炉安排

### 必回炉

1. AOP 通知类型：`@Before`、`@AfterReturning`、`@AfterThrowing`、`@Around`、`@After`
2. 同类内部 `this.xxx()` 调用事务为什么不生效
3. `Exception.class` 拼写
4. `rollbackFor = Exception.class`
5. 三级缓存提前暴露单例 Bean 引用
6. CGLIB 通过生成目标类子类实现代理
7. 脏读、不可重复读、幻读
8. Spring 常见事务隔离级别
9. Spring 默认 `DEFAULT`，MySQL InnoDB 默认 `REPEATABLE_READ`
10. `readOnly = true`

### 轻回炉

1. `mybatis.mapper-locations`
2. `@CrossOrigin`
3. `REQUIRED` 与 `REQUIRES_NEW`
4. `@Transactional` 加在 Service 层
