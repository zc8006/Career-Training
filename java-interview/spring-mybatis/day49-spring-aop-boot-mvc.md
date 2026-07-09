# Day49 - Spring AOP、Spring Boot 启动流程与 Spring MVC 请求链路

## 今日目标

Day49 继续执行全覆盖台账模式，重点回炉 Day47/Day48 的薄弱点，并开始补 Spring AOP 执行链、Spring Boot 启动流程、Spring MVC 请求链路。

训练规则：

- 严格闭卷，不提前提示关键词。
- 旧题回炉 9 道。
- 新题 4 道以内。
- 追问 3 道以内。
- 错题进入 Day50 回炉。

---

## 一、旧题回炉

### 1. BeanFactory 和 ApplicationContext 有什么区别？

我的回答：

> BeanFactory 是基础，是懒加载，ApplicationContext 是继承 BeanFactory，项目常用，国际化之类的都需要用它。

评分：8.5 / 10

修正版：

> BeanFactory 是 Spring 最基础的 IOC 容器，主要负责 Bean 的创建和管理，默认是懒加载，用到 Bean 时才创建。ApplicationContext 是 BeanFactory 的子接口，在它基础上扩展了更多企业级功能，比如国际化、事件发布、资源加载、AOP 自动代理、注解支持等。实际项目中一般使用 ApplicationContext，它默认会在容器启动时创建单例 Bean。

保命句：

> BeanFactory 是基础容器，默认懒加载；ApplicationContext 是更完整、更常用的高级容器，支持国际化、事件、资源加载和 AOP 等功能。

---

### 2. Spring Bean 的作用域有哪些？默认是什么？

我的回答：

> SpringBean 的作用域是 singletion 单例，只创建一次，proptype 复例，每次使用创建，request 每次请求创建，session 每次会话创建。

评分：8 / 10

问题点：

- `singleton` 拼写错成了 `singletion`。
- `prototype` 拼写错成了 `proptype`。
- 少了 `application`。
- prototype 更准确是“每次从容器获取 Bean 时创建新对象”。

修正版：

> Spring Bean 常见作用域有 singleton、prototype、request、session、application。singleton 是默认作用域，Spring 容器中只有一个 Bean 实例；prototype 表示每次从容器获取 Bean 时创建一个新 Bean；request 表示一次 HTTP 请求一个 Bean；session 表示一次 HTTP Session 一个 Bean；application 表示一个 Web 应用一个 Bean。

保命句：

> Spring Bean 默认是 singleton，常见作用域还有 prototype、request、session、application。

Day50 轻回炉：主要回炉拼写。

---

### 3. Spring Bean 的生命周期大概有哪些步骤？

我的回答：

> 加载 Bean，注入，初始化，使用，销毁。

评分：7 / 10

问题点：

- “加载 Bean”容易和 BeanDefinition 加载 / 类加载混淆。
- 面试中建议说“实例化 Bean”。

修正版：

> Spring Bean 生命周期大致是：实例化 Bean → 属性注入 → 初始化 → 使用 → 销毁。如果说完整一点，Spring 先根据 BeanDefinition 实例化 Bean 对象，然后进行属性注入，接着执行初始化相关回调，比如 Aware 接口、BeanPostProcessor 前置处理、初始化方法、BeanPostProcessor 后置处理，最后 Bean 可以被使用，容器关闭时执行销毁方法。

保命句：

> Bean 生命周期就是：实例化、属性注入、初始化、使用、销毁。

Day50 回炉：不要把“实例化”说成“加载”。

---

### 4. BeanPostProcessor 是什么？

我的回答：

> 忘记了。

评分：0 / 10

正确答案：

> BeanPostProcessor 是 Spring 提供的 Bean 后置处理器，是 Bean 生命周期里的扩展点，可以在 Bean 初始化前后对 Bean 做增强处理。它主要有两个方法：postProcessBeforeInitialization() 和 postProcessAfterInitialization()。Spring AOP 代理很多就是在初始化后通过 BeanPostProcessor 生成的。

生命周期位置：

```text
实例化 Bean
→ 属性注入
→ BeanPostProcessor 前置处理
→ 初始化方法
→ BeanPostProcessor 后置处理
→ 使用 Bean
```

保命句：

> BeanPostProcessor 是 Bean 初始化前后的扩展点，Spring 可以用它对 Bean 做增强，AOP 代理很多就是在初始化后生成的。

