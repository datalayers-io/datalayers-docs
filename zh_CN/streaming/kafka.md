---
title: "Kafka Connector"
description: "介绍 Kafka source connector 的配置方式、适用场景和示例。"
---

# Kafka Connector

Kafka connector 用于将 Kafka topic 中的消息持续读入 Datalayers source。

## 适用场景

- 设备遥测数据接入
- 应用事件流接入
- 日志或指标预处理

## 配置项

| 配置项 | 类型 | 默认值 | 必选 | 说明 |
| --- | --- | --- | --- | --- |
| `connector` | STRING | 无 | Yes | 固定为 `kafka` |
| `brokers` | STRING | 无 | Yes | Kafka broker 列表，逗号分隔，格式为 `host:port` |
| `topic` | STRING | 无 | Yes | 要消费的 topic |
| `offset` | STRING | `latest` | No | 起始消费位置，支持 `earliest`、`latest` |
| `group.id` | STRING | `datalayers-<pipeline_id>-group` | No | Consumer group ID，用于提交和恢复消费进度 |
| `client.id` | STRING | `datalayers-<pipeline_id>-<task_index>-consumer` | No | Kafka client ID |
| `security.protocol` | STRING | 无 | No | 安全协议，支持 `PLAINTEXT`、`SSL`、`SASL_PLAINTEXT`、`SASL_SSL` |
| `sasl.mechanism` | STRING | 无 | No | SASL 机制，支持 `PLAIN`、`SCRAM-SHA-256`、`SCRAM-SHA-512` |
| `sasl.username` | STRING | 无 | No | SASL 用户名 |
| `sasl.password` | STRING | 无 | No | SASL 密码 |

当配置项存在特殊字符，例如'.'号，在配置这些配置项时，需使用单引号括起来，例如：

```sql
CREATE SOURCE src_kafka_meta (
  ...
) WITH (
  'group.id' = "your_group_id",
  'client.id' = "your_client_id"
);
```

## Metadata 字段

Kafka source 当前支持以下 metadata key：

| metadata key | 类型 | 说明 |
| --- | --- | --- |
| `topic` | STRING | 当前消息所在的 topic |
| `partition` | INT32 | 当前消息所在分区 |
| `offset` | INT64 | 当前消息 offset |

示例：

```sql
CREATE SOURCE src_kafka_meta (
  ts TIMESTAMP(9),
  value FLOAT64,
  source_topic STRING METADATA FROM 'topic',
  source_partition INT32 METADATA FROM 'partition',
  source_offset INT64 METADATA FROM 'offset'
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_stream_demo',
  format='json'
);
```

Format 相关配置请参考 [Formats](./format.md)。

## 示例1：读取 Kafka JSON 事件流

### 1. 启动 Kafka

先拉取 Kafka 镜像：

```bash
docker pull confluentinc/cp-kafka:7.7.1
```

```bash
docker run -d --name dl-kafka \
  -p 9092:9092 \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_PROCESS_ROLES='broker,controller' \
  -e KAFKA_LISTENERS='PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:9093' \
  -e KAFKA_ADVERTISED_LISTENERS='PLAINTEXT://127.0.0.1:9092' \
  -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP='CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT' \
  -e KAFKA_CONTROLLER_QUORUM_VOTERS='1@127.0.0.1:9093' \
  -e KAFKA_CONTROLLER_LISTENER_NAMES='CONTROLLER' \
  -e KAFKA_INTER_BROKER_LISTENER_NAME='PLAINTEXT' \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  -e CLUSTER_ID='MkU3OEVBNTcwNTJENDM2Qk' \
  confluentinc/cp-kafka:7.7.1
```

创建 topic：

```bash
docker exec -it dl-kafka kafka-topics \
  --bootstrap-server 127.0.0.1:9092 \
  --create \
  --topic topic_stream_demo \
  --partitions 1 \
  --replication-factor 1
```

### 2. 创建 sink table、source 和 pipeline

```sql
CREATE DATABASE stream_demo;
USE stream_demo;

CREATE TABLE sink_t (
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE SOURCE src_kafka (
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_stream_demo',
  offset='earliest',
  'group.id'='stream_demo_group',
  'client.id'='stream_demo_client',
  format='json'
);

CREATE PIPELINE p_kafka
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_kafka
WHERE value >= 2.0;
```

### 3. 发布消息

```bash
docker exec -it dl-kafka kafka-console-producer \
  --bootstrap-server 127.0.0.1:9092 \
  --topic topic_stream_demo
```

输入：

```json
{"ts":"2025-01-01T00:00:01Z","sid":"sid-1","value":1.0}
{"ts":"2025-01-01T00:00:02Z","sid":"sid-2","value":2.0}
{"ts":"2025-01-01T00:00:03Z","sid":"sid-3","value":3.0}
```

### 4. 查询结果

```sql
SELECT ts, sid, value FROM sink_t ORDER BY ts;
```

预期仅看到 `value >= 2.0` 的两行。

## 示例2：Unix 时间戳处理

一个常见的场景是，当消息中的时间字段为 Unix 时间戳，非 RFC3339 / ISO8601 格式的时间字符串。同时 sink table 的时间戳列为 Timestamp 类型，且精度可能与消息中时间戳精度不一致。我们支持两种方式处理这种场景。

### 方式一：CREATE SOURCE 时用计算列转换

在 source 中声明 `ts` 为 `INT64`，再用计算列语法（使用 `AS` 指定列的运行时计算表达式）将其转为时间戳。这个转换发生在运行时，source 读入数据后会自动根据表达式和列类型计算 `ts_timestamp` 列：

```sql
CREATE SOURCE src_kafka_unixtime (
  ts INT64,
  sid STRING,
  value FLOAT64,
  ts_timestamp TIMESTAMP(3) AS ts * 1000
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_unixtime_demo',
  format='json'
);

CREATE PIPELINE p_kafka_unixtime
SINK TO sink_t
AS
SELECT ts_timestamp AS ts, sid, value
FROM src_kafka_unixtime
WHERE value >= 2.0;
```

其中 `ts * 1000` 将秒级时间戳转为毫秒，系统自动 CAST 为 `TIMESTAMP(3)`。也可以显式声明类型转换，例如 `ts_timestamp TIMESTAMP(3) AS CAST(ts * 1000 AS TIMESTAMP(3))`。

### 方式二：CREATE PIPELINE 时用 UDF 转换

source 保持 `ts` 为 `INT64`，pipeline 中调用函数转换：

```sql
CREATE SOURCE src_kafka_unixtime (
  ts INT64,
  sid STRING,
  value FLOAT64
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_unixtime_demo',
  format='json'
);

CREATE PIPELINE p_kafka_unixtime
SINK TO sink_t
AS
SELECT from_unixtime(ts) AS ts, sid, value
FROM src_kafka_unixtime
WHERE value >= 2.0;
```

### 发布消息

```json
{"ts":1735689600,"sid":"sid-1","value":1.0}
{"ts":1735689660,"sid":"sid-2","value":2.0}
```

`sink_t` 表结构与示例1相同。两种方式均输出 `TIMESTAMP` 类型的时间戳列，可与 sink 表兼容。

## 注意事项

- 当前 Kafka 仅支持作为 source，不支持作为 sink
- 若缺少必选项，如 `brokers`，`CREATE SOURCE` 会直接失败
- 若 `DROP SOURCE` 时该 source 仍被某个 pipeline 引用，执行会失败
