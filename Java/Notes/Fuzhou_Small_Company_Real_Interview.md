# 福州小厂 Java 真实面经 1～3（含答案）

> 来源：2026 年 8 月收集的三份“福州小厂 Java 面经”截图。
>
> 使用方式：答案按面试口语组织，先说结论，再补原理和项目场景。每日训练时优先随机抽查，不要只看答案。

## 题目清单

1. 自我介绍
2. Java 基本数据类型
3. Spring Boot 常用注解
4. Spring Boot 自动装配原理
5. 隐式锁和显式锁的区别
6. 线程的创建方式
7. 事务的四大特性
8. 数据库与缓存双写一致性问题
9. 是否了解微服务
10. 项目简单介绍
11. 平时使用的 AI 工具
12. 数组去重
13. 删除重名的学生对象
14. MySQL 性能调优
15. 常用数据结构
16. Redis 数据类型及作用
17. Linux 常用命令
18. 简历项目架构
19. `==` 和 `equals()` 的区别
20. `ArrayList` 和 `LinkedList` 的区别
21. Spring AOP 原理
22. Bean 生命周期中在哪个阶段做资源初始化
23. MySQL 锁机制
24. MyBatis-Plus 分页插件原理
25. 缓存三大问题及解决方案
26. 分布式锁原理
27. 项目中的分层架构设计
28. 项目中 Redis 用在什么地方
29. 项目中遇到的难点及解决方案
30. 反问面试官

---

## 一、个人与项目表达

### 1. 请做一下自我介绍

#### 面试口语版

```text
您好，我叫周永欣，有二十多年的 IT 从业经验，做过开发、系统设计和小组管理，长期参与日本客户项目。
技术上主要使用 Java、Spring Boot、MySQL，也做过 .NET、MuleSoft API 集成以及前后端开发。
我比较熟悉从需求和规格确认、设计开发，到测试、上线和问题排查的完整流程。
最近我重点在巩固 Java 后端技术，同时做了基于 Spring Boot 和 MySQL 的酒店管理系统，以及 AI/RAG 相关实践。
我的优势是项目经验比较全面、责任心强，并且遇到陌生业务时能够先梳理流程，再快速定位和解决问题。
希望能在贵公司的 Java 项目中发挥这些经验，也继续深入后端和系统架构方向。
```

#### 注意

- 控制在 60～90 秒。
- 根据岗位突出 Java，不要把所有技术栈逐个念一遍。
- “二十多年经验”之后必须落到能给公司带来的价值，避免只强调年限。
- 没有实际生产经验的技术要说“学习或实践过”，不要包装成大型生产项目。

### 2. 简单介绍一个项目

可以选择真实做过且自己最熟悉的项目。回答顺序固定为：项目背景 → 技术架构 → 我的职责 → 难点 → 结果。

#### 酒店 PMS 实践项目示例

```text
我做过一个酒店 PMS 管理系统，主要处理房型、房态、订单、入住和退房等业务。
后端采用 Java、Spring Boot 和 MySQL，前端使用 Vue，服务通过 REST API 交互，并用 Docker 部署。
我主要负责后端接口、数据库设计、订单流程以及部署和问题排查。
项目中的重点是避免同一房间在时间重叠的情况下被重复预订，所以在服务层做了日期区间校验，并结合数据库事务保证订单和房态更新的一致性。
另外，针对第三方 OTA 接口不稳定的问题，我设计了超时、重试、幂等和失败记录，避免重复创建订单。
```

> 面试时只能使用自己确实做过、并能接住追问的细节。

### 3. 介绍简历中的项目架构

```text
项目整体采用前后端分离架构。前端通过 HTTPS 调用后端 REST API；后端使用 Spring Boot，并按 Controller、Service、Mapper 分层；数据存储使用 MySQL，热点或临时数据可以放 Redis；外部系统通过独立的适配层调用。

Controller 负责参数接收和结果返回，Service 负责业务规则与事务，Mapper 负责数据库访问。统一异常处理、日志、鉴权等公共逻辑放在基础设施层或通过过滤器、拦截器和 AOP 实现。

部署时使用 Docker，配置与代码分离。访问量上来后，可以通过负载均衡部署多个应用实例，并根据实际瓶颈增加缓存、消息队列或拆分服务。
```

不要只罗列组件。面试官追问时要能说明：为什么这样分层、事务放在哪里、Redis 存什么、系统出现异常如何排查。

