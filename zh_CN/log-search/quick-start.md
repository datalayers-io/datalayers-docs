# 日志检索快速开始

本文示例演示如何利用倒排索引启用高效日志检索。

## 1. 创建日志表

```SQL
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

```SQL
CREATE INVERTED INDEX idx_message ON logs (message)
WITH (tokenizer='english', case_sensitive='false', with_position='true');
```

## 3. 为历史数据补建索引（可选）

如果 `idx_message` 创建前已经写入过数据，执行：

```SQL
REFRESH INDEX idx_message ON logs;
```

## 4. 执行日志检索

```SQL
SELECT ts, service, level, message
FROM logs
WHERE MATCH('message', 'database timeout')
ORDER BY SCORE() DESC
LIMIT 20;
```

```SQL
SELECT ts, service, level, message
FROM logs
WHERE QUERY('message:"connection refused" OR message:in [timeout retry]')
ORDER BY SCORE() DESC
LIMIT 20;
```

## 5. 清理索引

```SQL
DROP INDEX idx_message ON logs;
```
