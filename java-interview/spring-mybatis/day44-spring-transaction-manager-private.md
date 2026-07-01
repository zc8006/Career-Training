# Day 44 - Spring 事务管理器、隔离级别与 private 方法事务失效

日期：2026-07-01

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 主线：事务传播行为回炉、事务隔离级别、事务管理器、多个事务管理器指定、private 方法事务失效

---

## 一、旧题回炉

### 1. 普通 `Exception` 回滚配置

**题目：** 如果普通 `Exception` 也要触发事务回滚，`@Transactional` 应该怎么写？

**作答：** `@Transactional(rollbackFor = Exception.class)`

**评分：** 10 / 10

**标准答案：**

如果希望普通 `Exception` 也触发事务回滚，需要配置：

```java
@Transactional(rollbackFor = Exception.class)
```

---

### 2. `REPEATABLE_READ` 拼写与作用

**题目：** `REPEATABLE_READ` 怎么拼？它能避免什么问题？

**初答：** `REPEATABLE_TABLE`，能防止不可重复读。

**评分：** 5 / 10

**问题：**

拼写错误，不是 `REPEATABLE_TABLE`，而是 `REPEATABLE_READ`。

**标准答案：**

`REPEATABLE_READ` 表示可重复读，可以避免不可重复读，也就是同一个事务中多次读取同一行数据，结果保持一致。

**保命句：**

`REPEATABLE_READ` 是可重复读，可以避免不可重复读。

**复述结果：** 通过。

---

### 3. `@AfterReturning` 和 `@AfterThrowing`

**题目：** `@AfterReturning` 和 `@AfterThrowing` 分别在什么时机执行？

**作答：** `AfterReturning` 是在正常结束后执行，`AfterThrowing` 是在异常结束后执行。

**评分：** 8 / 10

**标准答案：**

`@AfterReturning` 在方法正常返回后执行，`@AfterThrowing` 在方法抛出异常后执行。

---

### 4. `@Around` 里的 `proceed()`

**题目：** `@Around` 里的 `proceed()` 是干什么的？如果不调用它会怎么样？

**初答：** 明确调用哪个方法。

**评分：** 3 / 10

**问题：**

`proceed()` 不是“明确调用哪个方法”，而是继续执行原来的目标方法。

**标准答案：**

`proceed()` 用来继续执行原来的目标方法。如果不调用 `proceed()`，目标方法不会执行，业务逻辑也不会继续往下走。

**保命句：**

`proceed()` 是继续执行目标方法，不调用它，目标方法就不会执行。

**复述结果：** 通过。

---

### 5. `NESTED` 和 `REQUIRES_NEW`

**题目：** `NESTED` 和 `REQUIRES_NEW` 的最大区别是什么？

**作答：** `NESTED` 是设置一个保存点，回滚的时候基于这个保存点来执行，外层事务可能不会受到影响，`REQUIRES_NEW` 没说完整。

**评分：** 6.5 / 10

**标准答案：**

`NESTED` 是在外层事务里创建保存点，内层失败可以回滚到保存点，外层可以继续；`REQUIRES_NEW` 是挂起外层事务，开启一个独立的新事务。

**保命句：**

`NESTED` 是基于保存点的嵌套事务，`REQUIRES_NEW` 是独立新事务。

---

### 6. `SUPPORTS` 和 `NOT_SUPPORTED`

**题目：** `SUPPORTS` 和 `NOT_SUPPORTED` 的区别是什么？

**作答：** `SUPPORTS` 是有事务就用事务，没有事务就不用事务；`NOT_SUPPORTED` 是有事务就挂起，不用事务。

**评分：** 9 / 10

**标准答案：**

`SUPPORTS` 是支持当前事务，有事务就加入，没有事务就非事务执行；`NOT_SUPPORTED` 是不支持事务，如果当前有事务就挂起事务，自己以非事务方式执行。

---

### 7. `MANDATORY` 和 `NEVER`

**题目：** `MANDATORY` 和 `NEVER` 分别是什么意思？

**初答：** `MANDATORY` 不知道，`NEVER` 是有事务就报错。

**评分：** 5 / 10

**标准答案：**

`MANDATORY` 表示必须在已有事务中执行，如果当前没有事务就报错；`NEVER` 表示不能在事务中执行，如果当前有事务就报错。

**保命句：**

