# Spring + Spring Boot + MyBatis 面试训练

本目录用于记录 Java 面试训练中 Spring、Spring Boot、MyBatis 相关的高频题、保命句、错题回炉和每日背诵清单。当前训练范围已逐步扩展到 Java 集合、JVM、并发等 Java 核心主题。

## 当前进度

| Day | 主题 | 文件 |
|---|---|---|
| Day 27 | MyBatis 核心回炉 + 主键回填/分页/缓存 | [day27-mybatis-core.md](./day27-mybatis-core.md) |
| Day 28 | MyBatis 回炉 + Spring Boot 三层结构 + 事务失效 | [day28-spring-transaction.md](./day28-spring-transaction.md) |
| Day 29 | Spring IOC/AOP/Bean 生命周期 + 事务 AOP 原理 | [day29-spring-core.md](./day29-spring-core.md) |
| Day 44 | Spring 事务管理器、隔离级别与 private 方法事务失效 | [day44-spring-transaction-manager-private.md](./day44-spring-transaction-manager-private.md) |
| Day 45 | Spring 事务管理器、异常捕获与手动回滚 | [day45-spring-transaction-manager-catch-rollback.md](./day45-spring-transaction-manager-catch-rollback.md) |
| Day 47 | Spring AOP、Bean 生命周期与循环依赖回炉 | [day47-spring-aop-bean-lifecycle.md](./day47-spring-aop-bean-lifecycle.md) |
| Day 49 | Spring AOP、Spring Boot 启动流程与 Spring MVC 请求链路 | [day49-spring-aop-boot-mvc.md](./day49-spring-boot-mvc.md) |
| Day 50 | Spring AOP 注解、代理限制与事务回炉 | [day50-spring-aop-annotation-transaction.md](./day50-spring-aop-annotation-transaction.md) |
| Day 51 | AOP 代理限制与 Spring MVC 全局异常处理 | [day51-aop-proxy-spring-mvc-exception.md](./day51-aop-proxy-spring-mvc-exception.md) |
| Day 52 | Spring Boot 自动配置与自我成长模式 | [day52-spring-boot-auto-configuration.md](./day52-spring-boot-auto-configuration.md) |
| Day 53 | Spring 回顾 + Java 集合基础 + 成长记录 | [day53-java-collection-spring-review.md](./day53-java-collection-spring-review.md) |
| Day 55 | Java 集合回炉 + JVM 入门 + 长期记忆策略 | [day55-java-collections-jvm.md](./day55-java-collections-jvm.md) |
| Day 56 | JVM GC 基础 + 长期记忆复测 | [day56-jvm-gc-review.md](./day56-jvm-gc-review.md) |
| Day 57 | JVM GC 间隔回炉 + Spring/并发复测 + 自我成长 | [day57-jvm-gc-spaced-review.md](./day57-jvm-gc-spaced-review.md) |
| Day 58 | JVM 年轻代、Survivor、对象晋升与 GC 原理链路 | [day58-jvm-young-generation-review.md](./day58-jvm-young-generation-review.md) |
| Day 59 | JVM GC 回炉、STW、内存泄漏与表达精准度 | [day59-jvm-stw-memory-leak-review.md](./day59-jvm-stw-memory-leak-review.md) |
| Day 60 | JVM 高频回炉 + TLAB / 逃逸分析 / 标量替换 | [day60-jvm-tlab-escape-analysis-review.md](./day60-jvm-tlab-escape-analysis-review.md) |

## Day61 必回炉

1. 年轻代结构：Eden + S0 + S1
2. Survivor 的完整作用：存活对象 + 配合复制算法
3. Stop-The-World：不只 Full GC
4. Java 常见内存泄漏场景
5. TLAB 是什么、属于哪里
6. 逃逸分析是什么
7. 标量替换是什么
8. JVM 五大运行时区域延迟复测
9. GC Roots 延迟复测
10. 四种引用延迟复测，并穿插 Spring / MyBatis / 集合历史题

## 自我成长模式

后续训练不仅关注面试八股，还加入技术成长闭环。

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

## 长期记忆机制（Day55 起）

用户明确反馈：短期记忆不等于长期掌握，可能昨天会、过几天就忘。因此训练增加“间隔回炉 + 稳定度”机制。

### 间隔回炉

- 新题 / 错题：D+1 必回炉
- D+1 答对：D+3 再抽查
- D+3 答对：D+7 再抽查
- D+7 答对：D+14 再抽查
- 任意节点遗忘：立即降级，并重新从 D+1 开始

### 每日 10 道回顾组成

1. 最近 3 天错题 / 0 分题
2. 最近 7 天会但不稳定的知识点
3. 历史高频弱点随机抽查
4. 已熟练题少量穿插，防止假性掌握

### 掌握判定

一次答对只表示“当前会”，不直接标记长期熟练。

- 当天会：当前记忆
- 次日会：短期稳定
- 3 天后会：初步长期记忆
- 7 天后会：较稳定
- 14 天后会：长期稳定

