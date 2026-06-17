# Day 33 - 参数校验 / RequestBody 与 ResponseBody / 回炉

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. Spring Bean 初始化阶段一般可以用哪些方式做初始化逻辑？

**保命句：**

Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。

> Day 34 必回炉：第一次仍然拼写不稳。

### 2. Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**保命句：**

Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。

> Day 34 必回炉：`destroy` 仍然容易写成 `destory`。

### 3. Spring Boot 项目启动流程大概是什么？

**保命句：**

Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，启动内嵌 Tomcat。

> Day 34 必回炉：第一次漏了加载配置、自动配置和内嵌 Tomcat。

### 4. Spring MVC 里统一异常处理一般怎么做？用什么注解？

**保命句：**

统一异常处理用 `@RestControllerAdvice` + `@ExceptionHandler`，把异常统一封装成 code 和 message 返回。

### 5. Spring MVC 里的 `Interceptor` 一般可以用来做什么？有哪些常见方法？

**保命句：**

Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。

> Day 34 必回炉：第一次方法名不完整。

### 6. `preHandle` 返回 `true` 和 `false` 分别代表什么？

**保命句：**

`preHandle` 返回 `true` 放行，返回 `false` 拦截，不再进入 Controller。

### 7. MyBatis 模糊查询 `like` 怎么写？为什么不建议用 `${}`？

**保命句：**

MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。

### 8. `@SpringBootApplication` 主要由哪几个核心注解组成？

**保命句：**

`@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。

### 9. Spring Boot 多环境配置怎么做？

**保命句：**

多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。

### 10. `Filter` 和 `Interceptor` 有什么区别？如果两个都配置了，谁先执行？

**保命句：**

Filter 先执行，Interceptor 后执行；Filter 在 `DispatcherServlet` 之前，Interceptor 在 Controller 前后。

## 新题

### 1. Spring MVC 中常见的参数校验怎么做？

**保命句：**

参数校验一般用 `@Valid` 或 `@Validated`，在 DTO 字段上加 `@NotNull`、`@NotBlank`、`@Size` 等注解。

**完整说法：**

Spring MVC 参数校验一般在 DTO 属性上加校验注解，比如 `@NotNull`、`@NotBlank`、`@Size`，然后在 Controller 入参前加 `@Valid` 或 `@Validated` 触发校验。如果校验失败，可以配合统一异常处理返回错误信息。

> Day 34 轻回炉：第一次把 `@Valid` 说成了 void。

### 2. `@Valid` 和 `@Validated` 有什么区别？

**保命句：**

`@Valid` 用于普通参数校验，`@Validated` 是 Spring 的增强版，支持分组校验。

**完整说法：**

`@Valid` 是 Java 标准的参数校验注解，常用于 Controller 入参校验。`@Validated` 是 Spring 提供的增强版，除了能做参数校验，还支持分组校验。

**例子：**

新增时不需要 id，修改时必须有 id，可以用 `@Validated(AddGroup.class)` 和 `@Validated(UpdateGroup.class)` 做分组校验。

> Day 34 必回炉：第一次不完整。

### 3. 参数校验失败后，项目里一般怎么统一返回错误信息？

**保命句：**

参数校验失败后，用 `@RestControllerAdvice` + `@ExceptionHandler` 统一处理，再封装成 `Result<T>` 返回 code 和 message。

**完整说法：**

参数校验失败后，一般通过统一异常处理来返回错误信息。可以用 `@RestControllerAdvice` 配合 `@ExceptionHandler` 捕获参数校验异常，然后把错误信息封装成统一的 `Result<T>`，返回 code、message、data。

> Day 34 轻回炉：第一次只说了 Result，没有说处理机制。

### 4. `@RequestBody` 和 `@ResponseBody` 分别是什么作用？有什么区别？

**保命句：**

`@RequestBody` 是接收请求体 JSON，`@ResponseBody` 是把返回对象转成 JSON 响应。

**完整说法：**

`@RequestBody` 用在方法参数上，用来接收请求体中的 JSON 数据，并转换成 Java 对象。`@ResponseBody` 用在方法或类上，用来把方法返回的 Java 对象写入响应体，通常转换成 JSON 返回给前端。

## 追问

### 1. `@RequestBody` 一般和什么请求方式一起用？为什么？

**保命句：**

`@RequestBody` 常和 POST、PUT 一起用，用来接收请求体里的 JSON 数据。

### 2. `@NotNull`、`@NotBlank`、`@NotEmpty` 有什么区别？

**保命句：**

`@NotNull` 不能为 null，`@NotEmpty` 不能为空，`@NotBlank` 不能是空白字符串。

**完整说法：**

`@NotNull` 表示不能为 null；`@NotEmpty` 表示不能为 null，也不能为空；`@NotBlank` 表示不能为 null、不能为空，也不能全是空格，通常用于字符串参数校验。

> Day 34 必回炉：第一次概念反了。

### 3. 参数校验失败后，为什么通常要交给统一异常处理，而不是直接在 Controller 里判断？

**保命句：**

统一异常处理可以统一返回错误信息，减少重复代码，让 Controller 更干净。

**完整说法：**

参数校验失败后交给统一异常处理，可以统一返回 code 和 message，减少 Controller 里的重复判断和 try-catch，让业务代码更清晰，也更容易维护。

## Day 34 回炉

### 必回炉

1. Bean 初始化方式：`@PostConstruct`、`InitializingBean`、`init-method`
2. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`
3. Spring Boot 启动流程：`SpringApplication.run()` → 创建容器 → 加载配置和自动配置 → 扫描 Bean → 启动内嵌 Tomcat
4. Interceptor 常见方法：`preHandle`、`postHandle`、`afterCompletion`
5. `@Valid` 和 `@Validated` 区别：`@Valid` 普通校验，`@Validated` 支持分组校验
6. `@NotNull`、`@NotEmpty`、`@NotBlank` 区别

### 轻回炉

1. Spring Bean 销毁的 `destroy` 拼写
2. `@SpringBootApplication` 三个核心注解
3. 多环境配置：`application-dev.yml` + `spring.profiles.active`
4. 参数校验失败后的统一异常处理
5. `@RequestBody` 和 `@ResponseBody` 区别
6. MyBatis 模糊查询 `like concat('%', #{param}, '%')`

## Day 33 背诵清单

1. Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。
2. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
3. Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，启动内嵌 Tomcat。
4. 统一异常处理用 `@RestControllerAdvice` + `@ExceptionHandler`，把异常统一封装成 code 和 message 返回。
5. Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。
6. `preHandle` 返回 `true` 放行，返回 `false` 拦截，不再进入 Controller。
7. MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。
8. `@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。
9. 多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。
10. 参数校验一般用 `@Valid` 或 `@Validated`，在 DTO 字段上加 `@NotNull`、`@NotBlank`、`@Size` 等注解。
11. `@Valid` 用于普通参数校验，`@Validated` 是 Spring 的增强版，支持分组校验。
12. 参数校验失败后，用 `@RestControllerAdvice` + `@ExceptionHandler` 统一处理，再封装成 `Result<T>` 返回 code 和 message。
13. `@RequestBody` 是接收请求体 JSON，`@ResponseBody` 是把返回对象转成 JSON 响应。
14. `@RequestBody` 常和 POST、PUT 一起用，用来接收请求体里的 JSON 数据。
15. `@NotNull` 不能为 null，`@NotEmpty` 不能为空，`@NotBlank` 不能是空白字符串。
16. 统一异常处理可以统一返回错误信息，减少重复代码，让 Controller 更干净。
