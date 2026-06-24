# Day 37 - Spring Bean 作用域与线程安全

日期：2026-06-22

## 今日完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3
- 主线：Spring Boot 扫描、MyBatis Mapper、Bean 注册、Bean 作用域、单例 Bean 线程安全

---

## 一、旧题回炉

### 1. Spring Bean 销毁方式

**题目：** Spring Bean 销毁阶段一般可以用哪些方式做资源释放？

**初答问题：**

- 把 `@PreDestroy` 说成 `@Destroy`
- 把 `DisposableBean` 说成 `DesposableBean`
- `destroy-method` 能记住

**标准答案：**

Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。

**结果：** 复述通过，Day 38 必回炉。

---

### 2. Spring MVC Interceptor

**题目：** Spring MVC 里的 `Interceptor` 一般可以用来做什么？有哪些常见方法？

**初答问题：**

- 能答出登录验证、权限校验、日志处理
- 能答出 `preHandle`、`postHandle`
- 第三个方法仍然没说准，说成 `compenet`

**标准答案：**

Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。

**结果：** 复述通过，Day 38 继续回炉。

---

### 3. 跨域

**题目：** 什么是跨域？Spring Boot 里一般怎么解决跨域问题？

**初答问题：**

- 能说出域名、端口不一致
- 漏掉协议不一致
- `@CrossOrigin` 说成 `@cros`

**标准答案：**

跨域是前后端协议、域名或端口不一致导致的，Spring Boot 可以用 `@CrossOrigin` 或全局 CORS 配置解决。

**结果：** 复述通过，Day 38 继续回炉。

---

### 4. Spring Boot 默认扫描范围

**题目：** Spring Boot 默认会扫描哪些包？如果 Bean 没有生效，可能是什么原因？

**初答：** 会扫描启动类下面的包和子包，可能是启动类路径不对，没有加注解。

**标准答案：**

Spring Boot 默认扫描启动类所在包及子包，Bean 没生效可能是包路径不对，或者没有加对应注解。

**结果：** 基本通过。

---

### 5. 扩大扫描范围

**题目：** 如果某个类不在 Spring Boot 默认扫描范围内，怎么让它被扫描到？

**初答问题：**

- 能说出调整包结构
- `@ComponentScan` 说成 `CompenetScan`
- 说成“指定这个类”，实际更常见是指定扫描包

**标准答案：**

类不在默认扫描范围内，可以调整包结构，或者用 `scanBasePackages` / `@ComponentScan` 指定扫描包。

**结果：** 复述通过，Day 38 轻回炉。

---

### 6. `@MapperScan` 与 `@Mapper`

**题目：** `@MapperScan` 是干什么的？它和每个 Mapper 接口上都写 `@Mapper` 有什么区别？

**初答问题：**

- 能说出扫描 Mapper
- 对 `@Mapper` 的表达仍不稳定，说成“每次对 MyBatis 生成代理对象”

**标准答案：**

`@Mapper` 标在单个 Mapper 接口上，`@MapperScan` 批量扫描 Mapper 包，让 MyBatis 生成 Mapper 代理对象。

**结果：** 复述通过，Day 38 继续回炉。

---

### 7. MyBatis XML 位置与配置项

**题目：** Spring Boot 整合 MyBatis 时，XML 文件一般放在哪里？配置项一般叫什么？

**初答问题：**

- 说成 `resource/mapper`
- 配置项误说成 `configuration`

**标准答案：**

XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。

**结果：** 复述通过，Day 38 必回炉。

---

### 8. Mapper 没有被扫描的后果

**题目：** 如果 Mapper 接口上没有写 `@Mapper`，启动类上也没有配置 `@MapperScan`，可能会发生什么问题？

**初答：** 没有 `@Mapper`，MyBatis 就不能给接口生成代理对象；没有 `@MapperScan`，就不能扫描 Mapper 接口，启动时可能报错。

**标准答案：**

没有 `@Mapper` 或 `@MapperScan`，Mapper 可能不会被扫描成代理对象，Service 注入 Mapper 时会失败。

**结果：** 基本通过，比 Day 36 明显进步。

---

### 9. `@Bean` 和 `@Component`

**题目：** `@Bean` 和 `@Component` 有什么区别？分别适合什么场景？

**初答：** `@Component` 是自己创建类时用；`@Bean` 是类不是自己创建的，但想让 Spring 管理，一般在配置类里用。

**修正点：**

不是让 Spring 管理“方法”，而是管理“方法返回的对象”。

**标准答案：**

`@Component` 用在类上，通过组件扫描把当前类注册成 Bean；`@Bean` 用在方法上，通常写在配置类里，把方法返回的对象注册成 Bean。自己写的类常用 `@Component`，第三方对象或需要手动创建的对象常用 `@Bean`。

**结果：** 基本通过。

---

### 10. `@Configuration`

**题目：** `@Configuration` 是什么？它一般和哪个注解一起用？

**初答：** 是管理配置类的，一般和 `@Bean` 一起用。

**修正点：**

`@Configuration` 不是“管理配置类”，而是标记这个类是配置类。

**标准答案：**

`@Configuration` 表示配置类，通常和 `@Bean` 一起用，用来把对象注册到 Spring 容器。

**结果：** 基本通过。

---

## 二、新题

### 1. Spring Bean 作用域

**题目：** Spring Bean 默认是什么作用域？常见的 Bean 作用域有哪些？

**初答问题：**

- 能说出单例、`prototype`、`request`、`session`
- `singleton`、`prototype` 拼写不稳
- `request` / `session` 不需要说成 `requestBean` / `sessionBean`

**标准答案：**

