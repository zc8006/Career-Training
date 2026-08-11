# Day55 面试训练记录

## 今日主题

- Java 集合回炉：HashMap / ArrayList / ConcurrentHashMap
- Spring / Spring Boot / MyBatis 历史题回炉
- JVM 基础入门
- 自我成长与长期记忆策略

---

# 一、旧题回炉（10题）

## 1. HashMap put 流程

用户回答：
> 根据 key 生成 hashcode，查找对应的 hashcode，没有就追加，如果存在比较 key，如果一样，就更新值。

评分：8/10

纠正：
- 不是“查找对应的 hashcode”，而是根据 hash 计算数组桶下标。
- 桶为空直接插入；有冲突时比较 hash / equals，相同 key 覆盖，不同则在链表或红黑树中继续处理。
- 插入后还需要判断是否触发扩容。

保命句：
> 算 hash → 定位桶 → 判断冲突 → equals 比较 → 覆盖或插入 → 判断扩容。

状态：理解 80%

---

## 2. HashMap 链表树化条件

用户回答：
> 当链表超过8，数组大于64会转换成红黑树。

评分：9/10

标准：
> 桶内链表节点数量达到树化阈值 8，并且数组容量至少为 64 时才树化；容量不足 64 时优先扩容。

保命句：
> 链表达到8，容量达到64才树化；不足64先扩容。

状态：理解 90%

---

## 3. ArrayList 扩容与插入

用户回答：
> 默认是10，如果超过10会自动扩容，从中间插入的时候会自动向后移动节点。

评分：8.5/10

纠正：
- ArrayList 底层是数组，所以是“移动数组元素”，不是节点。
- 容量不足时一般扩容为原容量约 1.5 倍。

保命句：
> ArrayList 默认容量10，扩容约1.5倍；中间插入慢，因为要移动后续数组元素。

状态：理解 85%

---

## 4. ConcurrentHashMap JDK7 / JDK8

用户回答：
> ConcurrentHashMap 使用了锁，JDK7 用的是分段式锁，JDK8 用的是 Segment + CAS 锁。

评分：7/10

纠正：
- JDK7：Segment + ReentrantLock
- JDK8：取消 Segment，采用 CAS + synchronized

保命句：
> JDK7：Segment + ReentrantLock；JDK8：无 Segment，CAS + synchronized。

状态：理解 75%，出现记忆回退，Day56 必回炉。

---

## 5. Spring 三级缓存

用户回答：
> 一级缓存放初始化后的 bean，二级缓存放声明好的 bean，三级缓存放 ObjectFactory，三级缓存为了防止互相依赖的问题。

评分：8/10

纠正：
- 一级 singletonObjects：完整单例 Bean
- 二级 earlySingletonObjects：早期 Bean 引用
- 三级 singletonFactories：ObjectFactory
- 用于解决部分单例 Bean 的循环依赖，并支持按需暴露早期引用。

保命句：
> 一级完整 Bean，二级早期引用，三级 ObjectFactory；三级缓存按需暴露早期引用，解决部分单例循环依赖。

状态：理解 90%

---

## 6. BeanPostProcessor 与 AOP

用户回答：
> BeanPostProcess 是在初始化前后对 bean 进行增强，AOP 代理对象引用的时候就需要对代理方法增强依靠的就是 BeanPostProcess。

评分：9/10

纠正：
- 正确名称是 BeanPostProcessor。
- 它本质是 Bean 初始化前后的生命周期扩展点；AOP 利用相关 BeanPostProcessor 在 Bean 创建过程中生成 / 包装代理对象。

保命句：
> BeanPostProcessor 是 Bean 初始化前后的扩展点，Spring AOP 利用它在 Bean 创建过程中生成和包装代理对象。

状态：理解 95%

---

## 7. @ConditionalOnClass / @ConditionalOnMissingBean

用户回答：
> 忘记了。

评分：0/10

标准：
- @ConditionalOnClass：类路径存在指定类时配置才生效。
- @ConditionalOnMissingBean：容器里没有指定 Bean 时才创建默认 Bean。

保命句：
> OnClass：类存在才配置；OnMissingBean：没有 Bean 才创建。

状态：连续多次遗忘，高优先级错题，Day56 必回炉。

---

## 8. Spring Boot 自动配置

用户回答：
> 加载依赖后根据配置文件有条件的创建 Bean。

评分：8/10

纠正：
自动配置判断的不只是配置文件，还会判断 classpath 中的类、容器中的 Bean、配置属性、Web 环境等。

保命句：
> Spring Boot 自动配置就是加载候选自动配置类，再根据条件决定是否创建 Bean。