原则：

> 训练目标不是“当天会”，而是“隔几天后，无提示仍然能说出来”。

## Day60 成长观察

### 已明显趋稳
- JVM 五大区域：首次无提示、术语标准地完整输出“堆、虚拟机栈、程序计数器、本地方法栈、方法区”
- GC Roots：Day59、Day60 连续无提示完整输出“栈、静态、常量、JNI / Native”，开始进入较稳定阶段
- 四种引用：强 / 软 / 弱 / 虚的边界已经能完整输出，进入较稳定阶段
- 对象晋升老年代：能够主动说出多次 GC 后年龄达标晋升，也知道 Survivor 空间压力可能导致提前晋升
- 内存泄漏 vs OOM：已经能说清“泄漏长期积累可能导致 OOM”的因果关系

### 正在从“知道”进入“理解”
- Survivor 不只是“复制”，而是存放 Minor GC 后仍存活的对象，并配合 S0 / S1 复制
- 年轻代为什么适合复制算法、老年代为什么不适合一直复制，已经能从对象存活率和复制成本解释
- JVM 对象生命周期主线继续稳定：`new 对象 → Eden → Minor GC → Survivor → 多次存活 → 晋升老年代`
- TLAB / 逃逸分析 / 标量替换开始作为对象分配优化链路建立，而不是孤立名词

### 顽固弱点
- 年轻代结构：Day60 再次把“Eden + S0 + S1”答成 Minor GC，说明内存区域和 GC 动作仍会混淆，重置为 D+1
- STW：仍容易和 Full GC 绑定，需要继续固定“某些 GC 阶段暂停用户线程，不只 Full GC”
- Java 常见内存泄漏场景：已经理解本质，但 static 集合、缓存、ThreadLocal 等典型场景还不能稳定输出

### Day60 新增进阶题的掌握要求

TLAB、逃逸分析、标量替换属于 JVM 进阶追问，不与 HashMap、Spring 事务、MyBatis 等高频题设置同样的背诵要求。

当前只要求一句话能说清：

- TLAB：Eden 中给每个线程预留的小块分配空间，减少对象分配竞争
- 逃逸分析：判断对象是否逃出当前方法或线程
- 标量替换：把未逃逸对象拆成基本变量，减少真实对象分配和 GC 压力

训练原则：优先保证高频题稳定，不因为进入 JVM 就无限向低收益源码细节扩展。

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
17. HashMap put：算 hash → 定位桶 → 判断冲突 → equals 比较 → 覆盖或插入 → 判断扩容。
18. HashMap 树化：链表达到 8，容量达到 64；容量不足 64 先扩容。
19. ConcurrentHashMap：JDK7 Segment + ReentrantLock；JDK8 无 Segment，CAS + synchronized。
20. JVM 内存主要包括堆、虚拟机栈、程序计数器、本地方法栈和方法区。
21. 对象主要在堆，方法执行信息主要在栈；堆共享，栈私有。
22. 递归过深容易导致 StackOverflowError；内存无法继续分配可能导致 OutOfMemoryError。
23. GC 从 GC Roots 出发做可达性分析，不可达对象才可能被回收。
24. GC Roots 先记：栈、静态、常量、Native。
25. 强 > 软 > 弱 > 虚，引用保留能力逐渐减弱。
26. GC 基础算法：标记清除、复制、标记整理；分代收集是按不同代选择不同回收策略。
27. Minor GC 主要回收年轻代；Full GC 范围更大；Major GC 通常理解为老年代 GC。
28. 年轻代 = Eden + S0 + S1。
29. 年轻代对象死得快、活得少，所以适合复制算法。
30. 对象在年轻代多次 GC 后仍存活，达到晋升条件时可能进入老年代。
31. 事务失效本质看两件事：有没有经过代理，异常有没有正确抛出来。
32. Eden 放新对象，Survivor 放 Minor GC 后仍存活的对象。
33. 两个 Survivor 是为了配合复制算法，让存活对象在 S0 / S1 之间来回复制。
34. 引用可以在栈，对象通常在堆；新对象一般先到 Eden。
35. 大多数对象生命周期短，所以优先放年轻代，提高垃圾回收效率。
36. 年轻代存活对象少，适合复制；老年代存活对象多，复制成本高。
37. STW 就是 JVM 在某些 GC 阶段暂停用户线程，不只 Full GC 才会发生。
38. Full GC 范围更大、处理对象更多，因此通常比 Minor GC 更慢。
39. 内存泄漏是对象已经没用了但引用还在，GC 无法回收；OOM 是内存不足、无法继续分配。
40. 同类内部事务调用本质是 this.xxx()，没有经过 Spring 代理对象，所以事务增强不生效。
41. TLAB 是 Eden 中给线程预留的小块私有分配区域，用来减少多线程对象分配竞争。
42. 逃逸分析就是判断对象有没有逃出当前方法或线程。
43. 标量替换就是把对象拆成基本变量，减少真实对象分配和 GC 压力。
