# 时间序列引擎

`ts_engine` 部分定义了 Datalayers 中时间序列引擎的配置设置。根据用户资源与数据模型，合理的配合将获得更好的性能。

## 配置示例

```toml
# The configurations of the Time-Series engine.
[ts_engine]
# The size of the request channel for each worker.
# Default: 128.
# worker_channel_size = 128

# The max size of memory that memtable will used.
# Server will reject to write after the memory used overflow this limitation
# Default: 80% of system memory.
#max_memory_used_size = "10GB"

# Cache size for SST file metadata. Setting it to 0 to disable the cache.
# Default: 512M
meta_cache_size = "512M"

# 服务退出时，是否将 `memtable` 中的数据进行
# Default: true.
flush_on_exit = true

# Whether or not to preload parquet metadata on startup.
# This config only takes effect if the `ts_engine.meta_cache_size` is greater than 0.
# Default: true.
preload_parquet_metadata = true

[ts_engine.schemaless]
# When using schemaless to write data, is automatic table modification allowed.
# Default: false.
auto_alter_table = true

# The configurations of the Write-Ahead Logging (WAL) component.
[ts_engine.wal]
# The type of the WAL.
# Currently, only the local WAL is supported.
# Default: "local".
type = "local"

# Whether or not to disable writing to WAL and replaying from WAL.
# It's required to set to false in production environment if strong consistency is necessary.
# Default: false.
disable = false

# Whether or not to skip WAL replay upon restart.
# It's meant to be used for development only.
# Default: false.
skip_replay = false

# The path to store WAL files.
# Default: "/var/lib/datalayers/wal".
path = "/var/lib/datalayers/wal"

# The fixed time period to flush cached WAL files to persistent storage.
# Triggers flush immediately if the `flush_interval` is 0.
# Default: "0s".
# ** It's only used when the type is `local` **.
flush_interval = "0s"

# The maximum size of a WAL file.
# Default: "32MB".
# ** It's only used when the type is `local` **.
max_file_size = "64MB"
```
