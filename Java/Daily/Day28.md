# Day 28｜Java 面试抽查：Spring 回炉与 Redis 专项

日期：2026-08-21

## 今日完成情况

- 旧题回炉：9 道
- 新题专项：4 道
- 训练重点：Spring Bean、AOP、事务、自动配置、Java 集合与包装类、Redis
- 结果：Spring 主线基本能够口述；Redis 已建立基础框架，但缓存异常治理和布隆过滤器仍需反复回炉

> 说明：Redis 内容目前是面试学习与练习方案，不包装成真实生产项目经验。

## 一、旧题回炉

### 1. Spring Bean 生命周期｜A

面试口语版：

Spring 先实例化 Bean，然后进行属性赋值和依赖注入；接着执行各种 Aware 回调和 BeanPostProcessor 的前置处理；再执行 @PostConstruct、InitializingBean 或自定义 init-method 等初始化方法；之后执行 BeanPostProcessor 的后置处理，Bean 就可以使用了。容器关闭时执行 @PreDestroy、DisposableBean 或自定义 destroy-method 等销毁回调。

记忆顺序：

```text
实例化 → 依赖注入 → Aware → 前置处理 → 初始化 → 后置处理 → 使用 → 销毁
```

### 2. ==、equals 与 hashCode｜A

- 基本类型使用 `==` 比较值。
- 引用类型使用 `==` 比较两个引用是否指向同一个对象。
- `Object.equals()` 默认效果与 `==` 类似；类重写后可以按业务字段比较内容。
- 如果重写 `equals()`，必须同时重写 `hashCode()`，保证相等对象具有相同哈希值。
- `hashCode()` 相同不代表对象一定相等，因为可能发生哈希冲突。
- `HashMap`、`HashSet` 先根据哈希值定位桶，再通过 `equals()` 判断是否为同一个逻辑对象。

### 3. Spring AOP 与动态代理｜A

AOP 是面向切面编程，用来把事务、日志、权限校验等公共逻辑从业务代码中抽取出来。Spring 为目标 Bean 创建代理对象，外部调用时先进入代理对象，由代理对象执行增强逻辑，再调用目标方法。

- JDK 动态代理：基于接口创建代理。
- CGLIB：通过继承目标类创建子类代理，因此无法继承 final 类，也无法重写并增强 final 方法。

### 4. @Transactional 常见失效场景｜A

- 方法不是可代理的方法，例如 private 方法。
- 同一个类中内部调用，没有经过 Spring 代理对象。
- 异常被 catch 后没有继续抛出，代理感知不到异常。
- 默认只对 RuntimeException 和 Error 回滚；受检异常需要配置 `rollbackFor`。
- 对象由自己 `new` 创建，不是 Spring 管理的 Bean。
- 数据库或存储引擎不支持事务等。

### 5. Spring Boot 自动配置｜B

面试口语版：

Starter 负责引入一组相关依赖，使相应类进入 classpath；`@SpringBootApplication` 中的 `@EnableAutoConfiguration` 会加载候选自动配置类；随后通过 `@ConditionalOnClass`、`@ConditionalOnProperty`、`@ConditionalOnMissingBean` 等条件判断配置是否生效。条件满足时创建默认 Bean；用户已经自定义相应 Bean 时，自动配置通常会退让。

### 6. ArrayList 与 LinkedList｜A

- `ArrayList` 底层是动态数组，按下标随机访问为 O(1)。
- `LinkedList` 底层是双向链表，按下标访问需要遍历，为 O(n)。
- `ArrayList` 在中间插入或删除需要移动后续元素。
- `LinkedList` 已经拿到节点时修改前后指针很快，但如果先按下标寻找节点，整体仍是 O(n)。
- `LinkedList` 每个节点还要保存前后指针，通常内存占用更高。
- 实际项目一般优先选择 `ArrayList`；只有明确适合链表操作的场景才使用 `LinkedList`。

### 7. int 与 Integer｜B