Day50 必回炉。

---

### 5. @PostConstruct 和 @PreDestroy 分别什么时候执行？

我的回答：

> PostConstruct 是初始化 Bean 之前执行，PreDestroy 是销毁 Bean 之前执行。

评分：7 / 10

问题点：

- `@PreDestroy` 答对。
- `@PostConstruct` 更准确是：属性注入完成后、Bean 使用前执行，属于初始化回调。

修正版：

> @PostConstruct 在 Bean 创建完成、依赖注入完成之后执行，属于初始化回调。@PreDestroy 在容器关闭、Bean 销毁之前执行，属于销毁前回调。

保命句：

> PostConstruct 在属性注入完成后、Bean 使用前执行；PreDestroy 在 Bean 销毁前执行。

Day50 回炉。

---

### 6. @SpringBootApplication 包含哪几个核心注解？

我的回答：

> SpringBootApplication 包含 springbootConfiguration、EnableAutoConfiguration、CompoteScan。

评分：6.5 / 10

问题点：拼写仍不稳定。

正确拼写：

```java
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan
```

修正版：

> @SpringBootApplication 主要包含三个核心注解：@SpringBootConfiguration 表示当前类是 Spring Boot 配置类；@EnableAutoConfiguration 开启自动配置；@ComponentScan 开启组件扫描，默认扫描启动类所在包及其子包。

保命句：

> @SpringBootApplication = 配置类 + 自动配置 + 组件扫描。

Day50 回炉：重点回炉拼写。

---

### 7. Spring Boot 自动配置原理是什么？

我的回答：

> 扫描 classpath 下面相关的组件，使用 EnableAutoConfiguration 根据条件创建 Bean。

评分：8 / 10

问题点：

- “扫描 classpath 组件”容易和 @ComponentScan 混淆。
- 自动配置更准确是加载自动配置类，再根据 classpath、配置文件和条件注解创建 Bean。

修正版：

> Spring Boot 自动配置是通过 @EnableAutoConfiguration 开启的。它会加载一批自动配置类，这些自动配置类会根据当前项目的 classpath 依赖、配置文件以及 @Conditional 系列条件注解，判断是否创建对应的 Bean。starter 负责引入依赖，自动配置类负责根据条件创建 Bean。

保命句：

> Spring Boot 自动配置就是：@EnableAutoConfiguration 加载自动配置类，再根据 classpath、配置和条件判断创建 Bean。

---

### 8. Spring 三级缓存分别大概放什么？

我的回答：

> 三级缓存放循环依赖的 Bean。

评分：4 / 10

问题点：

- 三级缓存不是三个地方都放循环依赖 Bean。
- 一级、二级、三级缓存各自放的东西不同。

修正版：

> 一级缓存放已经创建完成的单例 Bean。二级缓存放提前暴露的早期 Bean 引用。三级缓存放 ObjectFactory 工厂对象，用来在需要时生成早期 Bean 引用，尤其是可能生成早期代理对象。

保命句：

> 一级缓存放完整 Bean，二级缓存放早期 Bean 引用，三级缓存放能生成早期引用的工厂对象。

Day50 必回炉。

---

### 9. 为什么 setter 循环依赖能解决，构造器循环依赖解决不了？

我的回答：

> 构造器注入的时候必须创建 Bean。

评分：5 / 10

问题点：

- 只答出了构造器这一半。
- 没有说明 setter 为什么能解决。

修正版：

> setter 注入可以解决循环依赖，是因为 Spring 可以先实例化 Bean，再进行属性注入。对象实例化后，即使属性还没注入完成，也可以提前暴露早期引用。构造器注入解决不了，是因为构造器执行完成之前，对象还没有创建出来，Spring 没法提前暴露早期引用。

保命句：

> setter 注入是先创建对象再注入属性，所以能提前暴露；构造器注入必须先拿到依赖才能创建对象，所以解决不了循环依赖。

Day50 必回炉。

---

## 二、新题

### 1. Spring AOP 的执行链大概是什么？多个切面同时增强一个方法时，大概怎么执行？

我的回答：

> 不知道。

评分：0 / 10

正确答案：

> Spring AOP 底层会把多个增强封装成拦截器链。方法调用进入代理对象后，会按照切面顺序依次执行前置逻辑，然后执行目标方法，目标方法执行完成后，再按照相反顺序执行后置逻辑。

