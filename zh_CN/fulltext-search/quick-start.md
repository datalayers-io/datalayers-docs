---
title: "全文检索快速开始"
description: "通过一个日志表示例，快速了解在 Datalayers 中创建倒排索引、补建历史索引、执行全文检索并验证结果的基本流程。"
---
# 全文检索快速开始

本文以日志检索为例，演示如何在 Datalayers 中为 `STRING` 列创建倒排索引，并使用 `MATCH`、`QUERY` 与 `SCORE()` 完成基础全文检索。

示例中的 `message` 列存放英文日志内容，因此索引配置采用 `standard` 分词器；如果你的日志以中文为主，建议改用 `tokenizer='chinese'`。

## 1. 创建表

首先创建一张用于存放日志的示例表，其中 `message` 为待检索字段：

```sql
CREATE TABLE logs (
  ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  service STRING,
  level STRING,
  message STRING,
  timestamp key(ts)
)
PARTITION BY HASH(service) PARTITIONS 1;
```

## 2. 创建倒排索引

在 `message` 列上创建倒排索引：

```sql
CREATE INVERTED INDEX idx_message ON logs (message)
WITH (tokenizer='standard', filters='lowercase,english_stop', with_position='true');
```

索引参数说明：

- `tokenizer='standard'`：适合英文文本，按空格和标点进行分词
- `filters='lowercase,english_stop'`：统一大小写并过滤常见英文停用词
- `with_position='true'`：保存词位置信息，便于短语检索和更准确的相关性排序

## 3. 为历史数据补建索引（可选）

如果 `idx_message` 创建前表中已经存在历史数据，需要执行一次索引刷新，将存量数据纳入倒排索引：

```sql
REFRESH INDEX idx_message ON logs;
```

## 4. 执行全文检索

`MATCH` 适合直接按关键词或多个词项进行检索：

```sql
SELECT ts, service, level, message
FROM logs
WHERE MATCH('message', 'database timeout')
ORDER BY SCORE() DESC
LIMIT 20;
```

`QUERY` 适合表达短语匹配、布尔逻辑或集合匹配：

```sql
SELECT ts, service, level, message
FROM logs
WHERE QUERY('message:"connection refused" OR message:in [timeout retry]')
ORDER BY SCORE() DESC
LIMIT 20;
```

查询说明：

- `MATCH` 和 `QUERY` 只能出现在 `WHERE` 子句中
- `SCORE()` 必须与全文检索函数一起使用
- `ORDER BY SCORE() DESC` 可让最相关的结果排在前面

## 5. 验证结果

如果查询能够返回包含目标关键词或短语的日志记录，并且最相关结果排在前面，说明倒排索引已生效，全文检索链路验证成功。

## 6. 删除索引（可选）

如果需要清理测试环境中的索引，可执行：

```sql
DROP INDEX idx_message ON logs;
```

## 相关文档

- 全文检索概述：[全文检索概述](./overview.md)
- 全文检索函数：[全文检索函数](../sql-reference/fulltext-functions.md)
- 创建倒排索引：[CREATE 语句（含 CREATE INVERTED INDEX / CREATE VECTOR INDEX）](../sql-reference/statements/create.md)
- 刷新索引：[REFRESH 语句详解](../sql-reference/statements/refresh.md)
- 删除索引：[DROP 语句详解](../sql-reference/statements/drop.md)
