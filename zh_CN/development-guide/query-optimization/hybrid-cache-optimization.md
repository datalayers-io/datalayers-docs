# 数据缓存优化指南

## 概述

数据缓存是 Datalayers 提供的高性能查询优化机制，采用创新的内存+磁盘混合缓存架构。该功能特别适用于存算分离场景，可显著减少远程I/O操作，提升查询性能并降低运营成本。

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
