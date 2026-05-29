---
title: "Blackhole Connector"
description: "Blackhole 是一个 sink 专用 connector，接收所有输入数据并直接丢弃，适用于测试、开发调试和基准压测。"
---

# Blackhole Connector

## 概述

Blackhole connector 是一个 sink 专用 connector。它接收 pipeline 输出的所有数据并直接丢弃，不写入任何外部存储或内部表。Blackhole sink 的最典型用途包括：

- **功能测试**：验证 pipeline 定义是否正确、source 数据是否能被正常读取和执行
- **基准压测**：评估数据从 source 到 pipeline 的端到端吞吐量，排除 sink 写入延迟的影响
- **开发调试**：快速调试 pipeline 的 AS SELECT 逻辑，无需事先创建 sink table

## 配置选项

Blackhole connector 不需要任何额外配置选项。只需在 `CREATE SINK` 中指定 `connector='blackhole'` 即可。

## 使用示例

### 创建 Blackhole Sink

```sql
CREATE SINK bh WITH (connector='blackhole');
```

### 在 Pipeline 中使用 Blackhole Sink

```sql
CREATE SOURCE s1 (
    ts TIMESTAMP(9),
    sid STRING,
    value FLOAT64
) WITH (
    connector='http',
    endpoint='http://127.0.0.1:8080/data',
    poll='once',
    format='json'
);

CREATE SINK bh WITH (connector='blackhole');

CREATE PIPELINE p1
SINK TO bh
AS
SELECT ts, sid, value
FROM s1
WHERE value >= 2.0;
```

### 管理 Sink

```sql
-- 查看所有 sink
SHOW SINKS;

-- 查看 sink 的定义 SQL
SHOW CREATE SINK bh;

-- 删除 sink
DROP SINK bh;
```

## 注意事项

- Blackhole 是 sink 专用 connector，不能作为 source 使用
- 所有写入 blackhole 的数据都会被丢弃，无法恢复
- 删除被 pipeline 引用的 sink 前，需先删除对应的 pipeline
