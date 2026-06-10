# Celonis - Build Action Flows Notes

## 考试信息

```text
25 questions
45 minutes
Passing score: 68%
```

## 核心概念

### Action Flow

```text
Action Flow 是用于自动化业务任务的流程。
它通常由 Trigger、Module、Connection 组成。
```

### Trigger

触发流程的入口。

### Module

执行具体动作，例如发送邮件、调用 HTTP API、处理数据。

### Connection

连接外部系统或 Celonis 服务所需的认证信息。

### Data pill

动态数据占位符，可以把前一步输出的数据传给后一步。

## 关键流程

```text
Save
Create Version
Deploy
Activate
```

如果没有 Create Version / Deploy，修改可能不会生效。

## 常见组件

- Router：分支
- Filter：控制分支条件
- HTTP module：调用外部 API
- Parse response：解析 JSON
- Text Aggregator：聚合文本
- Sleep：处理限流或等待
- Error handler：错误处理

## 重要经验

- No Run, No Data：没有运行过就没有可用数据样本
- AI 模块在训练环境中可能不可用
- Process Orchestration 集成时，权限和 OAuth Client 可能影响能否配置
