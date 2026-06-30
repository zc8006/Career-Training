# Day 43 - Spring 事务传播行为

日期：2026-06-30

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 主线：AOP 通知、环绕增强、事务隔离级别、声明式事务、异常回滚、事务传播行为

---

## 一、旧题回炉

### 1. AOP 常见通知类型

**题目：** AOP 常见通知类型有哪些？分别在什么时机执行？

**初答：** `@Before` 方法执行前，`@AfterReturning` 方法执行后。

**评分：** 4 / 10

**问题：**

- `@AfterReturning` 不是简单“方法执行后”，而是方法正常返回后
- 漏了 `@AfterThrowing`、`@Around`、`@After`

**标准答案：**

AOP 常见通知有 `@Before`、`@AfterReturning`、`@AfterThrowing`、`@Around` 和 `@After`。`@Before` 在方法执行前，`@AfterReturning` 在方法正常返回后，`@AfterThrowing` 在方法抛异常后，`@Around` 是环绕增强，`@After` 是方法执行后一定会执行。

**保命句：**

AOP 常见通知有 `@Before`、`@AfterReturning`、`@AfterThrowing` 和 `@Around`，分别对应执行前、正常返回后、异常后和环绕增强。

**复述结果：** 通过。

**补充：**

`@After` 是最终通知，不管方法正常结束还是抛异常，都会执行。

---

### 2. `@Around` 与 `proceed()`

**题目：** `@Around` 为什么叫环绕增强？`proceed()` 是干什么的？

**初答：** `Around` 在方法前后都可以执行，`proceed` 是设定用哪种通知。

**评分：** 5 / 10

**问题：**

`proceed()` 不是设定用哪种通知，而是继续执行目标方法。如果不调用 `proceed()`，原来的业务方法就不会真正执行。

**标准答案：**

`@Around` 叫环绕增强，是因为它可以包住目标方法，在方法执行前后都加逻辑。`proceed()` 表示继续执行原来的目标方法，如果不调用它，目标方法就不会执行。

**保命句：**

`@Around` 可以包住目标方法，`proceed()` 用来继续执行原来的目标方法。

**复述结果：** 通过。

---

### 3. `READ_COMMITTED` 和 `REPEATABLE_READ`

**题目：** `READ_COMMITTED` 和 `REPEATABLE_READ` 分别能避免什么问题？

**作答：** `READ_COMMITTED` 是避免脏读，`REPEATALE_READ` 是用来解决不可重复读。

**评分：** 8 / 10

**问题：**

拼写错误，不是 `REPEATALE_READ`，而是 `REPEATABLE_READ`。

**标准答案：**

`READ_COMMITTED` 表示读已提交，可以避免脏读；`REPEATABLE_READ` 表示可重复读，可以避免不可重复读。

---

### 4. 声明式事务和编程式事务

**题目：** 什么是声明式事务？它和编程式事务有什么区别？

**作答：** 声明式事务是事务的开启、提交、回滚都交给 Spring 来管理，编程式事务是所有的东西都需要手动编写。

**评分：** 8.5 / 10

**补充点：**

声明式事务一般通过 `@Transactional` 实现；编程式事务一般通过 `TransactionTemplate` 或 `PlatformTransactionManager` 手动控制。

**标准答案：**

声明式事务是通过 `@Transactional` 让 Spring 自动管理事务的开启、提交和回滚；编程式事务是开发者自己写代码，手动控制事务的开启、提交和回滚。

---

### 5. 类上和方法上的 `@Transactional`

**题目：** 类上和方法上都加了 `@Transactional`，以哪个为准？为什么？

**作答：** 以方法的为准，类加上了，是所有的方法都使用这个，方法加上了只是针对这个方法实施。

**评分：** 8.5 / 10

**修正点：**

可以说：方法上的配置只对当前方法生效，优先级更高。

**标准答案：**

类上的 `@Transactional` 是默认配置，表示这个类里的 public 方法默认都使用这个事务配置；方法上的 `@Transactional` 更具体，只对当前方法生效。如果类和方法上都加了，一般以方法上的配置为准。

---

### 6. 异常被 catch 后事务是否回滚

**题目：** 如果在 `@Transactional` 方法里把异常 `catch` 住了，没有再抛出，事务会回滚吗？为什么？

**作答：** 不会回滚，Spring 接收不到异常。

**评分：** 9 / 10

**标准答案：**

不会回滚。因为异常被 `catch` 住后没有抛出，Spring 会认为方法正常执行完成，所以事务会提交。

---

### 7. catch 后如何让事务回滚

**题目：** 如果在事务方法里必须 `catch` 异常，但又想让事务回滚，应该怎么做？

**作答：** 手动抛出异常。

**评分：** 8 / 10

**补充点：**

除了重新抛出异常，也可以手动设置事务回滚标记。