示意：

```text
切面1前置
  切面2前置
    目标方法执行
  切面2后置
切面1后置
```

补充：

> 多个切面的顺序可以通过 @Order 控制，数字越小，优先级越高，越先进入，越后退出。

保命句：

> AOP 执行链就是拦截器链：先按顺序执行前置增强，再执行目标方法，最后反向执行后置增强。

Day50 必回炉。

---

### 2. Spring Boot 启动流程大概是什么？

我的回答：

> application.run 创建容器，扫描组件，加载依赖，自动配置，实例化 bean，初始化 bean。

评分：7.5 / 10

问题点：

- 标准说法是 SpringApplication.run()。
- “加载依赖”不准确，建议说加载配置、准备环境、加载自动配置类。
- Web 项目最后要补内嵌 Tomcat 启动。

修正版：

> Spring Boot 启动时，首先执行 SpringApplication.run()，然后准备运行环境，创建 Spring 容器，加载配置和自动配置类，进行组件扫描，把需要的 Bean 注册到容器中。接着 Spring 会实例化 Bean、完成依赖注入和初始化。最后启动内嵌 Web 容器，比如 Tomcat，对外提供服务。

保命句：

> Spring Boot 启动流程就是：run 方法启动 → 准备环境 → 创建容器 → 加载配置和自动配置 → 扫描组件 → 创建并初始化 Bean → 启动内嵌 Tomcat。

---

### 3. Spring MVC 一个请求从进入到返回，大概经历哪些步骤？

我的回答：

> displayPatch.session 到 control 然后到 service，到 mapper 到 mybatis 执行 sql，然后返回结果。

评分：5.5 / 10

问题点：

- `displayPatch.session` 应为 `DispatcherServlet`。
- `control` 应为 `Controller`。
- 缺少 HandlerMapping 和 HandlerAdapter。

修正版：

> 一个请求进入 Spring MVC 后，首先会到 DispatcherServlet，它作为前端控制器负责统一分发请求。然后通过 HandlerMapping 找到对应的 Controller 方法，再通过 HandlerAdapter 调用这个方法。Controller 调用 Service，Service 处理业务和事务，再调用 Mapper，MyBatis 执行 SQL 访问数据库，最后结果逐层返回，通常通过 JSON 返回给前端。

保命句：

> 请求先到 DispatcherServlet，再找到 Controller，Controller 调 Service，Service 调 Mapper，MyBatis 执行 SQL，最后返回 JSON。

简化链路：

```text
DispatcherServlet
→ HandlerMapping
→ HandlerAdapter
→ Controller
→ Service
→ Mapper
→ MyBatis
→ MySQL
→ JSON 返回
```

Day50 必回炉。

---

### 4. HandlerMapping 和 HandlerAdapter 分别是干什么的？

我的回答：

> 字段名是不是匹配的区别。

评分：2 / 10

问题点：

- 答偏到 MyBatis 字段名和 Java 属性名映射。
- 这是 Spring MVC 请求处理链路问题。

正确答案：

> HandlerMapping 用来根据请求 URL 找到对应的处理器，也就是找到哪个 Controller 方法处理这个请求。HandlerAdapter 用来适配并调用这个处理器方法，负责参数解析、方法执行和返回值处理。

保命句：

> HandlerMapping 负责找到 Controller 方法，HandlerAdapter 负责调用 Controller 方法。

Day50 必回炉。

---

## 三、追问

### 1. 为什么 Spring MVC 请求要先经过 DispatcherServlet？

我的回答：

> 不知道。

评分：0 / 10

正确答案：

> DispatcherServlet 是 Spring MVC 的前端控制器，负责统一接收所有请求，并把请求分发给对应的 Controller。Spring MVC 使用 DispatcherServlet 作为统一入口，是为了把请求接收、处理器查找、方法调用、参数解析、返回值处理等流程统一管理起来。

保命句：

> DispatcherServlet 是 Spring MVC 的统一入口，负责接收请求、分发请求、调用 Controller，并处理返回结果。

Day50 必回炉。

---

### 2. Controller、Service、Mapper 分别负责什么？

我的回答：

> control 负责验证参数和返回响应，service 负责业务处理调用 mapper，mapper 负责调用 mybatis 执行相关的 sql 并返回结果。

