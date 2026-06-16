# Day 32 - Spring MVC 流程 / Filter 与 Interceptor / 统一异常处理

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. Spring Bean 初始化阶段一般可以用哪些方式做初始化逻辑？

**保命句：**

Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。

> Day 33 必回炉：仍然容易忘，且拼写不稳。

### 2. Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**保命句：**

Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。

> Day 33 必回炉：`destroy` 容易写成 `destory`。

### 3. MyBatis 模糊查询 like 怎么写？为什么不建议用 `${}`？

**保命句：**

MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。

### 4. Spring Boot 项目启动流程大概是什么？

**保命句：**

Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，启动内嵌 Tomcat。

> Day 33 必回炉：第一次忘记。

### 5. `@SpringBootApplication` 主要由哪几个核心注解组成？

**保命句：**

`@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。

> Day 33 轻回炉：注解拼写不稳。

### 6. Spring Boot 多环境配置怎么做？

**保命句：**

多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。

> Day 33 轻回炉：文件名和 `spring.profiles.active` 需要说准。

### 7. `@Autowired` 是什么作用？它属于 IOC 还是 DI？

**保命句：**

`@Autowired` 用来注入依赖对象，属于 DI。

**补充：**

`@Autowired` 可以用于字段注入、构造方法注入、setter 方法注入。

### 8. `@RestController` 和 `@Controller` 有什么区别？

**保命句：**

`@RestController` = `@Controller` + `@ResponseBody`，默认返回 JSON；`@Controller` 一般返回页面。

> Day 33 轻回炉：`@ResponseBody` 拼写。

### 9. `@RequestParam`、`@PathVariable`、`@RequestBody` 有什么区别？

**保命句：**

`@RequestParam` 接收查询参数，`@PathVariable` 接收路径变量，`@RequestBody` 接收请求体 JSON。

### 10. `@RequestMapping`、`@GetMapping`、`@PostMapping` 有什么区别？

**保命句：**

`@RequestMapping` 是通用映射，`@GetMapping` 处理 GET 请求，`@PostMapping` 处理 POST 请求。

## 新题

### 1. Spring MVC 的请求执行流程大概是什么？

**保命句：**

请求先到 `DispatcherServlet`，再找到 Controller，Controller 调 Service，Service 调 Mapper，最后把结果以 JSON 返回。

**稍完整说法：**

浏览器请求先进入 `DispatcherServlet`，`DispatcherServlet` 根据请求路径找到对应的 Controller 方法，然后调用 Controller。Controller 接收参数后调用 Service 处理业务，Service 调 Mapper，Mapper 通过 MyBatis 执行 SQL。最后结果返回给 Controller，如果是接口请求，就通过 JSON 返回给前端。

### 2. `Filter` 和 `Interceptor` 有什么区别？

**保命句：**

Filter 在 `DispatcherServlet` 之前执行，Interceptor 在 Controller 前后执行。

**完整说法：**

`Filter` 是 Servlet 规范里的过滤器，在请求进入 `DispatcherServlet` 之前执行。`Interceptor` 是 Spring MVC 的拦截器，在请求进入 Controller 前后执行。Filter 更偏底层通用处理，Interceptor 更适合做和 Spring MVC 相关的登录校验、权限校验、日志等。

### 3. Spring MVC 里统一异常处理一般怎么做？用什么注解？

**保命句：**

统一异常处理用 `@RestControllerAdvice` + `@ExceptionHandler`，把异常统一封装成 code 和 message 返回。

**完整说法：**

Spring MVC 统一异常处理一般用 `@RestControllerAdvice` 配合 `@ExceptionHandler`。在异常处理方法里捕获指定异常，然后统一返回 code、message、data 这种结果格式。

> Day 33 必回炉：第一次注解说错。

### 4. Spring MVC 里拦截器 `Interceptor` 一般可以用来做什么？有哪些常见方法？

**保命句：**

Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。

**完整说法：**

Spring MVC 拦截器一般用于登录校验、权限校验、日志记录、接口耗时统计等。常见方法有 `preHandle`、`postHandle`、`afterCompletion`，其中 `preHandle` 在 Controller 执行前调用，常用来做登录和权限校验。

> Day 33 必回炉：第一次不会。

## 追问

### 1. `preHandle` 方法返回 `true` 和 `false` 分别代表什么？

**保命句：**

`preHandle` 返回 `true` 放行，返回 `false` 拦截，不再进入 Controller。

> Day 33 必回炉：第一次不会。

### 2. `Filter` 和 `Interceptor` 如果都配置了，请求会先经过哪个？为什么？

**保命句：**

Filter 先执行，Interceptor 后执行；Filter 在 `DispatcherServlet` 之前，Interceptor 在 Controller 前后。

### 3. 为什么项目里一般要做统一异常处理，而不是每个 Controller 方法里都写 try-catch？

**保命句：**

统一异常处理可以统一返回 code 和 message，减少重复 try-catch，让业务代码更清晰。

## Day 33 回炉

### 必回炉

1. Bean 初始化方式：`@PostConstruct`、`InitializingBean`、`init-method`
2. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`
3. Spring Boot 启动流程：`SpringApplication.run()` → 创建容器 → 加载配置和自动配置 → 扫描 Bean → 启动内嵌 Tomcat
4. 统一异常处理：`@RestControllerAdvice` + `@ExceptionHandler`
5. Interceptor 常见方法：`preHandle`、`postHandle`、`afterCompletion`
6. `preHandle` 返回值：`true` 放行，`false` 拦截

### 轻回炉

1. MyBatis 模糊查询 `like concat('%', #{param}, '%')`
2. `@SpringBootApplication` 三个注解拼写
3. 多环境配置：`application-dev.yml` + `spring.profiles.active`
4. `@ResponseBody` 拼写
5. `@RequestBody` 用法
6. `Filter` 和 `Interceptor` 区别

## Day 32 背诵清单

1. Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。
2. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
3. MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。
4. Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，启动内嵌 Tomcat。
5. `@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。
6. 多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。
7. `@Autowired` 用来注入依赖对象，属于 DI。
8. `@RestController` = `@Controller` + `@ResponseBody`，默认返回 JSON；`@Controller` 一般返回页面。
9. `@RequestParam` 接收查询参数，`@PathVariable` 接收路径变量，`@RequestBody` 接收请求体 JSON。
10. `@RequestMapping` 是通用映射，`@GetMapping` 处理 GET 请求，`@PostMapping` 处理 POST 请求。
11. 请求先到 `DispatcherServlet`，再找到 Controller，Controller 调 Service，Service 调 Mapper，最后把结果以 JSON 返回。
12. Filter 在 `DispatcherServlet` 之前执行，Interceptor 在 Controller 前后执行。
13. 统一异常处理用 `@RestControllerAdvice` + `@ExceptionHandler`，把异常统一封装成 code 和 message 返回。
14. Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。
15. `preHandle` 返回 `true` 放行，返回 `false` 拦截，不再进入 Controller。
16. 统一异常处理可以统一返回 code 和 message，减少重复 try-catch，让业务代码更清晰。
