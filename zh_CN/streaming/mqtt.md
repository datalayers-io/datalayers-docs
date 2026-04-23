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
| `broker` | STRING | 无 | Yes | MQTT broker 地址，格式为 `[scheme://]host:port`；未写 scheme 时默认 `tcp` |
| `topic` | STRING | 无 | Yes | 要订阅的 topic 或 topic filter |
| `qos` | STRING | `0` | No | 服务质量等级，支持 `0`、`1`、`2` |
| `client_id` | STRING | `datalayers-<job_id>-consumer` | No | MQTT client ID |
| `keep_alive` | STRING | `60s` | No | keep alive 时间，采用 duration 格式，例如 `60s` |
| `connect_timeout` | STRING | `10s` | No | 建立连接的超时时间 |
| `version` | STRING | 无 | No | MQTT 协议版本，支持 `3.1.1`、`5.0` |
| `username` | STRING | 无 | No | 认证用户名 |
| `password` | STRING | 无 | No | 认证密码 |
| `ca` | STRING | 无 | No | TLS CA 文件或内容 |
| `cert` | STRING | 无 | No | TLS 客户端证书 |
| `key` | STRING | 无 | No | TLS 客户端私钥 |

其中，`qos` 表示 MQTT 消息投递质量等级：

- `0`：至多一次。性能最好，但消息可能丢失。
- `1`：至少一次。更可靠，但消息可能重复。
- `2`：仅有一次。语义最强，但开销更高。

`broker` 支持以下 scheme：

- `tcp`
- `ssl`
- `ws`
- `wss`

## Metadata 字段

MQTT source 当前支持以下 metadata key：

| metadata key | 类型 | 说明 |
| --- | --- | --- |
| `topic` | STRING | 当前消息实际所在的 topic |

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
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64,
  TIMESTAMP KEY(ts)
) ENGINE=TimeSeries
PARTITION BY HASH(sid) PARTITIONS 1;

CREATE SOURCE src_mqtt (
  ts TIMESTAMP(9),
  sid STRING,
  value FLOAT64
) WITH (
  connector='mqtt',
  broker='tcp://127.0.0.1:1883',
  topic='topic/stream_demo',
  qos='1',
  keep_alive='60s',
  connect_timeout='10s',
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
- `topic` 支持普通 topic filter，也支持 `$share/<group>/<filter>` 共享订阅格式