评分：8 / 10

问题点：

- 应说 Controller，不是 control。
- Mapper 更准确是 MyBatis 的接口层，负责定义 SQL 操作，由 MyBatis 根据 Mapper 执行 SQL。

修正版：

> Controller 负责接收请求、参数校验、调用 Service，并返回响应结果。Service 负责业务逻辑处理和事务控制，必要时调用多个 Mapper 完成一个完整业务。Mapper 负责和数据库交互，定义 SQL 操作，MyBatis 根据 Mapper 方法执行 SQL 并封装结果。

保命句：

> Controller 管请求和响应，Service 管业务和事务，Mapper 管 SQL 和数据库访问。

---

### 3. 为什么事务一般放在 Service 层，而不是 Controller 或 Mapper 层？

我的回答：

> Service 主要负责业务处理，可能会有多个 SQL。

评分：8 / 10

修正版：

> 事务一般放在 Service 层，因为 Service 负责业务逻辑，一个业务操作可能会调用多个 Mapper、执行多条 SQL。事务控制的是整个业务流程的一致性，而不是单个 Controller 请求或某一条 SQL。Controller 主要负责接收请求和返回结果，Mapper 主要负责数据库访问，所以事务放在 Service 层最合适。

保命句：

> 事务放 Service 层，是为了控制整个业务流程的一致性；一个 Service 方法里可能调用多个 Mapper，多条 SQL 要么一起成功，要么一起回滚。

---

## 四、Day50 必回炉清单

1. BeanPostProcessor 是什么
2. Spring 三级缓存分别放什么
3. setter 循环依赖和构造器循环依赖区别
4. Spring AOP 执行链
5. Spring MVC 请求链路
6. HandlerMapping 和 HandlerAdapter
7. DispatcherServlet 的作用
8. @SpringBootApplication 三个注解拼写
9. @PostConstruct 准确执行时机
10. Bean 生命周期里要说“实例化”，不要说“加载”

---

## 五、Day49 背诵清单

1. BeanFactory 是基础容器，默认懒加载；ApplicationContext 是更完整、更常用的高级容器。
2. Spring Bean 默认是 singleton，常见还有 prototype、request、session、application。
3. Bean 生命周期：实例化、属性注入、初始化、使用、销毁。
4. BeanPostProcessor 是 Bean 初始化前后的扩展点，AOP 代理很多就是靠它在初始化后生成的。
5. PostConstruct 在属性注入完成后、Bean 使用前执行；PreDestroy 在 Bean 销毁前执行。
6. @SpringBootApplication = @SpringBootConfiguration + @EnableAutoConfiguration + @ComponentScan。
7. Spring Boot 自动配置就是 @EnableAutoConfiguration 加载自动配置类，再根据 classpath、配置和条件判断创建 Bean。
8. 一级缓存放完整 Bean，二级缓存放早期 Bean 引用，三级缓存放能生成早期引用的工厂对象。
9. AOP 执行链就是拦截器链：先按顺序执行前置增强，再执行目标方法，最后反向执行后置增强。
10. DispatcherServlet 是 Spring MVC 的统一入口，负责接收请求、分发请求、调用 Controller，并处理返回结果。
11. HandlerMapping 负责找到 Controller 方法，HandlerAdapter 负责调用 Controller 方法。
12. Controller 管请求和响应，Service 管业务和事务，Mapper 管 SQL 和数据库访问。

---

## 六、全覆盖台账更新

Day49 已覆盖：

- BeanFactory / ApplicationContext 回炉
- Bean 作用域回炉
- Bean 生命周期回炉
- BeanPostProcessor 回炉
- @PostConstruct / @PreDestroy 回炉
- @SpringBootApplication 回炉
- Spring Boot 自动配置回炉
- Spring 三级缓存回炉
- setter / 构造器循环依赖区别回炉
- Spring AOP 执行链入门
- Spring Boot 启动流程入门
- Spring MVC 请求链路入门
- HandlerMapping / HandlerAdapter 入门
- DispatcherServlet 作用入门
- Controller / Service / Mapper 分层回炉
- 事务为什么放 Service 层回炉

后续继续覆盖：

- Spring AOP 多切面顺序与 @Order
- Spring Boot 自动配置源码级流程
- Spring MVC 参数绑定、返回值处理、统一异常处理
- MyBatis 执行链、缓存与插件机制
