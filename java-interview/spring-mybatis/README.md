# Spring + Spring Boot + MyBatis 面试训练

本目录用于记录 Java 面试训练中 Spring、Spring Boot、MyBatis 相关的高频题、保命句、错题回炉和每日背诵清单。

## 当前进度

| Day | 主题 | 文件 |
|---|---|---|
| Day 27 | MyBatis 核心回炉 + 主键回填/分页/缓存 | [day27-mybatis-core.md](./day27-mybatis-core.md) |
| Day 28 | MyBatis 回炉 + Spring Boot 三层结构 + 事务失效 | [day28-spring-transaction.md](./day28-spring-transaction.md) |
| Day 29 | Spring IOC/AOP/Bean 生命周期 + 事务 AOP 原理 | [day29-spring-core.md](./day29-spring-core.md) |
| Day 44 | Spring 事务管理器、隔离级别与 private 方法事务失效 | [day44-spring-transaction-manager-private.md](./day44-spring-transaction-manager-private.md) |
| Day 45 | Spring 事务管理器、异常捕获与手动回滚 | [day45-spring-transaction-manager-catch-rollback.md](./day45-spring-transaction-manager-catch-rollback.md) |

## 固定训练规则

1. 旧题回炉 8～10 道
2. 新题 4 道以内
3. 追问最多 3 个
4. 最后整理背诵清单
5. 答错题标记为第二天回炉

## 当前重点问题

### Day 46 必回炉

1. `TransactionManager` 作用：事务开启、提交、回滚，不要和数据源 / 连接池混淆。
2. `setRollbackOnly()` 是否立即回滚：不是立即回滚，是标记当前事务最终必须回滚。

### Day 46 轻回炉

1. `MANDATORY` / `NEVER`
2. `REQUIRED` 拼写
3. 隔离级别和传播行为的区别
4. 多事务管理器 `transactionManager` 拼写
5. `DataSourceTransactionManager` 和 `JpaTransactionManager`
6. 多 Mapper 操作如何通过 Service 层事务保证一致性

## 高频保命句总览

1. MyBatis 是半自动 ORM，因为 SQL 要自己写，但参数映射和结果映射由 MyBatis 自动完成。
2. Mapper 没有实现类也能调用，是因为 MyBatis 通过动态代理生成 Mapper 代理对象。
3. `#{}` 是预编译占位符，安全；`${}` 是字符串拼接，不安全。
4. 模糊查询用 `where name like concat('%', #{keyword}, '%')`，不要用 `${}`。
5. 动态 SQL 用来根据条件动态拼接 SQL，常见标签有 `if`、`where`、`set`、`choose`、`foreach`。
6. Controller 接收请求并返回结果，Service 处理业务和事务，Mapper 执行 SQL。
7. 事务放 Service 层，是为了控制整个业务流程的一致性。
8. Spring 事务是基于 AOP 代理实现的，方法前开启事务，成功提交，异常回滚。
9. IOC 管对象，DI 管注入。
10. AOP 抽取事务、日志、权限等公共逻辑，在不修改业务代码的情况下增强方法。
11. Spring AOP 是动态代理，有接口用 JDK 动态代理，没有接口用 CGLIB。
12. Spring Bean 生命周期：创建对象 → 注入依赖 → 初始化 → 使用 → 销毁。
