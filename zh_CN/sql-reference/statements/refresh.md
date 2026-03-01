# REFRESH 语句详解

## 功能概述

`REFRESH` 语句用于触发索引的数据刷新构建。对创建索引前写入的历史数据，可通过该语句补建索引。

## 语法

### REFRESH INDEX

```SQL
REFRESH INDEX index_name ON [database.]table_name [LIMIT n] [SYNC]
```

## 参数说明

- `index_name`：索引名称。
- `[database.]table_name`：索引所属表名，可带数据库前缀。
- `LIMIT n`：限制本次刷新的分区/任务数量。
- `SYNC`：同步执行，命令会等待刷新结束后返回。

## 示例

```SQL
REFRESH INDEX idx_message ON logs;

REFRESH INDEX idx_message ON logs LIMIT 1;

REFRESH INDEX idx_message ON logs SYNC;
```
