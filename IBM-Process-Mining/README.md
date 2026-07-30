# IBM Process Mining

用于沉淀 IBM Process Mining 项目的分析方法、SQL、面板设计、问题验证与复盘。

## 目录

```text
IBM-Process-Mining
├── IBM_Process_Mining_Master.md
├── Self_Growth_Mode.md
├── Notes
├── WrongAnswers.md
└── SQL
    └── EBS_Threshold
```

## 当前分析主线

- Phase1 / Phase2 人工与 RPA 对比
- DDD 范围排除
- 人工介入原因分类
- EBS 大于阈值需检查的原因分析
- 原因分类、处理时长、Rework、RPA 恢复率联动分析

## 数据口径

- 分类表：`manual_reason_tbl`
- 分类字段：`UUID`、`Status`
- 属性表：`manual_entry_classification1`
- EBS 筛选：`TRIM(OCR_FEEDBACK) = 'EBS_大于阈值需检查'`
- 分类方式：基于分类名称及批注关键词使用 `LIKE / NOT LIKE`
- 同一条 `UUID + Status` 只保留一个分类
- 同一 UUID 的不同 Status 可以进入不同分类
- IBM Process Mining 2.0.3 中避免使用 `WITH`，采用嵌套子查询

## 使用原则

1. 临时验证先写入 `Notes`。
2. 错误口径、失败 SQL 和修正原因写入 `WrongAnswers.md`。
3. 稳定结论再同步到 `IBM_Process_Mining_Master.md`。
4. 每次分析按 `Self_Growth_Mode.md` 复盘，形成可复用的方法。