### 4. 项目中 Redis 用在什么地方

```text
项目中 Redis 主要用于三类场景。
第一是缓存读取频率高、变化不频繁的数据，降低数据库压力；第二是保存登录状态、验证码或短期令牌；第三是利用 SET NX 和过期时间实现简单的幂等控制或分布式锁。

使用缓存时我会同时考虑过期时间、数据一致性和缓存穿透等问题。不能为了使用 Redis 而缓存所有数据，强一致、频繁变化或者查询量不大的数据一般仍直接访问数据库。
```

### 5. 项目中遇到过什么难点，如何解决

使用 STAR 思路，但不要机械地说出 STAR 四个字。

#### OTA 重复订单示例

```text
项目对接外部 OTA 时，网络超时后对方可能重试。如果第一次请求其实已经成功，第二次再处理就会产生重复订单。

我先通过请求日志和业务数据确认重复发生在重试场景，然后把外部订单号作为业务幂等键，在数据库增加唯一约束。请求进入后先检查处理状态，重复请求直接返回第一次的结果；同时把外部调用的请求、响应和状态记录下来，方便补偿和排查。

这样即使请求超时或重复发送，也不会重复创建订单。这个问题让我认识到，接口重试必须和幂等设计一起考虑。
```

### 6. 平时使用哪些 AI 工具

```text
我平时会使用 ChatGPT 和 Codex 辅助学习、代码分析和文档整理，也会根据工作环境使用企业允许的 AI 工具。
例如，我会让 AI 帮我解释陌生代码、生成测试思路、检查 SQL 或整理接口文档，但不会直接复制结果上线。
涉及业务数据时会遵守公司的安全要求，先做脱敏；AI 生成的代码也必须经过人工审查、测试和静态检查。
我把 AI 当作提高效率的助手，最终设计和质量仍由开发人员负责。
```

### 7. 你有什么想问我们的（反问）

建议根据面试过程选择 2～3 个：

```text
1. 这个岗位目前主要负责新项目开发，还是现有系统维护和改造？
2. 团队现在使用的 Java、Spring Boot 和数据库版本是什么？
3. 目前系统最希望这个岗位入职后解决的问题是什么？
4. 团队的开发、代码评审、测试和发布流程是怎样的？
5. 如果顺利入职，前三个月对这个岗位最重要的期待是什么？
```

不建议一开始只问加班、休假和涨薪；这些可以在 HR 环节确认。

---

## 二、Java 基础与集合

### 8. Java 有哪些基本数据类型

Java 有 8 种基本数据类型：

| 类型 | 大小 | 说明 |
| --- | ---: | --- |
| `byte` | 8 位 | 整数，范围 -128～127 |
| `short` | 16 位 | 短整数 |
| `int` | 32 位 | 最常用整数类型 |
| `long` | 64 位 | 长整数，字面量通常加 `L` |
| `float` | 32 位 | 单精度，字面量通常加 `F` |
| `double` | 64 位 | 双精度，默认浮点类型 |
| `char` | 16 位 | UTF-16 代码单元 |
| `boolean` | JVM 规范未规定固定存储位数 | 只有 `true` 和 `false` |

```text
基本类型直接保存值，对应的包装类型是 Byte、Short、Integer、Long、Float、Double、Character 和 Boolean。
包装类型可以为 null，也可以用于泛型和集合；基本类型与包装类型之间可以自动装箱和拆箱，但拆箱 null 会产生 NullPointerException。
```

### 9. `==` 和 `equals()` 有什么区别

```text
对于基本类型，== 比较的是值；对于引用类型，== 比较两个引用是否指向同一个对象。
equals() 是 Object 定义的方法，默认行为也相当于比较地址，但 String、Integer 等类重写后通常比较内容。

自定义对象如果需要按业务字段判断相等，就应同时重写 equals() 和 hashCode()，否则放入 HashSet 或作为 HashMap 的 key 时可能出现不符合预期的结果。
```

补充：字符串内容比较使用 `equals()`，不要依赖字符串常量池使用 `==`。

### 10. `ArrayList` 和 `LinkedList` 有什么区别

```text
ArrayList 底层是动态数组，支持按下标 O(1) 随机访问，连续内存的缓存局部性也较好；尾部追加通常很快，但中间插入和删除需要移动元素。

LinkedList 底层是双向链表，按下标查找需要 O(n) 遍历。已经定位到节点时，插入和删除只需修改指针，但查找节点本身仍有成本，而且每个节点还要保存前后指针，占用更多内存。

实际项目中大部分场景优先使用 ArrayList。只有频繁在两端操作时，可以考虑 Deque，例如 ArrayDeque，而不是默认选择 LinkedList。
```

