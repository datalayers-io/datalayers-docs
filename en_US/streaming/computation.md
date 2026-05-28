---
title: "Datalayers Streaming - Computation"
description: "Describes the computation capabilities supported by Datalayers streaming, including projection, filtering, and Lookup Join, with SQL examples and expected results."
---

# Streaming - Computation

This document introduces the computation capabilities currently supported by Datalayers streaming and provides `CREATE PIPELINE` SQL examples with expected query results for each.

## Supported Capabilities

| Capability | Description |
| --- | --- |
| Projection | Select specific columns from the source to the sink |
| Filtering | Apply conditions on events using `WHERE` |
| Lookup Join | Join a streaming source with an internal Datalayers dimension table (TimeSeries) using `INNER JOIN` or `LEFT JOIN` |

> Note: The current version only supports TimeSeries tables as dimension tables. Relational tables are not yet supported.

## Environment Setup

The following examples are based on a Kafka source. Please complete the basic environment setup described in [Quick Start](/streaming/quick-start), including:

1. **Start Kafka**

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

2. **Launch dlsql**

   ```bash
   dlsql -h 127.0.0.1 -P 8360 -u admin -p public
   ```

3. **Create database**

   ```sql
   CREATE DATABASE stream_demo;
   USE stream_demo;
   ```

### Shared Kafka Topic

All examples share the same Kafka topic `topic_compute_demo`. Create the topic:

```bash
docker exec -it dl-kafka kafka-topics \
  --bootstrap-server 127.0.0.1:9092 \
  --create --topic topic_compute_demo \
  --partitions 1 --replication-factor 1
```

### Shared Source

Create a shared source for all subsequent pipeline examples:

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

### Shared Sink Table

All examples share the same sink table (truncate or recreate between examples):

```sql
CREATE TABLE sink_t (
  ts TIMESTAMP(9),
  order_id STRING,
  customer_id STRING,
  product STRING,
  quantity INT32,
  price FLOAT64,
  -- extra columns used by lookup join examples
  customer_name STRING,
  customer_tier STRING,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(order_id) PARTITIONS 1;
```

### Publish Test Data

```bash
docker exec -it dl-kafka kafka-console-producer \
  --bootstrap-server 127.0.0.1:9092 \
  --topic topic_compute_demo
```

Enter the following JSON data:

```json
{"ts":"2025-01-01T00:00:01Z","order_id":"ord-1","customer_id":"cust-a","product":"widget","quantity":10,"price":9.99}
{"ts":"2025-01-01T00:00:02Z","order_id":"ord-2","customer_id":"cust-b","product":"gadget","quantity":5,"price":19.99}
{"ts":"2025-01-01T00:00:03Z","order_id":"ord-3","customer_id":"cust-a","product":"doodad","quantity":2,"price":4.99}
{"ts":"2025-01-01T00:00:04Z","order_id":"ord-4","customer_id":"cust-c","product":"widget","quantity":1,"price":9.99}
```

Press `Ctrl-D` after input.

---

## Projection

Projection selects a subset of columns from the source to send to the sink. It can also compute derived columns via expressions.

### Example: Select Specific Columns

```sql
CREATE PIPELINE p_projection
SINK TO sink_t
AS
SELECT ts, order_id, customer_id, product
FROM src_events;
```

### Query Results

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

### Cleanup

```sql
ALTER PIPELINE p_projection STOP;
DROP PIPELINE p_projection;
```

---

## Filtering

Use the `WHERE` clause to keep only events that satisfy a condition.

### Example: Filter Orders with Quantity > 2 and Price > 5.0

```sql
CREATE PIPELINE p_filter
SINK TO sink_t
AS
SELECT ts, order_id, customer_id, product, quantity, price
FROM src_events
WHERE quantity > 2 AND price > 5.0;
```

### Query Results

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

`ord-3` has `price` 4.99 (not > 5.0), so it is filtered out. `ord-4` has `quantity` 1 (not > 2), so it is also filtered out.

### Cleanup

```sql
ALTER PIPELINE p_filter STOP;
DROP PIPELINE p_filter;
```

---

## Lookup Join

Lookup Join allows joining a streaming source with an internal Datalayers dimension table, using fields from the source to look up corresponding attributes in the dimension table and appending the matched columns to the output.

### Supported Features

| Feature | Support |
| --- | --- |
| JOIN Types | `INNER JOIN`, `LEFT JOIN` |
| Dimension Table Type | TimeSeries table |
| Join Condition | Equi-join (`=`), right-side column must be a dimension table primary-key column |
| Composite Keys | Supported (the join condition column just needs to be part of the primary key) |
| Multi-row Matches | Standard SQL join behavior: each matching row in the dimension table combines with the source row |

> Currently **not supported**:
> - Non-equi joins
> - `RIGHT JOIN` / `FULL OUTER JOIN`
> - Relational tables as dimension tables
> - External systems (MySQL, Redis, etc.) as dimension tables

### Dimension Table Setup

Create a customer dimension table with `customer_id`, `customer_name`, and `tier`.

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

Insert dimension data:

```sql
INSERT INTO dim_customers (ts, customer_id, customer_name, tier) VALUES
('2025-01-01T00:00:00Z', 'cust-a', 'Alice', 'Gold'),
('2025-01-01T00:00:00Z', 'cust-b', 'Bob', 'Silver');
-- cust-c has no dimension record — used to demonstrate NULL-fill in LEFT JOIN
```

### INNER JOIN Example

Only matched orders are emitted; unmatched orders are dropped:

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

Query results:

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

`ord-4` (`cust-c`) has no matching record in the dimension table and is dropped by `INNER JOIN`.

### LEFT JOIN Example

LEFT JOIN preserves all source events. When no dimension record matches, the dimension columns are NULL:

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

Query results:

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

`ord-4` (`cust-c`) is kept, but `customer_name` and `tier` are NULL.

### Cleanup

```sql
ALTER PIPELINE p_lookup_inner STOP;
DROP PIPELINE p_lookup_inner;
ALTER PIPELINE p_lookup_left STOP;
DROP PIPELINE p_lookup_left;
TRUNCATE TABLE sink_t;
```

---

## Limitations & Roadmap

| Capability | Status | Roadmap |
| --- | --- | --- |
| Relational dimension tables | Not supported | Future release |
| External dimension tables (MySQL, Redis, etc.) | Not supported | Future release via `CREATE SOURCE ... WITH (lookup='true')` |
| `RIGHT JOIN` / `FULL OUTER JOIN` | Not supported | Under evaluation |
| Non-equi joins | Not supported | Under evaluation |
| CDC dimension table updates | Not supported | Future TTL-based or CDC pipeline support |
| Lookup Cache | Not enabled | Will be enabled in a future release to reduce redundant queries |
