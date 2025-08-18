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

在使用对象外存储（如：OBS、OSS、COS、Azure、GCP、S3、MinIO等）时，为降低远程 IO 带来的性能损失，可以配置混合缓存（内存 + 磁盘），将热数据缓存在 内存/磁盘 中，以加速查询。具体配置如下：

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

## Hints

SQL Hints 是一种在 SQL 查询中嵌入的特殊指令，用于指导数据库优化器选择特定的执行计划，从而提升查询性能或解决优化器的决策偏差。Datalayers 在 v2.3.9 开始支持该特性。

### 语法

```sql
SELECT /*+ SET_VAR(parallel_degree=1) */ * FROM table;
```

### 查询并行度控制

在查询时，Datalayers 默认策略会尝试调度更多的 CPU 资源，通过并行化将任务拆分为多个子任务（如数据分片、并行扫描、聚合）来加速查询。这种逻辑对于数据量较大时有显著优势，但对于小查询则会带来一定的副作用。因此在小查询时通过指定并行度，可极大提升查询 QPS 与性能。在时序场景，一般来说查询某设备一小段时间范围内的数据，建议设置 `parallel_degree=1`，可显著提升系统查询的 QPS。