### 11. 常用数据结构有哪些

```text
常见数据结构包括数组、链表、栈、队列、哈希表、树、堆和图。
Java 中 ArrayList 对应动态数组，LinkedList 是双向链表，ArrayDeque 可用作栈和队列，HashMap/HashSet 基于哈希表，TreeMap/TreeSet 基于红黑树，PriorityQueue 基于堆。

选择数据结构时主要看操作特点：是否需要随机访问、是否频繁插入删除、是否需要去重、是否要求排序，以及时间和空间复杂度。
```

### 12. 数组如何去重

#### 保留原顺序

```java
int[] source = {3, 1, 3, 2, 1};

int[] result = Arrays.stream(source)
        .distinct()
        .toArray();
```

如果是对象数组，需要正确实现 `equals()` 和 `hashCode()`。数据量很大或需要自定义去重字段时，可使用 `LinkedHashSet` 或 `Map`。

```java
Integer[] source = {3, 1, 3, 2, 1};
List<Integer> result = new ArrayList<>(
        new LinkedHashSet<>(Arrays.asList(source))
);
```

时间复杂度通常为 O(n)，额外空间复杂度为 O(n)。

### 13. 如何删除重名的学生对象

先确认业务规则：是保留第一条、保留最后一条，还是按学生 ID 而不是姓名去重。姓名可能重复，生产系统通常应使用唯一 ID。

#### 按姓名保留第一条

```java
List<Student> uniqueStudents = new ArrayList<>(
        students.stream()
                .collect(Collectors.toMap(
                        Student::getName,
                        Function.identity(),
                        (first, duplicate) -> first,
                        LinkedHashMap::new
                ))
                .values()
);
```

#### 按姓名保留最后一条

把合并函数改成：

```java
(oldValue, newValue) -> newValue
```

如果题目要求用 `Set`，需要让 `Student` 的 `equals()` 和 `hashCode()` 基于去重字段实现，但要注意这会定义对象的全局相等语义。

---

## 三、Spring 与 MyBatis

### 14. Spring Boot 常用注解有哪些

按作用分类回答比逐个背诵更清楚：

```text
启动与配置：@SpringBootApplication、@Configuration、@Bean、@ConfigurationProperties。
Bean 管理：@Component、@Service、@Repository、@Controller、@RestController。
依赖注入：@Autowired、@Qualifier、@Resource，项目中更推荐构造器注入。
Web：@RequestMapping、@GetMapping、@PostMapping、@RequestBody、@PathVariable、@RequestParam。
事务和异步：@Transactional、@Async、@Scheduled。
校验和异常：@Valid、@Validated、@ControllerAdvice、@ExceptionHandler。
```

`@SpringBootApplication` 组合了 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan`。

### 15. Spring Boot 自动装配原理

```text
Spring Boot 自动配置的入口是 @SpringBootApplication 中的 @EnableAutoConfiguration。
它通过 AutoConfigurationImportSelector 导入候选自动配置类。

在 Spring Boot 3 中，候选配置主要记录在 META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports 文件中。自动配置类再通过 @ConditionalOnClass、@ConditionalOnMissingBean、@ConditionalOnProperty 等条件注解判断当前环境是否满足要求。

例如类路径存在某个数据库连接池、配置文件中提供了相关属性，并且用户没有自己定义同类型 Bean 时，Spring Boot 才创建默认 Bean。用户自己配置 Bean 后，默认配置通常会退让。
```

一句话总结：自动配置就是“根据依赖、配置和现有 Bean 按条件装配默认组件”。

### 16. Spring AOP 的原理是什么

```text
Spring AOP 的核心是动态代理。容器创建 Bean 时，如果发现它匹配切点，就会为它创建代理对象；外部通过代理对象调用方法时，代理会在目标方法前后执行日志、事务、权限等增强逻辑。

有接口时通常可以使用 JDK 动态代理；没有接口时可以使用基于子类的 CGLIB 代理。Spring Boot 目前通常默认使用 CGLIB，但面试时重点是理解代理机制。

