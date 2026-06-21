# Day 35 - Spring Boot 扫描范围 / MyBatis Mapper 扫描 / XML 映射

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. Spring Bean 初始化阶段一般可以用哪些方式做初始化逻辑？

**保命句：**

Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。

**表现记录：**

- `InitializingBean` 这次拼写正确。
- 正式说的时候记得带上 `@PostConstruct` 的 `@`。

### 2. Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**保命句：**

Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。

**问题记录：**

- 第一次说成了 `Destroy`、`DisopebleBean`。
- 正确是 `@PreDestroy`、`DisposableBean`、`destroy-method`。

> Day 36 必回炉。

### 3. Spring MVC 里的 `Interceptor` 一般可以用来做什么？有哪些常见方法？

**保命句：**

Interceptor 做登录、权限、日志，方法是 `preHandle`、`postHandle`、`afterCompletion`。

**问题记录：**

- 第一次把 `afterCompletion` 说成了 `main`。

> Day 36 必回炉。

### 4. Spring Boot 多环境配置怎么做？用哪个配置项指定当前环境？

**保命句：**

多环境配置用 `application-dev.yml`，通过 `spring.profiles.active` 指定当前环境。

**完整说法：**

多环境配置一般用 `application-dev.yml`、`application-prod.yml` 区分不同环境，再通过 `spring.profiles.active` 指定当前环境。

### 5. 什么是跨域？Spring Boot 里一般怎么解决跨域问题？

**保命句：**

跨域是前后端协议、域名或端口不一致导致的，Spring Boot 可以用 `@CrossOrigin` 或全局 CORS 配置解决。

**问题记录：**

- 第一次忘记。
- 第二次能复述，注意大小写：`Spring Boot`、`@CrossOrigin`、`CORS`。

> Day 36 必回炉。

### 6. Spring Boot 里读取配置文件的值，一般有哪些方式？

**保命句：**

读取配置可以用 `@Value` 读取单个值，也可以用 `@ConfigurationProperties` 批量绑定配置对象。

**完整说法：**

`@Value` 适合配置少、读取单个配置项；`@ConfigurationProperties` 适合配置多、批量绑定一组配置到对象里。

> Day 36 轻回炉。

### 7. `@Repository` 和 MyBatis 的 `@Mapper` 有什么区别？实际项目里 Mapper 接口一般用哪个？

**保命句：**

`@Repository` 是 Spring 的持久层注解，`@Mapper` 是 MyBatis 的 Mapper 接口注解，实际项目一般用 `@Mapper` 或 `@MapperScan`。

**完整说法：**

`@Repository` 是 Spring 的持久层组件注解，主要表示 DAO 层 Bean。`@Mapper` 是 MyBatis 的注解，用来标识 Mapper 接口，让 MyBatis 为接口生成代理对象。实际项目里 Mapper 接口一般用 `@Mapper`，或者通过 `@MapperScan` 批量扫描。

> Day 36 轻回炉。

### 8. Spring Boot 项目启动流程大概是什么？

**保命句：**

`SpringApplication.run()` 创建容器，加载配置和自动配置，扫描 Bean，最后启动内嵌 Tomcat。

**完整说法：**

Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，初始化 Bean，最后启动内嵌 Tomcat。

**问题记录：**

- 第一次说成了 `application.run`。
- 漏了加载配置、自动配置、扫描 Bean。

> Day 36 轻回炉。

### 9. `@NotNull`、`@NotEmpty`、`@NotBlank` 有什么区别？

**保命句：**

`@NotNull` 不能为 null，`@NotEmpty` 不能为空，`@NotBlank` 不能是空白字符串。

**完整说法：**

`@NotBlank` 通常用于字符串，不能为 null、不能是空字符串，也不能全是空格。

### 10. `@SpringBootApplication` 主要由哪几个核心注解组成？分别有什么作用？

**保命句：**

`@SpringBootApplication` 主要由 `@SpringBootConfiguration`、`@EnableAutoConfiguration` 和 `@ComponentScan` 组成，分别表示配置类、自动配置和组件扫描。

**问题记录：**

- 最后一个不能只说 `component`，要说 `@ComponentScan`。

> Day 36 轻回炉。

## 新题

### 1. Spring Boot 默认会扫描哪些包？如果 Controller 或 Service 没有生效，可能是什么原因？

**保命句：**

Spring Boot 默认扫描启动类所在包及子包，Bean 没生效可能是包路径不对，或者没有加对应注解。

**完整说法：**

Spring Boot 默认会扫描启动类所在包及其子包。如果 Controller、Service 没有生效，可能是类放在了启动类包路径之外，或者没有加对应的组件注解。MyBatis Mapper 还需要加 `@Mapper` 或配置 `@MapperScan`。

> Day 36 必回炉：第一次说成了“扫描配置里依赖的包”。

### 2. 如果某个 Controller 或 Service 不在启动类所在包及子包下，怎么让 Spring Boot 扫描到它？

**保命句：**

类不在默认扫描范围内，可以调整包结构，或者用 `scanBasePackages` / `@ComponentScan` 指定扫描包。

**完整说法：**

如果类不在启动类所在包及子包下，Spring Boot 默认扫描不到。可以调整包结构，把它放到启动类子包下，也可以通过 `scanBasePackages` 或 `@ComponentScan` 指定要扫描的包路径。

> Day 36 必回炉：第一次不知道。

### 3. MyBatis 里 `@MapperScan` 是干什么的？它和每个 Mapper 接口上都写 `@Mapper` 有什么区别？