- `int` 是基本数据类型；`Integer` 是包装类，本质是对象。
- 泛型不能使用基本类型，因此使用 `List<Integer>`，不能使用 `List<int>`。
- 自动装箱通常调用 `Integer.valueOf()`；拆箱会调用 `intValue()`。
- `Integer` 为 null 时自动拆箱会抛出 NullPointerException。
- 成员变量和数组元素有默认值：`int` 为 0，`Integer` 为 null；局部变量没有默认值，使用前必须赋值。
- 默认情况下，自动装箱会复用 -128～127 的缓存对象；比较两个 `Integer` 的数值应使用 `equals()`，不能依赖 `==`。

### 8. Student 按学号去重并保留原顺序｜A

方案一：如果“学号相同就是同一个学生”属于 Student 的业务身份，可以按学号重写 `equals()` 和 `hashCode()`，再放入 `LinkedHashSet<Student>`，它会去重并保留首次出现顺序。

方案二：如果不适合修改 Student 的相等规则，遍历原列表，用 `HashSet<String>` 保存已经出现的学号；`seen.add(studentNo)` 返回 true 时才把 Student 加入结果列表。这种方式也会保留第一次出现的对象。

### 9. @Controller 与 @RestController｜A

- `@Controller` 通常用于 MVC 页面，方法返回值可以交给视图解析器处理。
- `@RestController` 等价于 `@Controller + @ResponseBody`，方法返回值直接写入 HTTP 响应体，通常序列化为 JSON。
- 使用 `@Controller` 时，也可以在需要返回 JSON 的方法上单独添加 `@ResponseBody`。

## 二、Redis 新题专项

### 1. 五种常用数据类型及业务场景

| 类型 | 特点 | 常见场景 |
|---|---|---|
| String | 字符串、整数或二进制数据 | JSON 缓存、验证码、计数器、简单分布式锁 |
| Hash | 一个 Key 下保存多个字段 | 用户信息、商品信息等对象字段 |
| List | 有序、可重复 | 消息列表、时间线、简单队列 |
| Set | 无序、元素不重复 | 去重、标签、共同关注和交并集 |
| ZSet | 元素不重复，每个元素带 score 并排序 | 排行榜、热度榜、延时任务候选方案 |

这些类型不是代替 Spring。Spring 负责接收请求、执行业务和返回 JSON；Redis 负责跨请求、跨进程保存可快速访问的数据结构。

例：排行榜页面请求到达 Controller，Service 使用 Redis 的 ZSet 读取前 100 名，再由 Controller 返回 JSON。若只用普通 Java List，每台服务器各有一份，重启会丢失，多实例之间也无法共享。

### 2. Cache Aside 读写流程

读取：

1. 先查询 Redis。
2. 命中则直接返回。
3. 未命中再查询数据库。
4. 把数据库结果写入 Redis，并设置过期时间。
5. 返回结果。

更新：

1. 先更新数据库。
2. 数据库更新成功后删除缓存。
3. 下次查询未命中时，再从数据库加载新数据并回填缓存。

不建议简单地“先删缓存再更新数据库”：删除后、数据库更新前，另一个请求可能读到数据库旧值并重新写入缓存，随后数据库才更新成功，造成旧缓存残留。

补充：删除缓存也可能失败，工程上可通过重试、消息队列或订阅数据库变更日志等方式提高最终一致性。

### 3. 缓存穿透、击穿和雪崩

| 问题 | 含义 | 常用治理 |
|---|---|---|
| 穿透 | 查询数据库也不存在的数据，请求每次都绕过缓存打到数据库 | 缓存空值并设置较短 TTL、参数校验、布隆过滤器 |
| 击穿 | 某个热点 Key 失效，大量并发同时查询数据库 | 互斥锁、逻辑过期、热点数据不过期并异步刷新 |
| 雪崩 | 大量 Key 同时失效或 Redis 故障，大量请求集中打到数据库 | TTL 加随机值、限流降级、多级缓存、Redis 高可用 |

缓存空值能够缓解穿透，是因为第一次查不到后也在 Redis 留下“该数据不存在”的标记，后续相同请求可直接返回，不再重复访问数据库。设置较短 TTL 是为了避免以后数据库新增该数据时，空值长期阻止正常查询。

### 4. 布隆过滤器的实际使用

布隆过滤器用于快速判断“某个 ID 是否可能存在”：