**标准答案：**

如果事务方法里必须 `catch` 异常，但又希望事务回滚，可以在 `catch` 里重新抛出异常，或者手动调用 `TransactionAspectSupport.currentTransactionStatus().setRollbackOnly()` 标记事务回滚。

**保命句：**

异常被 catch 后如果还想回滚，要么重新抛出异常，要么手动设置事务回滚。

---

### 8. 普通 `Exception` 默认是否回滚

**题目：** `@Transactional` 默认遇到普通 `Exception` 会不会回滚？如果想让它回滚，怎么配置？

**作答：** 不会回滚，需要加 `@Transationl(rollBackFor=Exception.class)`。

**评分：** 7 / 10

**问题：**

标准写法是：

```java
@Transactional(rollbackFor = Exception.class)
```

注意：

- `Transactional`，中间是 `ctional`
- `rollbackFor`，小写 `b`

**标准答案：**

`@Transactional` 默认遇到普通 `Exception` 不会回滚，只会对 `RuntimeException` 和 `Error` 回滚。如果希望普通 `Exception` 也回滚，需要配置 `@Transactional(rollbackFor = Exception.class)`。

---

### 9. 声明式事务和 Spring AOP 的关系

**题目：** 声明式事务为什么底层和 Spring AOP 有关？

**作答：** 声明式事务使用 `@Transational`，自动开启、提交和回滚，这些都是基于 AOP 的对象代理来实现。

**评分：** 8 / 10

**问题：**

拼写错误，不是 `@Transational`，而是 `@Transactional`。

**标准答案：**

声明式事务底层和 Spring AOP 有关，因为 `@Transactional` 是通过代理对象拦截方法调用，在方法执行前开启事务，方法正常结束后提交事务，方法抛异常时回滚事务。

**保命句：**

声明式事务是通过 Spring AOP 代理实现的，在方法执行前后自动加入事务开启、提交和回滚逻辑。

---

### 10. JDK 动态代理和 CGLIB

**题目：** JDK 动态代理和 CGLIB 有什么区别？

**作答：** JDK 动态代理是有接口的时候使用，对接口生成对象代理，CGLIB 是没有接口，对类生成子类对象代理。

**评分：** 8 / 10

**修正点：**

不要说“对类生成子类对象代理”，标准说法是：CGLIB 通过生成目标类的子类来实现代理。

**标准答案：**

JDK 动态代理要求目标类实现接口，它生成的是接口代理对象；CGLIB 不要求接口，它通过生成目标类的子类来实现代理。简单说，JDK 动态代理基于接口，CGLIB 基于继承。

---

## 二、新题：事务传播行为

### 1. `NESTED` 和 `REQUIRES_NEW`

**题目：** Spring 事务传播行为里的 `NESTED` 是什么意思？它和 `REQUIRES_NEW` 有什么区别？

**初答：** `REQUIRES_NEW` 是每次创建新的事务，`NESTED` 是新的事务不会影响到调用的事务。

**评分：** 6 / 10

**修正点：**

`NESTED` 不是完全独立的新事务。它更像是在外层事务里创建一个保存点 savepoint。内层失败可以回滚到保存点，外层事务可以继续执行；但如果外层事务最终回滚，内层也会一起回滚。

**标准答案：**

`NESTED` 表示嵌套事务，如果当前已经有事务，就在当前事务里创建保存点，内层异常可以回滚到保存点，不一定影响外层事务。`REQUIRES_NEW` 是挂起外层事务，重新开启一个独立事务。

**保命句：**

`NESTED` 是基于保存点的嵌套事务，`REQUIRES_NEW` 是独立新事务。

**复述结果：** 通过。

---

### 2. `SUPPORTS` 和 `MANDATORY`

**题目：** Spring 事务传播行为里的 `SUPPORTS` 和 `MANDATORY` 分别是什么意思？

**初答：** 不知道。

**评分：** 0 / 10

**标准答案：**

`SUPPORTS` 表示支持当前事务，如果当前有事务就加入，没有事务就非事务执行。`MANDATORY` 表示必须存在事务，如果当前没有事务，就抛异常。

**保命句：**

`SUPPORTS` 是有事务就加入，没有事务就不用事务；`MANDATORY` 是必须有事务，没有就报错。

**复述结果：** 通过。

---

### 3. `NOT_SUPPORTED` 和 `NEVER`

**题目：** Spring 事务传播行为里的 `NOT_SUPPORTED` 和 `NEVER` 分别是什么意思？

**初答：** 不知道。

**评分：** 0 / 10

**标准答案：**

`NOT_SUPPORTED` 表示不以事务方式执行，如果当前存在事务，就把当前事务挂起；`NEVER` 表示必须非事务执行，如果当前存在事务，就抛异常。

**保命句：**

