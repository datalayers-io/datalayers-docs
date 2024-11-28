# 高性能查询

除数据建模以及索引外，通过优化配置也能极大的提升数据查询性能。本章节主要介绍如何通过优化配置，提升数据查询的效率。

## 配置 meta 缓存

数据在查询的过程中，会读取存储引擎中的 meta 信息用于查询优化，频繁的 IO 会增加查询过程中额外的开销，因此将该部份信息进行缓存能极大的提升查询效率。建议值：存储文件大小的 1%。配置如下：

```toml
[ts_engine]

# Cache size for SST file metadata. Setting it to 0 to disable the cache.
# Default: 128M
meta_cache_size = "256M"
```

注：当内存过小，缓存被高频换入、换出，可能会导致查询变慢。

## 配置热数据缓存

在使用对象外存储（OBS、Azure、S3、MinIO等）时，为降低远程 IO 带来的性能损失，可以配置混合缓存（内存 + 磁盘），将热数据缓存在 内存/磁盘 中，以加速查询。具体配置如下：

```toml

# The configurations of storage.
[storage]

# The configurations of the file meta memory cache.
[storage.file_meta_cache.memory]
# 0 means disable mem file meta cache
# Default: "512MB"
capacity = "512MB"

# The shard number of mem cache
# More shards will help distribute the load and improve performance by reducing contention.
# But too many shards might lead to increased overhead due to managing more individual cache segments.
# Default: 16
# shards = 16

# !!! Disk cache configuration not working on standalone mode
# The configurations of the file meta disk cache.
[storage.file_meta_cache.disk]
# Disk cache capicity
# 0 means disable disk cache
# Default: "0GB"
capacity = "1GB"

# The directory where the disk cache will be stored
# Default: "/var/lib/datalayers/meta_cache"
path = "/var/lib/datalayers/meta_cache"


# The configurations of the file data memory cache.
[storage.file_cache.memory]
# 0 means disable mem cache
# Default: "0MB"
capacity = "1GB"


# The configurations of the file data disk cache.
# !!! Disk cache configuration not working on standalone mode
[storage.file_cache.disk]
# Disk cache capicity
# 0 means disable disk cache
# Default: "10GB"
capacity = "30GB"

# The directory where the disk cache will be stored
# Default: "/var/lib/datalayers/file_cache"
path = "/var/lib/datalayers/file_cache"
```

注：当内存、磁盘设置较小、且查询场景无热点数据，缓存的高频的换入、换出可能影响查询性能。
