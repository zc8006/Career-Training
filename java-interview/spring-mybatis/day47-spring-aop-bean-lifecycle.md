# Day47 - Spring AOP、Bean 生命周期与循环依赖回炉

## 今日目标

Day47 开始进入全覆盖台账模式，不只按单个题目推进，而是围绕来源资料中的 Spring / Spring Boot / MyBatis 高频考点逐步清零。

今日主题：

1. Spring AOP 基础与动态代理
2. Spring 事务失效原因回炉
3. Spring IOC 容器、Bean 作用域、生命周期
4. Spring Boot 自动配置基础回炉
5. BeanPostProcessor 与循环依赖入门

---

## 一、旧题回炉

### 1. Spring AOP 是什么？一般用来解决什么问题？底层大概怎么实现？

我的回答：

> AOP 是面向切面编程，事务和日志等交给 Spring 管理，代码专注于业务开发，底层就是生成对象代理，对执行方法前后进行增强。

评分：8.5 / 10

修正版：

> AOP 是面向切面编程，主要用来把日志、事务、权限、监控等公共逻辑从业务代码中抽离出来，避免代码重复，让业务代码更专注。Spring AOP 底层主要基于动态代理实现，如果目标类有接口，默认使用 JDK 动态代理；如果没有接口，通常使用 CGLIB 生成子类代理。代理对象会在目标方法执行前后织入增强逻辑。

保命句：

> AOP 就是把公共逻辑抽出来，通过代理在方法执行前后做增强，比如事务、日志、权限。

---

### 2. JDK 动态代理和 CGLIB 动态代理有什么区别？Spring AOP 什么时候用 JDK，什么时候用 CGLIB？

我的回答：

> JDK 动态代理是处理有接口的，CGLIB 是没有接口，针对类的，对类生成子类进行对象代理。

评分：8 / 10

修正版：

> JDK 动态代理要求目标类实现接口，它会基于接口生成代理对象。CGLIB 不要求目标类实现接口，它通过继承目标类生成子类代理。Spring AOP 默认情况下，如果目标类有接口，一般使用 JDK 动态代理；如果没有接口，会使用 CGLIB。

补充：

- JDK 动态代理靠接口。
- CGLIB 靠继承子类。
- CGLIB 不能代理 final 类 / final 方法。
- private 方法也不能正常被代理增强。

保命句：

> JDK 动态代理靠接口，CGLIB 靠继承子类；有接口优先 JDK，没有接口用 CGLIB。

---

### 3. Spring 事务为什么会失效？说 5 个常见原因。

我的回答：

> 类的内部方法调用，私有，被 catch 住，异常类型不对，自己创建的 bean。

评分：8.5 / 10

修正版：

> Spring 事务失效常见原因有：同一个类内部方法调用，本质是 this.xxx()，没有经过代理对象；方法不是 public，比如 private 方法；异常被 catch 后没有继续抛出；异常类型不符合回滚规则，默认只回滚 RuntimeException 和 Error；对象不是 Spring 容器管理的 Bean，比如自己 new 出来的对象。

保命句：

> Spring 事务底层依赖 AOP 代理，所以没走代理、方法不符合代理条件、异常没抛出去、异常类型不匹配、对象不归 Spring 管，事务都可能失效。

---

### 4. BeanFactory 和 ApplicationContext 有什么区别？

我的回答：

> 不知道。

评分：0 / 10

正确答案：

> BeanFactory 是 Spring 最基础的 IOC 容器，主要负责 Bean 的创建和管理。ApplicationContext 是 BeanFactory 的子接口，在 BeanFactory 基础上增强了很多企业级功能，比如国际化、事件发布、资源加载、AOP 自动代理、注解支持等。BeanFactory 默认懒加载，用到 Bean 时才创建；ApplicationContext 默认启动时创建单例 Bean。实际项目中一般使用 ApplicationContext。

保命句：

> BeanFactory 是基础容器，ApplicationContext 是更完整、更常用的高级容器。

Day48 必回炉。

---

### 5. Spring Bean 的作用域有哪些？默认是什么？

我的回答：

> 忘记了。

评分：0 / 10

正确答案：

> Spring Bean 默认作用域是 singleton，也就是单例，整个 Spring 容器中只有一个 Bean 实例。常见作用域还有 prototype，每次获取都会创建新对象；request 表示一次 HTTP 请求一个 Bean；session 表示一次会话一个 Bean；application 表示一个 Web 应用一个 Bean。

保命句：

> 默认 singleton，常见还有 prototype、request、session、application。

Day48 必回炉。

---

### 6. @Autowired 和 @Resource 有什么区别？

我的回答：

> Autowired 是类型匹配，如果类型相同可以用 Quality，Resource 是接口名称匹配。

评分：7.5 / 10

问题点：

- `Quality` 拼写错误，正确是 `@Qualifier`。
- `@Resource` 不是接口名称匹配，而是默认按名称注入，找不到再按类型匹配。

