---
title: "应用示例"
description: "通过 Kafka、MQTT 和 HTTP 示例说明流计算的典型使用方式。"
---

# 应用示例

## 场景 1：Kafka 设备遥测阈值过滤

当前版本的流计算能力以在线清洗和简单过滤为主，暂不支持复杂窗口聚合、状态管理和事件时间处理等功能。

### Kafka 场景

设备持续上报遥测数据，只保留超过阈值的异常事件，并写入内部时序表供后续查询和告警使用。

### 建表

```sql
CREATE TABLE sink_device_alerts (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;
```

### 创建 Kafka source

```sql
CREATE SOURCE src_device_kafka (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_device_metrics',
  offset='earliest',
  format='json'
);
```

### 创建 Kafka pipeline

```sql
CREATE PIPELINE p_device_alerts
SINK TO sink_device_alerts
AS
SELECT ts, sid, value
FROM src_device_kafka
WHERE value >= 80.0;
```

### Kafka 场景价值

- 将高频原始数据过滤成低频异常流
- 降低下游表的写入量
- 便于后续告警系统或看板直接查询

## 场景 2：MQTT 现场数据预过滤

### MQTT 场景

工业设备或边缘网关通过 MQTT 上报 JSON 消息，只保留满足业务条件的数据写入数据库。

### 创建 MQTT source

```sql
CREATE SOURCE src_factory_mqtt (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='mqtt',
  broker='127.0.0.1:1883',
  topic='factory/line1/sensor',
  qos='1',
  format='json'
);
```

### 创建 MQTT sink table 和 pipeline

```sql
CREATE TABLE sink_factory_events (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE PIPELINE p_factory_events
SINK TO sink_factory_events
AS
SELECT ts, sid, value
FROM src_factory_mqtt
WHERE value >= 2.0;
```

### MQTT 场景价值

- 适合现场 MQTT 主题的在线接入
- 可以先完成统一 schema 和基础过滤，再进入内部分析链路

## 场景 3：HTTP 外部接口接入

### HTTP 场景

某个第三方系统仅提供 HTTP API，没有消息队列。此时可以按固定周期轮询接口，并将返回结果持续写入数据库。

### 创建 HTTP once source

```sql
CREATE SOURCE src_http_once (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='http',
  endpoint='http://127.0.0.1:18080/once',
  method='GET',
  poll='once',
  format='csv'
);
```

### 创建 HTTP interval source

```sql
CREATE SOURCE src_http_poll (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='http',
  endpoint='http://127.0.0.1:18080/poll?ts=${now_ts}',
  method='GET',
  poll='interval(200)',
  format='csv'
);
```

### 创建 HTTP pipeline

```sql
CREATE TABLE sink_http_poll (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE PIPELINE p_http_poll
SINK TO sink_http_poll
AS
SELECT ts, sid, value
FROM src_http_poll
WHERE value >= 201.0;
```

### HTTP 应用场景

- 适合轮询第三方接口、设备网关接口或内部 HTTP 服务
- 可以把 API 返回结果直接转成持续可查的表数据
