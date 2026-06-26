# Day 40 - Spring 事务失效与传播行为

日期：2026-06-26

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 主线：跨域、MyBatis XML、循环依赖、AOP、事务失效、事务回滚、事务传播行为

---

## 一、旧题回炉

### 1. 跨域与 CORS

**题目：** 什么是跨域？Spring Boot 里一般怎么解决跨域问题？

**作答：** 协议、端口、域名不一致会导致不一样，一般用 CORS 全局配置或者 `@CrossOrigin` 注解。

**评分：** 8.5 / 10

**修正点：**

- “会导致不一样”建议改成“会导致跨域问题”
- `@CrossOrigin` 这次说对了

**标准答案：**

跨域是前后端协议、域名或端口不一致导致的，Spring Boot 可以用 `@CrossOrigin` 或全局 CORS 配置解决。

---

### 2. MyBatis XML 位置与配置项

**题目：** Spring Boot 整合 MyBatis 时，XML 文件一般放在哪里？配置项一般叫什么？

**初答：** `resources/mapper` 下面，`mybatis.mapper-location`。

**评分：** 7 / 10

**修正点：**

- 不是 `mybatis.mapper-location`
- 正确是 `mybatis.mapper-locations`
- 最后是 `locations`，有 `s`

**标准答案：**

XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。

**复述结果：** 通过。

---

### 3. Spring 能解决哪些循环依赖

**题目：** Spring 能解决哪些循环依赖？哪些循环依赖解决不了？

**作答：** 解决部分字段注入循环依赖，构造器注入循环依赖解决不了。

**评分：** 8 / 10

**补充点：**

再补两个关键词会更完整：单例 Bean、Setter 注入。

**标准答案：**

Spring 一般可以解决单例 Bean 的字段注入或 Setter 注入循环依赖，但解决不了构造器注入循环依赖。因为构造器注入要求对象创建时依赖必须已经准备好。

---

### 4. 三级缓存提前暴露 Bean 引用

**题目：** Spring 为什么能解决部分字段注入的循环依赖？大概靠什么机制？

**作答：** 通过三级缓存，暴露其中的一个 Bean，来解决。

**评分：** 8 / 10

**补充点：**

更标准说法是：提前暴露单例 Bean 的引用。

**标准答案：**

Spring 能解决部分字段注入的循环依赖，主要靠三级缓存。它会提前暴露单例 Bean 的引用，让其他 Bean 在属性注入时可以先拿到这个对象。

---

### 5. Spring AOP

**题目：** 什么是 Spring AOP？一般用来解决什么问题？

**作答：** AOP 是面向切面编程，把日志、事务这些处理提取成共通，从而简化业务代码。

**评分：** 8.5 / 10

**补充点：**

再补一句“通过代理增强方法”会更完整。

**标准答案：**

Spring AOP 是面向切面编程，主要用来把日志、事务、权限校验等横切关注点从业务代码中抽离出来，通过代理机制统一增强方法逻辑，让业务代码更加清晰。

---

### 6. 切点、通知和切面

**题目：** 什么是切点、通知和切面？用自己的话说一下。

**作答：** 切面是切点和通知的集合，切点就是对哪个方法进行拦截，通知就是如何增强。

**评分：** 9 / 10

**标准答案：**

切点表示要拦截哪些方法，通知表示在方法执行前、后或异常时要增强什么逻辑，切面就是切点和通知的组合。

---

### 7. AOP 常见通知类型

**题目：** AOP 里常见的通知类型有哪些？比如方法执行前、正常返回后、异常时分别对应什么？

**初答：** 忘记。

**评分：** 0 / 10

**常见通知：**

- `@Before`：方法执行前
- `@AfterReturning`：方法正常返回后
- `@AfterThrowing`：方法抛异常后
- `@Around`：环绕增强，能控制方法执行前后
- `@After`：方法执行后，不管成功还是异常都会执行

**标准答案：**

AOP 常见通知有 `@Before`、`@After`、`@AfterReturning`、`@AfterThrowing`、`@Around`。其中 `@Before` 在方法执行前，`@AfterReturning` 在正常返回后，`@AfterThrowing` 在异常后，`@Around` 可以包住整个方法执行过程。

**保命句：**