`MANDATORY` 是必须有事务，没有就报错；`NEVER` 是不能有事务，有事务就报错。

**复述结果：** 通过。

---

### 8. 默认传播行为 `REQUIRED`

**题目：** Spring 事务默认传播行为是什么？它是什么意思？

**作答：** 默认传播行为是 `REQUIERD`，有事务就加入，没有事务就创建事务。

**评分：** 8 / 10

**问题：**

拼写错误，不是 `REQUIERD`，而是 `REQUIRED`。

**标准答案：**

Spring 事务默认传播行为是 `REQUIRED`。它表示当前有事务就加入当前事务，没有事务就新建一个事务。

---

### 9. 默认回滚异常

**题目：** `@Transactional` 默认遇到哪些异常会回滚？普通 `Exception` 默认会不会回滚？

**作答：** 默认遇到 `RuntimeException` 会回滚，普通 `Exception` 不会回滚。

**评分：** 8 / 10

**补充点：**

`Error` 默认也会回滚。

**标准答案：**

`@Transactional` 默认遇到 `RuntimeException` 和 `Error` 会回滚，普通 `Exception` 默认不会回滚。如果希望普通 `Exception` 也回滚，需要配置 `rollbackFor = Exception.class`。

---

### 10. JDK 动态代理和 CGLIB

**题目：** JDK 动态代理和 CGLIB 有什么区别？

**作答：** JDK 动态代理是给接口生成对象代理，CGLIB 是给类创建子类，进行对象代理。

**评分：** 8 / 10

**标准答案：**

JDK 动态代理要求目标类实现接口，它生成的是接口代理对象；CGLIB 不要求接口，它通过生成目标类的子类来实现代理。简单说，JDK 动态代理基于接口，CGLIB 基于继承。

---

## 二、新题

### 1. 隔离级别和传播行为的区别

**题目：** Spring 事务的隔离级别和传播行为有什么区别？

**作答：** 隔离级别是对单个事务，传播行为是多个事务之间的行为。

**评分：** 8 / 10

**标准答案：**

事务隔离级别解决的是并发事务之间的数据一致性问题，比如脏读、不可重复读、幻读；事务传播行为解决的是一个事务方法调用另一个事务方法时，事务应该加入当前事务、新建事务、挂起事务还是报错。

---

### 2. Spring Boot 为什么一般不用手动配置事务管理器

**题目：** Spring Boot 里为什么一般不需要手动配置事务管理器？什么时候可能需要手动配置？

**初答：** 事务不是有依赖吗，如果需要手动修改的时候。

**评分：** 4 / 10

**标准答案：**

Spring Boot 一般不需要手动配置事务管理器，因为它会根据数据源和相关依赖自动配置事务管理器。比如使用 JDBC 或 MyBatis 时，会自动配置 `DataSourceTransactionManager`。如果项目里有多数据源、多个事务管理器，或者需要指定某个事务管理器，就可能需要手动配置。

**保命句：**

Spring Boot 会自动配置事务管理器；只有多数据源或需要自定义事务管理器时，才需要手动配置。

**复述结果：** 通过。

---

### 3. 多个事务管理器时如何指定

**题目：** 如果项目里有多个事务管理器，`@Transactional` 怎么指定使用哪一个？

**初答：** 不知道。

**评分：** 0 / 10

**标准答案：**

如果项目里有多个事务管理器，可以通过 `@Transactional(transactionManager = "xxxTransactionManager")` 指定使用哪一个事务管理器。

**标准写法：**

```java
@Transactional(transactionManager = "orderTransactionManager")
```

也可以写：

```java
@Transactional("orderTransactionManager")
```

**保命句：**

多个事务管理器时，可以在 `@Transactional` 里通过 `transactionManager` 指定。

**复述结果：** 通过。

---

### 4. `@Transactional` 加在 `private` 方法上为什么不生效

**题目：** `@Transactional` 只能加在 `public` 方法上吗？加在 `private` 方法上为什么通常不生效？

**作答：** 只能加在 `public` 方法上，`private` 对象代理访问不了。

**评分：** 8 / 10

**标准答案：**

`@Transactional` 通常建议加在 public 方法上。加在 private 方法上通常不生效，因为 Spring 事务基于 AOP 代理，private 方法不能被代理对象正常拦截，事务增强逻辑不会执行。

---

