# Day 36 - Spring Boot 扫描、MyBatis Mapper 与 Spring 依赖注入

日期：2026-06-21

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 追加讨论：构造器注入多个依赖、`@RequiredArgsConstructor` 与 Lombok

---

## 一、旧题回炉

### 1. Spring Bean 销毁方式

**题目：** Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**初答问题：**

- `@PreDestroy` 基本能说出
- `DisposableBean` 拼写不稳定
- `destroy-method` 能记住

**标准答案：**

Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。

**结果：** 复述通过，但 Day 37 继续回炉 `DisposableBean`。

---

### 2. Spring MVC Interceptor

**题目：** Spring MVC 里的 `Interceptor` 一般可以用来做什么？有哪些常见方法？

**初答问题：**

- 能答出登录验证、权限校验、日志输出
- 能答出 `preHandle`、`postHandle`
- 第三个方法误说成 `mantile`

**标准答案：**

Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。

**结果：** 复述通过，但 Day 37 继续回炉 `afterCompletion`。

---

### 3. 跨域

**题目：** 什么是跨域？Spring Boot 里一般怎么解决跨域问题？

**初答问题：**

- 能说出端口、域名不同
- 忘记 `@CrossOrigin` 完整注解名
- CORS 表达不稳定

**标准答案：**

跨域是前后端协议、域名或端口不一致导致的，Spring Boot 可以用 `@CrossOrigin` 或全局 CORS 配置解决。

**结果：** 复述通过，但 Day 37 继续回炉。

---

### 4. Spring Boot 默认扫描范围

**题目：** Spring Boot 默认会扫描哪些包？如果 Bean 没有生效，可能是什么原因？

**初答问题：**

- 说成“当前类下面的包和子包”
- 原因说成类名不对、依赖没配置，不够准确

**标准答案：**

Spring Boot 默认扫描启动类所在包及子包，Bean 没生效可能是包路径不对，或者没有加对应注解。

**结果：** 复述通过，Day 37 必回炉。

---

### 5. 扩大扫描范围

**题目：** 如果某个类不在 Spring Boot 默认扫描范围内，怎么让它被扫描到？

**初答：** 修改类路径，或者配置扫描类。

**标准答案：**

类不在默认扫描范围内，可以调整包结构，或者用 `scanBasePackages` / `@ComponentScan` 指定扫描包。

**结果：** 基本通过，Day 37 轻回炉。

---

### 6. `@MapperScan` 与 `@Mapper`

**题目：** `@MapperScan` 是干什么的？它和每个 Mapper 接口上都写 `@Mapper` 有什么区别？

**初答问题：**

- 能说出 `@MapperScan` 扫描 Mapper 包
- 误把 `@Mapper` 说成“注入依赖，执行 MyBatis”

**标准答案：**

`@Mapper` 标在单个 Mapper 接口上，`@MapperScan` 批量扫描 Mapper 包，让 MyBatis 生成 Mapper 代理对象。

**结果：** 复述通过，Day 37 继续回炉。

---

### 7. MyBatis XML 位置与配置项

**题目：** Spring Boot 整合 MyBatis 时，XML 文件一般放在哪里？配置项一般叫什么？

**初答问题：** 误说成 `mapper.profiles`。

**标准答案：**

XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。

**结果：** 复述通过，Day 37 必回炉。

---

### 8. Mapper 没有被扫描的后果

**题目：** 如果 Mapper 接口上没有写 `@Mapper`，启动类上也没有配置 `@MapperScan`，可能会发生什么问题？

**初答问题：** 说成“找不到相关的包，导致加载错误”，方向接近但不准确。

**标准答案：**

没有 `@Mapper` 或 `@MapperScan`，Mapper 可能不会被扫描成代理对象，Service 注入 Mapper 时会失败。

**结果：** 复述通过，Day 37 继续回炉。

---

### 9. Spring Boot 启动流程

**题目：** Spring Boot 启动流程大概是什么？

**初答：** `springApplication.run` 创建容器，扫描配置，自动配置，创建组件，启动 Tomcat。

**修正点：**

- 正式写法是 `SpringApplication.run()`
- “扫描配置”应说“加载配置”
- “创建组件”可说“扫描 Bean、初始化 Bean”

**标准答案：**

Spring Boot 启动时，先执行 `SpringApplication.run()`，创建 Spring 容器，加载配置和自动配置，扫描 Bean，初始化 Bean，最后启动内嵌 Tomcat。

