# MyBatis / Spring Boot / Spring Batch 面试主线整理

## 1. Spring Boot 请求完整链路

### 面试保命答案

```text
前端请求进入 Spring Boot 后，先经过 DispatcherServlet，然后分发到 Controller。
Controller 负责接收参数和返回结果，Service 负责业务逻辑和事务控制，Mapper 负责调用 MyBatis 执行 SQL。
MyBatis 访问 MySQL 后把结果映射成 Java 对象，最后 Controller 返回 JSON。
```

### 背诵句

```text
DispatcherServlet → Controller → Service → 事务 → Mapper → MyBatis → MySQL → JSON 返回。
```

---

## 2. Controller、Service、Mapper 分别负责什么？

```text
Controller 负责接收请求、参数校验、调用 Service、返回结果。
Service 负责业务逻辑和事务控制。
Mapper 负责数据库访问，通过 MyBatis 执行 SQL。
```

项目说法：

```text
我一般把事务放在 Service 层，因为一个业务流程可能包含多个数据库操作，需要保证整体一致性。
```

---

## 3. MyBatis 是什么？

```text
MyBatis 是 Java 持久层框架，用来简化 JDBC，负责 SQL 执行、参数映射和结果封装。
它不像 Hibernate 那样完全自动生成 SQL，而是让开发者自己写 SQL，所以 SQL 可控性更强。
```

---

## 4. MyBatis 和 JDBC 有什么区别？

```text
JDBC 需要自己写连接、执行 SQL、结果封装、关闭资源等重复代码。
MyBatis 把这些流程封装了，我们主要写 Mapper 接口和 SQL 映射文件或注解。
这样代码更简洁，也更方便维护。
```

---

## 5. `#{}` 和 `${}` 的区别

```text
#{} 是预编译参数，会使用占位符，可以防止 SQL 注入。
${} 是字符串拼接，适合动态表名、字段名等场景，但有 SQL 注入风险。
项目中普通参数一般使用 #{}。
```

---

## 6. Mapper 为什么没有实现类也能调用？

```text
Mapper 接口是通过 MyBatis 动态代理实现的。
MyBatis 会根据接口全限定名对应 mapper.xml 的 namespace，再根据方法名找到对应 SQL 的 statement id。
调用 Mapper 方法时，代理对象会执行对应 SQL 并封装结果。
```

背诵句：

```text
Mapper 靠动态代理，SQL 靠 namespace + 方法名定位。
```

---

## 7. MyBatis 一级缓存和二级缓存

```text
一级缓存是 SqlSession 级别，默认开启。
同一个 SqlSession 中执行相同查询，可能直接从缓存中取数据。

二级缓存是 Mapper 级别，需要手动开启。
多个 SqlSession 可以共享二级缓存，但如果数据更新后缓存没有及时失效，可能读到旧数据。
所以项目中使用二级缓存要谨慎。
```

---

## 8. MyBatis 批量插入怎么做？

```text
小批量可以用 foreach 拼接多条数据插入。
大批量可以用 ExecutorType.BATCH，并且要分批提交，避免一次性提交太多数据导致内存或数据库压力过大。
```

背诵句：

```text
小批量 foreach，大批量 ExecutorType.BATCH，数据多要分批提交。
```

---

## 9. MyBatis 一对一、一对多怎么实现？

```text
一对一可以用 association，一对多可以用 collection。
SQL 一般通过 left join 查询数据，再通过 resultMap 把结果封装成对象结构。
```

背诵句：

```text
left join 负责查数据，association / collection 负责封装对象。
```

---

## 10. resultType 和 resultMap 区别

```text
resultType 适合简单映射，字段名和属性名一致时可以自动封装。
resultMap 适合复杂映射，比如字段名和属性名不一致、一对一、一对多等场景。
```

背诵句：

```text
resultType 自动映射，resultMap 手动映射；简单用 resultType，复杂用 resultMap。
```

---

## 11. 字段名和属性名不一致怎么办？

```text
可以在 SQL 中使用别名，让查询字段名和 Java 属性名一致。
也可以使用 resultMap 手动配置字段和属性的映射关系。
```

---

## 12. MyBatis 分页怎么做？

```text
分页可以手写 limit，也可以使用 PageHelper。
RowBounds 偏逻辑分页，可能先查出大量数据再内存截取，所以大数据量分页不推荐。
PageHelper 会拦截 SQL，并改写成带 limit 的物理分页 SQL。
```

---

## 13. MyBatis 插件机制和 PageHelper 原理

