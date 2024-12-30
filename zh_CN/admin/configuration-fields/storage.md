# 存储

`storage` 部分配置了 Datalayers 系统中的各种存储组件和缓存机制。这些配置控制数据如何在内存、磁盘上缓存，以及如何存储在不同的后端存储中，如本地存储、FDB 和对象存储（S3、Azure、GCS）。

```toml
# The configurations of storage.
[storage]
# The namespace is the path prefix that used to store all data
# Default: "DL".
# namespace = "DL"

# 指定 standalone(单机) 模式下，元数据的存储路径 
[storage.meta.local]
# The path to store system meta data in standalone mode.
# Default: "/var/lib/datalayers/meta".
# path = "/var/lib/datalayers/meta"

# 指定集群模式下，元数据存储位置
[storage.meta.cluster]
# The cluster file of FoundationDB.
# Default: "/etc/foundationdb/fdb.cluster" on linux system.
# cluster_file = "/etc/foundationdb/fdb.cluster"

# The global default storage type which one we use to store sst files when creating table.
# Datalayers will use local disk (standalone) and fdb (cluster) as the default storage type
# if not specified. User also can specify the `storage_type` to override this
# through `table options` when creating table.
[storage.object_store]

# 指定数据默认的存储位置，配置该项后，在 create table 时，会将该值写入到 table options 中的 storage_type 中。现支持以下选项：
# - s3.
# - azure.
# - gcs.
# - local (only working in standalone mode)
# - fdb (only working in cluster)
# Default: local|fdb
# default_storage_type = ""

# 指定单机模式下，数据的存储路径 (only working in standalone mode, and enabled by default).
[storage.object_store.local]
# Default: "/var/lib/datalayers/data"
# path = "/var/lib/datalayers/data"

# The configurations of object store base on fdb (only working in cluster mode, and enabled by default).
[storage.object_store.fdb]
# cluster_file = "/etc/foundationdb/fdb.cluster"

# The rate limitation per second.
# Default: "5MB".
# write_rate_limit = "5MB"

# The configurations of the S3 object store.
# [storage.object_store.s3]
# bucket = "datalayers"
# access_key = "CPjH8R6WYrb9KB6riEZo"
# secret_key = "TsTal5DGJXNoebYevijfEP2DkgWs96IKVm0uores"
# endpoint = "http://127.0.0.1:9000"
# region = "datalayers"

# [storage.object_store.azure]
# container = "datalayers" # your can change it as you want
# account_name = "PLEASE CHANGE ME"
# account_key = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"

# [storage.object_store.gcs]
# bucket = "datalayers" # your can change it as you want
# scope = "PLEASE CHANGE ME"
# credential_path = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"

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
