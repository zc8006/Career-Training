# Day 27 - MyBatis 核心回炉

## 训练完成情况

- 旧题回炉：10 / 10
- 新题：4 / 4
- 追问：3 / 3

## 旧题回炉

### 1. 为什么说 MyBatis 是半自动 ORM？

**保命句：**

MyBatis 是半自动 ORM，因为 SQL 要自己写，但参数映射和结果映射由 MyBatis 自动完成；全自动 ORM 通常连 SQL 也由框架自动生成。

### 2. Mapper 接口为什么没有实现类也能调用？

**保命句：**

Mapper 没有实现类也能调用，是因为 MyBatis 通过动态代理生成 Mapper 代理对象，根据 `namespace + 方法名` 找到 SQL 并执行。

### 3. namespace 有什么作用？

**保命句：**

`namespace` 通常对应 Mapper 接口全限定名，MyBatis 通过 `namespace + 方法名` 定位 SQL。

### 4. Mapper 方法能不能重载？

**保命句：**

Mapper 方法不建议重载，因为 MyBatis 主要通过 `namespace + 方法名` 定位 SQL，同名方法会导致 SQL 映射不清晰。

### 5. resultType 和 resultMap 有什么区别？

**保命句：**

简单自动映射用 `resultType`，复杂手动映射用 `resultMap`。

### 6. 字段名和 Java 属性名不一致怎么办？

**保命句：**

字段和属性不一致，可以用 SQL 别名、驼峰命名映射；复杂情况用 `resultMap` 手动映射。

### 7. 模糊查询 like 怎么写？

**正确写法：**

```sql
where name like concat('%', #{keyword}, '%')
```

**保命句：**

模糊查询用 `like concat('%', #{keyword}, '%')`，不要用 `${}` 拼接。

### 8. 动态 SQL 有什么用？常见标签有哪些？

**保命句：**

动态 SQL 用来根据条件动态拼接 SQL，常见标签有 `if`、`where`、`set`、`choose`、`foreach`。

### 9. MyBatis 如何批量插入？

**保命句：**

小批量用 `foreach`，大批量用 `ExecutorType.BATCH`，数据多要分批提交。

### 10. foreach 一般用在哪些场景？

**保命句：**

`foreach` 用来遍历集合参数，常见场景是 `in` 查询、小批量插入、批量删除等 SQL 拼接。

## 新题

### 1. MyBatis 插入数据后，如何获取数据库自动生成的主键 ID？

**保命句：**

自增主键用 `useGeneratedKeys=true`，再用 `keyProperty` 指定回填到哪个属性。

**示例：**

```xml
<insert id="insertUser" useGeneratedKeys="true" keyProperty="id">
    insert into user(name, age)
    values(#{name}, #{age})
</insert>
```

### 2. Mapper 方法中如果要传多个参数，MyBatis 一般怎么处理？

**保命句：**

MyBatis 多参数可以用 `@Param`，参数多时封装成对象；`resultMap` 是结果映射，不是传参用的。

### 3. MyBatis 分页一般怎么做？RowBounds 和 PageHelper 有什么区别？

**保命句：**

分页可以手写 `limit` 或用 PageHelper；`RowBounds` 偏逻辑分页，PageHelper 拦截 SQL 改写成物理分页 SQL。

### 4. MyBatis 一级缓存和二级缓存是什么？

**保命句：**

一级缓存是 `SqlSession` 级别，默认开启；二级缓存是 Mapper 级别，需要手动开启，实际项目要谨慎使用。

## 追问

### 1. 为什么二级缓存实际项目里要谨慎使用？

**保命句：**

二级缓存范围比较大，多个 `SqlSession` 共享缓存，如果数据更新后缓存没有及时失效，就可能读到旧数据，所以项目里要谨慎使用。

### 2. useGeneratedKeys 和 keyProperty 分别是什么意思？

**保命句：**

`useGeneratedKeys` 表示开启自增主键回填，`keyProperty` 表示把生成的主键回填到对象的哪个属性。

### 3. 为什么 RowBounds 不适合大数据量分页？

**保命句：**

`RowBounds` 偏逻辑分页，可能先查出大量数据再内存截取，所以大数据量分页不推荐，项目里一般用 PageHelper 或手写 `limit`。

## 明天回炉题

1. 模糊查询 `like` 怎么写？
2. 动态 SQL 常见标签有哪些？
3. MyBatis 主键回填怎么做？
4. Mapper 多参数怎么传？
5. `RowBounds` 和 PageHelper 区别？
6. 为什么 `RowBounds` 不适合大数据量分页？
