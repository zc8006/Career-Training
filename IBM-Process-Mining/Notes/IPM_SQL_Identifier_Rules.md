# IBM Process Mining 2.0.3 SQL 字段书写规则

## 已确认规则

在 Advanced edit mode 中，普通英文表名和字段名直接写，不加双引号。

正确示例：

```sql
SELECT
    UUID,
    Status,
    DATA,
    Processor
FROM comments_detail_tbl
```

关联时同样直接写：

```sql
comment_data.DATA
clean_data.CLEAN_ED
attr.OCRFeedback
```

过滤条件：

```sql
WHERE comment_data.DATA IS NOT NULL
  AND TRIM(comment_data.DATA) <> ''
  AND TRIM(comment_data.DATA) <> '-'
```

## 禁止写法

不要把普通英文字段写成双引号标识符：

```sql
comment_data."Data"
"Data"
```

更不能使用中文弯引号：

```sql
comment_data.“Data”
“Data”
```

这类写法可能导致：

```text
标识 Data 未知
```

## 例外

只有输出别名包含中文、空格或特殊字符时，才使用英文半角双引号：

```sql
COUNT(*) AS "录入报错次数"
```

不要给原始表字段随意添加双引号。

## 当前 Comments 表

已验证可用：

```sql
SELECT
    UUID,
    Status,
    DATA,
    Processor
FROM comments_detail_tbl
```

字段含义：

- UUID：Case标识
- Status：状态或时间字段，具体语义需根据数据确认
- DATA：Comments内容
- Processor：处理人

## 执行原则

1. 先用最小 SELECT 验证表名和字段名。
2. 验证成功后再增加 WHERE、GROUP BY 和聚合。
3. 未验证的表名、字段名和函数不得写入完整 SQL。
4. 用户已确认的原始字段写法优先于通用数据库习惯。
