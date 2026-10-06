# Java Interview Training

这个目录用于管理 Java 后端面试训练资料。

## 当前进度

- 最新进度：Day 28
- 当前主线：Java 基础、集合、并发、JVM、MySQL、MyBatis、Spring、Spring Boot、Redis、项目排查
- 当前专项：Spring 高频题回炉、Redis 缓存与分布式锁
- 训练目标：不是单纯看完资料，而是把高频题练到能说出口、能接追问、能结合项目经验回答

## 训练方法

每天固定节奏：

1. 旧题回炉 8～10 道
2. 新题 4～6 道
3. 追问 3～5 个以内
4. 最后整理 8～10 句背诵清单

每道题按三类管理：

- A：稳定掌握，能独立回答并接追问
- B：半熟，知道关键词但表达不稳定
- C：不会或容易混，进入错题本重点回炉

## 文件结构

```text
Java
├── README.md
├── Java_Interview_Master.md          # 长期主档案，只放最终面试可说版本
├── WrongAnswers.md                   # 原错题本
├── WrongAnswers_Collected.md         # 从历史训练中整理出来的错题资产
├── Daily
│   ├── Day08-Day12.md                # 已整理的阶段训练记录
│   ├── Day12-Day26.md                # Day 12～26 阶段记录
│   ├── Day27.md                      # Day 27 训练记录
│   └── Day28.md                      # Spring 回炉与 Redis 专项
└── Notes
    ├── Interview_Training_Rules.md   # 训练规则和节奏
    ├── Fuzhou_Small_Company_Real_Interview.md # 福州小厂真实面经 1～3（含答案）
    └── MyBatis_SpringBoot_SpringBatch_Master.md
```

## 使用原则

- Daily：保留当天练习记录、回炉题、新题、追问、背诵清单
- Notes：按专题整理，比如 MyBatis、Spring Boot、Spring Batch、排查题
- WrongAnswers：只放真正答错、说不稳、容易混的内容
- Master：只放最后面试前要背的稳定答案，不堆流水账
- 未实际使用过的技术只写为学习方案或练习场景，不包装成真实项目经验

## 真实面经每日抽查

- `Notes/Fuzhou_Small_Company_Real_Interview.md` 已整理三份福州小厂 Java 真实面经，共 30 道题并附面试口语版答案。
- 每天从真实面经随机抽取 3～4 题，混入当天 8～10 道旧题回炉。
- 至少覆盖 1 道 Java/Spring、1 道数据库/缓存、1 道项目表达。
- B/C 题分别在之后 1 天、3 天、7 天重复抽查。

## 后续整理计划

目前已整理 Day 8～Day 28 的可访问训练内容。下一阶段优先回炉：

1. `int` 与 `Integer` 默认值的适用范围。
2. Spring Boot 自动配置完整口述。
3. Redis 缓存穿透、击穿、雪崩及治理方案。
4. 布隆过滤器的初始化、增量同步、误判与重建。
5. Redis 分布式锁的超时、误删、续期和主从切换追问。
