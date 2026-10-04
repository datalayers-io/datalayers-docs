---
title: "Datalayers 流计算 - 计算能力"
description: "介绍 Datalayers 流计算支持的计算功能，包括投影、过滤、Lookup Join，并提供 SQL 示例与预期结果。"
---

# 流计算 - 计算能力

本文介绍 Datalayers 流计算当前支持的计算能力，并给出每种能力的 `CREATE PIPELINE` SQL 示例及预期的查询结果。

## 支持的能力

| 能力 | 说明 |
| --- | --- |
| 投影（Projection） | 从 source 中选择特定列输出 |
| 过滤（Filter） | 使用 `WHERE` 子句对事件进行条件过滤 |
| Lookup Join | 将流式 source 与 Datalayers 内部维表（TimeSeries）进行 `INNER JOIN` 或 `LEFT JOIN` |

> 注意：当前版本仅支持 TimeSeries 表作为维表，暂不支持 Relational 表。

## 环境准备

以下示例均基于 Kafka source。请确保已完成 [快速开始](./quick-start.md) 中的基础环境准备，包括：

1. **启动 Kafka**

   ```bash
   docker pull confluentinc/cp-kafka:7.7.1
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
     -e CLUSTER_ID='MkU3OEVBNTcwNTJENDM2Qk' \
     confluentinc/cp-kafka:7.7.1
   ```

2. **进入 dlsql**

   ```bash
   dlsql -h 127.0.0.1 -P 8360 -u admin -p public
   ```

3. **创建数据库**

   ```sql
   CREATE DATABASE stream_demo;
   USE stream_demo;
   ```

### 公共 Kafka Topic

本文所有示例共用同一个 Kafka topic `topic_compute_demo`。创建 topic：

```bash
docker exec -it dl-kafka kafka-topics \
  --bootstrap-server 127.0.0.1:9092 \
  --create --topic topic_compute_demo \
  --partitions 1 --replication-factor 1
```

### 公共 Source

创建一个公共 source，后续各个示例会在此基础上创建 pipeline：

```sql
CREATE SOURCE src_events (
  ts TIMESTAMP(9),
  order_id STRING,
  customer_id STRING,
  product STRING,
  quantity INT32,
  price FLOAT64,
  WATERMARK FOR ts
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_compute_demo',
  offset='earliest',
  format='json'
);
```

### 公共 Sink Table

所有示例共享同一个 sink table（每次示例使用前会清空或删除重建）：

```sql
CREATE TABLE sink_t (
  ts TIMESTAMP(9),
  order_id STRING,
  customer_id STRING,
  product STRING,
  quantity INT32,
  price FLOAT64,
  -- 以下是 lookup join 示例可能新增的列
  customer_name STRING,
  customer_tier STRING,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(order_id) PARTITIONS 1;
```

### 发布测试数据

```bash
docker exec -it dl-kafka kafka-console-producer \
  --bootstrap-server 127.0.0.1:9092 \
  --topic topic_compute_demo
```

输入以下 JSON 数据：

```json
{"ts":"2025-01-01T00:00:01Z","order_id":"ord-1","customer_id":"cust-a","product":"widget","quantity":10,"price":9.99}
{"ts":"2025-01-01T00:00:02Z","order_id":"ord-2","customer_id":"cust-b","product":"gadget","quantity":5,"price":19.99}
{"ts":"2025-01-01T00:00:03Z","order_id":"ord-3","customer_id":"cust-a","product":"doodad","quantity":2,"price":4.99}
{"ts":"2025-01-01T00:00:04Z","order_id":"ord-4","customer_id":"cust-c","product":"widget","quantity":1,"price":9.99}
```

输入完毕后按 `Ctrl-D`。

---

## 投影（Projection）

投影用于选择 source 的部分列输出到 sink，也可以通过表达式计算新列。

### 示例：选择部分列

```sql
CREATE PIPELINE p_projection
SINK TO sink_t
AS
SELECT ts, order_id, customer_id, product
FROM src_events;
```

### 查询结果

```sql
SELECT order_id, customer_id, product FROM sink_t ORDER BY order_id;
```

```text
+---------+-------------+---------+
| order_id| customer_id | product |
+---------+-------------+---------+
| ord-1   | cust-a      | widget  |
| ord-2   | cust-b      | gadget  |
| ord-3   | cust-a      | doodad  |
| ord-4   | cust-c      | widget  |
+---------+-------------+---------+
```

### 清理

```sql
ALTER PIPELINE p_projection STOP;
DROP PIPELINE p_projection;
```

---

## 过滤（Filter）

使用 `WHERE` 子句仅保留满足条件的事件。

### 示例：过滤数量大于 2 且价格大于 5.0 的订单

```sql
CREATE PIPELINE p_filter
SINK TO sink_t
AS
SELECT ts, order_id, customer_id, product, quantity, price
FROM src_events
WHERE quantity > 2 AND price > 5.0;
```

### 查询结果

```sql
SELECT order_id, customer_id, quantity, price FROM sink_t ORDER BY order_id;
```

```text
+---------+-------------+----------+-------+
| order_id| customer_id | quantity | price |
+---------+-------------+----------+-------+
| ord-1   | cust-a      | 10       | 9.99  |
| ord-2   | cust-b      | 5        | 19.99 |
+---------+-------------+----------+-------+
```

