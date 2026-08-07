# Day51 - AOP 代理限制与 Spring MVC 全局异常处理

## 一、旧题回炉

1. BeanPostProcessor：0 分
   - Bean 初始化前后的扩展点。
   - 常用方法：`postProcessBeforeInitialization()`、`postProcessAfterInitialization()`。
   - AOP 代理很多通过 BeanPostProcessor 生成。

2. Spring 三级缓存：0 分
   - 一级缓存：完整单例 Bean。
   - 二级缓存：早期 Bean 引用。
   - 三级缓存：生成早期引用的 `ObjectFactory`。

3. JoinPoint / ProceedingJoinPoint：0 分
   - JoinPoint 用于获取方法名、参数、目标对象等连接点信息。
   - ProceedingJoinPoint 是 JoinPoint 的子接口，主要用于 `@Around`，通过 `proceed()` 执行目标方法。

4. private 方法与 this 调用失效区别：2 分
   - private 方法：代理对象无法重写，因此方法本身不能被增强。
   - 同类内部 `this.xxx()`：方法可能可以被代理，但本次调用绕过了代理对象。

5. `@Order` 多切面顺序：0 分
   - 数字越小优先级越高。
   - 高优先级切面先进入、后退出。

6. JDK 动态代理与 CGLIB：9 分
   - JDK 动态代理基于接口。
   - CGLIB 通过继承目标类生成子类代理。

7. final 方法为什么不能被 CGLIB 增强：0 分
   - CGLIB 依赖子类重写方法，final 方法不能被重写。

8. final 类为什么不能被 CGLIB 代理：6 分
   - CGLIB 需要继承目标类，final 类不能被继承。

## 二、新题

1. `@RequestParam`、`@PathVariable`、`@RequestBody`：9 分
   - RequestParam：获取查询参数或表单参数。
   - PathVariable：获取 URL 路径占位符。
   - RequestBody：读取请求体并转换为 Java 对象。

2. `@Controller` 和 `@RestController`：8.5 分
   - Controller 默认用于返回视图。
   - RestController 默认返回响应体。
   - `@RestController = @Controller + @ResponseBody`。

3. `@ResponseBody`：8.5 分
   - 返回值不再解析为视图，而是通过消息转换器写入 HTTP 响应体。
   - Java 对象通常转换为 JSON。

4. Spring MVC 全局异常处理：0 分
   - 使用 `@RestControllerAdvice` 配合 `@ExceptionHandler`。
   - 对多个 Controller 的异常统一处理并返回统一 JSON。

## 三、追问

1. `@ControllerAdvice` 和 `@RestControllerAdvice`：0 分
   - `@RestControllerAdvice = @ControllerAdvice + @ResponseBody`。

2. `@ExceptionHandler` 写在 Controller 和全局处理类中的区别
   - 写在 Controller：只处理当前 Controller 的异常。
   - 写在 RestControllerAdvice：可处理多个 Controller 的异常。

3. 局部与全局异常处理优先级：10 分
   - Controller 内部的局部 ExceptionHandler 通常优先于全局 RestControllerAdvice。

## 四、Day52 必回炉

1. BeanPostProcessor
2. Spring 三级缓存
3. JoinPoint 和 ProceedingJoinPoint
4. private 方法与内部 this 调用失效区别
5. `@Order` 执行顺序
6. final 类和 final 方法为什么不能被 CGLIB 代理
7. 全局异常处理的两个核心注解
8. ControllerAdvice 和 RestControllerAdvice
9. 局部与全局 ExceptionHandler 的生效范围
10. 局部异常处理优先于全局异常处理

## 五、Day51 背诵清单

1. BeanPostProcessor 是 Bean 初始化前后的扩展点。
2. 一级缓存放完整 Bean，二级缓存放早期引用，三级缓存放 ObjectFactory。
3. JoinPoint 获取方法信息，ProceedingJoinPoint 通过 proceed() 执行目标方法。
4. private 方法失效是因为代理无法重写。
5. 同类内部调用失效是因为 this 调用绕过了代理对象。
6. `@Order` 数字越小优先级越高，先进入、后退出。
7. JDK 动态代理依赖接口，CGLIB 依赖继承。
8. final 类不能继承，final 方法不能重写，所以 CGLIB 无法增强。
9. `RestControllerAdvice = ControllerAdvice + ResponseBody`。
10. 全局异常处理使用 `@RestControllerAdvice` 配合 `@ExceptionHandler`。
11. Controller 内部的 ExceptionHandler 只对当前 Controller 生效。
12. 局部异常处理优先于全局异常处理。
