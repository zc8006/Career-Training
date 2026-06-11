# Day 12 到 Day 26 Java 面试训练整理

> 目标：把 Day 12～Day 26 的 Java 面试训练沉淀成 GitHub 可复习资料。  
> 当前主线：Spring / Spring Boot / MyBatis。  
> 训练规则：旧题回炉 8～10 道，新题 4 道以内，追问最多 3 个，最后整理背诵清单。

---

## 总览

这一阶段从 Spring Boot 项目排查、Spring Batch、并发保命题，逐步切回 Spring / Spring Boot / MyBatis 主线。

重点链路：

```text
前端请求 → DispatcherServlet → Controller → Service → 事务 → Mapper → MyBatis → MySQL → Java 对象 → JSON 返回
```

核心目标不是刷题数量，而是：

```text
能说出口、能接追问、能结合项目和排查经验回答。
```

---

# Day 12：Spring Boot 排查回炉 + Spring Batch 新题

## 已完成回炉

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

## Day 12 背诵清单

```text
1. Spring Batch 是批处理框架，适合大批量、定时、分步骤的数据处理任务。
2. Job 是整个批处理任务，Step 是任务中的一个步骤。
3. Reader 读，Processor 处理，Writer 写。
4. Batch 失败处理：看日志定位 Step，支持 restart、skip、retry，并用事务保证数据一致性。
5. 大批量处理：分页/游标读取，chunk 分批处理，分批写入和提交，避免一次性加载。
6. 查数据库用分页/游标；读文件用流式读取；Spring Batch 用 chunk 分批处理。
7. 大文件导入：Reader 流式读，Processor 处理，Writer 批量写，chunk 分批提交。
```

---

# Day 13：Spring Batch 回炉 + 批处理场景表达

## 重点题

1. Spring Batch 和普通定时任务有什么区别？
2. Spring Batch 为什么适合大批量数据？
3. chunk 是什么？为什么要分批提交？
4. 批处理失败后怎么继续？
5. 怎么避免重复导入？
6. Web 接口日志和 Batch 日志有什么区别？
7. 脏数据怎么处理？

## 背诵清单

```text
1. 普通定时任务主要负责定时触发；Spring Batch 负责大批量、分步骤、分批处理。
2. chunk 是分批处理和提交，比如每 1000 条提交一次，避免一次性加载和提交太多数据。
3. Batch 失败后先看日志定位 Step，再考虑 restart、skip、retry。
4. 防止重复导入可以用唯一键、批次号、状态表或幂等设计。
5. Web 日志重点看请求链路；Batch 日志重点看 Job、Step、批次、失败数据和执行状态。
6. 脏数据可以先校验、记录错误行、跳过或单独输出错误文件。
```

---

# Day 14：Spring Batch 项目追问强化

## 重点题

1. 如果导入 50 万行 CSV，你怎么设计？
2. Reader / Processor / Writer 在 CSV 导入里分别做什么？
3. 失败重跑时怎么保证不重复？
4. JobRepository 和 JobLauncher 是什么？
5. JobParameters 有什么作用？

## 背诵清单

```text
1. 50 万行 CSV 导入：Reader 流式读取，Processor 校验转换，Writer 批量写库，chunk 分批提交。
2. JobLauncher 负责启动 Job，JobRepository 负责记录 Job 和 Step 的执行状态。
3. JobParameters 表示本次执行参数，比如文件名、批次号、执行日期。
4. 批处理要考虑失败重试、跳过、重启和幂等。
5. 大批量导入不能一次性读入内存，要流式读取、分批处理、分批提交。
```

---

# Day 15：阶段复盘 + 错题资产化

## 重点回炉

1. Spring Batch 和普通定时任务区别。
2. JobRepository / JobLauncher / JobParameters。
3. Spring Boot 请求链路。
4. Spring Boot 排查题。
5. MyBatis Mapper 动态代理。
6. PageHelper 原理。

## 错题提醒

