---
title: "Datalayers 流计算概述"
description: "介绍 Datalayers 流计算的核心链路、Source 与 Pipeline 模型、支持的接入方式、典型场景以及当前能力边界。"
---

# Datalayers 流计算概述

流计算用于持续接收外部事件流，并在数据到达时完成处理和写入。它也可以理解为实时 ETL、实时数据清洗或轻量级流式处理。相比先落库再离线处理的方式，它更适合实时监控、告警预处理和在线数据清洗等低延迟场景。

## 核心处理链路

在 Datalayers 中，流计算链路由三部分组成：

- `SOURCE`：定义外部数据流的 schema、connector 和 format
- `PIPELINE`：定义实时处理逻辑
- `SINK TABLE`：接收 pipeline 输出结果的内部表，目前必须是 `TimeSeries` 表

流程如下：

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

## 典型应用场景

- 从 Kafka、MQTT、HTTP 持续接收或拉取数据
- 在数据入库前做字段筛选、投影、阈值过滤等实时处理
- 将清洗、转换后的结果写入内部时序表，供 SQL 查询、看板或告警系统使用
- 作为边缘采集或消息接入后的第一段在线处理链路

当前 `PIPELINE` 仅支持基于单个 source 的投影和过滤，暂不支持 join、聚合、窗口、排序、limit、union、子查询等复杂算子。

## 核心 SQL 对象

### Source

`SOURCE` 用于声明输入流的列定义、connector 和 format。它本身不保存数据，只负责将外部消息解码为表结构。示例：

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

`PIPELINE` 表示持续运行的实时任务，负责从 source 读取数据、执行处理并写入 sink table。

```sql
CREATE PIPELINE p_kafka
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_kafka
WHERE value >= 2.0;
```

### Sink Table

`SINK` 不是独立对象，而是一张已存在的内部表。当前必须使用 `TimeSeries` 引擎，且查询输出 schema 必须与 sink table 严格兼容。

## Connector 与 Format

Connector 用于描述外部数据系统，决定 source 如何读取数据。

Format 用于描述消息编码格式，Datalayers 会据此将原始消息解码为表结构。

当前版本支持的 connector 类型请参考 [流计算 Connectors](./connectors.md)。

当前版本支持的消息格式请参考 [流计算 Formats](./format.md)。

## 管理与运维

流计算对象创建后，可以用以下语句查看和控制：

```sql
-- 查看当前数据库下的所有 source
SHOW SOURCES;

-- 查看当前数据库下的所有 pipeline
SHOW PIPELINES;

-- 查看指定 source 的定义 SQL
SHOW CREATE SOURCE src_kafka;

-- 查看指定 pipeline 的定义 SQL
SHOW CREATE PIPELINE p_kafka;

-- 停止一个运行中的 pipeline
ALTER PIPELINE p_kafka STOP;

-- 重启一个 pipeline
ALTER PIPELINE p_kafka RESTART;

-- 删除指定 pipeline
DROP PIPELINE p_kafka;

-- 删除指定 source
DROP SOURCE src_kafka;
```

## 相关文档

- 了解如何快速体验一条最小流计算链路：[快速开始](./quick-start.md)
- 了解 Datalayers 的流计算模型 ：[计算模型](./model.md)
- 了解流计算的典型业务场景和示例：[应用示例](./use_cases.md)
- 了解 JSON、CSV 等消息格式及其配置方式：[流计算 Formats](./format.md)
- 了解当前支持的 connector 类型和配置方式：[流计算 Connectors](./connectors.md)
