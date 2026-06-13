# Day 30 - Spring Boot 自动配置 / Starter / 配置文件

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. MyBatis 模糊查询 like 怎么写？

**保命句：**

模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。

> Day 31 轻抽：需要一次写出标准版本。

### 2. Spring 事务和 AOP 是什么关系？

**保命句：**

Spring 事务是基于 AOP 代理实现的，方法前开启事务，成功提交，异常回滚。

### 3. Spring Bean 初始化阶段有哪些方式？

**保命句：**

Bean 初始化可以用 `@PostConstruct`，也可以实现 `InitializingBean`，或者配置 `init-method`。

> Day 31 必回炉：第一次忘记。

### 4. Spring Bean 销毁阶段有哪些方式？

**保命句：**

Bean 销毁可以用 `@PreDestroy`，也可以实现 `DisposableBean`，或者配置 `destroy-method`。

> Day 31 必回炉：第一次忘记，第二次拼写不稳。

### 5. rollbackFor = Exception.class 是解决什么问题？

**保命句：**

`rollbackFor = Exception.class` 是为了解决普通 Exception 默认不回滚的问题。

### 6. 为什么同类内部调用事务会失效？

**保命句：**

同类内部调用事务会失效，是因为 `this.xxx()` 调用没有经过 Spring 代理对象，而事务是基于 AOP 代理实现的。

### 7. Spring 事务在什么情况下会失效？

**保命句：**

Spring 事务失效主要是：没走代理、方法不是 public、异常被 catch、普通 Exception 没配 rollbackFor、对象不是 Spring Bean。

### 8. Spring AOP 底层怎么实现？JDK 动态代理和 CGLIB 有什么区别？

**保命句：**

Spring AOP 是动态代理，有接口用 JDK 动态代理，没有接口用 CGLIB。

**补充：**

JDK 动态代理是基于接口生成代理对象；CGLIB 是通过生成目标类的子类来实现代理。

### 9. Spring Bean 生命周期大概是什么？

**保命句：**

Spring Bean 生命周期：创建对象 → 注入依赖 → 初始化 → 使用 → 销毁。

### 10. IOC 和 DI 分别是什么？

**保命句：**

IOC 管对象，DI 管注入；IOC 把对象交给 Spring 管理，DI 把依赖对象注入进来。

## 新题

### 1. Spring Boot 自动配置是什么？大概原理是什么？

**保命句：**

自动配置就是 Spring Boot 根据依赖、配置和 classpath 环境，自动帮我们创建 Bean，核心是 `@EnableAutoConfiguration` 和条件判断。

**面试版：**

Spring Boot 自动配置是指 Spring Boot 根据项目引入的依赖、配置文件以及 classpath 环境，自动判断并创建需要的 Bean。它主要由 `@EnableAutoConfiguration` 开启，底层会加载自动配置类，再通过条件注解判断当前环境是否满足条件，满足就创建对应 Bean。

> Day 31 轻抽：`@EnableAutoConfiguration` 拼写。

### 2. @SpringBootApplication 由哪几个核心注解组成？

**保命句：**

`@SpringBootApplication` = 配置类 + 自动配置 + 组件扫描。

**完整说法：**

`@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成。`@SpringBootConfiguration` 表示当前类是配置类，`@EnableAutoConfiguration` 开启自动配置，`@ComponentScan` 负责扫描当前包及子包下的组件。

> Day 31 轻抽：三个注解名字。

### 3. Spring Boot Starter 是什么？有什么作用？

**保命句：**

Starter 是一组依赖集合，用来简化依赖引入，配合自动配置快速搭建功能。

**例子：**

`spring-boot-starter-web` 会引入 Spring MVC、内嵌 Tomcat、JSON 转换等 Web 开发相关依赖。

### 4. Spring Boot 为什么可以不用外部 Tomcat，也能直接启动 Web 项目？

**保命句：**

Spring Boot 内嵌 Tomcat，引入 Web Starter 后可以打成 jar 包，直接用 `java -jar` 启动 Web 项目。

**面试版：**

Spring Boot Web 项目默认内嵌 Tomcat。引入 `spring-boot-starter-web` 后，会带上内嵌 Tomcat 相关依赖。启动时 Spring Boot 会自动启动内嵌 Tomcat，并把 Web 应用部署进去，所以不需要单独安装外部 Tomcat。

## 追问

### 1. spring-boot-starter-web 一般会带来哪些东西？

**保命句：**

Web Starter 会带来 Spring MVC、内嵌 Tomcat、JSON 转换等 Web 开发常用依赖。

### 2. application.properties 和 application.yml 有什么区别？

**保命句：**

properties 是 key-value，yml 是层级结构；功能类似，yml 更清晰但要注意缩进。

### 3. Spring Boot 多环境配置怎么做？

**保命句：**

多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。

## Day 31 回炉

### 必回炉

1. Bean 初始化方式：`@PostConstruct`、`InitializingBean`、`init-method`
2. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`

### 轻回炉

1. 模糊查询 `like` 标准写法
2. `@EnableAutoConfiguration` 拼写
3. `@SpringBootApplication` 三个核心注解
4. 多环境配置：`application-dev.yml` + `spring.profiles.active`
5. `@Autowired` 拼写

## Day 30 背诵清单

1. 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。
2. Spring 事务是基于 AOP 代理实现的，方法前开启事务，成功提交，异常回滚。
3. Bean 初始化可以用 `@PostConstruct`，也可以实现 `InitializingBean`，或者配置 `init-method`。
4. Bean 销毁可以用 `@PreDestroy`，也可以实现 `DisposableBean`，或者配置 `destroy-method`。
5. `rollbackFor = Exception.class` 是为了解决普通 Exception 默认不回滚的问题。
6. 同类内部调用事务会失效，是因为 `this.xxx()` 调用没有经过 Spring 代理对象。
7. Spring 事务失效主要是：没走代理、方法不是 public、异常被 catch、普通 Exception 没配 rollbackFor、对象不是 Spring Bean。
8. Spring AOP 是动态代理，有接口用 JDK 动态代理，没有接口用 CGLIB。
9. Spring Bean 生命周期：创建对象 → 注入依赖 → 初始化 → 使用 → 销毁。
10. IOC 管对象，DI 管注入；IOC 把对象交给 Spring 管理，DI 把依赖对象注入进来。
11. 自动配置就是 Spring Boot 根据依赖、配置和 classpath 环境，自动帮我们创建 Bean，核心是 `@EnableAutoConfiguration` 和条件判断。
12. `@SpringBootApplication` = `@SpringBootConfiguration` + `@EnableAutoConfiguration` + `@ComponentScan`。
13. Starter 是一组依赖集合，用来简化依赖引入，配合自动配置快速搭建功能。
14. Spring Boot 内嵌 Tomcat，引入 Web Starter 后可以打成 jar 包，直接用 `java -jar` 启动 Web 项目。
15. properties 是 key-value，yml 是层级结构；功能类似，yml 更清晰但要注意缩进。
16. 多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。
