# Java Interview Master

## 目标

用于 Java / Spring / Spring Boot / MyBatis 面试训练。

当前重点不是死背概念，而是：

- 能用自己的话说明核心原理
- 能结合项目经验回答
- 能回答追问
- 能把答案压缩成面试可说版本

## 训练节奏

每天固定结构：

1. 旧题回炉 8～10 道
2. 新题 4～6 道
3. 追问 3～5 个以内
4. 最后整理 8～10 句背诵清单

## 当前主线

1. Java 基础
2. Spring
3. Spring Boot
4. MyBatis
5. MySQL
6. Redis
7. JVM
8. 并发
9. 项目经验

## Spring 核心答案

### IoC 是什么？

简单版：

```text
IoC 是控制反转，就是对象的创建和依赖关系不再由我们自己 new，而是交给 Spring 容器管理。
这样可以降低代码耦合，方便扩展和测试。
```

面试版：

```text
IoC 是 Spring 的核心思想，主要是把对象创建和依赖管理交给容器处理。
以前对象之间直接 new，耦合比较强；使用 IoC 后，Bean 由 Spring 创建和管理，再通过 DI 注入依赖。
这样代码更容易维护，也更方便做扩展和测试。
```

### DI 是什么？

```text
DI 是依赖注入，是 IoC 的具体实现方式。
Spring 在创建 Bean 的时候，会把它依赖的对象自动注入进去。
常见方式有构造器注入、Setter 注入和字段注入。
项目中更推荐构造器注入，因为依赖关系更清晰，也方便测试。
```

## MyBatis 核心答案

### #{} 和 ${} 区别

```text
#{} 是预编译参数，会使用占位符，可以防止 SQL 注入。
${} 是字符串拼接，适合动态表名、字段名等场景，但要注意安全风险。
项目中普通参数一般使用 #{}。
```

### MyBatis 一级缓存和二级缓存

```text
一级缓存是 SqlSession 级别，默认开启。
同一个 SqlSession 中执行相同查询，可能直接从缓存中取数据。

二级缓存是 Mapper 级别，需要手动开启。
多个 SqlSession 可以共享二级缓存，但如果数据更新后缓存没有及时失效，可能读到旧数据。
所以项目中使用二级缓存要谨慎。
```

### RowBounds 和 PageHelper

```text
RowBounds 偏逻辑分页，可能先查出大量数据再在内存中截取，所以大数据量分页不推荐。
PageHelper 会拦截 SQL，并改写成带 limit 的物理分页 SQL。
项目中一般使用 PageHelper 或手写 limit。
```

## 常用背诵句

```text
Spring 的核心是 IoC 和 AOP。
IoC 负责对象创建和依赖管理。
DI 是 IoC 的具体实现方式。
AOP 用来处理日志、事务、权限等横切逻辑。
Spring Boot 通过自动配置减少 XML 和手动配置。
MyBatis 是半自动 ORM 框架，SQL 可控性比较强。
#{} 可以防止 SQL 注入，${} 是字符串拼接。
PageHelper 是物理分页，RowBounds 偏逻辑分页。
```
