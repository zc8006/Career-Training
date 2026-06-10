# Spring / Spring Boot / MyBatis Notes

## Spring

### IoC

- 控制反转
- 对象创建交给 Spring 容器
- 降低耦合
- 方便扩展和测试

### DI

- 依赖注入
- IoC 的实现方式
- 推荐构造器注入

### AOP

- 面向切面编程
- 适合日志、事务、权限、监控
- 减少重复代码

## Spring Boot

### 自动配置

```text
Spring Boot 会根据 classpath、配置文件和条件注解自动装配 Bean。
```

关键词：

- starter
- auto configuration
- conditional annotation
- application.yml

## MyBatis

### 常用点

- Mapper
- XML
- 动态 SQL
- #{} / ${}
- 一级缓存 / 二级缓存
- PageHelper
- useGeneratedKeys

### useGeneratedKeys

```text
useGeneratedKeys 用于数据库自增主键回填。
keyProperty 指定把生成的主键设置到对象的哪个属性上。
```