```text
1. Spring Batch 不是定时任务本身，它是批处理框架。
2. JobLauncher 启动 Job；JobRepository 记录执行状态；JobParameters 表示本次执行参数。
3. PageHelper = MyBatis 插件拦截 SQL + 改写分页 SQL。
```

---

# Day 16～Day 19：Java 并发保命范围

> 后续已确认：不深挖锁源码，不面 JUC 底层框架；并发只保留面试保命题。

## 必会题

1. sleep 和 wait 区别。
2. volatile 是什么？
3. volatile 为什么不能保证 count++ 原子性？
4. AtomicInteger 为什么线程安全？
5. synchronized 和 ReentrantLock 区别。
6. 死锁是什么？怎么避免？
7. 公平锁和非公平锁区别。
8. 乐观锁和悲观锁区别。
9. synchronized 锁的是什么？
10. 线程池核心参数有哪些？
11. CAS 有什么问题？
12. ThreadLocal 是什么？为什么要 remove？

## 背诵清单

```text
1. sleep 不释放锁；wait 会释放锁，需要 notify/notifyAll 唤醒。
2. volatile 保证可见性，禁止指令重排序，但不能保证 count++ 的原子性。
3. count++ 是读、加、写三步，多线程同时执行可能丢失更新。
4. AtomicInteger 通过 CAS 保证线程安全，没被别人改过就更新，改了就重试。
5. synchronized 是内置锁，自动释放；ReentrantLock 是显式锁，需要手动释放，但更灵活。
6. 死锁是多个线程互相等待对方的锁；避免方式是固定加锁顺序、减少锁持有时间、避免嵌套锁、tryLock 超时退出。
7. 公平锁按排队顺序获取锁；非公平锁允许插队，性能高但可能饥饿。
8. 乐观锁更新时检查版本或 CAS；悲观锁操作前先加锁。
9. 普通同步方法锁 this，静态同步方法锁 Class，同步代码块锁括号里的对象。
10. 线程池核心参数：核心线程数、最大线程数、空闲时间、时间单位、任务队列、线程工厂、拒绝策略。
11. CAS 问题：ABA、自旋消耗 CPU、只能保证单个变量原子操作。
12. ThreadLocal 是线程本地变量，用完要 remove，避免线程池复用导致数据污染或内存泄漏。
```

---

# Day 20：并发收尾 + Spring 主线回归

## 旧题回炉

1. synchronized 和 ReentrantLock 区别。
2. 死锁是什么？怎么避免？
3. 线程池核心参数。
4. CAS 有什么问题？
5. ThreadLocal 是什么？
6. ThreadLocal 为什么有内存泄漏风险？
7. ThreadLocal 常见使用场景。
8. ThreadLocal 和线程池区别。
9. volatile 是什么？
10. AtomicInteger 为什么线程安全？

## 新题

1. AQS 是什么？只保留一句保命答案。
2. Spring Bean 生命周期是什么？
3. Spring Bean 作用域有哪些？
4. IOC 和 DI 是什么？

## 追问

1. 为什么 IOC 可以降低代码耦合？
2. `@Autowired` 和 `@Resource` 区别。
3. Spring 事务为什么一般加在 Service 层？

## 背诵清单

```text
1. AQS 是 Java 并发包里的同步器框架，核心是 state + 等待队列。
2. Bean 生命周期：创建 Bean 对象 → 属性注入 → 初始化 → 使用 → 销毁。
3. singleton 默认单例，prototype 每次新建，request 一次请求一个，session 一次会话一个。
4. IOC 是思想，把对象创建和管理交给 Spring 容器；DI 是实现方式，由 Spring 把依赖对象注入进来。
5. @Autowired 默认按类型，多个实现配合 @Qualifier；@Resource 默认按名称。
6. 事务放 Service 层，是因为 Service 管业务流程，可能调用多个 Mapper，需要统一提交或回滚，保证数据一致性。
```

---

# Day 21：Spring AOP + 常用注解

## 旧题回炉