- 判断为不存在：一定不存在，可以直接拒绝请求。
- 判断为存在：可能存在，也可能误判，仍需查询缓存或数据库确认。
- 优点是空间小、判断快；缺点是存在误判，标准布隆过滤器不适合直接删除元素。

使用 Redisson 的练习示例：

```java
RBloomFilter<Long> filter =
        redissonClient.getBloomFilter("bloom:product:id");

filter.tryInit(1_000_000L, 0.01);

// 初始化：将数据库中已有商品 ID 写入
filter.add(productId);

// 查询：不存在则直接返回；可能存在再查缓存和数据库
if (!filter.contains(productId)) {
    return null;
}
```

推荐流程：

1. 系统初始化或定时任务把数据库已有 ID 加入过滤器。
2. 新增数据时，数据库事务提交成功后再把新 ID 加入过滤器。
3. 查询时先过布隆过滤器，再查 Redis 和数据库。
4. 删除或数据偏差较多时，通过新过滤器重建并切换，避免直接删除位导致其他元素误判。
5. 布隆过滤器与缓存空值可组合使用，过滤器挡住大部分非法 ID，空值处理少量误判。

### 5. Redis 分布式锁

可靠的基础思路：

```text
SET lock:order:1001 request-uuid NX EX 30
```

- `NX`：只有 Key 不存在时才加锁。
- `EX 30`：设置过期时间，防止持锁服务宕机后永久死锁。
- 唯一值：标识锁的持有者，防止线程执行超时后误删别人重新获得的锁。
- 加锁和设置 TTL 必须是一条原子命令，不能先 `SETNX` 再单独 `EXPIRE`。

解锁时必须先比较值，再删除 Key，并使用 Lua 保证这两个动作原子执行：

```lua
if redis.call('get', KEYS[1]) == ARGV[1] then
    return redis.call('del', KEYS[1])
else
    return 0
end
```

实际 Java 项目通常优先使用 Redisson 的 `RLock`，减少手写错误。未显式指定租约时间时，Redisson 的看门狗机制可在持锁实例仍存活时续期；仍需通过 `try/finally` 释放锁，并正确处理加锁失败和业务超时。

## 三、今日薄弱项

1. `int` 与 `Integer` 的默认值必须限定为“成员变量和数组元素”；局部变量没有默认值。
2. Spring Boot 自动配置需要一次说完整：Starter、加载配置类、条件判断、默认 Bean、用户配置退让。
3. 缓存穿透、击穿、雪崩的概念已经能区分，但治理方案还没有形成稳定口述。
4. 布隆过滤器刚建立实际使用流程，需要继续追问初始化、增量同步、误判和重建。
5. 分布式锁基础已掌握，后续补充锁超时但业务未完成、可重入、主从切换等追问。

## 四、回炉安排

- 2026-08-22：口述 `int/Integer`、缓存三兄弟、布隆过滤器。
- 2026-08-24：场景追问自动配置、Cache Aside 并发不一致、分布式锁误删。
- 2026-08-28：不看答案完成 Redis 专题完整模拟面试。

## 五、今日 10 句背诵清单

1. Bean 生命周期：实例化、依赖注入、Aware、前置处理、初始化、后置处理、使用、销毁。
2. 相等对象必须有相同 hashCode，但 hashCode 相同的对象不一定 equals。
3. Spring AOP 通过代理对象在目标方法前后执行事务、日志和权限等增强逻辑。
4. 同类内部调用不经过 Spring 代理，是 @Transactional 常见失效原因。
5. Starter 引入依赖，自动配置加载候选配置类，条件满足时创建默认 Bean，用户配置存在时退让。
6. ArrayList 随机访问快；LinkedList 按下标查找慢，插入快的前提是已经拿到节点。
7. 只有成员变量和数组元素才有默认值，Java 局部变量使用前必须赋值。
8. Cache Aside 读取先缓存后数据库，更新先数据库后删除缓存。
9. 穿透是查不到，击穿是单个热点失效，雪崩是大量缓存同时失效或缓存服务故障。
10. Redis 锁使用 SET NX EX 原子加锁、唯一值标识持有者、Lua 原子判断并删除。
