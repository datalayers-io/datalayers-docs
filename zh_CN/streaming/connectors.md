---
title: "Datalayers 流计算 Connectors"
description: "介绍 Datalayers 流计算支持的 Connector 类型、适用场景以及 Source 侧接入方式。"
---

# 流计算 Connectors

## 什么是 Connector

Connector 决定 source 如何从外部系统读取数据，或 sink 如何将数据写入外部系统，负责建立连接、拉取/推送消息，并将原始消息交给 format 解码。

当前版本中：

- source 和 sink 都支持 connector
- source connector 负责从外部系统读取数据
- sink connector 负责将数据写入外部目标（例如 blackhole）

## 支持的 Connector 类型

| Connector | 作为 source | 作为 sink | 典型场景 |
| --- | --- | --- | --- |
| Kafka | Yes | No | 消息队列事件流接入 |
| MQTT | Yes | No | IoT / 边缘设备消息接入 |
| HTTP | Yes | No | 单次或周期轮询 HTTP 接口 |
| Blackhole | No | Yes | 丢弃所有写入数据，用于测试或基准压测 |

### Kafka

Kafka connector 适合持续消费 topic 中的结构化事件流。

- 文档入口：[Kafka Connector](./kafka.md)
- format：`json`、`csv`
- metadata：`topic`、`partition`、`offset`，以及所有 source 都支持的通用 metadata `source_name`。其中 `source_name` 是 source 的名称，可以在 create source 时通过 `METADATA FROM 'source_name'` 引用

### MQTT

MQTT connector 适合订阅设备、网关或边缘服务上报的主题消息。

- 文档入口：[MQTT Connector](./mqtt.md)
- format：`json`、`csv`
- metadata：`topic`，以及通用 metadata `source_name`

### HTTP

HTTP connector 适合按固定周期轮询第三方 API 或内部 HTTP 服务。

- 文档入口：[HTTP Connector](./http.md)
- format：`json`、`csv`、`parquet`
- metadata：通用 metadata `source_name`

### Blackhole

Blackhole connector 是一个 sink 专用 connector，它会接收所有输入数据并直接丢弃，不写入任何存储。常用于测试、开发调试以及流计算框架的基准压测场景。

- 文档入口：[Blackhole Connector](./blackhole.md)
- format：不支持配置 format，因为它不需要对输入数据进行解码