1. Bean 生命周期。
2. Bean 作用域。
3. IOC 和 DI。
4. `@Autowired` 和 `@Resource`。
5. 事务为什么加在 Service 层。
6. Spring 事务失效原因。
7. `@Transactional` 默认什么异常回滚。
8. Spring Boot 自动配置原理。
9. 请求从 Controller 到数据库返回流程。
10. MyBatis `#{}` 和 `${}` 区别。

## 新题

1. Spring AOP 是什么？
2. Spring AOP 底层是怎么实现的？
3. `@Component`、`@Service`、`@Repository`、`@Controller` 区别。
4. `@Controller` 和 `@RestController` 区别。

## 追问

1. 为什么 `@RestController` 不需要每个方法都写 `@ResponseBody`？
2. `@Service` 和 `@Component` 本质上有区别吗？
3. AOP 为什么能让事务生效？

## 背诵清单

```text
1. AOP 是面向切面编程，把日志、事务、权限等公共逻辑从业务代码中抽出来，通过代理统一增强。
2. Spring AOP 底层是动态代理，有接口用 JDK 动态代理，没有接口用 CGLIB。
3. @Component 是通用组件，@Service 标业务层，@Repository 标持久层，@Controller 标控制层。
4. @Controller 通常返回页面；@RestController = @Controller + @ResponseBody，通常返回 JSON 数据。
5. @Service 本质上也是 @Component，都是注册 Bean；只是 @Service 表示业务层，语义更清楚。
6. AOP 能让事务生效，是因为 Spring 通过动态代理在方法前后增强：方法前开启事务，成功提交，异常回滚。
```

---

# Day 22：Spring MVC 参数注解 + 校验 + 全局异常

## 旧题回炉

1. Bean 生命周期。
2. Bean 作用域。
3. Spring AOP 是什么？
4. Spring AOP 底层实现。
5. 常用组件注解区别。
6. `@Controller` 和 `@RestController` 区别。
7. AOP 为什么能让事务生效？
8. Spring 事务失效原因。
9. Spring Boot 自动配置原理。
10. 请求链路。

## 新题

1. `@RequestMapping`、`@GetMapping`、`@PostMapping` 区别。
2. `@RequestParam`、`@PathVariable`、`@RequestBody` 区别。
3. Spring Boot 参数校验怎么做？
4. Spring Boot 全局异常处理怎么做？

## 追问

1. 参数校验失败后，为什么要配合全局异常处理？
2. `@RequestParam` 和 `@PathVariable` 都能传 id，场景有什么区别？
3. `@RequestBody` 为什么通常用于 POST，而不是 GET？

## 背诵清单

```text
1. @RequestMapping 是通用请求映射；@GetMapping 处理 GET 请求；@PostMapping 处理 POST 请求。
2. @RequestParam 接收 URL 查询参数；@PathVariable 接收路径参数；@RequestBody 接收请求体里的 JSON。
3. 参数校验：DTO 字段加校验注解，Controller 参数加 @Valid，失败后用全局异常处理统一返回。
4. 全局异常处理用 @RestControllerAdvice + @ExceptionHandler，统一捕获异常并返回统一结果格式。
5. 查询条件用 @RequestParam，资源路径用 @PathVariable。
6. GET 通常用 URL 参数查询数据；POST 通常用 Body 提交 JSON 数据，所以 @RequestBody 更常用于 POST。
```

---

# Day 23：Filter / Interceptor + 跨域 + 统一返回 + 配置文件

## 旧题回炉

1. `@Controller` 和 `@RestController` 区别。
2. `@RequestMapping` / `@GetMapping` / `@PostMapping` 区别。
3. `@RequestParam` / `@PathVariable` / `@RequestBody` 区别。
4. 参数校验怎么做。
5. 全局异常处理怎么做。
6. AOP 是什么。
7. AOP 底层实现。
8. Spring 事务失效原因。
9. Spring Boot 自动配置原理。
10. 请求链路。

## 新题

1. Filter 和 Interceptor 有什么区别？
2. Spring Boot 跨域问题怎么处理？
3. Spring Boot 统一返回结果怎么做？
4. `application.properties` 和 `application.yml` 有什么区别？

## 追问