因为增强发生在代理对象上，所以同一个类内部通过 this 调用另一个方法，没有经过代理，事务等 AOP 增强可能失效。private、final 等无法被正常代理的方法也需要特别注意。
```

### 17. Bean 生命周期中在哪个阶段做资源初始化

```text
Bean 大致经历实例化、属性注入、Aware 回调、BeanPostProcessor 前置处理、初始化、后置处理、使用和销毁。

需要依赖注入完成后再初始化资源，可以使用 @PostConstruct、实现 InitializingBean 的 afterPropertiesSet()，或者配置 initMethod。执行顺序通常是 @PostConstruct、afterPropertiesSet()、initMethod。

释放资源可以使用 @PreDestroy、DisposableBean 的 destroy() 或 destroyMethod。
```

一般优先使用 `@PostConstruct` / `@PreDestroy`，但不要在初始化方法中执行特别耗时或可能长期阻塞的任务。

### 18. MyBatis-Plus 分页插件原理

```text
MyBatis-Plus 分页插件本质上是 MyBatis 拦截器。
执行查询时，PaginationInnerInterceptor 会拦截 Executor 的查询过程，根据 Page 对象中的页码和每页数量改写原 SQL，生成适配当前数据库方言的物理分页 SQL，例如 MySQL 的 limit。

通常还会执行一条 count SQL 统计总记录数，然后把数据列表、总数和分页信息封装回 Page 对象。配置时要指定正确的数据库类型，并把分页插件放在其他会改写 SQL 的插件之后。
```

```java
@Bean
public MybatisPlusInterceptor mybatisPlusInterceptor() {
    MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
    interceptor.addInnerInterceptor(
            new PaginationInnerInterceptor(DbType.MYSQL)
    );
    return interceptor;
}
```

---

## 四、并发、锁与事务

### 19. 隐式锁和显式锁有什么区别

如果题目出现在 Java 并发部分，通常指 `synchronized` 和 `Lock`。

```text
synchronized 是隐式锁，由 JVM 自动获取和释放，即使发生异常也会自动释放，语法简单。

Lock 是显式锁，需要手动 lock() 和 unlock()，所以 unlock() 必须放在 finally 中。它提供 tryLock()、可中断获取、超时获取、公平锁以及多个 Condition，控制能力更强。

简单同步优先使用 synchronized；需要超时、可中断、公平策略或多个等待条件时，可以使用 ReentrantLock。
```

```java
lock.lock();
try {
    // 受保护的共享资源
} finally {
    lock.unlock();
}
```

如果面试官指 MySQL：隐式锁是执行 `UPDATE`、`DELETE` 等语句时数据库自动加锁；显式锁是主动使用 `SELECT ... FOR UPDATE`、`LOCK TABLES` 等方式加锁。应先向面试官确认语境。

### 20. 创建线程有哪些方式

```text
常见写法有继承 Thread、实现 Runnable、实现 Callable 配合 FutureTask，以及通过线程池提交任务。

Thread 和 Runnable 不能直接返回执行结果；Callable 可以返回结果并抛出异常。生产项目通常使用 ThreadPoolExecutor 或 Spring 管理的线程池，因为线程创建和销毁成本较高，线程池也便于限制并发、复用线程和统一监控。
```

```java
ExecutorService pool = Executors.newFixedThreadPool(4);
Future<Integer> future = pool.submit(() -> 1 + 1);
Integer result = future.get();
pool.shutdown();
```

补充：生产系统不建议无边界地使用 `newCachedThreadPool()`；更稳妥的是明确配置核心线程数、最大线程数、队列、线程工厂和拒绝策略。

### 21. 事务的四大特性是什么

```text
事务四大特性是 ACID。
原子性：事务中的操作要么全部成功，要么全部回滚。
一致性：事务执行前后，数据必须满足业务规则和约束。
隔离性：并发事务之间尽量互不影响，不同隔离级别解决脏读、不可重复读和幻读等问题。
持久性：事务提交后，结果即使发生故障也不能丢失。
```

MySQL InnoDB 通常通过 undo log 支持回滚和 MVCC，通过 redo log 保证持久性，通过锁和 MVCC 实现隔离性；一致性是前三者和业务约束共同保证的结果。

### 22. 分布式锁的原理是什么

```text
分布式锁用于多个应用实例之间对同一共享资源进行互斥访问。它至少要考虑互斥性、过期释放、只能由持有者解锁，以及服务异常后的容错。

Redis 的基本做法是使用 SET key uniqueValue NX PX expireTime 原子加锁。value 使用请求唯一标识；释放锁时通过 Lua 脚本先比较 value，再删除 key，避免删除别人的锁。

