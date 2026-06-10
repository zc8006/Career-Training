# Celonis - Write PQL Queries Notes

## 考试信息

```text
25 questions
45 minutes
Passing score: 68%
```

## 主题

- Code with PQL
- Joins in the Data
- PU-Functions
- Filtering
- Process-related functions

## 核心概念

### Event Log 三要素

```text
Case ID
Activity
Timestamp
```

### Process-related functions

重点：

- 活动顺序
- Throughput time
- Rework
- Process path
- Activity filter

### Throughput time

吞吐时间通常是两个时间点之间的差值，例如从开始活动到结束活动。

常见思路：

```text
start timestamp
end timestamp
difference between them
```

### NOT 关键字

如果题目问“要把包含 price change activities 的 case 算进去，需要删除哪个关键词”，通常是删除 `NOT`。

因为原来的 PQL 可能是在排除 price change activities，加上 NOT 表示“不包含”。
删除 NOT 后，就变成包含这些活动。

## PU-Functions

需要重点掌握：

- PU_COUNT
- PU_SUM
- PU_AVG
- PU_FIRST
- PU_LAST
- DOMAIN_TABLE
- Target table / source column 判断

## Join / Filter

数据模型通常包含：

- 活动表
- Case 表
- 业务主数据表

Filter 会影响指标计算结果，考试中要注意过滤顺序和作用范围。
