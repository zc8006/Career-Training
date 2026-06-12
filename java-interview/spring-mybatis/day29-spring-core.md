# Day 29 - Spring IOC / AOP / Bean 生命周期

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. MyBatis 模糊查询 like 怎么写？

**保命句：**

模糊查询用 `where name like concat('%', #{keyword}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，不安全。

> Day 30 必回炉：第一次 SQL 语法仍漏了 `like`。

### 2. 动态 SQL 有什么用？常见标签有哪些？

**保命句：**

动态 SQL 用来根据条件动态拼接 SQL，常见标签有 `if`、`where`、`set`、`choose`、`foreach`。

### 3. rollbackFor = Exception.class 是解决什么问题的？

**保命句：**

`rollbackFor = Exception.class` 用来让普通 Exception 也触发事务回滚。

### 4. 为什么同一个类里的方法互相调用，@Transactional 可能会失效？

**保命句：**

同类内部调用事务会失效，是因为 `this.xxx()` 调用没有经过 Spring 代理对象，而事务是基于 AOP 代理实现的。

### 5. Spring 事务在什么情况下会失效？

**保命句：**

Spring 事务失效主要是：没走代理、方法不是 public、异常被 catch、普通 Exception 没配 `rollbackFor`、对象不是 Spring Bean。

### 6. @Transactional 默认遇到什么异常会回滚？

**保命句：**

`@Transactional` 默认 RuntimeException 和 Error 回滚，普通 Exception 不回滚。

### 7. Controller、Service、Mapper 分别负责什么？

**保命句：**

Controller 接收请求并返回结果，Service 处理业务和事务，Mapper 执行 SQL；业务逻辑放 Service 层，职责更清晰，也方便复用和维护。

### 8. 为什么事务一般加在 Service 层？

**保命句：**

事务放 Service 层，是为了控制整个业务流程的一致性。

### 9. MyBatis 一级缓存和二级缓存是什么？

**保命句：**

一级缓存是 `SqlSession` 级别，默认开启；二级缓存是 Mapper / namespace 级别，需要手动开启，多个 `SqlSession` 可以共享。

二级缓存要谨慎使用，因为如果数据库数据更新后缓存没有及时失效，其他查询可能读到旧数据，导致数据不一致。

### 10. #{} 和 ${} 有什么区别？

**保命句：**

`#{}` 是预编译占位符，安全；`${}` 是字符串拼接，不安全。

## 新题

### 1. Spring IOC 是什么？DI 又是什么？

**保命句：**

IOC 管对象，DI 管注入；IOC 把对象交给 Spring 管理，DI 把依赖对象注入进来。

**面试版：**

IOC 是控制反转，意思是对象的创建、管理和依赖关系不再由程序自己控制，而是交给 Spring 容器管理。DI 是依赖注入，是实现 IOC 的方式，Spring 会把需要的依赖对象注入到 Bean 里，比如通过 `@Autowired` 注入 Service、Mapper 等对象。

### 2. Spring AOP 是什么？一般用在什么场景？

**保命句：**

AOP 是面向切面编程，用来抽取事务、日志、权限等公共逻辑，在不修改业务代码的情况下增强方法。

**常见场景：**

1. 事务
2. 日志
3. 权限校验
4. 接口耗时统计
5. 异常处理

### 3. Spring AOP 底层一般怎么实现？JDK 动态代理和 CGLIB 有什么区别？

**保命句：**

Spring AOP 是动态代理，有接口用 JDK 动态代理，没有接口用 CGLIB。

**完整说法：**

Spring AOP 底层主要基于动态代理。有接口时用 JDK 动态代理，基于接口生成代理对象；没有接口时用 CGLIB，在运行时生成目标类的子类代理对象。代理对象由 Spring 自动创建，不需要我们手动继承。

### 4. Spring Bean 的生命周期大概是什么？

**保命句：**

Spring Bean 生命周期：创建对象 → 注入依赖 → 初始化 → 使用 → 销毁。

**稍完整说法：**

Spring Bean 生命周期大概是：实例化 Bean、属性注入、初始化、使用 Bean、销毁 Bean。初始化阶段可能会执行 `@PostConstruct`、`InitializingBean` 或自定义 `init-method`；销毁阶段可能会执行 `@PreDestroy` 或 `destroy-method`。

## 追问

### 1. Spring AOP 和事务是什么关系？为什么说 Spring 事务底层依赖 AOP？

**保命句：**

Spring 事务是基于 AOP 代理实现的，方法前开启事务，成功提交，异常回滚。

**面试版：**

Spring 事务是 AOP 的一个典型应用。`@Transactional` 本质上是通过 AOP 代理对方法进行增强，在方法执行前开启事务，方法执行成功后提交事务，方法抛出异常时回滚事务。所以如果方法调用没有经过代理对象，事务就可能失效。

### 2. Spring Bean 生命周期里，初始化阶段一般可以用哪些方式做初始化逻辑？

**保命句：**

Bean 初始化可以用 `@PostConstruct`，也可以实现 `InitializingBean`，或者配置 `init-method`。

### 3. Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**保命句：**

Bean 销毁可以用 `@PreDestroy`，也可以实现 `DisposableBean`，或者配置 `destroy-method`。

## Day 30 回炉

### 必回炉

1. 模糊查询 `like` 写法：必须说出 `where name like concat('%', #{keyword}, '%')`
2. Spring 事务和 AOP 的关系
3. Bean 初始化方式：`@PostConstruct`、`InitializingBean`、`init-method`
4. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`

### 轻回炉

1. `rollbackFor = Exception.class`
2. 同类内部调用事务为什么失效

## Day 29 背诵清单

1. 模糊查询用 `where name like concat('%', #{keyword}, '%')`，不要用 `${}`。
2. 动态 SQL 用来根据条件动态拼接 SQL，常见标签有 `if`、`where`、`set`、`choose`、`foreach`。
3. `rollbackFor = Exception.class` 用来让普通 Exception 也触发事务回滚。
4. 同类内部调用事务会失效，是因为 `this.xxx()` 调用没有经过 Spring 代理对象。
5. Spring 事务失效常见原因：没走代理、方法不是 public、异常被 catch、普通 Exception 没配 rollbackFor、对象不是 Spring Bean。
6. `@Transactional` 默认 RuntimeException 和 Error 回滚，普通 Exception 不回滚。
7. IOC 管对象，DI 管注入。
8. AOP 是面向切面编程，用来抽取事务、日志、权限等公共逻辑。
9. Spring AOP 是动态代理，有接口用 JDK 动态代理，没有接口用 CGLIB。
10. Spring Bean 生命周期：创建对象 → 注入依赖 → 初始化 → 使用 → 销毁。
11. Spring 事务是基于 AOP 代理实现的，方法前开启事务，成功提交，异常回滚。
12. Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。
13. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
