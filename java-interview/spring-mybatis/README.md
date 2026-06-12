# Spring + Spring Boot + MyBatis 面试训练

本目录用于记录 Java 面试训练中 Spring、Spring Boot、MyBatis 相关的高频题、保命句、错题回炉和每日背诵清单。

## 当前进度

| Day | 主题 | 文件 |
|---|---|---|
| Day 27 | MyBatis 核心回炉 + 主键回填/分页/缓存 | [day27-mybatis-core.md](./day27-mybatis-core.md) |
| Day 28 | MyBatis 回炉 + Spring Boot 三层结构 + 事务失效 | [day28-spring-transaction.md](./day28-spring-transaction.md) |
| Day 29 | Spring IOC/AOP/Bean 生命周期 + 事务 AOP 原理 | [day29-spring-core.md](./day29-spring-core.md) |

## 固定训练规则

1. 旧题回炉 8～10 道
2. 新题 4 道以内
3. 追问最多 3 个
4. 最后整理背诵清单
5. 答错题标记为第二天回炉

## 当前重点问题

### 必须继续卡的题

1. MyBatis 模糊查询 `like` 写法：必须说出 `where name like concat('%', #{keyword}, '%')`
2. Spring 事务和 AOP 的关系
3. Bean 初始化方式：`@PostConstruct`、`InitializingBean`、`init-method`
4. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`

### 轻回炉题

1. `rollbackFor = Exception.class`
2. 同类内部调用事务为什么失效
3. 动态 SQL 标签不要漏 `set`

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