修正版：

> @Autowired 是 Spring 提供的注解，默认按类型注入。如果同一个类型有多个 Bean，可以配合 @Qualifier 指定 Bean 名称。@Resource 是 Java / Jakarta 提供的注解，默认按名称注入，如果找不到对应名称，再按类型匹配。

保命句：

> Autowired 默认按类型，多个同类型用 Qualifier；Resource 默认按名称，找不到再按类型。

---

### 7. Spring Bean 的生命周期大概有哪些步骤？

我的回答：

> 创建，注入，使用，销毁。

评分：5 / 10

问题点：

- 漏了初始化。
- 没说 BeanPostProcessor 等扩展点。

修正版：

> Spring Bean 的生命周期大致是：实例化 Bean → 属性注入 → 初始化 → 使用 → 销毁。如果说完整一点，Spring 先根据 BeanDefinition 创建 Bean 对象，然后进行属性注入，再执行 Aware 接口、BeanPostProcessor 前置处理、初始化方法、BeanPostProcessor 后置处理，最后 Bean 可以被使用，容器关闭时执行销毁方法。

保命句：

> Bean 生命周期就是：实例化、属性注入、初始化、使用、销毁。

Day48 必回炉。

---

### 8. @PostConstruct 和 @PreDestroy 分别是什么时候执行？

我的回答：

> PostConstruct 是创建 Bean 的时候，PreDestroy 是销毁的时候。

评分：6 / 10

修正版：

> @PostConstruct 是在 Bean 创建并完成依赖注入之后执行，属于初始化回调。@PreDestroy 是在 Bean 被销毁之前执行，属于销毁前回调。

保命句：

> PostConstruct 在属性注入完成后、Bean 正式使用前执行；PreDestroy 在容器关闭、Bean 销毁前执行。

Day48 必回炉。

---

### 9. Spring Boot 的 @SpringBootApplication 包含哪几个核心注解？分别有什么作用？

我的回答：

> autoEnableConfiguration 自动配置，springbootConfiguration 配置类，CompontScan 组件扫描。

评分：7 / 10

问题点：注解名称拼写不稳。

正确拼写：

```java
@SpringBootConfiguration
@EnableAutoConfiguration
@ComponentScan
```

修正版：

> @SpringBootApplication 主要包含三个核心注解：@SpringBootConfiguration 表示当前类是 Spring Boot 配置类，本质上也是 @Configuration；@EnableAutoConfiguration 开启 Spring Boot 自动配置，根据依赖、配置和 classpath 环境自动创建需要的 Bean；@ComponentScan 开启组件扫描，默认扫描启动类所在包及其子包。

保命句：

> @SpringBootApplication = 配置类 + 自动配置 + 组件扫描。

Day48 必回炉。

---

### 10. Spring Boot 自动配置原理是什么？为什么引入 starter 后很多东西就能自动生效？

我的回答：

> 自动配置是去配置类和子类去加载相关的依赖，starter 是各种组件的集合，引入后会自动加载这些组件。

评分：6.5 / 10

问题点：

- 自动配置不是“加载子类”。
- starter 主要是依赖集合，真正创建 Bean 的是自动配置类。

修正版：

> Spring Boot 自动配置是通过 @EnableAutoConfiguration 开启的。它会加载一批自动配置类，这些配置类会根据当前项目引入的依赖、配置文件以及 classpath 环境，通过 @Conditional 系列条件判断，决定是否创建对应的 Bean。starter 本质上是一组依赖集合。引入 starter 后，相关依赖进入 classpath，自动配置类检测到条件满足，就会自动创建对应 Bean。

保命句：

> starter 负责把依赖带进来，自动配置负责根据条件创建 Bean。

Day48 必回炉。

---

## 二、新题

### 1. 什么是 BeanPostProcessor？它在 Bean 生命周期里起什么作用？

我的回答：

> 不知道。

评分：0 / 10

正确答案：

> BeanPostProcessor 是 Spring 提供的 Bean 后置处理器，用来在 Bean 初始化前后做扩展处理。它主要有两个方法：postProcessBeforeInitialization() 和 postProcessAfterInitialization()。Spring AOP 代理对象的生成也和 BeanPostProcessor 有关，很多时候会在 Bean 初始化后把原始 Bean 包装成代理对象。

生命周期位置：

> 实例化 → 属性注入 → postProcessBeforeInitialization → 初始化方法 → postProcessAfterInitialization → 使用

保命句：

> BeanPostProcessor 是 Bean 初始化前后的扩展点，AOP 代理很多就是靠它在初始化后生成的。

Day48 必回炉。

---

### 2. Spring 为什么能解决单例 Bean 的循环依赖？大概靠什么机制？

我的回答：

> 通过三级缓存，暴露其中的一个 bean，这样就可以创建 Bean，从而拿到这个 bean。

评分：7 / 10

修正版：

