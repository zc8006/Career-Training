# Career-Training

这个仓库用于统一管理我的职业训练资料，避免不同聊天窗口、不同学习主题混在一起。

## 当前主线

1. English：英语面试与日常沟通训练
2. Japanese：日语面试与技术表达训练
3. Java：Java / Spring / Spring Boot / MyBatis 面试训练
4. MuleSoft：MuleSoft API 集成与项目面试表达
5. Celonis：Celonis Academy 考试与实操总结

## 使用规则

- 每个模块都有一个 `*_Master.md`，作为长期主档案。
- 每天练习内容放到 `Daily` 或 `Notes`。
- 错题、不会说、容易混淆的内容放到 `WrongAnswers.md`。
- 重要结论先写进当天文件，确认稳定后再同步到 Master。
- Master 文件只保留“以后还要用”的内容，不堆太多临时记录。

## 推荐提交节奏

```bash
git add .
git commit -m "Update career training notes"
git push
```

## 文件结构

```text
Career-Training
├── English
│   ├── English_Training_Master.md
│   ├── Daily
│   └── WrongAnswers.md
├── Japanese
│   ├── Japanese_Training_Master.md
│   ├── Daily
│   └── WrongAnswers.md
├── Java
│   ├── Java_Interview_Master.md
│   ├── Notes
│   └── WrongAnswers.md
├── MuleSoft
│   ├── MuleSoft_Interview_Master.md
│   ├── Notes
│   └── WrongAnswers.md
└── Celonis
    ├── Celonis_Exam_Master.md
    ├── Notes
    └── WrongAnswers.md
```