AOP 常见通知有 `@Before`、`@AfterReturning`、`@AfterThrowing` 和 `@Around`，分别对应执行前、正常返回后、异常后和环绕增强。

**复述结果：** 通过。

---

### 8. `@Transactional` 为什么是 AOP 的典型应用

**题目：** `@Transactional` 为什么可以看成是 AOP 的典型应用？

**作答：** 把事务的开启、提交、回滚都通过代理对象进行增强处理。

**评分：** 9 / 10

**标准答案：**

`@Transactional` 可以看成 AOP 的典型应用，因为事务逻辑不是写在业务方法里，而是由 Spring 通过代理在方法执行前后统一处理，比如开启事务、提交事务和异常回滚。

---

### 9. AOP 适合和不适合的场景

**题目：** AOP 适合处理哪些场景？不适合处理哪些场景？

**作答：** AOP 适合处理日志、事务这些共通方法，实际业务的处理不行。

**评分：** 8 / 10

**补充点：**

再补两个常见场景会更完整：权限、监控。

**标准答案：**

AOP 适合处理日志、事务、权限、监控、审计这类横切逻辑，不适合处理复杂业务流程和核心业务判断。业务逻辑应该放在 Service 里，AOP 只做通用增强。

---

### 10. JDK 动态代理和 CGLIB 区别

**题目：** Spring AOP 底层有 JDK 动态代理和 CGLIB，两者有什么区别？

**作答：** JDK 动态代理是有接口的情况下，CGLIB 是没有接口的情况下对类及子类生成对象代理。

**评分：** 8 / 10

**修正点：**

- CGLIB 不是“对类及子类生成对象代理”
- 更标准是：CGLIB 通过生成目标类的子类来实现代理

**标准答案：**

JDK 动态代理要求目标类实现接口，它生成的是接口代理对象；CGLIB 不要求接口，它通过生成目标类的子类来实现代理。简单说，JDK 动态代理基于接口，CGLIB 基于继承。

---

## 二、新题：Spring 事务失效与传播行为

### 1. 同类内部调用事务为什么不生效

**题目：** 为什么同一个类里，一个方法直接调用另一个带 `@Transactional` 的方法，事务可能不生效？

**作答：** 事务能不能生效，因为 `this.xxx()` 这样调用，没法生成对象代理。

**评分：** 8 / 10

**修正点：**

不是“没法生成对象代理”，更标准是：没有经过代理对象调用，所以事务增强不会被触发。

**标准答案：**

因为 `@Transactional` 是通过 Spring AOP 代理实现的。同一个类里用 `this.xxx()` 直接调用方法时，没有经过 Spring 代理对象，所以事务拦截器不会执行，事务可能不生效。

---

### 2. `@Transactional` 常见失效场景

**题目：** `@Transactional` 常见的失效场景有哪些？说几个。

**作答：** 类的内部方法调用，`private`，异常类型不对，被 catch 住，自己创建的 Bean。

**评分：** 9 / 10

**标准答案：**

`@Transactional` 常见失效场景包括：同类内部方法调用、方法不是 public、异常被 catch 没有抛出、抛出的是默认不回滚的 checked exception、对象不是 Spring 容器管理的 Bean。核心原因是没有走 Spring 代理，或者事务拦截器没有机会感知异常。

---

### 3. `@Transactional` 默认回滚异常规则

**题目：** `@Transactional` 默认遇到什么异常会回滚？遇到什么异常默认不会回滚？

**作答：** `RuntimeException` 会回滚，`excepiton` 不会回滚，`rollbackfor` 需要使用。

**评分：** 8.5 / 10

**修正点：**

- 不是 `excepiton`，是 `Exception`
- 不是 `rollbackfor`，标准写法是 `rollbackFor`

**标准答案：**

`@Transactional` 默认遇到 `RuntimeException` 和 `Error` 会回滚，遇到普通的 checked exception，比如 `Exception`，默认不会回滚。如果希望所有异常都回滚，可以配置 `rollbackFor = Exception.class`。

**保命句：**

事务默认对 `RuntimeException` 回滚，对普通 `Exception` 不回滚；需要时可以用 `rollbackFor = Exception.class`。

---

### 4. 事务传播行为：`REQUIRED` 与 `REQUIRES_NEW`

**题目：** `@Transactional` 的传播行为是什么意思？常见的 `REQUIRED` 和 `REQUIRES_NEW` 有什么区别？

