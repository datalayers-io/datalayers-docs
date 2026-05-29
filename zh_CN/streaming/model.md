---
title: "流计算模型"
description: "介绍 Datalayers 流计算的核心对象及其关系。"
---

# 流计算模型

## 总体模型

Datalayers 的流计算采用 Dataflow 风格的处理模型。数据从外部系统持续进入 source，经由 pipeline 处理后写入 sink table 或外部 sink。

```text
external system -> source -> pipeline -> sink table / external sink
```

这一模型强调两点：

- 数据是持续到达的，不是一次性批处理
- 处理逻辑会常驻运行，直到被停止、失败或删除

如果你想进一步了解 Google 对 Dataflow 框架的官方解释，可以参考
[Dataflow overview](https://docs.cloud.google.com/dataflow/docs/overview)。

## Source

`SOURCE` 是外部事件流进入 Datalayers 的入口。

它主要负责三件事：

- 定义输入数据的列结构
- 指定使用哪个 connector 读取数据
- 指定使用哪个 format 解码消息

例如：

```sql
CREATE SOURCE src_mqtt (
  ts TIMESTAMP(9) NOT NULL COMMENT 'event time',
  sid STRING,
  source_topic STRING METADATA FROM 'topic',
  topic_tag STRING AS source_topic,
  value FLOAT64
) WITH (
  connector='mqtt',
  broker='127.0.0.1:1883',
  topic='topic/stream_demo',
  qos='1',
  format='json'
);
```

需要注意：

- source 只描述输入流，不保存数据
- `WITH (...)` 必须非空，且 connector / format 选项会严格校验

## Pipeline

`PIPELINE` 是持续运行的实时任务定义，绑定一个 source、一个 sink 和一条 `AS SELECT ...` 查询。

```sql
CREATE PIPELINE p_mqtt
SINK TO sink_t
AS
SELECT ts, sid, value
FROM src_mqtt
WHERE value >= 2.0;
```

pipeline 的职责是：

- 从 source 中持续读取事件
- 执行轻量级实时处理
- 将结果写入指定的 sink

当前版本对于 pipeline 有如下限制：

- 一个 pipeline 必须且只能引用一个 source
- 查询必须是 `SELECT`，不支持 CTE 语法
- 只支持投影和过滤
- 不支持 join、聚合、窗口、排序、limit、union、子查询等复杂算子

## Sink

`SINK` 描述流计算的输出目标，可以为一个内部表（sink table）或一个外部 connector（external sink）。内部表通过 `CREATE TABLE` 创建，外部 connector 则通过 `CREATE SINK` 定义。它们均可用于 pipeline 的输出。

### Sink Table

Pipeline 可以将结果写入一张 Datalayers 内部表。当前版本要求：

- sink table 必须事先创建
- sink table 必须使用 `TimeSeries` 引擎
- pipeline 输出列名和类型必须与 sink table 兼容；当类型可转换时，系统会自动补充 cast
- sink table 中非空且没有默认值的列，必须出现在 pipeline 输出里

### External Sink

```sql
CREATE SINK bh WITH (connector='blackhole');
```

示例中创建了一个 `blackhole` sink，它会丢弃所有输入数据。当前支持的 sink connector 类型请参考 [流计算 Connectors](./connectors.md)。

需要注意：

- connector 是必填项
- 当前仅支持 `blackhole` connector

## Pipeline 生命周期与状态

创建 pipeline 后，系统会在后台启动对应的实时任务。可以通过 `SHOW PIPELINES` 查看其状态，例如：

- `Running`
- `Stopped`
- `Failed`

`SHOW PIPELINES` 当前会展示 `state`、`up_time`、`stopped_time` 等状态列；在 cluster 模式下还会展示 `assigned_node`。

常见运维动作：

```sql
ALTER PIPELINE p1 STOP;
ALTER PIPELINE p1 RESTART;
ALTER PIPELINE p1 STOP;
DROP PIPELINE p1;
```
