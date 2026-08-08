# Day52 Spring Boot 自动配置训练

## 今日重点

- Spring Boot 自动配置原理
- SpringApplication.run 启动流程
- starter 与自动配置区别
- Conditional 条件装配

## 旧题回炉记录

### BeanPostProcessor

评分：0

BeanPostProcessor 是 Spring 提供的 Bean 后置处理器，是 Bean 生命周期中的扩展点，可以在初始化前后对 Bean 进行增强。

执行流程：

实例化 → 属性注入 → BeanPostProcessor 前置处理 → 初始化 → BeanPostProcessor 后置处理 → 使用

AOP 代理很多就是通过 BeanPostProcessor 后置处理阶段生成。

---

### Spring 三级缓存

一级缓存：singletonObjects

- 完整初始化后的单例 Bean

二级缓存：earlySingletonObjects

- 提前暴露的早期 Bean 引用

三级缓存：singletonFactories

- ObjectFactory，用于生成早期引用

作用：解决单例 setter 循环依赖。

---

### JoinPoint 与 ProceedingJoinPoint

JoinPoint：

- 获取切点信息
- 方法参数
- 方法签名

ProceedingJoinPoint：

- 继承 JoinPoint
- 拥有 proceed()
- 可以继续执行目标方法
- 主要用于 Around 通知

---

## 新题

### Spring Boot 自动配置原理

Spring Boot 自动配置根据：

- classpath 依赖
- 配置文件
- 条件注解

自动创建需要的 Bean。

流程：

starter 引入依赖

↓

@EnableAutoConfiguration

↓

加载自动配置类

↓

Conditional 判断

↓

创建 Bean

---

### starter 和自动配置区别

starter：

负责引入依赖，是相关依赖集合。

自动配置：

负责根据条件创建和装配 Bean。

保命句：

starter 负责依赖管理，自动配置负责 Bean 创建。

---

### Conditional 条件装配

常见注解：

@ConditionalOnClass

根据 classpath 是否存在类判断。

@ConditionalOnMissingBean

容器不存在 Bean 时才创建默认 Bean。

@ConditionalOnProperty

根据配置文件决定是否生效。

保命句：

Spring Boot 自动配置通过条件注解决定哪些配置生效，不是所有配置都会加载。

---

# 自我成长模式

## 目标

不仅为了背面试题，而是形成长期技术成长闭环。

## 每日复盘

1. 今天掌握了什么？
2. 哪些知识仍然模糊？
3. 能否结合项目经验说明？
4. 能否向别人解释清楚？

## 技术成长四层

### 第一层：知道

能够说出概念。

### 第二层：理解

能够解释原理。

### 第三层：应用

能够结合项目使用。

### 第四层：输出

能够设计方案、解决问题、指导别人。

## 面试提升目标

每个知识点要求：

概念 → 原理 → 使用场景 → 项目案例 → 常见问题

形成从八股到工程能力的提升。