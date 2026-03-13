---
title: "Datalayers 流计算 Formats"
description: "介绍 Datalayers 流计算支持的消息格式、配置项、示例以及 JSON 与 CSV 的选型建议。"
---

# 流计算 Formats

Format 用于将 connector 读取的消息解析为 source 的列结构。

## 支持的 Formats

| Format | 适用 connector | 说明 |
| --- | --- | --- |
| JSON | Kafka、MQTT、HTTP | 适合结构化事件消息 |
| CSV | Kafka、MQTT、HTTP | 适合简单表格型文本或按行输入 |

## 通用规则

### 通用配置项

| 配置项 | 类型 | 默认值 | 必选 | 说明 |
| --- | --- | --- | --- | --- |
| `format` | STRING | 无 | Yes | 指定消息格式，当前支持 `json` 和 `csv` |
| `bad_data` | STRING | `drop` | No | 坏数据处理策略，支持 `drop` 或 `fail` |

说明：

- `bad_data` 仅对 source 生效
- 当前按逐行方式解码消息，适合 newline-delimited JSON 和按行 CSV

## JSON

### JSON 特点

- 适合结构化或半结构化事件
- 常用于 Kafka、MQTT 和 HTTP 返回的结构化消息
- 字段名通常可直接映射到 source 列名

### JSON 示例数据

```json
{"ts":"2025-01-01T00:00:01Z","sid":"sid-1","value":1.0}
{"ts":"2025-01-01T00:00:02Z","sid":"sid-2","value":2.0}
```

### JSON 配置项

| 配置项 | 类型 | 默认值 | 必选 | 说明 |
| --- | --- | --- | --- | --- |
| `unstructured` | BOOL | `false` | No | 是否允许更宽松的 JSON 解码，默认按 schema 严格解析 |

### JSON 配置示例

```sql
CREATE SOURCE src_json (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='kafka',
  brokers='127.0.0.1:9092',
  topic='topic_json_demo',
  format='json',
  unstructured='false',
  bad_data='fail'
);
```

## CSV

### CSV 特点

- 结构简单，适合规则化文本数据
- 适合 HTTP 接口返回的表格型数据，也可用于 Kafka 或 MQTT 中的按行 CSV 消息
- 每行对应一条记录

### CSV 示例数据

```text
2025-01-01T00:00:03Z,sid-once,101
2025-01-01T00:00:04Z,sid-poll-1,201
```

### CSV 配置项

| 配置项 | 类型 | 默认值 | 必选 | 说明 |
| --- | --- | --- | --- | --- |
| `has_header` | BOOL | `false` | No | 是否将首行作为表头 |
| `delimiter` | STRING | `,` | No | 单字节分隔符 |

### CSV 配置示例

```sql
CREATE SOURCE src_csv (
  ts TIMESTAMP(9) NOT NULL,
  sid STRING NOT NULL,
  value FLOAT64
) WITH (
  connector='http',
  endpoint='http://127.0.0.1:18080/poll',
  method='GET',
  poll='interval(1000)',
  format='csv',
  has_header='false',
  delimiter=','
);
```

## 选型建议

| 格式 | 推荐场景 | 不足 |
| --- | --- | --- |
| JSON | 结构化事件、MQTT / Kafka 消息 | 文本体积通常更大 |
| CSV | 简单行式数据、HTTP 接口文本返回 | 字段可读性和扩展性较弱 |

## 常见问题

### bad_data 怎么选择

当上游消息偶尔出现坏行、但更关注链路持续可用时，可以使用 `bad_data='drop'`，让系统跳过当前坏批次。

当希望格式错误立即暴露、便于定位上游数据问题时，可以使用 `bad_data='fail'`。

## 相关文档

- [流计算 Connectors](./connectors.md)