Spring Bean 默认作用域是 `singleton`。常见作用域有 `singleton`、`prototype`、`request`、`session`。`singleton` 表示容器中只有一个 Bean，`prototype` 表示每次获取都会创建新 Bean，`request` 和 `session` 主要用于 Web 场景。

**结果：** 复述通过，Day 38 轻回炉。

---

### 2. `singleton` 和 `prototype`

**题目：** `singleton` 和 `prototype` 有什么区别？在实际项目里最常用的是哪一个？

**初答问题：**

- 结论正确
- `singleton` 拼写仍不稳
- `prototype` 说成“每次请求”，容易和 `request` 作用域混淆

**标准答案：**

`singleton` 表示 Spring 容器中只有一个 Bean 实例，所有地方复用同一个对象。`prototype` 表示每次从容器获取 Bean 时都会创建一个新对象。实际项目里最常用的是 `singleton`。

**结果：** 复述通过。

---

### 3. 修改 Bean 作用域

**题目：** Spring 里怎么修改 Bean 的作用域？举个例子。

**初答：** 不知道。

**标准答案：**

Spring 可以用 `@Scope` 修改 Bean 的作用域，比如 `@Scope("prototype")` 表示每次从容器获取都会创建新的 Bean 对象。

**保命句：**

修改 Bean 作用域用 `@Scope`，比如 `@Scope("prototype")`。

**结果：** 复述通过，Day 38 必回炉。

---

### 4. 单例 Bean 线程安全

**题目：** Spring 里的单例 Bean 一定是线程安全的吗？为什么？

**初答问题：**

- 结论正确：不一定安全
- 原因说成“因为没有加锁”，不够准确

**标准答案：**

Spring 单例 Bean 不一定线程安全。Spring 只保证容器中只有一个实例，不保证内部逻辑线程安全。如果 Bean 是无状态的，一般是安全的；如果有共享可变状态，就可能出现线程安全问题。

**结果：** 复述通过，Day 38 必回炉。

---

## 三、追问

### 1. Service 成员变量保存请求数据

**题目：** 在 `Service` 里定义一个成员变量保存用户请求数据，这样安全吗？为什么？

**初答：** 不安全，但原因不知道。

**标准答案：**

不安全。因为 Service 默认是单例 Bean，多个请求会共用同一个 Service 对象。如果把用户请求数据放在成员变量里，多线程同时访问时可能互相覆盖，导致数据混乱。

**结果：** 复述通过，Day 38 必回炉。

---

### 2. 常量和注入 Mapper 是否有线程安全问题

**题目：** 如果 Service 里只是定义一个常量，或者注入一个 Mapper 成员变量，这样有线程安全问题吗？为什么？

**初答问题：** 误以为有问题。

**标准答案：**

常量或注入的 Mapper 一般没有线程安全问题，因为它们不保存用户请求状态。线程安全问题主要来自共享可变成员变量。

**结果：** 复述通过，Day 38 必回炉。

---

### 3. `prototype` 注入 `singleton`

**题目：** 如果把一个 `prototype` Bean 注入到一个 `singleton` Bean 里，每次调用时都会拿到新的 `prototype` 对象吗？为什么？

**初答：** 不知道，需要例子说明。

**标准答案：**

`prototype` Bean 注入到 `singleton` Bean 里，不会每次调用都重新创建，因为 `singleton` 只创建一次，依赖也只注入一次。需要每次获取新对象时，可以使用 `ObjectProvider`。

**结果：** 复述通过，Day 38 必回炉。

---

## 四、Day 37 背诵清单

1. Bean 销毁可以用 `@PreDestroy`、`DisposableBean`、`destroy-method`。
2. Interceptor 常用于登录校验、权限校验和日志记录，常见方法有 `preHandle`、`postHandle`、`afterCompletion`。
3. 跨域是前后端协议、域名或端口不一致导致的，可以用 `@CrossOrigin` 或全局 CORS 配置解决。
4. 类不在默认扫描范围内，可以调整包结构，或者用 `scanBasePackages` / `@ComponentScan` 指定扫描包。
5. XML 一般放在 `resources/mapper` 下，通过 `mybatis.mapper-locations` 配置扫描路径。
6. `@Component` 用在类上，通过组件扫描注册 Bean；`@Bean` 用在方法上，把方法返回对象注册成 Bean。
7. Spring Bean 默认作用域是 `singleton`，常见作用域有 `singleton`、`prototype`、`request`、`session`。
8. 修改 Bean 作用域用 `@Scope`，比如 `@Scope("prototype")`。
9. Spring 单例 Bean 不一定线程安全，如果有共享可变状态，就可能出现线程安全问题。
10. `prototype` Bean 注入到 `singleton` Bean 里，不会每次调用都重新创建，因为 `singleton` 只创建一次，依赖也只注入一次。

---

## 五、Day 38 回炉安排

### 必回炉

1. Bean 销毁方式：`@PreDestroy`、`DisposableBean`、`destroy-method`
2. Interceptor 方法：`preHandle`、`postHandle`、`afterCompletion`
3. 跨域：`@CrossOrigin`、全局 CORS 配置
4. MyBatis XML 位置和配置项：`resources/mapper`、`mybatis.mapper-locations`
5. `@Scope` 修改 Bean 作用域
6. 单例 Bean 是否线程安全
7. Service 成员变量保存请求数据为什么不安全
8. 常量或注入 Mapper 为什么一般没有线程安全问题
9. `prototype` 注入 `singleton` 的行为

### 轻回炉

1. `@ComponentScan` 和 `scanBasePackages`
2. `@MapperScan` 与 `@Mapper`
3. `singleton`、`prototype`、`request`、`session`
4. `@Bean` 和 `@Component`
5. `@Configuration` 和 `@Bean`
