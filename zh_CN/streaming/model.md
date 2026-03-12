---
title: "流计算模型"
description: "介绍 Datalayers 流计算模型，包括 source、pipeline、sink table 等核心概念，以及它们之间的关系。"
---

# 流计算模型

## 总体模型

Datalayers 的流计算采用 Dataflow 风格的处理模型。数据从外部系统持续进入 source，经由 pipeline 执行实时处理，最终写入内部 sink table。

```text
external system -> source -> pipeline -> sink table
```

这个模型强调两点：

- 数据是持续到达的，不是一次性批处理
- 处理逻辑会常驻运行，直到被停止、失败或删除

如果你想进一步了解 Google 对 Dataflow 框架的官方解释，可以参考
[Dataflow overview](https://docs.cloud.google.com/dataflow/docs/overview)。

## Source

`SOURCE` 是外部事件流在 Datalayers 中的入口。

它主要负责三件事：

- 定义输入数据的列结构
- 指定使用哪个 connector 读取数据
- 指定使用哪个 format 解码消息

例如：

```sql
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
```

需要注意：

- source 只描述输入流，不保存结果
- `WITH (...)` 必须非空，且 connector / format 选项会严格校验

## Pipeline

`PIPELINE` 是持续运行的实时任务定义。它绑定一个 source、一个 sink table，以及一条 `AS SELECT ...` 查询。

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
- 执行轻量级实时变换
- 将结果写入 sink table

当前版本对于 pipeline 有如下限制：

- 一个 pipeline 必须且只能引用一个 source
- 查询必须是 `SELECT`，不支持 CTE 语法
- 只支持投影和过滤
- 不支持 join、聚合、窗口、排序、limit、union、子查询等复杂算子

## Sink Table

sink 不是独立对象，而是 Datalayers 中已经存在的一张内部表。当前版本要求：

- sink table 必须事先创建
- sink table 必须使用 `TimeSeries` 引擎
- pipeline 输出列名和类型必须与 sink table 严格兼容
- sink table 中非空且没有默认值的列，必须出现在 pipeline 输出里

这意味着，设计 sink table 时应先确定 pipeline 输出 schema，再创建表结构。

## Pipeline 生命周期与状态

创建 pipeline 后，系统会在后台启动对应的实时任务。你可以通过 `SHOW PIPELINES` 观察其状态，例如：

- `Running`
- `Stopped`
- `Failed`

如果 pipeline 运行失败，`SHOW PIPELINES` 中还会看到 `last_error`，可用于定位问题。

常见运维动作：

```sql
ALTER PIPELINE p1 STOP;
ALTER PIPELINE p1 RESTART;
DROP PIPELINE p1;
```