状态：理解 85%

---

## 9. MyBatis #{} / ${}

用户回答：
> ${} 是字符串拼接，容易被 SQL 注入，#{} 是会替换成 ? 问号交给 JDBC 处理。

评分：10/10

保命句：
> #{} 是预编译参数，安全；${} 是字符串拼接，有 SQL 注入风险。

状态：熟练

---

## 10. Spring 事务 this 内部调用

用户回答：
> this.xxx 这类内部调用，没有经过 Spring 的代理对象，所以 @Transactional 不会生效。

评分：10/10

保命句：
> 内部调用绕过代理，所以事务失效。

状态：熟练

---

# 二、JVM 新题（4题）

## 1. JVM 运行时内存区域

用户回答：
> 堆和栈，GC。

评分：4/10

纠正：GC 不是内存区域，而是垃圾回收机制。

常见运行时区域：
- 堆 Heap
- 虚拟机栈 JVM Stack
- 程序计数器 PC Register
- 本地方法栈 Native Method Stack
- 方法区 Method Area（HotSpot JDK8+ 主要由 Metaspace 元空间实现）

保命句：
> JVM 内存主要包括堆、虚拟机栈、程序计数器、本地方法栈和方法区。

状态：知道 40%，Day56 必回炉。

---

## 2. 堆和栈区别

用户回答：
> 不知道。

评分：0/10

核心：
- 堆：对象 / 数组，线程共享，GC 主要区域。
- 栈：线程私有，保存方法调用产生的栈帧、局部变量等。
- 堆不足常见 OOM；调用栈过深常见 StackOverflowError。

保命句：
> 对象主要在堆，方法执行信息主要在栈；堆共享，栈私有。

状态：知道阶段，Day56 必回炉。

---

## 3. StackOverflowError

用户回答：
> 不知道。

评分：0/10

核心：
> 方法调用层级太深导致线程栈空间耗尽，最典型是无限递归或递归层级过深。

保命句：
> 递归太深，栈帧不断增加，最终导致 StackOverflowError。

状态：知道阶段，Day56 必回炉。

---

## 4. OutOfMemoryError

用户回答：
> 可能是对象没有回收。

评分：6/10

纠正：
> OOM 表示 JVM 无法再申请到足够内存。常见情况是对象持续增加、长期被引用无法回收、内存泄漏或一次申请过大对象。

保命句：
> 栈太深是 StackOverflowError；内存不够分配是 OutOfMemoryError。

状态：知道 60%

---

# 三、Day55 自我成长总结

## 稳定掌握

- MyBatis #{} / ${}
- Spring 事务 this 内部调用
- BeanPostProcessor 与 AOP

## 正在变稳

- HashMap put 流程
- HashMap 树化条件 8 + 64
- ArrayList 扩容与中间插入
- Spring 三级缓存
- Spring Boot 自动配置

## 发生记忆回退

- ConcurrentHashMap JDK7 / JDK8：把 Segment 错放到 JDK8
- Conditional 条件装配：连续多次遗忘

## 新进入知识区

- JVM 运行时内存
- 堆和栈
- StackOverflowError
- OutOfMemoryError

---

# 四、长期记忆策略（从 Day56 起执行）

用户明确反馈：短期记住不代表长期掌握，可能昨天会、过几天就忘。

因此后续不再把“昨天答对”直接视为稳定掌握，而采用间隔回炉：

1. 新学 / 错题：次日回炉
2. 次日答对：3 天后再次随机抽查
3. 再答对：7 天后再次抽查
4. 再答对：14 天后再次抽查
5. 多轮稳定后才标记为“熟练 / 长期稳定”
6. 任何一次遗忘或明显回退：立即降级，并重新进入次日 → 3天 → 7天回炉链

每日 10 道回顾优先级：
- 最近 3 天错题 / 0分题
- 最近 7 天“会但不稳定”的知识点
- 历史高频弱点随机抽查
- 已熟练题少量穿插，防止假性掌握

原则：
> 训练目标不是“当天会”，而是“隔几天仍然能在无提示情况下说出来”。

---

# 五、Day56 必回炉

1. @ConditionalOnClass / @ConditionalOnMissingBean
2. ConcurrentHashMap：JDK7 Segment + ReentrantLock；JDK8 CAS + synchronized
3. JVM 五大运行时内存区域
4. 堆和栈的区别
5. StackOverflowError
6. OutOfMemoryError
7. HashMap put 流程（延迟复测）
8. HashMap 树化 8 + 64
9. Spring 三级缓存
10. 历史随机高频题 1 道

Day56 新题继续 JVM：对象存活判断、GC Roots、引用类型等。
