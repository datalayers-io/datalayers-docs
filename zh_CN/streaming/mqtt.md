---
title: "MQTT Connector"
description: "介绍 MQTT source connector 的配置方式、适用场景和示例。"
---

# MQTT Connector

MQTT connector 用于订阅 MQTT broker 中的主题消息，并持续读入 Datalayers source。

## 配置项

| 配置项 | 类型 | 默认值 | 必选 | 说明 |
| --- | --- | --- | --- | --- |
| `connector` | STRING | 无 | Yes | 固定为 `mqtt` |
| `broker` | STRING | 无 | Yes | MQTT broker 地址，格式为 `host:port` |
| `topic` | STRING | 无 | Yes | 要订阅的 topic 或 topic filter |
| `qos` | STRING | `0` | No | 服务质量等级，支持 `0`、`1`、`2` 或对应别名 |
| `client_id` | STRING | 无 | No | MQTT client ID |
| `keep_alive` | INT | 无 | No | keep alive 秒数 |
| `username` | STRING | 无 | No | 认证用户名 |
| `password` | STRING | 无 | No | 认证密码 |

其中，`qos` 表示 MQTT 消息投递质量等级，支持数字写法和别名写法：

- `0` 或 `at_most_once`：至多一次。性能最好，但消息可能丢失。
- `1` 或 `at_least_once`：至少一次。更可靠，但消息可能重复。
- `2` 或 `exactly_once`：仅有一次。语义最强，但开销更高。

Format 相关配置请参考 [Formats](./format.md)。

## 示例：读取 MQTT JSON 消息

### 1. 启动 MQTT broker

```bash
docker run -d --name emqx-enterprise -p 1883:1883 -p 8083:8083 -p 8084:8084 -p 8883:8883 -p 18083:18083 emqx/emqx-enterprise:6.1.1
```

### 2. 创建 sink table、source 和 pipeline

```sql
CREATE DATABASE stream_demo_mqtt;
USE stream_demo_mqtt;

CREATE TABLE sink_t (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE SOURCE src_mqtt (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='mqtt',
  broker='127.0.0.1:1883',
  topic='topic/stream_demo',
  qos='1',
  format='json'
);

CREATE PIPELINE p_mqtt
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_mqtt
WHERE value >= 2.0;
```

### 3. 发布测试消息

如果环境里有 `mosquitto_pub`，可以直接发送：

```bash
mosquitto_pub -h 127.0.0.1 -p 1883 -t topic/stream_demo -m '{"ts":"2025-01-01T00:00:01Z","sid":"sid-1","value":1.0}'
mosquitto_pub -h 127.0.0.1 -p 1883 -t topic/stream_demo -m '{"ts":"2025-01-01T00:00:02Z","sid":"sid-2","value":2.0}'
mosquitto_pub -h 127.0.0.1 -p 1883 -t topic/stream_demo -m '{"ts":"2025-01-01T00:00:03Z","sid":"sid-3","value":3.0}'
```

### 4. 查询结果

```sql
SELECT ts, sid, value FROM sink_t ORDER BY ts;
```

预期仅看到 `value >= 2.0` 的两行。

## 注意事项

- 当前 MQTT 仅支持作为 source，不支持作为 sink
- 建议先确认 topic 中消息 schema 与 source 列定义一致
- `qos` 默认值为 `0`，如需更强投递保障可显式设置为 `1` 或 `2`