## 三、追问

### 1. 隔离级别和传播行为分别解决什么问题

**题目：** 事务隔离级别和事务传播行为，分别解决什么问题？

**作答：** 事务隔离级别解决脏读、不可重复读、幻读的问题，事务传播行为主要是什么时候创建事务、如何回滚、提交的问题。

**评分：** 7 / 10

**修正点：**

传播行为不是主要讲“如何回滚、提交”，而是讲一个事务方法调用另一个事务方法时，是加入事务、新建事务、挂起事务、非事务执行，还是报错。

**标准答案：**

事务隔离级别解决并发事务之间的数据一致性问题，比如脏读、不可重复读、幻读；事务传播行为解决事务方法之间相互调用时，事务应该加入当前事务、新建事务、挂起事务、非事务执行还是报错。

**保命句：**

隔离级别解决并发读写问题，传播行为解决事务方法调用时事务怎么传递。

---

### 2. 多事务管理器如何指定

**题目：** 如果项目里有多个事务管理器，`@Transactional` 怎么指定使用哪一个？

**作答：** `@Transactional` 里通过 `transactionalManager` 来指定哪个事务管理器。

**评分：** 7 / 10

**问题：**

配置名写错，不是 `transactionalManager`，而是 `transactionManager`。

**标准写法：**

```java
@Transactional(transactionManager = "orderTransactionManager")
```

**标准答案：**

如果项目里有多个事务管理器，可以通过 `@Transactional(transactionManager = "xxxTransactionManager")` 指定使用哪一个事务管理器。

**保命句：**

多个事务管理器时，可以在 `@Transactional` 里通过 `transactionManager` 指定。

---

### 3. private 方法事务为什么通常不生效

**题目：** 为什么 `@Transactional` 加在 `private` 方法上通常不生效？

**作答：** `private`，AOP 拦截不到，而且都是类的内部方法调用。

**评分：** 9 / 10

**标准答案：**

`@Transactional` 加在 `private` 方法上通常不生效，因为 Spring 事务是基于 AOP 代理实现的，`private` 方法不能被代理对象正常拦截，而且通常是类内部调用，没有经过代理对象。

---

## 四、Day 44 背诵清单

1. 普通 `Exception` 想回滚，要写 `@Transactional(rollbackFor = Exception.class)`。
2. `REPEATABLE_READ` 是可重复读，可以避免不可重复读。
3. `@AfterReturning` 在方法正常返回后执行，`@AfterThrowing` 在方法抛异常后执行。
4. `proceed()` 是继续执行目标方法，不调用它，目标方法就不会执行。
5. `NESTED` 是基于保存点的嵌套事务，`REQUIRES_NEW` 是独立新事务。
6. `SUPPORTS` 是有事务就加入，没有事务就不用事务。
7. `NOT_SUPPORTED` 是有事务就挂起，自己不用事务。
8. `MANDATORY` 是必须有事务，没有就报错；`NEVER` 是不能有事务，有事务就报错。
9. `REQUIRED` 是默认传播行为，有事务就加入，没有事务就新建。
10. `@Transactional` 默认遇到 `RuntimeException` 和 `Error` 会回滚，普通 `Exception` 默认不会回滚。
11. 隔离级别解决并发读写问题，传播行为解决事务方法调用时事务怎么传递。
12. Spring Boot 会自动配置事务管理器，多数据源或需要自定义时才需要手动配置。
13. 多个事务管理器时，可以在 `@Transactional` 里通过 `transactionManager` 指定。
14. `@Transactional` 加在 `private` 方法上通常不生效，因为代理对象拦截不到。

---

## 五、Day 45 回炉安排

### 必回炉

1. `REPEATABLE_READ` 拼写
2. `proceed()` 的作用
3. `NESTED` 和 `REQUIRES_NEW`
4. `MANDATORY` 和 `NEVER`
5. `REQUIRED` 拼写
6. `RuntimeException` 和 `Error` 默认回滚
7. 隔离级别和传播行为的区别
8. Spring Boot 自动配置事务管理器
9. 多事务管理器 `transactionManager` 写法
10. private 方法事务为什么不生效

### 轻回炉

1. `@AfterReturning` 和 `@AfterThrowing`
2. JDK 动态代理和 CGLIB
3. `SUPPORTS` 和 `NOT_SUPPORTED`