```text
MyBatis 插件机制是基于拦截器实现的，可以拦截 SQL 执行过程中的核心对象，比如 Executor、StatementHandler、ParameterHandler、ResultSetHandler。
PageHelper 的原理就是通过插件机制拦截要执行的 SQL，根据数据库方言把原 SQL 改写成分页 SQL，比如 MySQL 中加 limit，同时也可以生成 count SQL 查询总数。
```

背诵句：

```text
插件机制 = 拦截增强；PageHelper = 拦截 SQL + 改写分页 SQL。
```

---

## 14. Spring 事务为什么一般放在 Service 层？

```text
因为 Service 层代表一个完整业务流程，一个业务可能包含多个数据库操作。
事务放在 Service 层，可以保证这些操作要么一起成功，要么一起回滚，保证业务一致性。
```

---

## 15. Spring 事务失效原因

```text
Spring 事务底层依赖 AOP 代理，所以没有走代理时事务会失效。
常见原因包括：同类内部方法调用、方法不是 public、异常被 catch 没有抛出、普通 Exception 没配置 rollbackFor、对象不是 Spring 管理的 Bean。
```

背诵句：

```text
事务失效：没走代理、方法不符合、异常没抛出、对象不归 Spring 管。
```

---

## 16. `@Transactional` 默认什么异常回滚？

```text
@Transactional 默认遇到 RuntimeException 和 Error 会回滚。
普通 Exception 默认不回滚，如果希望普通异常也回滚，需要配置 rollbackFor = Exception.class。
```

---

## 17. REQUIRED、REQUIRES_NEW、NESTED 区别

```text
REQUIRED：有事务就加入，没有事务就新建，最常用。
REQUIRES_NEW：总是新开一个事务，如果外层有事务，会把外层事务挂起。
NESTED：嵌套事务，依赖保存点，属于外层事务的一部分。
```

背诵句：

```text
REQUIRED 共用事务；REQUIRES_NEW 新开事务；NESTED 是保存点，属于外层事务。
```

---

## 18. Spring 事务隔离级别

```text
读未提交最低，可能脏读。
读已提交可以防脏读。
可重复读可以防不可重复读。
串行化最安全，但性能最低。
```

---

## 19. Spring Boot 自动配置原理

```text
Spring Boot 自动配置是通过 @EnableAutoConfiguration 开启的。
它会加载自动配置类，并根据 classpath、配置文件和条件注解判断是否创建 Bean。
比如引入 spring-boot-starter-web 后，会自动配置 Spring MVC、内嵌 Tomcat、JSON 转换等组件。
```

背诵句：

```text
自动配置 = @EnableAutoConfiguration + 自动配置类 + 条件判断 + 创建 Bean。
```

---

## 20. `@SpringBootApplication` 包含哪些注解？

```text
@SpringBootApplication 是组合注解，主要包含：
@SpringBootConfiguration：表示配置类。
@EnableAutoConfiguration：开启自动配置。
@ComponentScan：组件扫描。
```

背诵句：

```text
@SpringBootApplication = 配置类 + 自动配置 + 组件扫描。
```

---

## 21. Spring Boot Starter 是什么？

```text
Starter 可以理解为一组依赖的集合。
比如引入 spring-boot-starter-web，就会自动带上 Web 开发需要的 Spring MVC、Tomcat、JSON 等依赖。
它的作用是简化依赖管理和项目搭建。
```

---

## 22. Spring Boot 为什么不用外部 Tomcat？

```text
Spring Boot 默认内嵌 Tomcat，可以直接通过 main 方法启动应用。
这样部署更简单，不需要单独安装和配置外部 Tomcat。
```

---

## 23. 统一异常处理怎么做？

```text
可以使用 @RestControllerAdvice 做全局异常处理，用 @ExceptionHandler 处理指定异常，最后返回统一 JSON 结果。
```

---

## 24. 参数校验怎么做？

```text
在 DTO 字段上加校验注解，比如 @NotNull、@NotBlank、@Size。
在 Controller 参数上加 @Valid 或 @Validated。
如果校验失败，异常交给全局异常处理统一返回。
```

---

## 25. Filter 和 Interceptor 区别

```text
Filter 属于 Servlet 规范，在 Spring MVC 之前执行。
Interceptor 属于 Spring MVC，在 Controller 前后执行。
Filter 更偏底层请求过滤，Interceptor 更适合登录校验、权限、日志等 MVC 场景。
```

背诵句：

```text
Filter 在 Spring MVC 前，Interceptor 在 Controller 前后。
```

---

## 26. 跨域问题怎么处理？