还要处理业务执行时间超过锁过期时间的问题。项目中通常优先使用 Redisson，因为它封装了可重入、自动续期和异常处理，但仍要合理设置等待时间、租约时间和业务幂等。
```

分布式锁不能代替数据库唯一约束和幂等设计。对金额、订单等核心数据，仍需用数据库约束做最后一道保护。

---

## 五、MySQL 与缓存

### 23. MySQL 锁机制有哪些

可以从粒度、模式和算法三个角度回答：

```text
按粒度分为全局锁、表锁和行锁。InnoDB 常用行锁，并且行锁是加在索引记录上的；查询条件没有有效使用索引时，可能锁住更大范围。

按模式分为共享锁 S 和排他锁 X。普通 select 一般使用 MVCC 快照读；select ... for update 属于当前读，会加排他锁。

按算法分为 Record Lock、Gap Lock 和 Next-Key Lock。Next-Key Lock 是记录锁和间隙锁的组合，在可重复读级别下可用于防止幻读。
```

发生死锁时，数据库会选择回滚其中一个事务。项目中应保持一致的加锁顺序、缩短事务、建立合适索引，并对死锁异常进行有限重试。

### 24. MySQL 如何进行性能调优

回答顺序：定位 → SQL/索引 → 架构与配置 → 验证。

```text
我不会一开始就盲目加索引，而是先通过慢查询日志、监控和业务调用链定位慢 SQL，再使用 EXPLAIN ANALYZE 查看执行计划、实际行数、索引使用情况和排序临时表。

SQL 层面会避免 select *、无条件大查询、对索引列做导致索引失效的函数或隐式类型转换，并优化 join 和分页。
索引层面根据 where、join、order by 和 group by 设计联合索引，遵守最左前缀，尽量使用覆盖索引，同时避免重复和低价值索引。

然后检查连接池、事务范围、锁等待、表结构和数据量。必要时再考虑缓存、读写分离、分库分表或异步处理。最后必须用相同数据和压测指标验证优化前后的执行时间、扫描行数和资源消耗。
```

### 25. Redis 有哪些数据类型，各自有什么作用

```text
String：缓存对象、计数器、分布式锁和验证码。
Hash：保存对象的多个字段，适合局部字段读写。
List：有序列表，可做简单队列，但可靠消息通常使用专业消息队列。
Set：无序去重集合，可做标签、共同关注和抽奖。
ZSet：带分数的有序集合，可做排行榜和延迟任务。

此外还有 Bitmap、HyperLogLog、Geo 和 Stream。Bitmap 适合签到，HyperLogLog 适合近似去重计数，Geo 适合地理位置，Stream 可处理消息流。
```

还应知道 Redis 快的原因：主要在内存中操作、数据结构高效、命令执行模型避免了大量线程竞争，并使用 I/O 多路复用处理网络连接。

### 26. 缓存三大问题是什么，如何解决

| 问题 | 含义 | 常见解决方法 |
| --- | --- | --- |
| 缓存穿透 | 查询数据库中根本不存在的数据，请求每次都落到数据库 | 参数校验、缓存空值、布隆过滤器、限流 |
| 缓存击穿 | 一个热点 Key 失效瞬间，大量请求同时访问数据库 | 互斥重建、逻辑过期、热点 Key 不过期并主动更新 |
| 缓存雪崩 | 大量 Key 同时失效或 Redis 故障，流量集中打到数据库 | 过期时间加随机值、多级缓存、高可用、限流降级和预热 |

```text
这三个问题不能只靠一种方案解决。实际项目还要结合监控、熔断、容量评估和数据库保护，避免缓存异常继续扩散。
```

### 27. 如何保证数据库与缓存双写一致性

常用的是 Cache Aside（旁路缓存）模式：

```text
读请求先查缓存，未命中再查数据库，并把结果写入缓存。
写请求先更新数据库，数据库事务提交成功后再删除缓存，而不是同时更新数据库和缓存。
```

为什么通常删除缓存：直接更新缓存容易遇到并发写入顺序与数据库提交顺序不一致，也可能维护大量无效缓存。

```text
即使采用“更新数据库后删除缓存”，数据库已提交但删除缓存失败时仍可能短暂不一致。
可以使用合理的缓存过期时间作为兜底，并通过重试、消息队列或订阅 binlog 最终删除缓存。对并发特别高的热点数据，还要结合版本号、互斥重建或延迟双删，但延迟双删不是绝对强一致方案。
```

如果业务要求绝对强一致，应优先直接读数据库或采用更严格的事务设计，不能把 Redis 缓存当作强一致存储。

---

## 六、微服务与系统设计

### 28. 是否了解微服务

```text
微服务是按照业务能力把一个系统拆成多个可以独立开发、部署和扩展的服务。每个服务有清晰边界，通过 HTTP、RPC 或消息进行通信，数据通常由各服务自己管理。

