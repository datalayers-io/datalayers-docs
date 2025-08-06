# 存储

`storage` 部分配置了 Datalayers 系统中的各种存储组件和缓存机制。这些配置控制数据如何在内存、磁盘上缓存，以及如何存储在不同的后端存储中，如本地存储、FDB 和对象存储（S3、Azure、GCS）。

```toml
# The configurations of storage.
[storage]
# The namespace is the path prefix that used to store all data
# Default: "DL".
# namespace = "DL"

# Global rate limit per second for object store uploading.
# Setting to 0 to disable rate limit
# Default: "0MB".
# write_rate_limit = "5MB"

# 单机模式下，元数据存储路径
[storage.meta.standalone]
# 相对`base_dir`的存储路径。如果希望数据存储到其他路径，可以指定为绝对路径
# Default: "meta".
# path = "meta"

# 集群模式下，元数据存储配置
[storage.meta.cluster]
# 连接 fdb 的配置文件`fdb.cluster`所在路径，不支持相对路径
# Default: "/etc/foundationdb/fdb.cluster" on linux system.
# cluster_file = "/etc/foundationdb/fdb.cluster"

# 对象存储配置
[storage.object_store]
# 指定全局默认的对象存储服务，新建表时，如未在 table options 中指定`storage_type`，
# 则默认使用该配置项作为文件的存储服务
# 支持的配置项如下（大小写不敏感）:
# - s3.
# - azure.
# - gcs.
# - local (only working in standalone mode)
# - fdb (only working in cluster)
# Default: 单机模式下为`local`，集群模式下为`fdb`
# default_storage_type = ""

# 本地对象存储路径 (仅单机模式支持).
[storage.object_store.local]
# 相对`base_dir`的存储路径。如果希望数据存储到其他路径，可以指定为绝对路径
# Default: "data"
# path = "data"

# Fdb 对象存储服务（仅集群模式支持）
[storage.object_store.fdb]
# 连接 fdb 的配置文件`fdb.cluster`所在路径，不支持相对路径
# cluster_file = "/etc/foundationdb/fdb.cluster"

# Uploading rate limit per second.
# Default: "5MB".
write_rate_limit = "2MB"

# S3 对象存储服务
# 支持`virtual-hosted–style`和`path-style`两种 URL 访问风格
# 当`virtual-hosted–style`设置为 true 时，bucket name 将作为 URL 域名的一部分，例如: https://bucket-name.s3.region-code.amazonaws.com，
# 否则 bucket name 将作为 URI 第一个分隔符之后路径，例如: https://s3.region-code.amazonaws.com/bucket-name
# [storage.object_store.s3]
# bucket = "datalayers"
# access_key = "CPjH8R6WYrb9KB6riEZo"
# secret_key = "TsTal5DGJXNoebYevijfEP2DkgWs96IKVm0uores"
# endpoint = "https://bucket-name.s3.region-code.amazonaws.com"
# region = "region-code"
# write_rate_limit = "0MB"
# virtual_hosted_style = true

# [storage.object_store.azure]
# container = "datalayers" # your can change it as you want
# account_name = "PLEASE CHANGE ME"
# account_key = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"
# write_rate_limit = "0MB"

# [storage.object_store.gcs]
# bucket = "datalayers" # your can change it as you want
# scope = "PLEASE CHANGE ME"
# credential_path = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"
# write_rate_limit = "0MB"

[storage.object_store.metadata_cache]
# 缓存对象存储文件的元信息，有利于快速检索文件信息
# 对象存储文件的元信息占比很小,建议配置为 256MB 即可
# Default: "0MB"
memory = "256MB"

[storage.object_store.file_cache]
# 在内存中缓存对象存储文件的二进制内容，有利于加速文件的读取
# 根据服务器资源情况进行配置
# Default: "0MB"
memory = "1024MB"

# 在本地磁盘中缓存对象存储文件的二进制内容，有利于加速文件的读取
# 根据服务器资源情况进行配置
# Default: "0GB"
disk = "20GB"

# 相对`base_dir`的存储路径。如果希望数据存储到其他路径，可以指定为绝对路径
# Default: "cache/file"
path = "cache/file"
```
