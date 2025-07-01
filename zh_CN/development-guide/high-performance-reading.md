# 高性能查询

除数据建模以及索引外，通过优化配置也能极大的提升数据查询性能。本章节主要介绍如何通过优化配置，提升数据查询的效率。

## 配置索引内存缓存

查询的过程中，会读取存储引擎中的**索引**数据用于查询优化，频繁的 IO 会增加查询过程中额外的开销，因此将**索引数据**缓存到内存中能极大的提升查询效率。如将所有索引数据都进行缓存的话，则需配置为存储文件大小的 2% 左右。当然，对于正常情况下，我们只需将热数据（高频查询的数据，如：近 7 天的数据）的索引数据进行缓存即可，因此可根据热数据的大小预估来配置缓存大小，当内存不够时，会根据 LFU 策略进行淘汰。

配置如下：

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

注：当内存过小，缓存被高频换入、换出，可能会导致查询变慢。

## 配置热数据缓存

在使用对象外存储（OBS、Azure、S3、MinIO等）时，为降低远程 IO 带来的性能损失，可以配置混合缓存（内存 + 磁盘），将热数据缓存在 内存/磁盘 中，以加速查询。具体配置如下：

```toml
[storage.object_store.metadata_cache]
# Setting to 0 to disable metadata cache in memory.
# Default: "0MB"
memory = "256MB"

[storage.object_store.file_cache]
# Setting to 0 to disable file cache in memory.
# Default: "0MB"
memory = "1024MB"

# Setting to 0 to disable file cache in disk.
# Default: "0GB"
disk = "20GB"

# The disk cache path
# Default: "/var/lib/datalayers/cache/file"
path = "/var/lib/datalayers/cache/file"
```

注：当内存、磁盘设置较小、且查询场景无热点数据，导致缓存数据被高频换入、换出影响查询性能。
