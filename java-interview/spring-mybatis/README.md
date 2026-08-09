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
| Day 50 | Spring AOP 注解、代理限制与事务回炉 | [day50-spring-aop-annotation-transaction.md](./day50-spring-aop-annotation-transaction.md) |
| Day 51 | AOP 代理限制与 Spring MVC 全局异常处理 | [day51-aop-proxy-spring-mvc-exception.md](./day51-aop-proxy-spring-mvc-exception.md) |
| Day 52 | Spring Boot 自动配置与自我成长模式 | [day52-spring-boot-auto-configuration.md](./day52-spring-boot-auto-configuration.md) |
| Day 53 | Spring 回顾 + Java 集合基础 + 成长记录 | [day53-java-collection-spring-review.md](./day53-java-collection-spring-review.md) |

## Day54 必回炉

1. BeanPostProcessor
2. Spring 三级缓存
3. JoinPoint / ProceedingJoinPoint
4. Conditional 条件装配
5. HashMap 源码细节
6. ConcurrentHashMap 原理
7. equals / hashCode 契约

## 自我成长模式

后续训练不仅关注面试八股，还加入技术成长闭环：

### 四层成长模型

1. 知道：能说出概念
2. 理解：能解释原理
3. 应用：能结合项目使用
4. 输出：能设计方案、解决问题、指导别人

### 每个知识点复盘

- 这是什么？
- 为什么这样设计？
- 项目哪里会用？
- 遇到问题如何解决？
- 能否向别人讲清楚？

目标：从背面试题，提升到工程能力。

## 后续全覆盖台账

1. Spring Boot 自动配置源码级流程
2. Spring MVC 参数绑定、消息转换器与返回值处理
3. Spring MVC 拦截器、过滤器与统一响应
4. MyBatis 执行链、缓存与插件机制
5. Java 集合源码
6. JVM
7. Java 并发编程

## 高频保命句总览

1. MyBatis 是半自动 ORM，因为 SQL 要自己写，但参数映射和结果映射由 MyBatis 自动完成。
2. Mapper 没有实现类也能调用，是因为 MyBatis 通过动态代理生成 Mapper 代理对象。
3. `#{}` 是预编译占位符，安全；`${}` 是字符串拼接，不安全。
4. Spring 事务是基于 AOP 代理实现的。
5. IOC 管对象，DI 管注入。
6. AOP 抽取公共逻辑，通过代理对象实现增强。
7. Spring Bean 生命周期：实例化 → 属性注入 → 初始化 → 使用 → 销毁。
8. BeanPostProcessor 是 Bean 初始化前后的扩展点。
9. starter 负责引入依赖，自动配置负责根据条件创建 Bean。
10. Spring Boot 自动配置通过 Conditional 条件注解决定是否生效。
11. private 方法不能被代理增强，this 调用失效是因为绕过代理对象。
12. DispatcherServlet 是 Spring MVC 请求入口。
13. HandlerMapping 找 Controller，HandlerAdapter 调 Controller。
14. 全局异常处理使用 RestControllerAdvice + ExceptionHandler。
15. HashMap JDK8 是数组+链表+红黑树，树化是为了优化极端 hash 冲突查询性能。
16. equals 相等的对象必须保证 hashCode 相等。
