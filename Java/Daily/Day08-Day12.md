# Day 8 到 Day 12 Java 面试训练记录

## 总览

这一阶段主要打通：

```text
Spring Boot 请求链路 → Controller → Service → 事务 → Mapper → MyBatis → MySQL → JSON 返回
```

重点模块：

- MyBatis 主线
- Spring Boot 基础与实战排查
- Spring 事务回炉
- Spring Batch 入门

---

# Day 8：MyBatis 主线

## 已练问题

1. MyBatis 是什么？
2. MyBatis 和 JDBC 有什么区别？
3. 一个请求进入 Spring Boot 后，从 Controller 到数据库返回，大概流程是什么？
4. Controller、Service、Mapper 分别负责什么？
5. 事务为什么一般放在 Service 层？
6. MyBatis 里 `#{}` 和 `${}` 有什么区别？
7. MyBatis 动态 SQL 有哪些标签？
8. Mapper 接口为什么没有实现类也能调用？
9. MyBatis 一级缓存和二级缓存是什么？
10. MyBatis 和 Spring Boot 怎么整合？
11. `@MapperScan` 和 `@Mapper` 有什么区别？
12. MyBatis 多参数怎么传？
13. `@Param("query") UserQuery query` 是什么意思？
14. 少量参数用什么？参数多用什么？
15. MyBatis 批量插入怎么做？
16. MyBatis 一对一、一对多怎么实现？
17. MyBatis 延迟加载是什么？优缺点？
18. `resultType` 和 `resultMap` 有什么区别？
19. 数据库字段名和 Java 属性名不一致怎么办？
20. MyBatis 分页怎么做？
21. PageHelper 的原理是什么？
22. MyBatis 主键回填怎么做？
23. MyBatis 插件机制是什么？

## Day 8 核心保命句

```text
1. MyBatis 是 Java 持久层框架，用来简化 JDBC，负责 SQL 执行、参数映射和结果封装。
2. JDBC 要自己写连接、执行、封装、关闭；MyBatis 把这些封装了，我们主要写 Mapper 和 SQL。
3. Mapper 靠动态代理，SQL 靠 namespace + 方法名定位。
4. 一级缓存默认开，SqlSession 级别；二级缓存默认不开，Mapper 级别，实际项目谨慎用。
5. PageHelper = MyBatis 插件拦截 SQL + 改写分页 SQL。
6. 小批量 foreach，大批量 ExecutorType.BATCH，数据多要分批提交。
7. left join 负责查数据，association / collection 负责封装对象。
8. resultType 自动映射，resultMap 手动映射；简单用 resultType，复杂用 resultMap。
```

---

# Day 9：MyBatis 回炉 + Spring Boot 基础/实战

## 已练问题

1. MyBatis 是什么？
2. MyBatis 和 JDBC 有什么区别？
3. `#{}` 和 `${}` 的区别？
4. Mapper 为什么没有实现类也能调用？
5. 一级缓存和二级缓存是什么？
6. MyBatis 和 Spring Boot 怎么整合？
7. `@MapperScan` 和 `@Mapper` 的区别？
8. 多参数怎么传？
9. 批量插入怎么做？
10. 一对一、一对多怎么实现？
11. 延迟加载是什么？
12. `resultType` 和 `resultMap` 区别？
13. 字段名和属性名不一致怎么办？
14. MyBatis 分页怎么做？
15. 主键回填怎么做？
16. 插件机制和 PageHelper 原理？
17. 请求进入 Spring Boot 后的完整链路？
18. Controller、Service、Mapper 分别负责什么？
19. 事务为什么放 Service 层？
20. Spring 事务失效原因？
21. `@Transactional` 默认什么异常回滚？
22. `REQUIRED` 和 `REQUIRES_NEW` 区别？
23. `NESTED` 和 `REQUIRES_NEW` 区别？
24. Spring 事务隔离级别有哪些？
25. Spring Boot 自动配置原理？
26. `@SpringBootApplication` 包含哪几个注解？
27. Spring Boot 启动流程？
28. Starter 是什么？
29. 为什么 Spring Boot 不用外部 Tomcat？
30. `application.properties` 和 `application.yml` 区别？
31. 多环境配置怎么做？
32. 统一异常处理怎么做？
33. 参数校验怎么做？
34. Filter 和 Interceptor 区别？
35. 接口报 500 怎么排查？

## Day 9 核心保命句

```text
1. DispatcherServlet → Controller → Service → 事务 → Mapper → MyBatis → MySQL → JSON 返回。
2. 事务放 Service 层，是为了控制整个业务流程的一致性。
3. 事务失效：没走代理、方法不符合、异常没抛出、对象不归 Spring 管。
4. @Transactional 默认 RuntimeException 回滚，普通 Exception 不回滚，需要 rollbackFor。
5. REQUIRED 共用事务；REQUIRES_NEW 新开事务。
6. NESTED 是保存点，属于外层事务；REQUIRES_NEW 是新事务，会挂起外层事务。
7. 读未提交最低，读已提交防脏读，可重复读防不可重复读，串行化最安全但性能最低。
8. 自动配置 = @EnableAutoConfiguration + 自动配置类 + 条件判断 + 创建 Bean。
9. @SpringBootApplication = 配置类 + 自动配置 + 组件扫描。
10. 500 排查：先看日志和堆栈，再查参数、业务代码、SQL、数据库和下游接口。
```

---

# Day 10：MyBatis + Spring Boot 回炉，加练实战题

## 回炉问题

