# Day 34 - Spring Boot 配置 / 跨域 / 组件注解 / MyBatis Mapper

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. Spring Bean 初始化阶段一般可以用哪些方式做初始化逻辑？

**保命句：**

Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。

**问题记录：**

- `InitializingBean` 拼写不稳。
- 记法：`Initial + izing + Bean`。

> Day 35 必回炉。

### 2. Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**保命句：**

Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。

**问题记录：**

- 容易把 `Destroy` 写成 `Destory`。
- 容易把 `DisposableBean` 写错。

> Day 35 必回炉。

### 3. Spring Boot 项目启动流程大概是什么？

**保命句：**

`SpringApplication.run()` 创建容器，加载配置和自动配置，扫描 Bean，最后启动内嵌 Tomcat。

**完整说法：**

Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，初始化 Bean，最后启动内嵌 Tomcat。

**问题记录：**

- 第一次漏了“启动内嵌 Tomcat”。

> Day 35 轻回炉。

### 4. Spring MVC 里的 `Interceptor` 一般可以用来做什么？有哪些常见方法？

**保命句：**

Interceptor 做登录、权限、日志，方法是 `preHandle`、`postHandle`、`afterCompletion`。

**完整说法：**

Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。

**问题记录：**

- 容易把 `preHandle` 说成 `preHandler`。
- 容易漏 `afterCompletion`。

> Day 35 必回炉。

### 5. `@Valid` 和 `@Validated` 有什么区别？

**保命句：**

`@Valid` 是普通参数校验，`@Validated` 是 Spring 的增强版，可以支持分组校验。

**小修正：**

`@Validated` 不说是 “Valid 的增强”，更准确说是 Spring 提供的增强版校验注解。

### 6. `@NotNull`、`@NotEmpty`、`@NotBlank` 有什么区别？

**保命句：**

`@NotNull` 不能为 null，`@NotEmpty` 不能为空，`@NotBlank` 不能是空白字符串。

**完整说法：**

`@NotNull` 表示不能为 null；`@NotEmpty` 表示不能为 null，也不能为空；`@NotBlank` 表示不能为 null、不能为空，也不能全是空格，通常用于字符串校验。

> Day 35 轻回炉。

### 7. `@SpringBootApplication` 主要由哪几个核心注解组成？分别有什么作用？

**保命句：**

