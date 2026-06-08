---
title: "Datalayers Hybrid Cache Hint 使用指南"
description: "介绍如何通过 hybrid_cache Hint 按查询控制对象存储缓存的启用与禁用。"
---
# Hybrid Cache Hint 使用指南

## 概述

Datalayers 默认会使用 Hybrid Cache（内存 + 磁盘混合缓存）缓存对象存储中 Parquet 文件的数据和对象元信息，以加速查询。但某些场景下，用户可能需要绕过缓存。`hybrid_cache` Hint 允许为单个查询临时禁用混合缓存。

## 语法

```sql
-- 禁用缓存（当前查询不走 Hybrid Cache）
SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;

-- 显式启用缓存（默认行为，无需设置）。注意，需要用户在配置文件中配置 Hybrid Cache 后才能真正启用
SELECT /*+ SET_VAR(hybrid_cache=on) */ * FROM t;
```

支持的值（大小写不敏感）：

| 值 | 含义 |
|----|------|
| `on` 或 `1` | 启用缓存（默认） |
| `off` 或 `0` | 禁用缓存 |

可与其他 Hint 组合使用：

```sql
SELECT /*+ SET_VAR(parallel_degree=4), SET_VAR(hybrid_cache=off) */ * FROM t;
```

## 适用场景

- **缓存预热后的基准测试**：对比缓存命中与绕过缓存的性能差异
- **排查缓存相关问题**：怀疑缓存数据不一致时，禁用缓存以验证
- **特定大查询**：某条查询扫描数据量远超缓存容量，频繁 evict 其他热点数据，可临时禁用

## 如何验证

使用 `EXPLAIN` 或 `EXPLAIN ANALYZE` 查看物理计划输出，确认 hybrid cache 的状态：

```sql
-- 如果用户配置了 Hybrid Cache，PartitionScanExec 算子会显示 hybrid_cache=on
EXPLAIN SELECT * FROM t;

-- 如果用户没有配置 Hybrid Cache，或通过 hint 禁用缓存，PartitionScanExec 算子会显示 hybrid_cache=off
EXPLAIN SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;
```

> **注意**：若用户在启动 Datalayers 时未配置 Hybrid Cache（`object_store.file_cache` 和 `object_store.metadata_cache` 均为空），无论 Hint 设置为何，输出均显示 `hybrid_cache=off`。