1. 统一返回结果和全局异常处理是什么关系？
2. Filter 和 Interceptor 谁先执行？为什么？
3. 如果前端说接口跨域了，你怎么排查？

## 背诵清单

```text
1. Filter 在 DispatcherServlet 之前，属于 Servlet 层；Interceptor 在 DispatcherServlet 之后、Controller 之前，属于 Spring MVC 层。
2. 跨域可以用 @CrossOrigin 或全局 CORS 配置处理，实际项目中要限制允许的域名、方法和请求头。
3. 统一返回结果一般用 Result<T>，包含 code、message、data，成功和失败都按统一格式返回。
4. properties 是 key=value，yml 是层级结构；作用基本一样，yml 更清晰但要注意缩进。
5. 统一返回结果定义返回格式，全局异常处理负责捕获异常后按这个格式返回错误信息。
6. 跨域排查先看浏览器 CORS 报错，确认前后端协议、域名、端口是否一致，再检查后端 CORS、网关或 Nginx 配置。
```

---

# Day 24：Spring Boot 项目排查题

## 旧题回炉

1. 全局异常处理。
2. 参数校验。
3. 自动配置原理。
4. Filter 和 Interceptor。
5. 跨域处理。
6. 跨域排查。
7. 统一返回结果。
8. 参数注解区别。
9. `@Controller` 和 `@RestController`。
10. 请求链路。

## 新题

1. Spring Boot 接口报 500，怎么排查？
2. Spring Boot 项目启动失败，怎么排查？
3. Spring Boot 配置不生效，怎么排查？
4. Spring Boot 日志怎么看？线上排查重点看什么？

## 追问调整

这天明确调整：不再问“为什么先看日志 / 为什么先看 profile / 为什么先看异常堆栈”这种弱追问，后续改成真实项目面试题。

## 背诵清单

```text
1. 500 排查先看日志和异常堆栈，再查请求参数、业务代码、SQL、数据库连接和下游接口。
2. 启动失败先看日志和异常堆栈，再查端口占用、配置文件、Bean 注入、依赖冲突、数据库连接和 MyBatis 配置。
3. 配置不生效先查配置文件位置、profile、配置 key、yml 缩进，以及 @Value / @ConfigurationProperties 是否写对。
4. 日志排查先按时间、接口、traceId 定位请求，再看异常堆栈、错误行号、请求参数、SQL、数据库和下游接口。
```

---

# Day 25：MyBatis 基础对比题

## 旧题回炉

1. Spring Boot 全局异常处理。
2. Spring Boot 参数校验。
3. Spring Boot 自动配置原理。
4. Filter 和 Interceptor 区别。
5. Spring Boot 跨域问题怎么处理。
6. 跨域怎么排查。
7. Spring Boot 统一返回结果。
8. `@RequestParam` / `@PathVariable` / `@RequestBody` 区别。
9. `@Controller` 和 `@RestController` 区别。
10. 请求进入 Spring Boot 项目后的完整链路。

## 新题

1. MyBatis 的优点是什么？
2. MyBatis 的缺点是什么？
3. MyBatis 适合什么场景？
4. MyBatis 和 Hibernate 有什么区别？

## 追问

1. 为什么说 MyBatis 是半自动 ORM？
2. MyBatis 手写 SQL 的好处和坏处分别是什么？
3. 既然 MyBatis 要自己写 SQL，为什么项目还不用 Hibernate？

## 背诵清单

```text
1. MyBatis 封装了 JDBC 的重复代码，我们主要写 SQL 和 Mapper；它 SQL 灵活，支持参数映射、结果映射和动态 SQL。
2. MyBatis 的缺点是 SQL 需要自己写，XML 和 SQL 多了维护成本高；并且和数据库 SQL 绑定较紧，换数据库时可能要改 SQL。
3. MyBatis 适合 SQL 复杂、需要手写 SQL 和 SQL 优化的场景；如果只是简单 CRUD，全自动 ORM 可能更省事。
4. MyBatis 手写 SQL，灵活、可控，适合复杂 SQL；Hibernate 自动生成 SQL，开发简单，但复杂 SQL 控制不如 MyBatis。
5. MyBatis 是半自动 ORM，因为 SQL 要自己写，但参数映射和结果映射由 MyBatis 帮我们完成。
6. 手写 SQL 的好处是灵活可控、方便优化；坏处是 SQL 多了维护成本高，换数据库时可能要改 SQL。
```

