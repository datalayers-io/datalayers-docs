# 日志表模型指南

## 概述

日志表模型是针对日志检索场景优化的数据模型。Datalayers 结合列式存储、分区机制与倒排索引能力，支持高吞吐写入与低延迟检索。

在日志场景中，建议优先明确以下目标：

- 写入吞吐：持续高并发日志写入
- 检索效率：基于关键词、短语和布尔表达式进行快速检索
- 存储成本：在保留可检索性的前提下控制资源开销

## 建表语法

```sql
CREATE TABLE [IF NOT EXISTS] [database.]table_name
(
    ts TIMESTAMP [ DEFAULT default_expr ],
    service STRING,
    level STRING,
    message STRING,
    ...,
    TIMESTAMP KEY (ts),
    [ INVERTED INDEX [index_name] (message_column) [WITH (key=value, ...)] ]
)
PARTITION BY HASH(partition_key) PARTITIONS n
[ENGINE=TimeSeries]
[ WITH ( [ key = value ] [, ... ] ) ]
```

## 建表实践

### 场景一：通用日志检索（按服务隔离）

在通用日志场景中，通常按 `service` 做分区，日志正文放在 `message` 字段，并在建表时直接声明倒排索引。

| 字段      | 备注 |
|-----------|------|
| ts        | 日志时间（必须字段） |
| service   | 服务名/应用名，用于隔离与过滤 |
| level     | 日志级别（INFO/WARN/ERROR） |
| message   | 日志正文，用于全文检索 |

建表语句如下：

```sql
CREATE TABLE logs (
    ts TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    service STRING NOT NULL,
    level STRING,
    message STRING,
    timestamp key(ts),
    inverted index idx_message (message) with (tokenizer=english, case_sensitive=false, with_position=true)
)
PARTITION BY HASH(service) PARTITIONS 2;
```

**说明**：

- `ts` 必须为 `TIMESTAMP`，并通过 `TIMESTAMP KEY` 指定
- `message` 建议使用 `STRING`，作为全文检索主字段
- 分区键选 `service` 有利于按服务过滤和并行查询

### 场景二：多租户日志检索（按租户隔离）

在多租户场景中，建议使用 `tenant_id` 作为分区键，先按租户过滤，再在日志正文中做全文检索。

| 字段       | 备注 |
|------------|------|
| ts         | 日志时间 |
| tenant_id  | 租户标识 |
| host       | 主机或节点 |
| message    | 日志正文 |

建表语句如下：

```sql
CREATE TABLE tenant_logs (
    ts TIMESTAMP NOT NULL,
    tenant_id STRING NOT NULL,
    host STRING,
    message STRING,
    timestamp key(ts),
    inverted index idx_tenant_message (message) with (tokenizer=chinese, case_sensitive=false, with_position=true)
)
PARTITION BY HASH(tenant_id) PARTITIONS 4;
```

**说明**：

- `tenant_id` 作为分区键可提升租户内查询效率
- 根据日志语言选择 `tokenizer`（如 `english` / `chinese`）
- `with_position=true` 可支持更精确的短语检索与相关性排序

## PARTITIONS 数量建议

- 当前 `PARTITIONS` 数量在建表后不支持动态修改，需在建表阶段一次性规划
- Partition 规划建议（写入能力与资源权衡）可直接参考：[高性能写入 - Partition 数量](../high-performance-ingestion.md#partition-count)
- 分区键应优先选择高基数且查询中常作为过滤条件的字段（如 `service`、`tenant_id`）
- 若后续发现 partition 规划不合理，通常需要通过新建目标表并迁移数据来调整

## 相关文档

- [CREATE 语句参考指南](../../sql-reference/statements/create.md)
- [REFRESH 语句详解](../../sql-reference/statements/refresh.md)
- [DROP 语句详解](../../sql-reference/statements/drop.md)
- [全文索引函数](../../sql-reference/fulltext-functions.md)
- [日志检索概述](../../log-search/overview.md)