**结果：** 基本通过，Day 37 轻回炉。

---

### 10. `@Value` 与 `@ConfigurationProperties`

**题目：** Spring Boot 里读取配置文件的值，一般有哪些方式？`@Value` 和 `@ConfigurationProperties` 有什么区别？

**初答：** `@Value` 是单个加载，`@ConfigurationProperties` 是加载对象。

**标准答案：**

`@Value` 适合读取单个配置项，`@ConfigurationProperties` 适合把一组配置批量绑定成 Java 对象，配置多时更推荐后者。

**结果：** 基本通过。

---

## 二、新题

### 1. `@Bean` 和 `@Component`

**题目：** `@Bean` 和 `@Component` 有什么区别？分别适合什么场景？

**初答问题：** 只答出 `@Component` 是普通组件。

**标准答案：**

`@Component` 用在类上，通过组件扫描把当前类注册成 Bean。`@Bean` 用在方法上，通常写在配置类里，把方法返回的对象注册成 Bean。自己写的类常用 `@Component`，第三方对象或需要手动创建的对象常用 `@Bean`。

**保命句：**

`@Component` 用在类上，靠扫描注册 Bean；`@Bean` 用在方法上，把方法返回对象注册成 Bean。

**结果：** Day 37 必回炉。

---

### 2. `@Configuration`

**题目：** `@Configuration` 是什么？它一般和哪个注解一起用？

**初答：** 不知道。

**标准答案：**

`@Configuration` 用来标记配置类，说明这个类里可以定义 Bean。它通常和 `@Bean` 一起使用，把方法返回的对象交给 Spring 管理。

**保命句：**

`@Configuration` 表示配置类，通常和 `@Bean` 一起用，用来把对象注册到 Spring 容器。

**结果：** 复述通过，Day 37 必回炉。

---

### 3. Spring 依赖注入方式

**题目：** Spring 里常见的依赖注入方式有哪些？实际项目里更推荐哪一种？

**初答问题：** 误以为依赖注入方式就是 `@Autowired`。

**标准答案：**

Spring 常见依赖注入方式有字段注入、构造器注入和 Setter 注入。实际项目里更推荐构造器注入，因为依赖更明确，也更方便测试。

**保命句：**

依赖注入有字段注入、构造器注入和 Setter 注入，更推荐构造器注入。

**结果：** 复述通过，Day 37 必回炉。

---

### 4. 同一接口多个实现类的注入问题

**题目：** 如果同一个接口有两个实现类，使用 `@Autowired` 注入时可能会出现什么问题？怎么解决？

**初答：** 因为类型相同可能会找不到对应实现类，用 `@Resource` 或者加一个指定注解。

**标准答案：**

如果同一个接口有多个实现类，`@Autowired` 按类型注入时可能不知道注入哪个 Bean，导致启动报错。可以用 `@Qualifier` 指定具体 Bean，也可以用 `@Primary` 指定默认 Bean，或者用 `@Resource` 按名称注入。

**结果：** 复述通过，Day 37 轻回炉。

---

## 三、追问

### 1. `@Qualifier` 和 `@Primary` 区别

**题目：** `@Qualifier` 和 `@Primary` 有什么区别？

**标准答案：**

`@Qualifier` 是在注入点指定具体使用哪个 Bean，`@Primary` 是在 Bean 定义上指定默认优先 Bean。多个 Bean 冲突时，`@Qualifier` 更明确，`@Primary` 是默认选择。

**结果：** 基本通过，Day 37 轻回炉。

---

### 2. 为什么推荐构造器注入

**题目：** 为什么实际项目里更推荐构造器注入，而不是字段注入？

**用户观点：** 更清晰，但实际项目大部分字段注入更方便。

**标准答案：**

实际项目里字段注入比较常见，因为简单方便。但从规范上更推荐构造器注入，因为依赖更明确，方便测试，也能保证对象创建时依赖完整。

**面试句：**

老项目里字段注入比较常见，但现在更推荐构造器注入，因为依赖关系更清晰，也更利于测试。

**结果：** 复述通过。

---

### 3. `@Autowired` 和 `@Resource` 区别

**题目：** `@Autowired` 和 `@Resource` 有什么区别？

**初答：** `@Autowired` 按类型注入，如果同一类型有多个 Bean 可以用 `@Qualifier`，`@Resource` 按名称注入。

