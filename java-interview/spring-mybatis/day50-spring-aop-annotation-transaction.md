# Day50 - Spring AOP 注解、代理限制与事务回炉

## 今日目标

继续清理 Spring 全覆盖台账：

- Bean 生命周期相关薄弱点
- Spring AOP 深入
- Spring MVC 链路巩固
- 事务回滚规则

---

## 一、旧题回炉

### 1. BeanPostProcessor 是什么？

回答：

> 是初始化 Bean 用的吗？

评分：4/10

修正版：

> BeanPostProcessor 是 Spring 提供的 Bean 后置处理器，是 Bean 生命周期中的扩展点，可以在 Bean 初始化前后对 Bean 进行增强处理。

核心方法：

```java
postProcessBeforeInitialization()
postProcessAfterInitialization()
```

保命句：

> BeanPostProcessor 是 Bean 初始化前后的扩展点，AOP 代理很多就是通过它生成的。

---

### 2. Spring 三级缓存分别放什么？

回答：

> 一级缓存放实例化 Bean，二级缓存放可暴露的 Bean，三级缓存忘记。

评分：6/10

修正版：

一级缓存：完整创建完成的单例 Bean。

二级缓存：提前暴露的早期 Bean 引用。

三级缓存：ObjectFactory，用于生成早期引用，支持 AOP 代理对象提前暴露。

保命句：

> 一级缓存放完整 Bean，二级缓存放早期 Bean 引用，三级缓存放创建早期引用的工厂对象。

---

### 3. setter 和构造器循环依赖区别

回答：

> 构造器注入需要创建好的 Bean，循环依赖无法创建 Bean。

评分：7/10

修正版：

setter 注入可以先实例化对象，再注入属性，所以可以提前暴露引用。

构造器注入必须先拿到依赖才能创建对象，对象还不存在，无法提前暴露引用。

保命句：

> setter 注入可以提前暴露对象，构造器注入必须先创建对象，所以无法解决循环依赖。

---

### 4. Spring AOP 执行链

回答：

> 生成代理对象，调用增强，执行对象方法，再调用增强。

评分：7/10

修正版：

多个切面会形成拦截器链：

```text
前置增强
 ↓
目标方法
 ↓
后置增强
```

进入按照顺序执行，返回按照相反顺序执行。

@Order 可以控制切面顺序。

保命句：

> AOP 通过代理对象执行拦截器链，先执行前置增强，再执行目标方法，最后反向执行后置增强。

---

### 5. Spring MVC 请求链路

回答：

> DispatcherServlet，Controller，Service，DAO 执行 SQL。

评分：7/10

完整流程：

```text
DispatcherServlet
 ↓
HandlerMapping
 ↓
HandlerAdapter
 ↓
Controller
 ↓
Service
 ↓
Mapper
 ↓
MyBatis
 ↓
Database
```

---

### 6. HandlerMapping 和 HandlerAdapter

回答：

> HandlerMapping 匹配 Controller，HandlerAdapter 调用 Controller。

评分：9/10

标准：

> HandlerMapping 负责根据请求找到 Controller 方法，HandlerAdapter 负责调用该方法并完成参数绑定和返回值处理。

---

### 7. DispatcherServlet 作用

回答：

> 核心作用，起始点。

评分：7/10

标准：

> DispatcherServlet 是 Spring MVC 的前端控制器，是请求处理入口，负责接收请求、分发请求、调用 Controller、处理返回结果。

---

### 8. @SpringBootApplication

正确：

```java
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan
```

保命句：

> SpringBootApplication = 配置类 + 自动配置 + 组件扫描。

---

### 9. @PostConstruct 和 @PreDestroy

标准：

> @PostConstruct 在 Bean 创建完成、依赖注入完成后执行；@PreDestroy 在 Bean 销毁前执行。

---

### 10. Bean 生命周期

标准：

```text
实例化
 ↓
属性注入
 ↓
初始化
 ↓
使用
 ↓
销毁
```

---

## 二、新题

### 1. @Before、@After、@Around 区别

@Before：方法执行前增强。

@After：方法结束后执行，无论异常还是正常。

@Around：环绕增强，可以通过 proceed() 控制目标方法执行。

保命句：

> Around 可以包裹整个方法，通过 proceed() 决定是否继续执行。

---

### 2. JoinPoint 和 ProceedingJoinPoint

JoinPoint：

- 获取切点信息
- 获取方法参数
- 获取目标方法信息

ProceedingJoinPoint：

- 是 JoinPoint 子接口
- 用于 Around
- 通过 proceed() 执行目标方法

保命句：

> JoinPoint 用于获取信息，ProceedingJoinPoint 可以通过 proceed() 继续执行目标方法。

---

### 3. private 为什么不能 AOP 增强？

回答：

> private 通过 this 调用，没有经过 Spring，所以无法代理。

评分：8/10

修正：

private 不能增强主要原因：代理对象无法重写 private 方法。

this 调用是另外一个问题：内部调用没有经过代理对象。

保命句：

> private 方法不能被代理重写，所以无法进行 AOP 增强；this 调用失效是因为没有经过代理对象。

---

### 4. 为什么普通 Exception 默认不回滚？

回答：

> rollbackFor 没指定。

评分：6/10

标准：

Spring 默认认为 RuntimeException 和 Error 表示程序错误，需要回滚；普通 Exception 通常属于可处理异常，所以默认不回滚。

需要普通异常回滚：

```java
@Transactional(rollbackFor = Exception.class)
```

---

## Day51 必回炉

1. BeanPostProcessor
2. 三级缓存细节
3. JoinPoint / ProceedingJoinPoint
4. private 与 this 调用事务失效区别
5. @Order 多切面顺序
6. AOP 代理限制

---

## Day50 背诵清单

1. BeanPostProcessor 是 Bean 初始化前后的扩展点。
2. 一级缓存完整 Bean，二级缓存早期引用，三级缓存 ObjectFactory。
3. setter 可以提前暴露对象，构造器不能解决循环依赖。
4. AOP 多切面形成拦截器链，进入顺序执行，返回反向执行。
5. HandlerMapping 找 Controller，HandlerAdapter 调 Controller。
6. DispatcherServlet 是 Spring MVC 请求入口。
7. SpringBootApplication 等于三个核心注解组合。
8. JoinPoint 获取信息，ProceedingJoinPoint 通过 proceed 执行方法。
9. private 不能被代理增强，this 调用不会经过代理。
10. Exception 默认不回滚，需要 rollbackFor。
