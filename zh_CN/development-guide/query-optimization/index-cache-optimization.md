---
title: "Datalayers 索引缓存调优指南"
description: "介绍 Datalayers 索引缓存的适用场景、配置方式和调优建议，帮助你减少索引读取开销并提升查询性能。"
---
# 索引缓存调优指南

## 概述

在查询过程中，系统需要读取索引元数据来完成查询规划和数据定位。频繁的磁盘 I/O 会增加查询延迟与系统开销。通过将索引相关元数据缓存到内存中，可以显著减少索引读取开销，从而提升查询性能。

## 缓存策略

### 全量缓存

如果系统内存充足，建议将所有索引数据加载到缓存中。配置缓存大小时，通常设置为存储文件总大小的2%左右。

### 热数据索引缓存

在实际生产环境中，通常只需缓存热数据（高频访问的数据，如最近7天的数据）的索引。可根据热数据量估算所需缓存大小。当缓存空间不足时，系统会基于LFU（最近最少使用）策略自动淘汰不常用的索引数据。

## 配置方法

修改 Datalayers 配置文件（默认路径：/etc/datalayers/datalayers.toml）中的以下参数：

```toml
[ts_engine]

# Cache size for SST file metadata. Setting it to 0 to disable the cache.
# Default: 128M
meta_cache_size = "256M"

# Whether or not to preload parquet metadata on startup.
# This config only takes effect if the `ts_engine.meta_cache_size` is greater than 0.
# Default: true.
preload_parquet_metadata = true
```

## 指标监控

可通过 Datalayers 提供的[指标看板](../../admin/system-monitor-grafana.md)观察缓存命中率情况，结合业务需求进行调优。

## 注意事项

- **内存资源评估**：如果系统内存不足，导致缓存频繁换入换出，反而可能降低查询性能。请根据实际内存资源合理配置缓存大小。
- **配置生效**：修改配置文件后，需要重启 Datalayers 服务才能使更改生效。
- **监控调整**：建议在生产环境中监控缓存命中率，根据实际访问模式调整缓存大小配置。

## 相关文档

- 了解整体调优方向，请参考 [查询性能调优概述](../query-performance-tuning-overview.md)
- 了解数据缓存，请参考 [数据缓存优化指南](./hybrid-cache-optimization.md)