**初答：** 传播行为就是嵌套事务有的时候需不需要创建，不知道。

**评分：** 4 / 10

**标准答案：**

事务传播行为表示一个事务方法调用另一个事务方法时，事务应该如何传播。`REQUIRED` 是默认传播行为，有事务就加入，没有事务就新建；`REQUIRES_NEW` 是每次都新建一个事务，如果外层已有事务，会先挂起外层事务。

**保命句：**

`REQUIRED` 是有事务就加入，没有就新建；`REQUIRES_NEW` 是总是新建一个事务。

**复述结果：** 通过。

---

## 三、追问

### 1. 为什么必须通过 Spring 管理的 Bean 调用事务方法

**题目：** 为什么 `@Transactional` 方法必须通过 Spring 管理的 Bean 调用才会生效？

**作答：** Spring 管理的 Bean 会生成代理对象，来进行开启、提交和回滚。

**评分：** 9 / 10

**标准答案：**

`@Transactional` 是通过 Spring AOP 代理实现的，只有通过 Spring 容器管理的代理对象调用方法时，事务拦截器才会执行，才能完成事务开启、提交和回滚。

---

### 2. 异常被 catch 后事务是否回滚

**题目：** 如果一个 `@Transactional` 方法里把异常 `catch` 住了，没有再抛出去，事务会回滚吗？为什么？

**作答：** 不会回滚，代理对象没有收到异常。

**评分：** 9 / 10

**标准答案：**

不会回滚。因为异常被方法内部 `catch` 住以后，没有继续向外抛出，Spring 事务代理感知不到异常，就会认为方法正常执行完成，所以会提交事务。

---

### 3. 如何让普通 `Exception` 也回滚

**题目：** 如果希望 `Exception` 这种普通异常也触发事务回滚，应该怎么配置？

**初答：** `rollbackFor="Exception"`

**评分：** 6 / 10

**修正点：**

标准写法是：

```java
@Transactional(rollbackFor = Exception.class)
```

**标准答案：**

如果希望普通 `Exception` 也触发事务回滚，可以配置 `@Transactional(rollbackFor = Exception.class)`。

**保命句：**

普通 `Exception` 默认不回滚，需要用 `rollbackFor = Exception.class` 指定回滚。

**复述结果：** 通过。

---

## 四、Day 40 背诵清单

1. 跨域是前后端协议、域名或端口不一致导致的，可以用 `@CrossOrigin` 或全局 CORS 配置解决。
2. XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。
3. Spring 能解决部分单例 Bean 的字段注入循环依赖，但解决不了构造器注入循环依赖。
4. Spring 解决字段注入循环依赖，主要靠三级缓存提前暴露 Bean 引用。
5. AOP 是面向切面编程，用来把日志、事务、权限等通用逻辑从业务代码中抽出来。
6. AOP 常见通知有 `@Before`、`@AfterReturning`、`@AfterThrowing` 和 `@Around`。
7. `@Transactional` 是通过 Spring AOP 代理实现的。
8. 同类内部 `this.xxx()` 调用没有经过代理对象，所以事务可能不生效。
9. `@Transactional` 默认对 `RuntimeException` 和 `Error` 回滚，对普通 `Exception` 默认不回滚。
10. 普通 `Exception` 默认不回滚，需要用 `rollbackFor = Exception.class` 指定回滚。
11. `REQUIRED` 是有事务就加入，没有就新建；`REQUIRES_NEW` 是总是新建一个事务。
12. 异常被 `catch` 住没有继续抛出，事务代理感知不到异常，默认不会回滚。

---

## 五、Day 41 回炉安排

### 必回炉

1. `mybatis.mapper-locations`
2. AOP 常见通知类型：`@Before`、`@AfterReturning`、`@AfterThrowing`、`@Around`
3. 同类内部 `this.xxx()` 调用事务为什么不生效
4. `@Transactional` 常见失效场景
5. `RuntimeException` / `Exception` 默认回滚规则
6. `rollbackFor = Exception.class`
7. `REQUIRED` 与 `REQUIRES_NEW`

### 轻回炉

1. `@CrossOrigin`
2. 三级缓存提前暴露 Bean 引用
3. AOP 适合和不适合的场景
4. JDK 动态代理与 CGLIB 区别
