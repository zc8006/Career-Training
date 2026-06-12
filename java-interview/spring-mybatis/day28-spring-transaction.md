# Day 28 - MyBatis 回炉 + Spring Boot 三层结构 + 事务

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. 模糊查询 like 怎么写？

**保命句：**

模糊查询用 `like concat('%', #{keyword}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。

> 注意：本题 Day 29 必回炉，因为第一次仍然写成了 `${}`。

### 2. 动态 SQL 常见标签

**保命句：**

动态 SQL 用来根据条件动态拼接 SQL，常见标签有 `if`、`where`、`set`、`choose`、`foreach`。

### 3. 主键回填

**保命句：**

主键回填用 `useGeneratedKeys=true` 和 `keyProperty`，把数据库生成的主键回填到对象属性里。

### 4. Mapper 多参数传递

**保命句：**

Mapper 多参数少量用 `@Param`，参数多封装成 DTO / Query 对象。

### 5. RowBounds 和 PageHelper 区别

**保命句：**

`RowBounds` 偏逻辑分页，可能先查大量数据再内存截取；PageHelper 是物理分页，通过拦截 SQL 改写成数据库分页 SQL。

### 6. 一级缓存和二级缓存

**保命句：**

一级缓存是 `SqlSession` 级别，默认开启；二级缓存是 Mapper 级别，需要手动开启。

### 7. resultType 和 resultMap

**保命句：**

简单自动映射用 `resultType`，复杂手动映射用 `resultMap`。

### 8. 字段名和 Java 属性名不一致怎么办？

**保命句：**

字段名和 Java 属性名不一致，可以用 SQL 别名、开启驼峰命名映射，复杂情况用 `resultMap` 手动映射。

### 9. #{} 和 ${} 区别

**保命句：**

`#{}` 是预编译占位符，会变成 `?`，参数交给 JDBC 处理，所以安全；`${}` 是字符串直接拼接，所以不安全。

### 10. Mapper 接口为什么没有实现类也能调用？

**保命句：**

Mapper 接口没有实现类也能调用，是因为 MyBatis 会为 Mapper 接口生成动态代理对象。调用方法时，代理对象根据 `namespace + 方法名` 找到对应 SQL，然后通过 SqlSession / Executor 执行，并把结果映射成 Java 对象返回。

## 新题

### 1. Controller、Service、Mapper 分别负责什么？

**保命句：**

Controller 接收请求并返回结果，Service 处理业务和事务，Mapper 负责执行 SQL 访问数据库。

### 2. 为什么事务一般加在 Service 层？

**保命句：**

事务放 Service 层，是为了控制整个业务流程的一致性。

**面试版：**

Service 层负责业务逻辑，一个业务方法里可能会调用多个 Mapper、执行多条 SQL。事务放在 Service 层，可以保证这些数据库操作要么一起成功，要么一起回滚，保证业务数据一致性。

### 3. Spring 事务在什么情况下会失效？

**保命句：**

Spring 事务失效主要是没走代理、异常没抛出或异常类型不符合回滚规则。

**常见原因：**

1. 同类内部方法调用，没有经过代理对象
2. 方法不是 public，比如 private 方法
3. 异常被 catch 住，没有继续抛出
4. 抛出普通 Exception，但没有配置 `rollbackFor`
5. 对象不是 Spring 容器管理的 Bean，比如自己 new 出来的对象

### 4. @Transactional 默认遇到什么异常会回滚？

**保命句：**

`@Transactional` 默认 RuntimeException 回滚，普通 Exception 不回滚；要回滚普通 Exception，需要配置 `rollbackFor = Exception.class`。

## 追问

### 1. 为什么同一个类里的方法互相调用，@Transactional 可能会失效？

**保命句：**

同类内部调用事务会失效，是因为 `this.xxx()` 调用没有经过 Spring 代理对象，而事务是基于 AOP 代理实现的。

### 2. rollbackFor = Exception.class 是解决什么问题的？

**保命句：**

`rollbackFor = Exception.class` 用来让普通 Exception 也触发事务回滚。

### 3. 为什么不建议把业务逻辑写在 Controller 里？

**保命句：**

Controller 只负责接收请求和返回结果，业务逻辑放 Service 层，这样职责清晰、方便复用和维护。

## Day 29 回炉

### 必回炉

1. 模糊查询 `like` 怎么写？不能再用 `${}`。

### 轻回炉

1. 动态 SQL 常见标签，别漏 `set`
2. `rollbackFor` 这个单词
3. 同类内部调用事务为什么失效
