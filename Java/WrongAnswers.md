# Java Wrong Answers

记录 Java / Spring / Spring Boot / MyBatis 面试错题。

## 记录格式

```text
日期：
题目：
我的回答：
问题点：
标准回答：
背诵版：
是否已掌握：No / Almost / Yes
```

---

## 示例

### RowBounds 是什么？

我的回答：

```text
RowBounds 是逻辑分页，有可能拆分的不对。
```

问题点：

```text
表达不准确，“拆分的不对”不适合面试。
```

背诵版：

```text
RowBounds 偏逻辑分页，可能先查出大量数据再在内存中截取，所以大数据量分页不推荐。
项目中一般使用 PageHelper 或手写 limit。
```

是否已掌握：Almost