**保命句：**

`@Mapper` 标在单个 Mapper 接口上，`@MapperScan` 批量扫描 Mapper 包，让 MyBatis 生成 Mapper 代理对象。

**完整说法：**

`@MapperScan` 用来批量扫描指定包下的 Mapper 接口，让 MyBatis 为这些接口生成代理对象。`@Mapper` 是写在单个 Mapper 接口上的，而 `@MapperScan` 是统一扫描一整个 Mapper 包，项目里 Mapper 比较多时更方便。

> Day 36 必回炉：第一次表达不清。

### 4. Spring Boot 整合 MyBatis 时，Mapper 接口和 XML 文件一般是怎么对应起来的？`namespace` 一般写什么？

**保命句：**

XML 的 `namespace` 写 Mapper 接口全限定名，SQL 的 `id` 对应接口方法名。

**完整说法：**

Spring Boot 整合 MyBatis 时，Mapper 接口和 XML 文件一般通过 `namespace` 和 SQL 的 `id` 对应。XML 里的 `namespace` 通常写 Mapper 接口的全限定名，SQL 标签的 `id` 对应 Mapper 接口里的方法名。

## 追问

### 1. 如果 MyBatis XML 里的 `namespace` 写错了，或者 SQL 标签的 `id` 和 Mapper 接口方法名对不上，会发生什么？

**保命句：**

`namespace` 或 `id` 对不上，MyBatis 就找不到对应 SQL，方法调用时会报错。

**完整说法：**

MyBatis 会找不到对应的 MappedStatement，调用 Mapper 方法时会报错，SQL 无法执行。

### 2. Spring Boot 整合 MyBatis 时，XML 文件一般放在哪里？配置项一般叫什么？

**保命句：**

XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。

**完整说法：**

MyBatis 的 XML 文件一般放在 `src/main/resources/mapper` 目录下，然后通过 `mybatis.mapper-locations` 配置 XML 文件路径，比如 `classpath:mapper/*.xml`。

> Day 36 必回炉：第一次不知道。

### 3. 如果 Mapper 接口上没有写 `@Mapper`，启动类上也没有配置 `@MapperScan`，可能会发生什么问题？

**保命句：**

没有 `@Mapper` 或 `@MapperScan`，Mapper 可能不会被扫描成代理对象，Service 注入 Mapper 时会失败。

**完整说法：**

如果 Mapper 接口上没有 `@Mapper`，启动类上也没有配置 `@MapperScan`，MyBatis 就可能扫描不到 Mapper 接口，也不会生成 Mapper 代理对象。这样在 Service 里注入 Mapper 时，可能会报找不到 Bean 的错误。

> Day 36 必回炉：第一次只说了“加载错误”，太笼统。

## Day 36 回炉

### 必回炉

1. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`
2. Interceptor 常见方法：`preHandle`、`postHandle`、`afterCompletion`
3. 跨域：协议、域名、端口不一致；`@CrossOrigin`；全局 CORS 配置
4. Spring Boot 默认扫描范围：启动类所在包及子包
5. 如何扩大扫描范围：`scanBasePackages`、`@ComponentScan`
6. `@MapperScan` 作用：批量扫描 Mapper 包，生成 Mapper 代理对象
7. MyBatis XML 位置和配置：`resources/mapper`、`mybatis.mapper-locations`
8. Mapper 没有 `@Mapper` / `@MapperScan` 的后果：Mapper 没被扫描成代理对象，Service 注入失败

### 轻回炉

1. `InitializingBean`
2. Spring Boot 启动流程
3. `@Repository` 和 `@Mapper`
4. `@NotNull`、`@NotEmpty`、`@NotBlank`
5. `@SpringBootApplication` 三个核心注解
6. `@Value` 和 `@ConfigurationProperties`

## Day 35 背诵清单

1. Bean 初始化可以用 `@PostConstruct`、`InitializingBean`、`init-method`。
2. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
3. Interceptor 做登录、权限、日志，方法是 `preHandle`、`postHandle`、`afterCompletion`。
4. 多环境配置用 `application-dev.yml`，通过 `spring.profiles.active` 指定当前环境。
5. 跨域是前后端协议、域名或端口不一致导致的，Spring Boot 可以用 `@CrossOrigin` 或全局 CORS 配置解决。
6. 读取配置可以用 `@Value` 读取单个值，也可以用 `@ConfigurationProperties` 批量绑定配置对象。
7. `@Repository` 是 Spring 的持久层注解，`@Mapper` 是 MyBatis 的 Mapper 接口注解，实际项目一般用 `@Mapper` 或 `@MapperScan`。
8. Spring Boot 默认扫描启动类所在包及子包，Bean 没生效可能是包路径不对，或者没有加对应注解。
9. 类不在默认扫描范围内，可以调整包结构，或者用 `scanBasePackages` / `@ComponentScan` 指定扫描包。
10. `@Mapper` 标在单个 Mapper 接口上，`@MapperScan` 批量扫描 Mapper 包，让 MyBatis 生成 Mapper 代理对象。
11. XML 的 `namespace` 写 Mapper 接口全限定名，SQL 的 `id` 对应接口方法名。
12. `namespace` 或 `id` 对不上，MyBatis 就找不到对应 SQL，方法调用时会报错。
13. XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。
14. 没有 `@Mapper` 或 `@MapperScan`，Mapper 可能不会被扫描成代理对象，Service 注入 Mapper 时会失败。
