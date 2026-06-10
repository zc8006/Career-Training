# Celonis - Get Data into Celonis Notes

## 考试信息

```text
34 questions
55 minutes
Passing score: 70%
```

## 主题权重

- Connect to Systems: 15%
- Extract Data: 15%
- Transform Data: 15%
- Load Data Models: 12%
- Manage and Troubleshoot a Data Pipeline: 15%
- Build an Object-Centric Data Model: 28%

## 重点

### 数据导入方式

- Process Connectors
- Extractors / Data Connections
- Extractor Builder
- File Uploads
- Data Ingestion API
- Celoxtractor

### Process Connector

```text
Process Connector 通常是最快、最常见的方式。
它提供连接、抽取、转换、Data Model、table relationships 和 load schedule 模板。
```

### Extractor

```text
Extractor 更像空白连接，需要自己从头搭建 extraction、transformation、data model。
```

### Data Ingestion API

```text
Data Ingestion API 用于把数据推送到 Celonis。
适合 Kafka、MuleSoft、ETL 工具、大数据量、低延迟或安全限制场景。
```

### QA Checklist

重点检查：

- Data Connection 是否有 errors / warnings
- Full extraction load 是否超过 12 小时
- Data Jobs 与 Replication Cockpit 的关系
- Data Model Load
- Scheduling
- Execution History
- Data Validation