---

# Day 26：MyBatis 映射、动态 SQL、批量插入

## 旧题回炉

1. MyBatis 的优点。
2. MyBatis 的缺点。
3. MyBatis 适合什么场景。
4. MyBatis 和 Hibernate 区别。
5. 为什么说 MyBatis 是半自动 ORM。
6. `#{}` 和 `${}` 的区别。
7. Mapper 接口为什么没有实现类也能调用。
8. mapper.xml 的 namespace 有什么作用。
9. Mapper 接口里的方法能不能重载。
10. `resultType` 和 `resultMap` 区别。

## 新题

1. 当实体类属性名和表字段名不一致时，MyBatis 怎么处理？
2. MyBatis 模糊查询 like 语句怎么写？
3. MyBatis 动态 SQL 有什么用？常见标签有哪些？
4. MyBatis 如何执行批量插入？

## 追问

1. 为什么大量数据插入时，不建议一次性用一个很大的 `foreach`？
2. `foreach` 一般用在哪些场景？
3. MyBatis 动态 SQL 里 `where` 标签有什么作用？

## 背诵清单

```text
1. MyBatis 是半自动 ORM，因为 SQL 要自己写，但参数映射和结果映射由 MyBatis 帮我们完成。
2. #{} 是预编译占位，安全；${} 是字符串拼接，不安全。
3. Mapper 没有实现类也能调用，是因为 MyBatis 通过动态代理生成代理对象，并根据 namespace + 方法名找到 SQL 执行。
4. namespace 通常对应 Mapper 接口全限定名，MyBatis 通过 namespace + 方法名定位 SQL。
5. Mapper 方法一般不能重载，因为 MyBatis 通过 namespace + 方法名定位 SQL，不按参数列表区分。
6. 简单自动映射用 resultType，复杂手动映射用 resultMap。
7. 字段和属性不一致，可以用 SQL 别名、驼峰命名映射，复杂情况用 resultMap。
8. 模糊查询用 like concat('%', #{keyword}, '%')，不要用 ${} 拼接。
9. 动态 SQL 用来根据条件动态拼接 SQL，常见标签有 if、where、set、choose、foreach。
10. 小批量用 foreach，大批量用 ExecutorType.BATCH，数据多要分批提交。
11. foreach 用来遍历集合，常用于批量插入和 in 查询；数据量大要分批。
12. where 标签会在有条件时自动加 WHERE，并自动去掉开头多余的 AND / OR。
```

---

# Day 27 必回炉

```text
1. MyBatis 是半自动 ORM
2. Mapper 动态代理原理
3. namespace 作用
4. Mapper 方法能不能重载
5. resultType 和 resultMap 区别
6. 字段名和属性名不一致怎么办
7. 模糊查询 like 怎么写
8. 动态 SQL 常见标签
9. 批量插入怎么做
10. foreach 使用场景
```

---

# 当前阶段错题 / 不稳点

```text
1. @RestControllerAdvice / @ExceptionHandler 名字不稳。
2. @Valid / @Validated 和 DTO 字段校验位置曾经混淆。
3. @EnableAutoConfiguration 拼写不稳。
4. CORS 跨域处理和排查需要继续回炉。
5. @ResponseBody 容易说成 responsecontroller。
6. DispatcherServlet 拼写还要继续压。
7. MyBatis 半自动 ORM 需要补“参数映射和结果映射由 MyBatis 完成”。
8. Mapper 动态代理要补“namespace + 方法名定位 SQL”。
```

---

# 后续整理原则

```text
Daily：放每天训练记录和背诵清单。
Notes：放稳定答案，方便面试前背。
WrongAnswers：只放真错题和不稳点。
Master：只放最终可说出口的面试答案，不堆流水账。
```
