---
title: "Datalayers 数据缓存优化指南"
description: "介绍 Datalayers 内存加磁盘混合数据缓存的适用场景、配置参数和调优建议，帮助你降低远程 I/O 开销。"
---
# Datalayers 数据缓存优化指南

## 概述

数据缓存是 Datalayers 提供的查询优化机制，采用内存加磁盘的混合缓存架构。该能力特别适用于存算分离和对象存储场景，可显著减少远程 I/O 操作，提升查询性能并降低访问成本。

## 适用场景

- 存储使用对象存储服务，包括阿里云、华为云、腾讯云、AWS、Azure、GCP 或兼容 S3 协议的服务（如：MinIO）
- 通过智能缓存技术，自动将热点数据缓存在本地内存和磁盘中，降低查询延迟，提升查询响应速度
- 有效降低对象存储服务的调用次数，降低成本

## 配置参数

在 Datalayers 配置文件（默认路径：/etc/datalayers/datalayers.toml）中设置以下参数：

```toml
[storage.object_store.file_cache]
# 配置为 0 时将禁用混合缓存
# Default: "0MB"
memory = "1024MB"

# 配置为 0 时将禁用磁盘缓存，建议磁盘为高速磁盘，如 SSD
# Default: "0GB"
disk = "20GB"

# The disk cache path
# Default: "/var/lib/datalayers/cache/file"
path = "cache/file"
```

## 指标监控

可通过 Datalayers 提供的[指标看板](../../admin/system-monitor-grafana.md)观察缓存命中率情况，结合业务需求进行调优。

## 注意事项

- 缓存大小设置过小，且查询模式缺乏热点数据时，频繁的缓存换入换出可能反而降低性能
- 修改配置后必须重启 Datalayers 服务才能生效

## 相关文档

- 了解对象存储接入，请参考 [对象存储配置指南](../object-storage.md)
- 了解整体调优方向，请参考 [查询性能调优概述](../query-performance-tuning-overview.md)
