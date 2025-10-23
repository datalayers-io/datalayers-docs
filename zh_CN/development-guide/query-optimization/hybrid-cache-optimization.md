# 数据缓存

数据缓存 是 Datalayers 提供的一种查询优化机制，利用混合缓存（内存+磁盘）来减少远程 IO，能够显著提升查询性能、降低成本。适用于存算分离场景，如存储使用OBS、OSS、COS、Azure、GCP、S3、MinIO等，通过混合缓存技术，将热点数据缓存在内存、磁盘中以加速查询。

## 配置

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

**注**：
- 当内存、磁盘设置较小、且查询场景无热点数据，导致缓存数据被高频换入、换出影响查询性能。
- 配置文件修改后，需重启 Datalayers 生效。