它的优点是服务可以独立发布和扩容，团队职责更清晰，单个模块技术改造也更灵活；缺点是引入了远程调用、分布式事务、服务治理、链路追踪、部署运维和数据一致性等复杂度。

常见配套能力包括服务注册发现、配置中心、网关、负载均衡、限流熔断、链路追踪和集中日志。是否拆成微服务应根据业务复杂度和团队规模决定，小系统不应该为了技术而过度拆分。
```

### 29. 项目中的分层架构如何设计

```text
常见分层包括 Controller、Service、Repository/Mapper 和基础设施层。

Controller 只负责接收参数、校验和返回结果；Service 负责业务规则、流程编排和事务边界；Mapper/Repository 负责数据访问；DTO 用于接口传输，Entity 对应持久化对象，避免数据库结构直接暴露给接口。

跨层公共能力，例如认证、日志、异常处理、缓存和外部系统调用，分别放在过滤器、拦截器、AOP 或独立的基础设施组件中。分层的目的不是增加类，而是让职责清晰、便于测试和维护。
```

事务一般放在 Service 的 public 方法上，因为一次业务操作可能涉及多个 Mapper。Controller 中不应堆积大量业务逻辑。

---

## 七、Linux 常用命令

### 30. 说一下常用的 Linux 命令

不要只背命令名，可以结合线上排查流程回答：

```text
文件与目录：ls、cd、pwd、cp、mv、mkdir、find。
查看文本：cat、less、head、tail，搜索一般用 grep 或 rg。
进程和资源：ps、top、free、df、du、kill。
网络与端口：ss、curl、ping、traceroute。
日志排查：tail -f、grep、awk、sed、journalctl。
权限和服务：chmod、chown、systemctl。
压缩：tar、gzip、unzip。
```

#### 排查 Java 服务示例

```bash
ps -ef | grep java
ss -lntp
top -H -p <pid>
tail -n 200 application.log
grep -n "ERROR" application.log
df -h
free -h
```

面试时可以补充：先确认服务进程和端口，再看 CPU、内存、磁盘，最后结合应用日志和调用链定位问题；不能看到进程就直接 `kill -9`。

---

## 每日抽查规则

这 30 题作为真实面经专项题库，加入日常旧题回炉：

1. 每天从本题库随机抽取 3～4 题，混入当天 8～10 道旧题。
2. 至少包含 1 道 Java/Spring 基础题、1 道数据库/缓存题、1 道项目表达题。
3. 训练时一次只问一道，不提前展示答案。
4. 回答只有关键词但不能形成完整面试表达时，判定为 B；原理错误或无法回答时判定为 C。
5. B/C 题进入错题本，并在之后 1 天、3 天、7 天重复抽查。
6. 项目题必须结合真实经历，禁止编造生产规模、访问量和个人职责。

## 10 句速记版

```text
Java 有 8 种基本数据类型，包装类型可以为 null，也可以用于泛型和集合。
基本类型使用 == 比较值，引用类型的 == 比较引用，equals() 是否比较内容取决于类是否重写。
ArrayList 基于动态数组、随机访问快；LinkedList 基于双向链表、按下标查询慢。
Spring Boot 根据依赖、配置和现有 Bean，通过条件注解完成自动配置。
Spring AOP 基于动态代理，同类内部 this 调用不会经过代理对象。
synchronized 是 JVM 自动释放的隐式锁，Lock 必须在 finally 中手动释放。
事务四大特性是原子性、一致性、隔离性和持久性。
MySQL 调优要先定位慢 SQL，再看执行计划、SQL、索引、锁和系统资源，最后验证结果。
缓存穿透是查不存在的数据，击穿是热点 Key 失效，雪崩是大量 Key 同时失效或缓存故障。
数据库与缓存通常采用旁路缓存：更新数据库后删除缓存，并通过过期时间和重试保证最终一致性。
```