```text
简单接口可以使用 @CrossOrigin。
全局配置可以实现 WebMvcConfigurer，配置允许的来源、方法、请求头等。
```

---

## 27. 统一返回结果怎么做？

```text
定义统一返回类 Result<T>。
正常情况返回 success，异常情况由全局异常处理返回 error，这样前端处理更统一。
```

---

## 28. 日志怎么看？

```text
先看时间和接口，再看异常类型、Caused by、堆栈行号、请求参数、SQL 和下游接口调用。
线上排查时重点看第一现场日志和最底层 Caused by。
```

---

## 29. Bean 注入失败怎么排查？

```text
先看错误日志和具体 Bean 名称。
再查类上有没有 @Component、@Service 等注解，包路径是否被扫描，是否有多个实现类，MapperScan 是否配置正确，配置文件是否正确，以及是否存在循环依赖。
```

---

## 30. 配置文件不生效怎么排查？

```text
先查当前激活的 profile，再查文件名、路径、缩进、属性名是否正确。
然后看启动参数、环境变量、外部配置是否覆盖了当前配置。
```

---

## 31. Spring Boot 启动失败怎么排查？

```text
先看启动日志和 Caused by。
常见原因包括端口冲突、配置错误、依赖冲突、Bean 创建失败、数据库连接失败、Mapper 扫描失败等。
```

---

## 32. 端口冲突怎么排查？

```text
先看日志确认冲突端口。
然后查哪个进程占用了端口，可以停止该进程，也可以修改 server.port。
```

---

## 33. MyBatis Mapper 扫描失败怎么排查？

```text
检查 MyBatis 依赖是否引入，Mapper 接口是否加 @Mapper，或者启动类是否配置 @MapperScan。
再检查包路径、XML 路径、namespace 和方法名是否匹配。
```

---

## 34. 接口响应很慢怎么排查？

```text
先看日志耗时，确认慢在哪一段。
再分别检查业务代码、SQL、数据库连接池、下游接口、网络和系统资源。
如果是 SQL 慢，看 EXPLAIN 和索引；如果是下游慢，考虑超时、重试、降级、缓存和异步；如果是数据量大，考虑分页、限字段、归档和分库分表。
```

---

## 35. SQL 慢怎么优化？

```text
先定位慢 SQL，再用 EXPLAIN 看执行计划，重点看索引是否命中、扫描行数是否过大、是否有 filesort 或临时表。
优化方式包括：加合适索引、改写 SQL、减少返回字段、分页查询、避免函数导致索引失效。
如果数据量非常大，再考虑分表、归档或分库分表。
```

---

## 36. Spring Batch 是什么？

```text
Spring Batch 是 Spring 生态中的批处理框架，适合大批量、定时、分步骤的数据处理任务。
常见场景包括数据导入、数据同步、报表生成、历史数据迁移等。
```

---

## 37. Job 和 Step 是什么？

```text
Job 表示一个完整的批处理任务。
Step 表示任务中的一个步骤。
一个 Job 可以包含多个 Step。
```

---

## 38. Reader / Processor / Writer 分别是什么？

```text
ItemReader 负责读取数据。
ItemProcessor 负责处理、校验、转换数据。
ItemWriter 负责写出数据，比如写入数据库或文件。
```

背诵句：

```text
Reader 读，Processor 处理，Writer 写。
```

---

## 39. Spring Batch 失败了怎么办？

```text
先看日志定位失败的 Step。
Spring Batch 支持 restart、skip、retry。
写库时要配合事务和 chunk 分批提交，并通过唯一键、批次号等方式保证幂等，避免重复导入。
```

---

## 40. 大批量数据怎么避免一次性加载太多？

```text
查数据库可以用分页或游标读取。
读文件可以用流式读取。
Spring Batch 中可以用 chunk 分批处理，比如每 1000 条提交一次，避免一次性加载全部数据。
```

---

## 41. Spring Batch 和普通定时任务有什么区别？

```text
普通定时任务主要负责定时触发。
Spring Batch 不只是触发任务，它更适合大批量、分步骤、分批处理，并支持失败重试、跳过和重启。
```

---

## 42. Spring Batch 大文件导入例子

```text
Spring Batch 导入 CSV 时，可以定义一个 Job，里面配置一个 Step。
Step 中 Reader 负责流式读取 CSV，Processor 负责校验和转换，Writer 负责批量写入数据库。
通过 chunk 设置每 1000 条提交一次事务。
失败时可以配置 retry、skip、restart，同时用唯一键或批次号保证幂等。
```