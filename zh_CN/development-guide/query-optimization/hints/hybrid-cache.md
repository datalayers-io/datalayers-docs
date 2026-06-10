---
title: "Datalayers Hybrid Cache Hint 使用指南"
description: "介绍如何使用 hybrid_cache Hint 按查询控制是否使用混合缓存。"
---
# Hybrid Cache Hint 使用指南

## 概述

Datalayers 在配置文件中打开混合缓存后，在查询时默认使用 Hybrid Cache（内存加磁盘的混合缓存）来加速查询。在某些场景下，绕过缓存会更合适（如对非热点数据进行一次性的分析查询）。`hybrid_cache` Hint 可用于控制单个查询时选择是否使用混合缓存。

## 语法

```sql
-- 禁用缓存（当前查询不走 Hybrid Cache）
SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;

-- 显式启用缓存（默认行为）
-- 注意：只有在配置文件中启用了 Hybrid Cache，该设置才会生效
SELECT /*+ SET_VAR(hybrid_cache=on) */ * FROM t;
```

支持的值（大小写不敏感）：

| 值           | 含义             |
| :----------- | :--------------- |
| `on` 或 `1`  | 启用缓存（默认） |
| `off` 或 `0` | 禁用缓存         |

可与其他 Hint 组合使用：

```sql
SELECT /*+ SET_VAR(parallel_degree=4), SET_VAR(hybrid_cache=off) */ * FROM t;
```

## 适用场景

- **缓存预热后的基准测试**：对比缓存命中与绕过缓存的性能差异
- **大范围扫描查询**：单条查询扫描的数据量远超缓存容量、可能频繁淘汰热点数据时，可临时禁用缓存

## 如何验证

使用 `EXPLAIN` 或 `EXPLAIN ANALYZE` 查看物理执行计划，确认 Hybrid Cache 的状态：

```sql
-- 如果已配置 Hybrid Cache，PartitionScanExec 算子会显示 hybrid_cache=on
EXPLAIN SELECT * FROM t;

-- 如果未配置 Hybrid Cache，或通过 hint 禁用了缓存，PartitionScanExec 算子会显示 hybrid_cache=off
EXPLAIN SELECT /*+ SET_VAR(hybrid_cache=off) */ * FROM t;
```

> **注意**：如果在启动 Datalayers 时未配置 Hybrid Cache（`object_store.file_cache` 和 `object_store.metadata_cache` 均为空），那么无论 Hint 如何设置，输出都会显示 `hybrid_cache=off`。
