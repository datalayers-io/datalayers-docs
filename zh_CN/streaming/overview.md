---
title: "流计算概述"
description: "Datalayers 流计算概述，介绍 source、pipeline、sink table 组成的实时处理链路，以及当前支持的 connector、format 和典型能力边界。"
---

# 流计算概述

## 什么是流计算

流计算用于持续接收外部事件流，并在数据到达时执行实时计算和写入。相比先落库再离线处理的方式，流计算更适合实时监控、告警预处理、在线数据清洗等延迟敏感型任务。

在 Datalayers 中，一条最小的流计算链路由三部分组成：

- `SOURCE`：定义外部数据流的 schema、connector 和 format
- `PIPELINE`：定义实时处理逻辑
- `SINK TABLE`：接收 pipeline 输出结果的内部表，目前必须是 `TimeSeries` 表

典型流程如下：

```text
Kafka / MQTT / HTTP
        |
        v
   CREATE SOURCE
        |
        v
  CREATE PIPELINE ... AS SELECT ...
        |
        v
   TimeSeries sink table
```

## 可以做什么

当前版本适合以下场景：

- 从 Kafka、MQTT、Polling HTTP 持续接收或拉取数据
- 在数据入库前做字段筛选、投影、阈值过滤等实时计算
- 将清洗、转换后的结果写入内部时序表，供 SQL 查询、看板或告警系统使用

当前版本暂不适合复杂流分析。`PIPELINE` 查询目前只支持单个 source 上的 `SELECT`、`WHERE` 和投影，不支持 join、聚合、窗口、排序、limit、union、子查询等复杂算子。

## 主要 SQL 对象

### Source

`SOURCE` 用来声明输入流的列定义、连接方、数据格式等信息。它与表不同，本身不保存数据，只负责把外部消息解码、转换成表结构。示例：

```sql
CREATE SOURCE src_kafka (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_stream_demo',
  format='json'
);
```

### Pipeline

`PIPELINE` 表示一个持续运行的实时任务。它从 source 读取数据，执行计算，再写入 sink table。

```sql
CREATE PIPELINE p_kafka
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_kafka
WHERE value >= 2.0;
```

### Sink Table

`SINK` 不是独立的流对象，而是一个已经存在的内部表。当前必须使用 `TimeSeries` 引擎，且 query 输出 schema 必须和 sink table 严格兼容。

## Connectors 与 Formats

Connector 描述一个外部数据系统，它可以是数据源（Source），Datalayers 负责从这个系统持续读取数据。它也可以是数据汇（Sink），Datalayers 负责把计算结果持续写入这个系统。

Format 描述数据的编码格式，Datalayers 负责把原始消息解码成表结构。

当前版本支持的 connectors 请参考 [Connectors](./connectors.md)。

当前版本支持的 formats 请参考 [Formats](./format.md)。

## 管理与运维

流计算对象创建后，可以用以下语句查看和控制：

```sql
# 查看当前数据库下的所有 source
SHOW SOURCES;

# 查看当前数据库下的所有 pipeline
SHOW PIPELINES;

# 查看指定 source 的定义 SQL
SHOW CREATE SOURCE src_kafka;

# 查看指定 pipeline 的定义 SQL
SHOW CREATE PIPELINE p_kafka;

# 停止一个运行中的 pipeline
ALTER PIPELINE p_kafka STOP;

# 重启一个 pipeline
ALTER PIPELINE p_kafka RESTART;

# 删除指定 pipeline
DROP PIPELINE p_kafka;

# 删除指定 source
DROP SOURCE src_kafka;
```

## 相关文档

- 了解如何快速体验一条最小流计算链路：[快速开始](./quick-start.md)
- 了解 source、pipeline、sink table 等核心概念：[核心概念](./concepts.md)
- 了解流计算的典型业务场景和示例：[案例](./use_cases.md)
- 了解 JSON、CSV 等消息格式及其配置方式：[Formats](./format.md)
- 了解当前支持的 connector 类型和配置方式：[Connectors](./connectors.md)