> Spring 解决单例 Bean 的循环依赖，主要依赖三级缓存。当 A 创建过程中需要 B，B 创建过程中又需要 A 时，Spring 会在 A 实例化后、属性注入前，把 A 的早期引用提前暴露到缓存中。这样 B 注入 A 时，就可以先拿到 A 的早期引用，B 创建完成后，再回到 A 继续完成属性注入和初始化。

保命句：

> Spring 通过三级缓存提前暴露单例 Bean 的早期引用，所以 setter 注入的循环依赖可以解决。

Day48 必回炉。

---

### 3. 为什么构造器注入的循环依赖 Spring 解决不了？

我的回答：

> 因为构造器注入时，Bean 还没实例化出来，没法提前暴露引用。

评分：10 / 10

修正版：

> 构造器注入时，Bean 还没有实例化完成，Spring 没法提前暴露早期引用，所以构造器循环依赖解决不了。Spring 解决循环依赖的前提是对象已经实例化出来了，只是属性还没注入完成。

保命句：

> setter 注入可以先创建对象再注入属性，所以能提前暴露；构造器注入必须先拿到依赖才能创建对象，所以解决不了循环依赖。

---

## 三、追问

### 追问 1：为什么 Spring 事务依赖 AOP 代理？

我的回答：

> Spring 事务是典型的 AOP，通过对象代理完成开启、提交和回滚。

评分：8 / 10

修正版：

> Spring 事务依赖 AOP 代理，是因为事务本质上属于横切逻辑。Spring 会为目标 Bean 创建代理对象，方法调用经过代理时，事务拦截器会在方法执行前开启事务，方法正常结束就提交，方法抛出符合规则的异常就回滚。

保命句：

> 事务是横切逻辑，Spring 通过 AOP 代理拦截方法，在方法前开启事务，方法后提交或回滚。

---

### 追问 2：为什么同一个类内部方法调用，事务会失效？

我的回答：

> 内部方法的调用是 this.xxx，没有经过 Spring 的代理对象，所以事务不会执行。

评分：10 / 10

修正版：

> Spring 事务是基于 AOP 代理实现的。只有外部调用经过代理对象时，事务拦截器才有机会增强方法。同一个类内部方法调用，本质是 this.xxx()，直接调用目标对象方法，没有经过代理对象，所以 @Transactional 不会生效。

保命句：

> 同一个类内部方法调用，本质是 this.xxx()，没有经过 Spring 代理对象，所以事务增强不会执行。

---

## 四、Day48 必回炉清单

1. BeanFactory 和 ApplicationContext 区别
2. Spring Bean 作用域
3. Bean 生命周期完整流程
4. BeanPostProcessor 是什么
5. @PostConstruct 执行时机
6. @SpringBootApplication 三个核心注解拼写
7. Spring Boot 自动配置原理
8. 三级缓存分别放什么
9. 为什么 setter 循环依赖能解决，构造器不能解决

---

## 五、Day47 背诵清单

1. AOP 是把日志、事务、权限等公共逻辑抽出来，通过代理在方法前后增强。
2. JDK 动态代理靠接口，CGLIB 靠继承子类。
3. 事务失效常见原因：没走代理、private、异常被 catch、异常类型不匹配、对象不是 Spring Bean。
4. BeanFactory 是基础容器，ApplicationContext 是高级容器。
5. Bean 默认作用域是 singleton，常见还有 prototype、request、session、application。
6. Autowired 默认按类型，多个同类型用 Qualifier；Resource 默认按名称。
7. Bean 生命周期：实例化、属性注入、初始化、使用、销毁。
8. PostConstruct 在属性注入完成后、Bean 使用前执行；PreDestroy 在销毁前执行。
9. SpringBootApplication = SpringBootConfiguration + EnableAutoConfiguration + ComponentScan。
10. starter 负责引入依赖，自动配置负责根据条件创建 Bean。
11. BeanPostProcessor 是 Bean 初始化前后的扩展点，AOP 代理很多就是靠它生成的。
12. Spring 通过三级缓存提前暴露单例 Bean 的早期引用，解决 setter 循环依赖。

---

## 六、全覆盖台账更新

已覆盖：

- Spring AOP 基础
- JDK 动态代理 / CGLIB
- Spring 事务失效
- BeanFactory / ApplicationContext
- Bean 作用域
- @Autowired / @Resource
- Bean 生命周期简版
- @PostConstruct / @PreDestroy
- @SpringBootApplication
- Spring Boot 自动配置基础
- BeanPostProcessor 入门
- 循环依赖三级缓存入门
- 构造器循环依赖为什么解决不了

仍需继续覆盖：

- 三级缓存一级 / 二级 / 三级分别放什么
- AOP 执行链与多切面顺序
- Spring Boot 自动配置源码级流程
- Spring Boot 启动流程
- Spring MVC 完整请求链路
- MyBatis 执行链、缓存与插件机制
