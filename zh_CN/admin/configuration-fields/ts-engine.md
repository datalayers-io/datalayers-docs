# 时间序列引擎

`ts_engine` 部分定义了 Datalayers 中时间序列引擎的配置设置。根据用户资源与数据模型，合理的配合将获得更好的性能。

## 配置示例

```toml
# The configurations of the Time-Series engine.
[ts_engine]
# The size of the request channel for each worker.
# Default: 128.
# worker_channel_size = 128

# `Memtable` 最多使用多少系统内存，达到该阈值时将触发停写
# Default: 80% of system memory.
#max_memory_used_size = "10GB"

# 缓存 SST 文件的结构化元信息，用于条件过滤以加速查询。
# 缓存配置过小，在文件较多时，可能导致缓存频繁换入换出，影响性能，可通过监控面板观察缓存的使用情况。
# 关于如何配置该缓存大小，可参考[高性能查询](https://docs.datalayers.cn/datalayers/latest/development-guide/high-performance-reading.html)
# Default: 512M
meta_cache_size = "512M"

# 服务启动时，预加载最近生成的文件的元信息。
# 在`meta_cache_size` 配置的缓存容量足够的情况下，系统将加载所有 SST 文件的结构化元信息
# Default: true.
preload_parquet_metadata = true

[ts_engine.schemaless]
# 使用 InfluxDB 行协议写入时，如果列的信息发生变化，是否允许系统自动改表。
# 尽可能保持写入数据的列的数量是稳定的，频繁新增列触发改表，会影响写入性能
# Default: false.
auto_alter_table = true

# The configurations of the Write-Ahead Logging (WAL) component.
[ts_engine.wal]
# The type of the WAL.
# Currently, only the local WAL is supported.
# Default: "local".
type = "local"

# 是否关闭 WAL 写入，生产环境建议保持默认值
# Default: false.
disable = false

# 服务重启时，是否跳过 WAL 重放，生产环境建议保持默认值
# Default: false.
skip_replay = false

# The path to store WAL files.
# Default: "/var/lib/datalayers/wal".
path = "/var/lib/datalayers/wal"

# The maximum size of a WAL file.
# Default: "32MB".
# ** It's only used when the type is `local` **.
max_file_size = "64MB"
```