注意：`ord-3` 虽然 `price` 满足条件，但 `quantity` 为 2（不大于 2），因此被过滤；`ord-4` 的 `quantity` 为 1 且 `price` 为 9.99，同样被过滤。

### 清理

```sql
ALTER PIPELINE p_filter STOP;
DROP PIPELINE p_filter;
```

---

## Lookup Join

Lookup Join 允许将流式 source 与 Datalayers 内部的维表进行关联，用 source 中的字段去维表中查找对应的属性，并将查到的列拼接到输出中。

### 支持情况

| 特性 | 支持 |
| --- | --- |
| JOIN 类型 | `INNER JOIN`、`LEFT JOIN` |
| 维表类型 | TimeSeries 表 |
| JOIN 条件 | 等值连接（`=`），右表列为维表主键列 |
| 复合主键 | 支持（只要 JOIN 条件中的右表列是主键的一部分即可） |
| 多行匹配 | 按 SQL 标准行为处理：维表中多行匹配同一 key 时，每个匹配行都与 source 行组合输出多条结果 |

> 当前版本**不支持**：
> - 非等值连接
> - `RIGHT JOIN` / `FULL OUTER JOIN`
> - Relational 表作为维表
> - 外部系统（MySQL、Redis 等）作为维表

### 维表准备

创建一个客户维表，包含 `customer_id`、`customer_name` 和 `tier`。

```sql
CREATE TABLE dim_customers (
  customer_id STRING,
  customer_name STRING,
  tier STRING,
  ts TIMESTAMP(9),
  TIMESTAMP KEY(ts),
  PRIMARY KEY (customer_id, ts)
) ENGINE=TimeSeries
PARTITION BY HASH(customer_id) PARTITIONS 1;
```

插入维表数据：

```sql
INSERT INTO dim_customers (ts, customer_id, customer_name, tier) VALUES
('2025-01-01T00:00:00Z', 'cust-a', 'Alice', 'Gold'),
('2025-01-01T00:00:00Z', 'cust-b', 'Bob', 'Silver');
-- cust-c 没有维表记录，用于展示 LEFT JOIN 的 NULL 填充行为
```

### INNER JOIN 示例

仅输出在维表中匹配到的订单，不匹配的订单被丢弃：

```sql
CREATE PIPELINE p_lookup_inner
SINK TO sink_t
AS
SELECT
  e.ts,
  e.order_id,
  e.customer_id,
  e.product,
  e.quantity,
  e.price,
  c.customer_name,
  c.tier
FROM src_events e
INNER JOIN dim_customers c
ON e.customer_id = c.customer_id;
```

查询结果：

```sql
SELECT order_id, customer_id, customer_name, tier FROM sink_t ORDER BY order_id;
```

```text
+---------+-------------+---------------+-------+
| order_id| customer_id | customer_name | tier  |
+---------+-------------+---------------+-------+
| ord-1   | cust-a      | Alice         | Gold  |
| ord-2   | cust-b      | Bob           | Silver|
| ord-3   | cust-a      | Alice         | Gold  |
+---------+-------------+---------------+-------+
```

`ord-4`（`cust-c`）在维表中没有记录，被 `INNER JOIN` 丢弃。

### LEFT JOIN 示例

LEFT JOIN 会保留所有 source 事件，维表中没有匹配时，维表列填充为 `NULL`：

```sql
CREATE PIPELINE p_lookup_left
SINK TO sink_t
AS
SELECT
  e.ts,
  e.order_id,
  e.customer_id,
  e.product,
  e.quantity,
  e.price,
  c.customer_name,
  c.tier
FROM src_events e
LEFT JOIN dim_customers c
ON e.customer_id = c.customer_id;
```

查询结果：

```sql
SELECT order_id, customer_id, customer_name, tier FROM sink_t ORDER BY order_id;
```

```text
+---------+-------------+---------------+-------+
| order_id| customer_id | customer_name | tier  |
+---------+-------------+---------------+-------+
| ord-1   | cust-a      | Alice         | Gold  |
| ord-2   | cust-b      | Bob           | Silver|
| ord-3   | cust-a      | Alice         | Gold  |
| ord-4   | cust-c      |               |       |
+---------+-------------+---------------+-------+
```

`ord-4`（`cust-c`）被保留，但 `customer_name` 和 `tier` 为空（NULL）。

### 清理

```sql
ALTER PIPELINE p_lookup_inner STOP;
DROP PIPELINE p_lookup_inner;
ALTER PIPELINE p_lookup_left STOP;
DROP PIPELINE p_lookup_left;
TRUNCATE TABLE sink_t;
```

---

## 限制与后续规划

| 能力 | 当前状态 | 后续规划 |
| --- | --- | --- |
| Relational 维表 | 不支持 | 后续版本支持 |
| 外部维表（MySQL、Redis 等） | 不支持 | 后续版本通过 `CREATE SOURCE ... WITH (lookup='true')` 支持 |
| `RIGHT JOIN` / `FULL OUTER JOIN` | 不支持 | 评估中 |
| 非等值 JOIN | 不支持 | 评估中 |
| CDC 维表更新 | 不支持 | 后续通过 TTL 或 CDC 管道支持 |
| Lookup Cache | 未启用 | 后续版本开启，减少重复查询 |
