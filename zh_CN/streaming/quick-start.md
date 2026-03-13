---
title: "流计算快速开始"
description: "通过 Kafka 示例快速体验 Datalayers 流计算，从创建 Source、Pipeline 到写入 TimeSeries sink table 的完整链路。"
---

# 流计算快速开始

本文通过一个最小可运行示例，演示 `Kafka -> Source -> Pipeline -> Sink Table` 的完整链路，帮助你快速验证 Datalayers 流计算的基本能力。

## 前提条件

- Datalayers 已启动，并暴露 Arrow Flight SQL 服务于 8360 端口
- 已安装 `dlsql` 命令行工具
- 本机已安装 Docker

## 快速体验

### Step 1：启动 Kafka

先拉取 Kafka 镜像：

```bash
docker pull confluentinc/cp-kafka:7.7.1
```

使用单节点 KRaft 模式启动一个本地 Kafka 容器：

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

创建测试 topic：

```bash
docker exec -it dl-kafka kafka-topics \
  --bootstrap-server 127.0.0.1:9092 \
  --create \
  --topic topic_stream_demo \
  --partitions 1 \
  --replication-factor 1
```

### Step 2：进入 dlsql

```bash
dlsql -h 127.0.0.1 -P 8360 -u admin -p public
```

### Step 3：创建数据库和 sink table

```sql
CREATE DATABASE stream_demo;
USE stream_demo;

CREATE TABLE sink_t (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;
```

这里的 `sink_t` 是 pipeline 的写入目标。当前版本要求 sink table 必须为 `TimeSeries` 表，且 pipeline 输出列名与类型需要与目标表兼容。

### Step 4：创建 source 和 pipeline

创建 Kafka source：

```sql
CREATE SOURCE src_kafka (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_stream_demo',
  offset='earliest',
  format='json'
);
```

创建 pipeline，仅保留 `value >= 2.0` 的事件：

```sql
CREATE PIPELINE p_kafka
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_kafka
WHERE value >= 2.0;
```

### Step 5：向 Kafka 发布测试数据

在另一个终端启动 producer，然后写入测试数据。

```bash
docker exec -it dl-kafka kafka-console-producer \
  --bootstrap-server 127.0.0.1:9092 \
  --topic topic_stream_demo
```

输入以下三行 JSON：

```json
{"ts":"2025-01-01T00:00:01Z","sid":"sid-1","value":1.0}
{"ts":"2025-01-01T00:00:02Z","sid":"sid-2","value":2.0}
{"ts":"2025-01-01T00:00:03Z","sid":"sid-3","value":3.0}
```

按 `Ctrl-D` 结束输入。

### Step 6：查询 sink table

回到 `dlsql`，执行：

```sql
SELECT ts, sid, value FROM sink_t ORDER BY ts;
```

预期结果仅包含两行，也就是 `value >= 2.0` 的记录，说明 pipeline 过滤条件已经生效。

### Step 7：查看和控制流任务

查看 source、pipeline 和重建 SQL：

```sql
-- 查看当前数据库下的所有 source
SHOW SOURCES;

-- 查看当前数据库下的所有 pipeline
SHOW PIPELINES;

-- 查看指定 source 的定义 SQL
SHOW CREATE SOURCE src_kafka;

-- 查看指定 pipeline 的定义 SQL
SHOW CREATE PIPELINE p_kafka;
```

停止和重启 pipeline：

```sql
-- 停止一个运行中的 pipeline
ALTER PIPELINE p_kafka STOP;

-- 重启一个 pipeline
ALTER PIPELINE p_kafka RESTART;
```

### Step 8：清理资源

```sql
-- 删除 pipeline
DROP PIPELINE p_kafka;

-- 删除 source
DROP SOURCE src_kafka;

-- 删除 sink table
DROP TABLE sink_t;

-- 删除数据库
DROP DATABASE stream_demo;
```

```bash
docker rm -f dl-kafka
```

## 相关文档

- 了解 Datalayers 的流计算模型，请参考 [计算模型](./model.md)
- 想了解支持的消息格式，请参考 [流计算 Formats](./format.md)
- 想了解支持的 Connector、配置方式和示例，请参考 [流计算 Connectors](./connectors.md)
