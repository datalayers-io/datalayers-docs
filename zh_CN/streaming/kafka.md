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
| `offset` | STRING | `latest` | No | 起始消费位置，支持 `earliest`、`latest`、`at(<timestamp>)` |
| `group_id` | STRING | 无 | No | 消费组 ID，用于基于已提交 offset 的启动和消费进度跟踪 |
| `auth_type` | STRING | `none` | No | 鉴权类型，支持 `none`、`sasl` |
| `protocol` | STRING | `sasl_plaintext` | No | SASL 协议。仅在 `auth_type='sasl'` 时生效；当前仅支持 `sasl_plaintext` |
| `mechanism` | STRING | `PLAIN` | No | SASL 机制。仅在 `auth_type='sasl'` 时生效；支持 `PLAIN`、`SCRAM-SHA-256`、`SCRAM-SHA-512` |
| `username` | STRING | 无 | No | SASL 用户名。仅在 `auth_type='sasl'` 时必填 |
| `password` | STRING | 无 | No | SASL 密码。仅在 `auth_type='sasl'` 时必填 |

## 配置约束

- `auth_type='none'`：表示不使用鉴权。此时不能设置 `protocol`、`mechanism`、`username`、`password`。
- `auth_type='sasl'`：表示使用 SASL 鉴权。此时必须同时设置 `username` 和 `password`。
- `auth_type='sasl'` 时，`protocol` 和 `mechanism` 可省略，分别默认取 `sasl_plaintext` 和 `PLAIN`。
- 当前 `protocol` 仅支持 `sasl_plaintext`。`sasl_ssl` 还未支持，配置后会报错。
- `offset='at(<timestamp>)'` 中的 `<timestamp>` 必须是整数时间戳。

Format 相关配置请参考 [Formats](./format.md)。

## 示例：读取 Kafka JSON 事件流

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

## 注意事项

- 当前 Kafka 仅支持作为 source，不支持作为 sink
- 若缺少必选项，如 `brokers`，`CREATE SOURCE` 会直接失败
- 若 `DROP SOURCE` 时该 source 仍被某个 pipeline 引用，执行会失败
