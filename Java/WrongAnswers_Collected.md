# Java Wrong Answers Collected

从历史 Java 面试训练中整理出来的错题和容易混淆点。

## 记录格式

```text
题目：
我的原回答：
问题点：
正确关键词：
保命答案：
复查时间：
状态：No / Almost / Yes
```

---

## 1. Java 异常体系是什么？Exception 和 RuntimeException 有什么区别？

我的原回答：

```text
不知道
```

问题点：

```text
异常体系完全空白。
```

正确关键词：

```text
Throwable、Error、Exception、RuntimeException、Checked Exception
```

保命答案：

```text
Java 异常体系最上层是 Throwable。
Throwable 下面分 Error 和 Exception。
Exception 又分 RuntimeException 和 checked Exception。
RuntimeException 是运行时异常，通常可以不强制捕获；checked Exception 是编译期检查异常，需要捕获或抛出。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 2. ConcurrentHashMap 为什么是线程安全的？

我的原回答：

```text
ConcurrentHashMap 是加锁的，所以线程安全。
```

问题点：

```text
回答太粗，没说锁粒度，也没说 JDK 1.7 和 JDK 1.8 的实现差异。
```

正确关键词：

```text
线程安全、减小锁粒度、JDK 1.7 Segment 分段锁、JDK 1.8 CAS + synchronized
```

保命答案：

```text
ConcurrentHashMap 不是锁整个 Map，而是通过减小锁粒度保证线程安全。
JDK 1.7 主要使用 Segment 分段锁。
JDK 1.8 主要使用 CAS + synchronized，锁的粒度更细。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 3. fail-fast 是什么？怎么避免？

我的原回答：

```text
fail-fast 是集合在循环中发生变化，发生的错误，应该先 remove 再进行添加。
```

问题点：

```text
知道遍历中修改集合会出错，但没有说出 ConcurrentModificationException、modCount，也把避免方式说错了。
```

正确关键词：

```text
Iterator、结构性修改、ConcurrentModificationException、modCount、expectedModCount、Iterator.remove、并发集合
```

保命答案：

```text
fail-fast 是指遍历集合时，如果集合结构被修改，就可能抛 ConcurrentModificationException。
它通常通过 modCount 和 expectedModCount 判断集合是否被并发修改。
避免方式是遍历时不要直接修改集合，可以使用 Iterator.remove，或者使用并发集合。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 4. List、Set、Map 有什么区别？

我的原回答：

```text
List 是数组，Set 是 set，Map 不知道。
```

问题点：

```text
把 List 和 ArrayList 混了；Map 不清楚。
```

正确关键词：

```text
List 有序可重复；Set 不重复；Map 存 key-value。
```

保命答案：

```text
List 是有序集合，元素可以重复。
Set 不允许重复元素。
Map 存 key-value 键值对，key 不能重复。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 5. Spring Bean 的作用域有哪些？

我的原回答：

```text
request 每次请求创建；session，生命周期。
```

问题点：

```text
漏了最核心的 singleton 和 prototype。
```

正确关键词：

```text
singleton、prototype、request、session
```

保命答案：

```text
Spring Bean 常见作用域有 singleton、prototype、request、session。
singleton 是默认单例，一个容器只有一个 Bean。
prototype 是每次获取都会创建新对象。
request 是一次请求一个。
session 是一次会话一个。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 6. Spring 事务隔离级别有哪些？

我的原回答：

```text
读未提交最低，读已提交防止幻读，可重复读防止幻读和不可重复读，串行化性能最低。
```

问题点：

```text
把读已提交和可重复读防的问题说错了。
```

正确关键词：

```text
READ_UNCOMMITTED、READ_COMMITTED、REPEATABLE_READ、SERIALIZABLE、脏读、不可重复读、幻读
```

保命答案：

```text
读未提交最低，可能出现脏读。
读已提交可以防脏读。
可重复读可以防不可重复读。
串行化最安全，但性能最低。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 7. Spring Boot 自动配置原理是什么？

我的原回答：

```text
不知道
```

问题点：

```text
自动配置原理完全空白。
```

正确关键词：

```text
@EnableAutoConfiguration、自动配置类、条件判断、创建 Bean
```

保命答案：

```text
Spring Boot 自动配置主要由 @EnableAutoConfiguration 开启。
它会加载自动配置类，并根据 classpath、配置文件和条件注解判断是否创建 Bean。
比如引入 spring-boot-starter-web 后，会自动配置 Spring MVC、内嵌 Tomcat、JSON 转换等组件。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 8. 一个请求进入 Spring Boot 项目后，从 Controller 到数据库返回，大概流程是什么？

我的原回答：

```text
不知道
```

问题点：

```text
Spring Boot 项目请求链路不清楚。
```

正确关键词：

```text
DispatcherServlet、Controller、Service、事务、Mapper、MyBatis、MySQL、JSON
```

保命答案：

```text
前端请求进入 DispatcherServlet，转发到 Controller。
Controller 调用 Service，Service 处理业务和事务。
Service 调用 Mapper，MyBatis 执行 SQL 访问 MySQL。
最后把结果封装成对象并返回 JSON。
```

复查时间：Day 8、Day 10、Day 14

状态：Almost

---

## 9. String、StringBuilder、StringBuffer 区别

问题点：

```text
把 StringBuilder 和 StringBuffer 的线程安全说反了。
```

保命答案：

```text
String 不可变。
StringBuilder 可变、线程不安全、性能高。
StringBuffer 可变、线程安全、性能低一些。
```

状态：Almost

---

## 10. HashMap 底层结构和 put 流程

问题点：

```text
只说了 hash，没说完整 put 流程。
```

保命答案：

```text
HashMap 底层是数组 + 链表 + 红黑树。
put 时先计算 hash，再定位数组下标。
如果没有冲突就直接放入。
如果有冲突，就比较 key，相同则覆盖，不同则挂到链表或红黑树上。
元素数量超过阈值后会扩容。
```

状态：Almost

---

## 11. Spring Batch 和普通定时任务区别

问题点：

```text
只说了 Batch 是大数据量处理，没说和普通定时任务的区别。
```

保命答案：

```text
普通定时任务主要负责定时触发。
Spring Batch 不只是触发任务，它更适合大批量、分步骤、分批处理，并支持失败重试、跳过和重启。
```

状态：Almost

---

## 12. JobRepository 和 JobLauncher

问题点：

```text
只知道 JobRepository，不知道 JobLauncher。
```

保命答案：

```text
JobLauncher 负责启动 Job。
JobRepository 负责记录 Job 和 Step 的执行状态。
JobParameters 表示本次执行参数。
```

状态：Almost

---

# 优先回炉清单

后续训练优先抽查这些题：

```text
1. Java 异常体系
2. ConcurrentHashMap 为什么线程安全
3. fail-fast 是什么
4. List / Set / Map 区别
5. Spring Bean 作用域
6. Spring 事务隔离级别
7. Spring Boot 自动配置原理
8. Spring Boot 请求链路
9. HashMap put 流程
10. Spring Batch 和普通定时任务区别
```