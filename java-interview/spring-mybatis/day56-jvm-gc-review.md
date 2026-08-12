# Day56 面试训练记录

## 今日主题
- 长期记忆回炉：Spring / MyBatis / Java 集合 / JVM
- JVM GC 基础：可达性分析、GC Roots、引用类型、垃圾回收算法

---

# 一、旧题回炉（10题）

## 1. @ConditionalOnClass / @ConditionalOnMissingBean
用户回答：
> ConditionalOnClass 按照配置加载，ConditionalOnMissingBean 如果用户没有创建 bean，才进行自动创建。

评分：6/10

纠正：
- `@ConditionalOnClass`：classpath 中存在指定类时配置才生效。
- `@ConditionalOnMissingBean`：容器中不存在指定 Bean 时才创建默认 Bean。

保命句：
> OnClass：有这个类才配；OnMissingBean：没这个 Bean 才建。

状态：比 Day55 有进步，但 OnClass 仍不稳定。

---

## 2. ConcurrentHashMap JDK7 / JDK8
用户回答：
> JDK7 使用分段锁，JDK8 使用 CAS + 异步锁。

评分：8/10

纠正：
- JDK7：Segment + ReentrantLock
- JDK8：取消 Segment，使用 CAS + synchronized

保命句：
> JDK7：Segment + ReentrantLock；JDK8：CAS + synchronized。

状态：比 Day55 稳定，术语 `synchronized` 仍需巩固。

---

## 3. JVM 运行时内存区域
用户回答：
> 堆、栈、程序计数器。

评分：6/10

完整：
- 堆
- 虚拟机栈
- 程序计数器
- 本地方法栈
- 方法区

保命句：
> 堆、栈、程序计数器、本地方法栈、方法区。

状态：从 Day55 的“堆和栈”提升到能主动说出程序计数器，但仍缺 2 项。

---

## 4. 堆和栈区别
用户回答：
> 堆主要放置对象，栈放置方法。

评分：7/10

纠正：
- 堆主要存对象实例，线程共享，GC 主要区域。
- 栈线程私有，主要存方法调用产生的栈帧、局部变量等。

保命句：
> 对象主要在堆，方法执行信息主要在栈；堆共享，栈私有。

状态：从 Day55 0 分提升到能说核心区别。

---

## 5. StackOverflowError
用户回答：
> 大数据量读入到堆里？

评分：2/10

纠正：
> 方法调用层级太深、递归过深导致栈帧不断增加，最终线程栈耗尽。

保命句：
> 递归太深，栈帧不断增加，最终导致 StackOverflowError。

状态：高优先级错题，仍与 OOM 混淆。

---

## 6. OutOfMemoryError
用户回答：
> 大数据量读入到内存里，或者发生了 Full GC。

评分：7/10

纠正：
> OOM 是 JVM 无法继续申请足够内存。Full GC 可能是 OOM 前的现象或回收尝试，不是 OOM 的直接原因。

保命句：
> 内存不够，而且 GC 也腾不出足够空间，就可能 OOM。

状态：理解 75%。

---

## 7. HashMap put 流程
用户回答：
> 根据 key 生成 hashcode，查找对应的 hashcode，没找到追加，如果找到比较 key，一致就更新。

评分：8/10

纠正：
- 根据 hash 计算桶下标，不是“查找 hashcode”。
- 桶中通过 hash + equals 判断是否同 key。
- 不同 key 继续在链表 / 红黑树中查找，最终插入。
- 插入后判断是否扩容。

保命句：
> 算 hash → 定位桶 → 判断冲突 → equals 比较 → 覆盖或插入 → 判断扩容。

状态：连续多天能说主流程，稳定度提升。

---

## 8. HashMap 树化条件
用户回答：
> 链表超过 8 并且数组超过 64 就转换成红黑树。

评分：9/10

标准：
> 某个桶链表节点数达到 8，并且数组容量至少 64 时树化；容量不足 64 时优先扩容。

保命句：
> 链表达到 8，容量达到 64 才树化；不足 64 先扩容。

状态：稳定度 90%。

---

## 9. Spring 三级缓存
用户回答：
> 一级缓存放初始化后的 bean，二级缓存放声明的 bean，三级缓存放 ObjectFactory。

评分：8/10

纠正：
- 一级：完整单例 Bean
- 二级：早期 Bean 引用
- 三级：ObjectFactory

保命句：
> 一级完整 Bean，二级早期引用，三级 ObjectFactory。

状态：一级和三级稳定，二级术语仍不稳。

---

## 10. MyBatis Mapper 代理
用户回答：
> MyBatis 生成 Mapper 接口代理对象，通过代理对象根据 namespace 加上接口名称实现 SQL 调用。

评分：9/10

纠正：
> 不是 namespace + 接口名称，而是 namespace + 方法名（statement id）定位 SQL。

保命句：
> Mapper 没实现类，是因为 MyBatis 动态代理；namespace + 方法名定位 SQL。

状态：隔多日仍能答出代理核心，开始形成长期记忆。

---

# 二、JVM 新题（4题）

## 1. JVM 怎么判断对象能否被回收
用户回答：
> 看这个对象还有没有被引用。

评分：7/10

标准：
> JVM 主要通过可达性分析，从 GC Roots 出发搜索。能从 GC Roots 到达的对象存活，不可达对象才可能被回收。

保命句：
> 从 GC Roots 做可达性分析，不可达对象才可能被回收。

---

## 2. GC Roots 常见有哪些
用户回答：
> 不知道。

评分：0/10

常见：
- 虚拟机栈中的局部变量引用
- 类的静态变量引用
- 常量引用
- JNI / Native 方法持有的引用

保命句：
> 栈、静态、常量、Native。

状态：Day57 必回炉。

---

## 3. 强引用 / 软引用 / 弱引用 / 虚引用
用户回答：
> 不知道。

评分：0/10

核心：
- 强引用：一般不回收
- 软引用：内存不足时可能回收
- 弱引用：GC 时容易回收
- 虚引用：主要跟踪对象回收，常配合 ReferenceQueue

保命句：
> 强 > 软 > 弱 > 虚；保留能力越来越弱。

状态：Day57 必回炉。

---

## 4. 常见垃圾回收算法
用户回答：
> 不知道。

评分：0/10

核心：
- 标记-清除
- 复制
- 标记-整理
- 分代收集

保命句：
> 年轻代对象死得快，适合复制；老年代对象活得久，更适合标记整理。

状态：Day57 必回炉。

---

# 三、Day56 结论

## 进步明显
- HashMap put 流程
- HashMap 树化 8 + 64
- MyBatis Mapper 动态代理
- 堆 vs 栈
- ConcurrentHashMap JDK7 / JDK8 边界

## 仍需重点回炉
- StackOverflowError
- JVM 五大运行时区域
- @ConditionalOnClass
- Spring 二级缓存术语
- synchronized 术语

## 新增 JVM 弱点
- GC Roots
- 四种引用
- GC 基础算法

---

# 四、Day57 必回炉

1. StackOverflowError
2. JVM 五大运行时区域
3. GC Roots
4. 强 / 软 / 弱 / 虚引用
5. 标记清除 / 复制 / 标记整理 / 分代收集
6. @ConditionalOnClass / @ConditionalOnMissingBean
7. ConcurrentHashMap JDK7 / JDK8
8. Spring 三级缓存（二级缓存术语）
9. OutOfMemoryError
10. 历史随机高频题 1 道

新题继续 JVM，最多 4 道：新生代 / 老年代、Minor GC / Full GC、对象晋升等。