1. 接口报 500 怎么排查？
2. MyBatis 是什么？
3. MyBatis 和 JDBC 有什么区别？
4. `#{}` 和 `${}` 区别？
5. Mapper 接口为什么没有实现类也能调用？
6. 一级缓存和二级缓存是什么？
7. MyBatis 批量插入怎么做？
8. MyBatis 一对一、一对多怎么实现？
9. PageHelper 的原理是什么？
10. Spring Boot 请求链路是什么？
11. 事务为什么一般加在 Service 层？
12. Spring 事务失效原因？
13. `@Transactional` 默认什么异常回滚？
14. `REQUIRED` 和 `REQUIRES_NEW` 区别？
15. Spring Boot 自动配置原理？
16. `@SpringBootApplication` 包含哪几个核心注解？
17. Spring Boot 启动流程？
18. Spring Boot Starter 是什么？
19. 为什么 Spring Boot 可以不用外部 Tomcat？
20. 多环境配置怎么做？

## 加练问题

21. 统一异常处理怎么做？
22. 参数校验怎么做？
23. Filter 和 Interceptor 区别？
24. 跨域问题怎么处理？
25. 统一返回结果怎么做？
26. 日志怎么看？
27. Bean 注入失败怎么排查？

## Day 10 核心保命句

```text
1. 统一异常处理：@RestControllerAdvice 统一拦截，@ExceptionHandler 处理指定异常，最后返回统一 JSON。
2. 参数校验：DTO 字段加校验注解，Controller 参数加 @Valid，异常交给全局异常处理。
3. Filter 在 Spring MVC 前，Interceptor 在 Controller 前后。
4. 跨域可以用 @CrossOrigin，也可以用 WebMvcConfigurer 做全局配置。
5. 统一返回：定义 Result<T>，正常返回 success，异常返回 error。
6. 看日志：先看时间和接口，再看异常类型、堆栈行号、参数、SQL 和下游接口。
7. Bean 注入失败：先看日志，再查注解、扫描范围、多个实现、MapperScan、循环依赖和配置。
```

---

# Day 11：Spring Boot 实战排查

## 回炉问题

1. Spring Boot 统一异常处理怎么做？
2. Spring Boot 参数校验怎么做？
3. Filter 和 Interceptor 有什么区别？
4. Spring Boot 跨域问题怎么处理？
5. Spring Boot 统一返回结果怎么做？
6. 日志怎么看？
7. Bean 注入失败怎么排查？
8. Spring Boot 自动配置原理是什么？
9. 请求进入 Spring Boot 项目后，从 Controller 到数据库返回，大概流程是什么？
10. PageHelper 的原理是什么？

## 新题

1. Spring Boot 配置文件不生效，怎么排查？
2. Spring Boot 启动失败，怎么排查？
3. Spring Boot 端口冲突怎么排查和解决？
4. MyBatis Mapper 扫描失败，怎么排查？
5. 接口响应很慢，怎么排查？

## 追问

1. 如果接口慢是 SQL 慢，怎么优化？
2. 如果接口慢是下游接口慢，怎么处理？
3. 如果接口慢是数据量大，怎么处理？

## Day 11 核心保命句

```text
1. 配置不生效：查 profile、文件名、缩进、属性名、启动参数、配置覆盖。
2. 启动失败：看日志和 Caused by，再查端口、配置、依赖、Bean、数据库、MapperScan。
3. 端口冲突：看日志确认端口 → 查占用进程 → 停进程或改 server.port。
4. Mapper 扫描失败：查依赖、@Mapper、@MapperScan、包路径、XML 路径、namespace 和方法名。
5. 接口慢：先看日志耗时，再查业务逻辑、SQL、数据库连接池、下游接口和系统资源。
6. SQL 慢：定位慢 SQL → 看 EXPLAIN → 查索引和扫描行数 → 优化 SQL / 索引 / 分页 → 最后再考虑分库分表。
7. 下游慢：看调用日志、耗时、返回码、超时；再考虑超时、重试、降级、缓存和异步。
8. 数据量大：先分页、限字段、加索引、归档；最后再考虑分库分表。
```

---

# Day 12：Spring Boot 排查回炉 + Spring Batch 新题

## 已完成回炉 8 道

1. Spring Boot 统一返回结果怎么做？
2. 日志怎么看？线上接口报错重点看什么？
3. Bean 注入失败怎么排查？
4. Spring Boot 配置文件不生效怎么排查？
5. Spring Boot 启动失败怎么排查？
6. MyBatis Mapper 扫描失败怎么排查？
7. 接口响应很慢怎么排查？
8. SQL 慢怎么优化？

## 已完成新题

1. 什么是 Spring Batch？适合什么场景？
2. Spring Batch 里的 Job 和 Step 是什么？
3. Spring Batch 里的 ItemReader、ItemProcessor、ItemWriter 分别是什么？
4. Spring Batch 任务失败了怎么办？怎么保证可以继续处理？
5. 大批量数据处理时，怎么避免一次性加载太多数据？
6. 读大文件是不是也要分批？有没有例子？

## Day 12 已学保命句

```text
1. Spring Batch 是批处理框架，适合大批量、定时、分步骤的数据处理任务。
2. Job 是整个批处理任务，Step 是任务中的一个步骤。
3. Reader 读，Processor 处理，Writer 写。
4. Batch 失败处理：看日志定位 Step，支持 restart、skip、retry，并用事务保证数据一致性。
5. 大批量处理：分页/游标读取，chunk 分批处理，分批写入和提交，避免一次性加载。
6. 查数据库用分页/游标；读文件用流式读取；Spring Batch 用 chunk 分批处理。
7. 大文件导入：Reader 流式读，Processor 处理，Writer 批量写，chunk 分批提交。
```

## Day 12 后续建议追问

```text
Spring Batch 和普通定时任务有什么区别？
```

保命方向：

```text
普通定时任务主要负责定时触发；Spring Batch 不只是触发任务，它更适合大批量、分步骤、分批处理，并支持失败重试、跳过和重启。
```