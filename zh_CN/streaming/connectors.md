---
title: "Datalayers 流计算 Connectors"
description: "介绍 Datalayers 流计算支持的 Connector 类型、适用场景以及 Source 侧接入方式。"
---

# 流计算 Connectors

## 什么是 Connector

Connector 决定 source 如何从外部系统读取数据，负责建立连接、拉取或订阅消息，并将原始消息交给 format 解码。

当前版本中：

- connector 只用于 source 侧
- 目前只支持 Datalayers 内部时序表作为 sink，暂不支持外部系统作为 sink
- 当前没有独立的 sink connector，也不支持 `CREATE SINK`

## 支持的 Connector 类型

| Connector | 作为 source | 作为 sink | 典型场景 |
| --- | --- | --- | --- |
| Kafka | Yes | No | 消息队列事件流接入 |
| MQTT | Yes | No | IoT / 边缘设备消息接入 |
| HTTP | Yes | No | 单次或周期轮询 HTTP 接口 |

### Kafka

Kafka connector 适合持续消费 topic 中的结构化事件流。

- 文档入口：[Kafka Connector](./kafka.md)
- format：`json`、`csv`

### MQTT

MQTT connector 适合订阅设备、网关或边缘服务上报的主题消息。

- 文档入口：[MQTT Connector](./mqtt.md)
- format：`json`、`csv`

### HTTP

HTTP connector 适合按固定周期轮询第三方 API 或内部 HTTP 服务。

- 文档入口：[HTTP Connector](./http.md)
- format：`json`、`csv`
