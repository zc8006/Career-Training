# Day 31 - Spring MVC 请求映射 / 参数接收 / Spring Boot 回炉

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. Spring Bean 初始化阶段一般可以用哪些方式做初始化逻辑？

**保命句：**

Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。

> Day 32 必回炉：第一次仍然忘记。

### 2. Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**保命句：**

Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。

> Day 32 必回炉：第一次仍然忘记。

### 3. MyBatis 模糊查询 like 怎么写？为什么不建议用 `${}`？

**保命句：**

MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。

> Day 32 必回炉：容易漏 `like`，也容易把 `concat` 写错。

### 4. `@EnableAutoConfiguration` 是什么作用？

**保命句：**

`@EnableAutoConfiguration` 开启自动配置，根据依赖、配置和条件判断自动创建 Bean。

### 5. `@SpringBootApplication` 主要由哪几个核心注解组成？

**保命句：**

`@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。

### 6. Spring Boot 多环境配置怎么做？

**保命句：**

多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。

### 7. IOC 和 DI 分别是什么？两者有什么关系？

**保命句：**

IOC 管对象，DI 管注入；IOC 把对象交给 Spring 管理，DI 把依赖对象注入进来。

### 8. `rollbackFor = Exception.class` 是解决什么问题？

**保命句：**

`rollbackFor = Exception.class` 是让普通 Exception 也触发事务回滚。

**补充：**

Spring 事务默认对 `RuntimeException` 和 `Error` 回滚，普通 `Exception` 需要配置 `rollbackFor` 才会回滚。

### 9. 为什么同一个类内部方法调用，`@Transactional` 可能会失效？

**保命句：**

同类内部方法调用本质是 `this.xxx()`，没有经过 Spring 代理对象，所以事务增强不会生效。

### 10. Spring Boot Starter 是什么？有什么作用？

**保命句：**

Starter 是一组依赖集合，用来简化依赖引入，配合自动配置快速搭建功能。

**例子：**

`spring-boot-starter-web` 会引入 Spring MVC、内嵌 Tomcat、JSON 转换等 Web 开发相关依赖。

## 新题

### 1. Spring Boot 项目启动流程大概是什么？

**保命句：**

Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，启动内嵌 Tomcat。

> Day 32 必回炉：新题第一次不知道。

### 2. `@Controller` 和 `@RestController` 有什么区别？

**保命句：**

`@RestController` = `@Controller` + `@ResponseBody`，默认返回 JSON；`@Controller` 一般返回页面。

**完整说法：**

`@Controller` 一般用于返回页面，如果要返回 JSON，需要在方法上加 `@ResponseBody`。`@RestController` 等于 `@Controller` + `@ResponseBody`，所以它的方法默认返回 JSON 数据。

### 3. `@RequestMapping`、`@GetMapping`、`@PostMapping` 有什么区别？

**保命句：**

`@RequestMapping` 是通用映射，`@GetMapping` 处理 GET 请求，`@PostMapping` 处理 POST 请求。

**完整说法：**

`@RequestMapping` 是通用请求映射注解，可以指定请求路径，也可以通过 `method` 指定 GET、POST 等请求方式。`@GetMapping` 是 `@RequestMapping(method = RequestMethod.GET)` 的简化写法，`@PostMapping` 是 POST 请求的简化写法。

### 4. `@RequestParam`、`@PathVariable`、`@RequestBody` 有什么区别？

**保命句：**

`@RequestParam` 接收查询参数，`@PathVariable` 接收路径变量，`@RequestBody` 接收请求体 JSON。

**完整说法：**

`@RequestParam` 用来接收 URL 后面的查询参数，比如 `?id=1`。`@PathVariable` 用来接收路径中的变量，比如 `/user/{id}`。`@RequestBody` 用来接收请求体里的 JSON 数据，常用于 POST 或 PUT 请求。

## 追问

### 1. `@RequestParam` 和 `@PathVariable` 分别适合什么场景？

**保命句：**

`@RequestParam` 适合查询条件，`@PathVariable` 适合资源 ID 这种路径变量。

**例子：**

```java
@GetMapping("/user")
public User getUser(@RequestParam Long id)
```

对应：

```text
/user?id=1
```

```java
@GetMapping("/user/{id}")
public User getUser(@PathVariable Long id)
```

对应：

```text
/user/1
```

### 2. GET 请求和 POST 请求有什么区别？

**保命句：**

GET 一般用于查询，参数放 URL；POST 一般用于提交数据，参数放 body。

### 3. 前端传 JSON 数据时，后端为什么通常用 `@RequestBody` 接收？

**保命句：**

前端传 JSON 时，数据在 body 里，后端用 `@RequestBody` 把 JSON 转成 Java 对象。

**补充：**

如果不用 `@RequestBody`，Spring 可能会按普通表单参数或 URL 参数去绑定，导致 JSON 数据接收不到。

## Day 32 回炉

### 必回炉

1. Bean 初始化方式：`@PostConstruct`、`InitializingBean`、`init-method`
2. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`
3. MyBatis 模糊查询：`like concat('%', #{param}, '%')`
4. Spring Boot 启动流程：`SpringApplication.run()` → 创建容器 → 加载配置和自动配置 → 扫描 Bean → 启动内嵌 Tomcat

### 轻回炉

1. `@SpringBootApplication` 三个核心注解
2. 多环境配置：`application-dev.yml` + `spring.profiles.active`
3. `@Autowired` 拼写
4. `@ResponseBody` 拼写
5. `@RequestBody` 用法

## Day 31 背诵清单

1. Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。
2. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
3. MyBatis 模糊查询用 `like concat('%', #{param}, '%')`，不要用 `${}`，因为 `${}` 是字符串拼接，有 SQL 注入风险。
4. `@EnableAutoConfiguration` 开启自动配置，根据依赖、配置和条件判断自动创建 Bean。
5. `@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。
6. 多环境配置用 `application-dev.yml`、`application-prod.yml`，再通过 `spring.profiles.active` 指定当前环境。
7. IOC 管对象，DI 管注入；IOC 把对象交给 Spring 管理，DI 把依赖对象注入进来。
8. `rollbackFor = Exception.class` 是让普通 Exception 也触发事务回滚。
9. 同类内部方法调用本质是 `this.xxx()`，没有经过 Spring 代理对象，所以事务增强不会生效。
10. Starter 是一组依赖集合，用来简化依赖引入，配合自动配置快速搭建功能。
11. Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，启动内嵌 Tomcat。
12. `@RestController` = `@Controller` + `@ResponseBody`，默认返回 JSON；`@Controller` 一般返回页面。
13. `@RequestMapping` 是通用映射，`@GetMapping` 处理 GET 请求，`@PostMapping` 处理 POST 请求。
14. `@RequestParam` 接收查询参数，`@PathVariable` 接收路径变量，`@RequestBody` 接收请求体 JSON。
15. GET 一般用于查询，参数放 URL；POST 一般用于提交数据，参数放 body。
16. 前端传 JSON 时，数据在 body 里，后端用 `@RequestBody` 把 JSON 转成 Java 对象。
