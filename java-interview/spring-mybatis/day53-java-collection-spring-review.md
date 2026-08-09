# Day53 面试训练记录

## 今日模式

新增训练模式：

- 回顾旧知识
- Java 基础补充
- Spring 原理强化
- 自我成长记录

---

# 一、回顾内容

## 1. BeanPostProcessor

状态：重点薄弱

核心：

> BeanPostProcessor 是 Spring 在 Bean 初始化前后的扩展点，可以对 Bean 进行增强，AOP 代理很多就是通过它生成。

---

## 2. Spring 三级缓存

状态：部分掌握

- 一级缓存：singletonObjects，完整 Bean
- 二级缓存：earlySingletonObjects，早期 Bean 引用
- 三级缓存：singletonFactories，ObjectFactory

保命句：

> 一级完整 Bean，二级早期引用，三级 ObjectFactory。

---

## 3. JoinPoint / ProceedingJoinPoint

状态：重点薄弱

- JoinPoint：获取方法信息
- ProceedingJoinPoint：可以通过 proceed() 执行目标方法，主要用于 Around

---

# 二、Spring Boot 回顾

## 自动配置流程

```
@EnableAutoConfiguration
        ↓
加载自动配置类
        ↓
Conditional 条件判断
        ↓
创建 Bean
```

核心：

> 根据依赖、配置和条件自动创建 Bean。

## 条件注解

- ConditionalOnClass：判断类是否存在
- ConditionalOnMissingBean：没有 Bean 时创建默认 Bean

---

# 三、Java 基础补充

## HashMap

JDK8：

> 数组 + 链表 + 红黑树

链表长度超过 8，并且数组容量达到 64 时树化。

目的：

> 优化 hash 冲突导致的查询性能下降。

---

## HashMap 线程安全

问题：

- 数据覆盖
- 数据丢失
- 扩容问题

解决：

- ConcurrentHashMap
- 加锁

---

## ConcurrentHashMap

JDK7：

> Segment 分段锁

JDK8：

> CAS + synchronized，锁粒度更小

---

## ArrayList vs LinkedList

ArrayList：

- 动态数组
- 查询快

LinkedList：

- 双向链表
- 节点操作方便

实际开发大多数优先 ArrayList。

---

## equals 和 hashCode

HashMap：

```
hashCode 定位桶
        ↓
equals 判断是否相同
```

规则：

> equals 相等的对象，hashCode 必须相等。

---

# 四、自我成长记录

## 已提升

- Spring Boot 自动配置流程：从不知道 → 能解释流程
- Spring MVC 请求链路：能够完整描述
- 事务 AOP：能够说明代理和事务增强
- Java 集合开始建立体系

## 当前薄弱

1. BeanPostProcessor
2. JoinPoint / ProceedingJoinPoint
3. Spring 条件装配
4. Java 集合源码细节
5. ConcurrentHashMap 原理

## 成长目标

从：

> 记住面试答案

提升到：

> 理解设计原因，并结合项目场景解决问题。