**标准答案：**

`@Autowired` 是 Spring 提供的注解，默认按类型注入；如果同一类型有多个 Bean，可以配合 `@Qualifier` 指定名称。`@Resource` 是 Java/Jakarta 规范里的注解，默认按名称注入。

**结果：** 通过。

---

## 四、追加讨论：构造器注入多个依赖

### 1. 多个依赖是否要写多个构造器？

**结论：** 不需要。

多个依赖只需要在一个构造器里声明多个参数，Spring 会自动注入对应的 Bean。

```java
@Service
public class OrderService {

    private final UserMapper userMapper;
    private final OrderMapper orderMapper;
    private final RedisTemplate redisTemplate;

    public OrderService(UserMapper userMapper,
                        OrderMapper orderMapper,
                        RedisTemplate redisTemplate) {
        this.userMapper = userMapper;
        this.orderMapper = orderMapper;
        this.redisTemplate = redisTemplate;
    }
}
```

**面试句：**

多个依赖不需要写多个构造器，只需要在一个构造器里声明多个参数，Spring 会自动注入对应的 Bean。

---

### 2. 如果有 20 个依赖怎么办？

**结论：** 这不是构造器注入的问题，而是类职责太重的问题。

字段注入只是把问题藏起来，构造器注入会把依赖过多的问题暴露出来。

如果一个 Service 有 20 个依赖，通常要考虑：

- 拆分 Service
- 抽出 Facade
- 把相关逻辑封装到专门组件

**面试句：**

如果构造器里依赖很多，说明这个类职责可能太重，需要考虑拆分 Service 或抽出 Facade。构造器注入不是让代码变乱，而是把依赖过多的问题暴露出来。

---

### 3. `@RequiredArgsConstructor`

**问题：** `@RequiredArgsConstructor` 是 Lombok 吗？

**结论：** 是。

`@RequiredArgsConstructor` 是 Lombok 提供的注解，会自动生成包含 `final` 字段的构造器。

```java
@RequiredArgsConstructor
@Service
public class OrderService {

    private final UserMapper userMapper;
    private final OrderMapper orderMapper;
}
```

Lombok 编译时会自动生成：

```java
public OrderService(UserMapper userMapper, OrderMapper orderMapper) {
    this.userMapper = userMapper;
    this.orderMapper = orderMapper;
}
```

**面试句：**

项目中常用 Lombok 的 `@RequiredArgsConstructor` 配合 `final` 字段实现构造器注入，可以减少样板代码。

---

## 五、Day 36 背诵清单

1. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
2. Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。
3. 跨域是前后端协议、域名或端口不一致导致的，可以用 `@CrossOrigin` 或全局 CORS 配置解决。
4. Spring Boot 默认扫描启动类所在包及子包，Bean 没生效可能是包路径不对，或者没有加对应注解。
5. `@Mapper` 标在单个 Mapper 接口上，`@MapperScan` 批量扫描 Mapper 包，让 MyBatis 生成 Mapper 代理对象。
6. XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。
7. 没有 `@Mapper` 或 `@MapperScan`，Mapper 可能不会被扫描成代理对象，Service 注入 Mapper 时会失败。
8. `@Component` 用在类上，靠扫描注册 Bean；`@Bean` 用在方法上，把方法返回对象注册成 Bean。
9. `@Configuration` 表示配置类，通常和 `@Bean` 一起用，用来把对象注册到 Spring 容器。
10. 老项目里字段注入比较常见，但现在更推荐构造器注入，因为依赖关系更清晰，也更利于测试。

---

## 六、Day 37 回炉安排

### 必回炉

1. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`
2. Interceptor 方法：`preHandle`、`postHandle`、`afterCompletion`
3. 跨域：`@CrossOrigin`、全局 CORS 配置
4. Spring Boot 默认扫描范围
5. `@MapperScan` 与 `@Mapper`
6. `resources/mapper` 与 `mybatis.mapper-locations`
7. Mapper 没有被扫描的后果
8. `@Bean` 和 `@Component`
9. `@Configuration` 和 `@Bean`
10. 依赖注入方式：字段注入、构造器注入、Setter 注入

### 轻回炉

1. Spring Boot 启动流程
2. `@Value` 和 `@ConfigurationProperties`
3. `@Qualifier` 和 `@Primary`
4. `@Autowired` 和 `@Resource`
5. `@RequiredArgsConstructor`