`@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。

**问题记录：**

- `ComponentScan` 拼写不稳。

> Day 35 轻回炉。

### 8. Spring Boot 多环境配置怎么做？用哪个配置项指定当前环境？

**保命句：**

多环境配置用 `application-dev.yml`，通过 `spring.profiles.active` 指定当前环境。

**完整说法：**

多环境配置用 `application-dev.yml`、`application-prod.yml` 区分不同环境，再通过 `spring.profiles.active` 指定当前使用哪个环境。

**问题记录：**

- 不能说 `springApplication-dev.yml`。
- 不能说 `springProfiles.active`。

> Day 35 必回炉。

### 9. 参数校验失败后，项目里一般怎么统一返回错误信息？用什么机制处理？

**保命句：**

参数校验失败后，用 `@RestControllerAdvice` + `@ExceptionHandler` 统一处理，再封装成 `Result<T>` 返回 code 和 message。

**完整说法：**

参数校验失败后，可以用 `@RestControllerAdvice` 配合 `@ExceptionHandler` 捕获参数校验异常，然后把错误信息封装成统一的 `Result<T>`，返回 code、message、data。

**问题记录：**

- `Result<T>` 拼写要注意。
- `@RestControllerAdvice` 和 `@ExceptionHandler` 要带注解符号。

> Day 35 轻回炉。

### 10. MyBatis 模糊查询 `like` 怎么写？为什么不建议用 `${}`？

**保命句：**

MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。

## 新题

### 1. 什么是跨域？Spring MVC / Spring Boot 里一般怎么解决跨域问题？

**保命句：**

跨域是前后端协议、域名或端口不一致导致的，Spring Boot 可以用 `@CrossOrigin` 或全局 CORS 配置解决。

**完整说法：**

跨域是浏览器的同源策略限制，如果前端和后端的协议、域名或端口不一致，就会产生跨域问题。Spring Boot 里可以用 `@CrossOrigin` 解决单个接口跨域，也可以通过全局 CORS 配置统一处理。

> Day 35 必回炉：第一次不知道。

### 2. Spring Boot 里读取配置文件的值，一般有哪些方式？

**保命句：**

读取配置可以用 `@Value` 读取单个值，也可以用 `@ConfigurationProperties` 批量绑定配置对象。

**完整说法：**

Spring Boot 读取配置文件常见方式有两种：一种是用 `@Value` 读取单个配置项，另一种是用 `@ConfigurationProperties` 把一组配置批量绑定到 Java 对象中。配置少可以用 `@Value`，配置多时更推荐 `@ConfigurationProperties`。

> Day 35 必回炉：第一次不知道。

### 3. `@Value` 和 `@ConfigurationProperties` 适合什么场景？有什么区别？

**保命句：**

`@Value` 适合读取单个配置项，`@ConfigurationProperties` 适合把一组配置批量绑定成 Java 对象。

**完整说法：**

`@Value` 适合配置少、读取单个值；`@ConfigurationProperties` 适合配置多、批量绑定一组配置到对象里。配置多时更推荐后者。

### 4. `@Component`、`@Service`、`@Repository`、`@Controller` 有什么区别？分别一般用在哪一层？

**保命句：**

`@Component` 是通用组件，`@Controller` 控制层，`@Service` 业务层，`@Repository` 持久层，本质上都会被 Spring 扫描成 Bean。

**完整说法：**

它们本质上都是 Spring 组件注解，都会把类交给 Spring 容器管理。`@Component` 是通用组件注解，`@Controller` 用在控制层，`@Service` 用在业务层，`@Repository` 用在持久层。

**小修正：**

- `@Controller` 不要说“画面类”，更标准说“控制层，接收请求，返回页面或数据”。
- `@Repository` 不要说“DB 类”，更标准说“持久层 / DAO 层”。

> Day 35 轻回炉。

## 追问

### 1. 既然它们本质上都会被 Spring 扫描成 Bean，为什么项目里还要区分这些注解？

**保命句：**

区分这些注解主要是为了让代码分层更清晰，职责更明确，便于维护。

**完整说法：**

虽然这些注解本质上都会注册成 Bean，但区分使用可以让代码分层更清晰，职责更明确，也方便后续维护和管理。

### 2. `@Controller` 和 `@RestController` 有什么区别？

**保命句：**

`@RestController` = `@Controller` + `@ResponseBody`，一般返回 JSON 数据。

**完整说法：**

`@Controller` 一般返回页面，`@RestController` 一般返回 JSON 数据，`@RestController` 等价于 `@Controller` 加 `@ResponseBody`。

### 3. `@Repository` 和 MyBatis 的 `@Mapper` 有什么区别？实际项目里 Mapper 接口一般用哪个？

**保命句：**

`@Repository` 是 Spring 的持久层注解，`@Mapper` 是 MyBatis 的 Mapper 接口注解，实际项目一般用 `@Mapper` 或 `@MapperScan`。

**完整说法：**

`@Repository` 是 Spring 的持久层组件注解，主要表示 DAO 层 Bean。`@Mapper` 是 MyBatis 的注解，用来标识 Mapper 接口，让 MyBatis 为接口生成代理对象。实际项目里 Mapper 接口一般用 `@Mapper`，或者通过 `@MapperScan` 批量扫描。

> Day 35 必回炉：第一次不知道。

## Day 35 回炉

### 必回炉

1. `InitializingBean` 拼写
2. Bean 销毁三个写法：`@PreDestroy`、`DisposableBean`、`destroy-method`
3. Interceptor 三个方法：`preHandle`、`postHandle`、`afterCompletion`
4. 多环境配置：`application-dev.yml`、`spring.profiles.active`
5. 跨域处理：`@CrossOrigin`、全局 CORS 配置
6. 读取配置：`@Value`、`@ConfigurationProperties`
7. `@Repository` 和 `@Mapper` 区别

### 轻回炉

1. Spring Boot 启动流程：补“启动内嵌 Tomcat”
2. `@NotNull`、`@NotEmpty`、`@NotBlank`
3. `@SpringBootApplication` 三个核心注解
4. 参数校验失败统一异常处理
5. `@RequestBody` 和 `@ResponseBody`
6. `@Component`、`@Controller`、`@Service`、`@Repository`
7. `@Controller` 和 `@RestController`

## Day 34 背诵清单

1. Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。
2. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
3. `SpringApplication.run()` 创建容器，加载配置和自动配置，扫描 Bean，最后启动内嵌 Tomcat。
4. Interceptor 做登录、权限、日志，方法是 `preHandle`、`postHandle`、`afterCompletion`。
5. `@Valid` 是普通参数校验，`@Validated` 是 Spring 的增强版，可以支持分组校验。
6. `@NotNull` 不能为 null，`@NotEmpty` 不能为空，`@NotBlank` 不能是空白字符串。
7. `@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成。
8. 多环境配置用 `application-dev.yml`，通过 `spring.profiles.active` 指定当前环境。
9. 参数校验失败后，用 `@RestControllerAdvice` + `@ExceptionHandler` 统一处理，再封装成 `Result<T>` 返回 code 和 message。
10. MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。
11. 跨域是前后端协议、域名或端口不一致导致的，Spring Boot 可以用 `@CrossOrigin` 或全局 CORS 配置解决。
12. 读取配置可以用 `@Value` 读取单个值，也可以用 `@ConfigurationProperties` 批量绑定配置对象。
13. `@Value` 适合读取单个配置项，`@ConfigurationProperties` 适合把一组配置批量绑定成 Java 对象。
14. `@Component` 是通用组件，`@Controller` 控制层，`@Service` 业务层，`@Repository` 持久层，本质上都会被 Spring 扫描成 Bean。
15. `@RestController` = `@Controller` + `@ResponseBody`，一般返回 JSON 数据。
16. `@Repository` 是 Spring 的持久层注解，`@Mapper` 是 MyBatis 的 Mapper 接口注解，实际项目一般用 `@Mapper` 或 `@MapperScan`。
