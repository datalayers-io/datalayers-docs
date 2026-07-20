---
title: "Datalayers LAST CACHE 优化指南"
description: "介绍 Datalayers LAST CACHE 的适用场景、配置方式和典型查询加速模式，帮助你优化最新值查询。"
---
# Datalayers LAST CACHE 优化指南

## 概述

在时序数据场景中，经常需要查询特定设备或点位的最新数据记录，用于实时监控和状态追踪。Datalayers 提供 LAST CACHE 功能，用于缓存最新记录，从而显著提升“查最新值”类查询性能。

### 热数据与冷数据

写入的数据会先进入 MemTable，因此最近写入的数据通常属于 **热数据**，并驻留在 MemTable 中。当查询某个主键的最新值时，如果该主键的最新记录仍在 MemTable 中，Datalayers 可以直接从内存返回结果，无需或仅需极少扫描 SST 文件，因此查询性能通常较高。

相较之下，长时间没有新写入的主键可视为 **冷数据**，其最新记录往往已经刷写到 SST 文件中。查询这类主键的最新值时，如果直接访问底层 SST 文件，I/O 开销会较大。LAST CACHE 正是为这类场景设计的缓存：它将每个主键的最新记录保存在内存中。在该主键被查询过，或其最新记录完成 flush 后，后续查询即可优先命中缓存，避免扫描 SST 文件，从而显著降低查询延迟。

## 功能特性

- **高效内存缓存**：专为最新数据查询优化
- **按需开启**：支持按表级别灵活控制启用与禁用

## 配置步骤

如需启用 LAST CACHE，需要完成以下两个步骤：

### 配置全局缓存大小

在 Datalayers 配置文件（默认路径：/etc/datalayers/datalayers.toml）中设置：

```toml
# 配置 LAST CACHE 在当前节点上，最多使用多少内存。
# 默认: 2GB
last_cache_size = "2GB"
```

此配置表示单个节点上 LAST CACHE 功能可使用的最大内存容量。

### 启用表级 LAST CACHE

在创建表时，通过 TABLE OPTIONS 启用该表的 LAST CACHE 优化：

```sql
CREATE TABLE `t` (
  `ts` TIMESTAMP(9) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `sid` INT32 NOT NULL,
  `value` REAL,
  `flag` INT8,
  TIMESTAMP KEY(`ts`)
)
PARTITION BY HASH (`sid`) PARTITIONS 2
ENGINE=TimeSeries
WITH (
  ENABLE_LAST_CACHE=TRUE
)
```

将 `ENABLE_LAST_CACHE` 设置为 `TRUE`，即可为该表启用 LAST CACHE 优化。

## 优化的查询场景

完成上述配置后，即可加速以下 SQL 查询：

- select * from t where sid = 1 order by ts desc limit 1
- select last_value(value order by ts) from t where sid = 1
- select first_value(value order by ts desc) from t where sid = 1

## 相关文档

- 了解表级配置，请参考 [时序存储使用指南](../table-design/timeseries-table-design.md)
- 了解整体调优方向，请参考 [查询性能调优概述](../query-performance-tuning-overview.md)