`NOT_SUPPORTED` 是有事务就挂起，自己不用事务；`NEVER` 是不能有事务，有事务就报错。

**复述结果：** 通过。

---

### 4. 默认事务传播行为

**题目：** Spring 事务传播行为里，默认的是哪一个？它是什么意思？

**初答：** 不知道。

**评分：** 0 / 10

**标准答案：**

Spring 事务默认传播行为是 `REQUIRED`。它表示当前有事务就加入当前事务，没有事务就新建一个事务。

**保命句：**

`REQUIRED` 是默认传播行为，有事务就加入，没有事务就新建。

**复述结果：** 通过。

---

## 三、追问

### 1. `REQUIRED` 和 `REQUIRES_NEW`

**题目：** `REQUIRED` 和 `REQUIRES_NEW` 的最大区别是什么？

**作答：** `REQUIRED` 是有事务就加入，没有事务就新建，`REQUIRES_NEW` 是每次都新建事务。

**评分：** 8.5 / 10

**补充点：**

`REQUIRES_NEW` 如果外层已经有事务，会先挂起外层事务。

**标准答案：**

`REQUIRED` 是有事务就加入，没有事务就新建；`REQUIRES_NEW` 是每次都开启一个新的独立事务，如果外层已经有事务，会先挂起外层事务。

---

### 2. `NESTED` 和 `REQUIRES_NEW`

**题目：** `NESTED` 和 `REQUIRES_NEW` 的最大区别是什么？

**作答：** `NESTED` 是设置一个保存点，不影响外层事务，`REQUIRES_NEW` 是每次都新建。

**评分：** 8 / 10

**修正点：**

“不影响外层事务”要说得谨慎一点。`NESTED` 不是完全独立事务，外层事务如果最终回滚，内层也会一起回滚。

**标准答案：**

`NESTED` 是在外层事务里创建保存点，内层失败可以回滚到保存点，外层可以继续；`REQUIRES_NEW` 是挂起外层事务，开启一个独立的新事务。

---

### 3. `SUPPORTS` 和 `NOT_SUPPORTED`

**题目：** `SUPPORTS` 和 `NOT_SUPPORTED` 的区别是什么？

**初答：** 不知道。

**评分：** 0 / 10

**标准答案：**

`SUPPORTS` 是支持当前事务，有事务就加入，没有事务就非事务执行；`NOT_SUPPORTED` 是不支持事务，如果当前有事务就挂起事务，自己以非事务方式执行。

**保命句：**

`SUPPORTS` 是有事务就加入，没有事务就不用事务；`NOT_SUPPORTED` 是有事务就挂起，自己不用事务。

**复述结果：** 通过。

---

## 四、Day 43 背诵清单

1. `@Before` 是方法执行前，`@AfterReturning` 是方法正常返回后。
2. `@AfterThrowing` 是方法抛异常后，`@Around` 是环绕增强。
3. `@Around` 可以包住目标方法，`proceed()` 用来继续执行原来的目标方法。
4. `READ_COMMITTED` 避免脏读，`REPEATABLE_READ` 避免不可重复读。
5. 声明式事务是通过 `@Transactional` 让 Spring 自动管理事务。
6. 编程式事务是自己写代码手动控制事务。
7. 类上的 `@Transactional` 是默认配置，方法上的配置优先级更高。
8. 异常被 `catch` 后如果还想回滚，要么重新抛出异常，要么手动设置事务回滚。
9. `@Transactional` 默认对普通 `Exception` 不回滚，需要配置 `rollbackFor = Exception.class`。
10. `REQUIRED` 是默认传播行为，有事务就加入，没有事务就新建。
11. `REQUIRES_NEW` 是独立新事务，如果外层有事务，会先挂起外层事务。
12. `NESTED` 是基于保存点的嵌套事务，不是完全独立事务。
13. `SUPPORTS` 是有事务就加入，没有事务就不用事务。
14. `MANDATORY` 是必须有事务，没有事务就报错。
15. `NOT_SUPPORTED` 是有事务就挂起，自己不用事务。
16. `NEVER` 是不能有事务，有事务就报错。

---

## 五、Day 44 回炉安排

### 必回炉

1. `@Transactional` 拼写
2. `rollbackFor` 大小写
3. `REPEATABLE_READ` 拼写
4. `@AfterReturning` 是正常返回后
5. `@Around` 和 `proceed()`
6. `NESTED` 基于保存点
7. `REQUIRES_NEW` 会挂起外层事务
8. `SUPPORTS` 和 `NOT_SUPPORTED`
9. `MANDATORY` 和 `NEVER`
10. 默认传播行为 `REQUIRED`

### 轻回炉

1. 声明式事务和编程式事务
2. 类上和方法上 `@Transactional` 优先级
3. catch 后事务回滚处理
4. JDK 动态代理和 CGLIB
