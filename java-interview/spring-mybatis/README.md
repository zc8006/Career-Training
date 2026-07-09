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
| Day 47 | Spring AOP、Bean 生命周期与循环依赖回炉 | [day47-spring-aop-bean-lifecycle.md](./day47-spring-aop-bean-lifecycle.md) |
| Day 49 | Spring AOP、Spring Boot 启动流程与 Spring MVC 请求链路 | [day49-spring-aop-boot-mvc.md](./day49-spring-aop-boot-mvc.md) |

## 固定训练规则

1. 旧题回炉 8～10 道
2. 新题 4 道以内
3. 追问最多 3 个
4. 最后整理背诵清单
5. 答错题标记为第二天回炉

## 当前重点问题

### Day 50 必回炉

1. `BeanPostProcessor` 是什么
2. Spring 三级缓存分别放什么
3. setter 循环依赖和构造器循环依赖区别
4. Spring AOP 执行链
5. Spring MVC 请求链路
6. `HandlerMapping` 和 `HandlerAdapter`
7. `DispatcherServlet` 的作用
8. `@SpringBootApplication` 三个注解拼写
9. `@PostConstruct` 准确执行时机
10. Bean 生命周期里要说“实例化”，不要说“加载”

### 后续全覆盖台账

1. Spring AOP 多切面顺序与 `@Order`
2. Spring Boot 自动配置源码级流程
3. Spring MVC 参数绑定、返回值处理、统一异常处理
4. MyBatis 执行链、缓存与插件机制

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
12. Spring Bean 生命周期：实例化 → 属性注入 → 初始化 → 使用 → 销毁。
13. BeanFactory 是基础容器，ApplicationContext 是更完整、更常用的高级容器。
14. starter 负责把依赖带进来，自动配置负责根据条件创建 Bean。
15. BeanPostProcessor 是 Bean 初始化前后的扩展点，AOP 代理很多就是靠它在初始化后生成的。
16. Spring 通过三级缓存提前暴露单例 Bean 的早期引用，解决 setter 循环依赖。
17. AOP 执行链就是拦截器链：先按顺序执行前置增强，再执行目标方法，最后反向执行后置增强。
18. DispatcherServlet 是 Spring MVC 的统一入口，负责接收请求、分发请求、调用 Controller，并处理返回结果。
19. HandlerMapping 负责找到 Controller 方法，HandlerAdapter 负责调用 Controller 方法。
