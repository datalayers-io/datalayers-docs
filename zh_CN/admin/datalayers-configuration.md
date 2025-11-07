# 配置文件介绍

本章节将介绍 Datalayers 配置文件信息。

## 配置文件目录

Datalayers 配置文件为 `datalayers.toml`，根据安装方式其所在位置有所不同：

| 安装方式           | 配置文件所在位置                         |
| ----------------- | -------------------------             |
| DEB 或 RPM 包安装  | `/etc/datalayers/datalayers.toml`     |
| Docker 容器       | `/etc/datalayers/datalayers.toml`     |
| 解压缩包安装       | `./etc/datalayers.toml`                |

主配置文件包含了大部分常用的配置项，如果您没有在配置文件中明确指定某个配置项，Datalayers 将使用默认配置。

## 配置文件示例

```toml
# Datalayers' configurations.
# The root directory of all local data storage paths
base_dir = "/var/lib/datalayers"

# The configurations of Datalayers server.
[server]
# In which mode to start the Datalayers server.
# - true: standalone mode.
# - false: cluster mode.
# Default: false.
standalone = false

# The Arrow FlightSql endpoint of the server.
# Users are expected to connect to this endpoint for communicating with the server through the Arrow FlightSql protocol.
# Default: "0.0.0.0:8360".
addr = "0.0.0.0:8360"

# The HTTP endpoint of the server.
# Default: "0.0.0.0:8361".
http = "0.0.0.0:8361"

# The unix socket file of peer server.
# Don't support peer server by default.
# Default: ""
# peer_addr = "run/datalayers.sock"

# A session is regarded timeout if it's not active in the past `session_timeout` duration.
# Default: "10s".
session_timeout = "10s"

# The timezone the server lives in.
# Default is Asia/Shanghai, if timezone not exist in configuration, we will use the machine local time.
timezone = "Asia/Shanghai"

# The configurations of tls certificates.
[server.tls]
# The key file for services with tls, both for https and flightsql
#key = "/etc/datalayers/certs/server.key"
# The cert file for services with tls, both for https and flightsql
#cert = "/etc/datalayers/certs/server.crt"

# The configurations of authorization.
[server.auth]
# The type of the authorization.
# type = "static" or "rbac"
# Default: "static"
type = "static"

# The username.
# Default: "admin".
username = "admin"

# The password.
# Default: "public".
password = "public"

# The provided JSON Web Token.
# Default: "871b3c2d706d875e9c6389fb2457d957".
jwt_secret = "871b3c2d706d875e9c6389fb2457d957"

# Password strength requirements.
# weak: no requirements, simple password.
# moderate: at least 8 characters, including at least three types of the following:
#   uppercase letters, lowercase letters, digits, and special characters.
# strong: at least 14 characters, including all types of the following:
#   uppercase letters, lowercase letters, digits, and special characters.
# Default: "weak"
#password_strength = "weak"

# Password protection against brute-force attacks.
# Form as "a/b/c", means:
# Account locked for "b" minutes after "a" failed password attempts,
#  and locked for another "c" miniutes after the each failed attempt.
# The maximum of a/b/c is 10/120/120 respectively, and will be set to 3/5/5 if too big.
# 0/-/- means no lockout.
# Default: "0/0/0"
#password_lockout = "3/5/5"

# The configurations of the Redis service.
[server.redis]
# Users can start this service only when Datalayers server starts in cluster mode.
# Do not support redis service by default.
# Default: "".
# addr = "0.0.0.0:6379"

# The username.
# Default: "admin".
#username = "admin"

# The password.
# Default: "public".
#password = "public"

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
# Default: 2GB
meta_cache_size = "2GB"

# Cache size for last value. Setting it to 0 to disable the cache.
# Default: 2GB
last_cache_size = "2GB"

# Whether or not to preload parquet metadata on startup.
# This config only takes effect if the `ts_engine.meta_cache_size` is greater than 0.
# Default: true.
preload_parquet_metadata = true

[ts_engine.schemaless]
# When using schemaless to write data, is automatic table modification allowed.
# Default: false.
auto_alter_table = false

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

# The path relative to `base_dir` where the WAL files are stored.
# Set to a absolute path if you want to store it at other independent dir.
# Default: "wal".
path = "wal"

# The maximum size of a WAL file.
# Default: "32MB".
# ** It's only used when the type is `local` **.
max_file_size = "64MB"


# The configurations of storage.
[storage]
# The namespace is the path prefix that used to store all data
# Default: "DL".
# namespace = "DL"

# Global rate limit per second for object store uploading.
# Setting to 0 to disable rate limit
# Default: "0MB".
# write_rate_limit = "5MB"

# The storage configurations for system meta data in standalone mode.
[storage.meta.standalone]
# The path relative to `base_dir` where system meta data is stored on local disk in standalone mode.
# Set to a absolute path if you want to store it at other independent dir.
# Default: "meta".
# path = "meta"

# The storage configurations for system meta data in cluster mode.
[storage.meta.cluster]
# The cluster file of FoundationDB.
# Default: "/etc/foundationdb/fdb.cluster" on linux system.
# cluster_file = "/etc/foundationdb/fdb.cluster"

# The global default storage type which one we use to store sst files when creating table.
# Datalayers will use local disk (standalone) and fdb (cluster) as the default storage type
# if not specified. User also can specify the `storage_type` to override this
# through `table options` when creating table.
[storage.object_store]
# Supported (the case is not sensitive):
# - s3.
# - azure.
# - gcs.
# - local (only working in standalone mode)
# - fdb (only working in cluster)
# Default: local|fdb
# default_storage_type = ""

# The configurations of object store based on local disk (only working in standalone mode, and enabled by default).
[storage.object_store.local]
# The path relative to `base_dir` where the data files is stored on local disk in standalone mode.
# Set to a absolute path if you want to store it at other independent dir.
# Default: "data"
# path = "data"

# The configurations of object store base on fdb (only working in cluster mode, and enabled by default).
[storage.object_store.fdb]
# cluster_file = "/etc/foundationdb/fdb.cluster"

# Uploading rate limit per second.
# Default: "5MB".
write_rate_limit = "2MB"

# The configurations of the S3 object store.
# We support both virtual-hosted–style and path-style URL access in S3 service.
# Set To true to enable virtual-hosted–style request.
# In a virtual-hosted–style URI, the bucket name is part of the domain name in the URL,
# the endpoint use the following format: https://bucket-name.s3.region-code.amazonaws.com.
# In a path-style URI, the bucket is the first slash-delimited component of the Request-URI,
# the endpoint use the following format: https://s3.region-code.amazonaws.com/bucket-name.
# We support path-style URL access in minio even though your minio service does not enable this feature,
# and you are also allowed accessing with path-style like http://<ip>:<port> or http://minio.example.net
# if you set `virtual_hosted_style` to false
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
# Setting to 0 to disable metadata cache in memory.
# Default: "0MB"
memory = "256MB"

# The file cache of storage is a hybrid cache. Enabling disk cache requires memory cache to be enabled as well.
# However, you can enable memory cache without enabling disk cache.
[storage.object_store.file_cache]
# Setting to 0 will disable both memory cache and disk cache.
# Default: "0MB"
# memory = "1024MB"

# Setting to 0 to disable file cache in disk.
# Default: "0GB"
# disk = "20GB"

# The path relative to `base_dir` where the data file cache is stored.
# Set to a absolute path if you want to store it at other independent dir.
# Default: "cache/file"
path = "cache/file"

[node]
# The name of the node. It's the unique identifier of the node in the cluster and cannot be repeated.
# Default: "localhost:8366".
name = "localhost:8366"

# The timeout of connecting to the cluster.
# Default: "1s".
connect_timeout = "1s"

# The timeout applied each request sent to the cluster.
# Default: "120s".
timeout = "120s"

# The maximum number of retries for internal connection.
# Default: 1.
retry_count = 1

# The provided token for internal communication in cluster mode.
# Default: "c720790361da729344983bfc44238f24".
token = "c720790361da729344983bfc44238f24"

# The maximum number of active connections at a time between each RPC endpoints.
# Default: 20.
rpc_max_conn = 20

# The minimum number of active connections at a time between each RPC endpoints.
# Default: 3.
rpc_min_conn = 3

# The timeout of keep-alive in the cluster, in seconds, minimum 5
# Default: "30s"
keepalive_timeout = "30s"

# The interval of keep-alive in the cluster, in seconds,
# Default: "10s"
keepalive_interval = "10s"

# Whether or not to failover automatically when node offline
# Default: false.
auto_failover = true

# The maximum duration allowed for node to be offline,
# if the node is offline for a long time, it will be failovered if auto_failover is true
# Minimum value: "3m"
# Default: "10m"
max_offline_duration = "10m"

# The configurations of the scheduler.
[scheduler]

# The configurations of the flush job.
[scheduler.flush]
# The maximum number of running flush jobs at the same time.
concurrence_limit = 10
# The maximum number of pending flush jobs at the same time
queue_limit = 10000

[scheduler.gc]
# The maximum number of running gc jobs at the same time.
concurrence_limit = 100
# The maximum number of pending gc jobs at the same time
queue_limit = 10000

[scheduler.compact]
# The maximum number of pending compact jobs at the same time
concurrence_limit = 3

[scheduler.cluster_compact_inactive]
# The maximum number of running `cluster compact inactive` jobs at the same time.
concurrence_limit = 10

[scheduler.cluster_compact_active]
# The maximum number of running `cluster compact active` jobs at the same time.
concurrence_limit = 10

# The configurations of logging.
[log]
# The directory to store log files.
# Default: "/var/log/datalayers".
path = "/var/log/datalayers/"

# The verbose level of logging.
# Supported levels (the case is not sensitive):
# - trace.
# - debug.
# - info.
# - warn.
# - error.
# Default: "info".
level = "info"

# The fixed time period for switching to a new log file.
# Supported rotation kinds:
# - "MINUTELY" or "M".
# - "HOURLY" or "H".
# - "DAILY" or "D".
# - "NEVER" or "N".
# Default: "HOURLY".
rotation = "DAILY"

# Enables logging to stdout if set to true.
# Default: true.
enable_stdout = true

# Enables logging to files if set to true.
# Default: false.
enable_file = false

# Enables logging errors to dedicated files if set to true.
# Default: false.
enable_err_file = false

# Makes the logging more verbose by inserting line number and file name.
# Default: true.
verbose = true

# The configurations of audit logs.
[audit]
# Whether to enable audit logs.
# Default: false.
enable = false

# The directory to store audit log files.
# The path relative to `base_dir`
# Default: "audit".
path = "audit"

# The maximum count of audit log files.
# Generate a new file every day.
# Default: 30.
max_files = 30

# Supported kinds of audit logs, separated by comma.
# Kind list: "dml", "ddl", "dql", "admin", "misc"
# "all" means all kinds could be logged.
# Default: "ddl,admin"
kinds = "ddl,admin"

# Supported actions of audit logs, separated by comma.
# Action list: "select", "insert", "update", "delete", "create", "alter", "drop", "truncate", "trim", 
#   "desc", "show", "create_user", "drop_user", "set_password", "grant", "revoke", 
#   "flush", "cluster", "migrate", "compact", "export", "misc",
# "all" means all actions could be logged.
# Default: "all"
actions = "all"

# Exclude actions of audit logs, separated by comma.
# Optional value is the same as `actions`.
# Default: "select,insert"
excludes = ""

# The configurations of the MCP (Model Context Protocol) server.
[mcp]
# Whether to enable SSE.
# Default: true.
enable_sse = false

# Whether to enable SSE OAuth.
# Default: false.
enable_sse_oauth = false

# The configurations of runtime.
#[runtime]

# The configurations of default runtime
#[runtime.default]
# Isolate number of CPU, float value
# >=1 means absolute number of CPU
# 0 means do not use isolate cpu for this runtime
# >0 and <1 means percentage of all CPU cores, 0.2  means 20% e.g.
# Default: 0.0
#cpu_cores = 0.0

# The configurations of background runtime
#[runtime.background]
#cpu_cores = 0.0

# The configurations of license.
# Configuration `key` has higher priority than `file`,
# when no `key` is specified, the `file` configuration will be used.
[license]
# A trial license key which may be deprecated.
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6Iua+nOWbvuacquadpe+8iOaIkOmDve+8ieaVsOaNruenkeaKgOaciemZkOWFrOWPuCIsImNlIjoieWluYm8ueWFuZ0BkYXRhbGF5ZXJzLmlvIiwic2QiOiIyMDI1MDUwOSIsInZkIjoyMzYsIm5sIjozLCJjbCI6MzAsImVsIjoxMDAwMDAsImZzIjpbXX0K.e1gDGsCpvPA1fy/j2JUDvuug/kxJQyuAan0fIn3gGmFL1JUQ3V1bsi73jVl6R3wBkxMbJ13tWdBcTYZREVCVjqy22HvcSkGYJqKiQ0qx2jP2Zq22z2oiO/3frs0xuMdF6g5IE9C6PQq5X/OeFi6eFSTze4mcJhc5DaeB176oSqkyyAf+aKS23ncybYE2Nb55tkKwEVkWao3guMVhIsySInE0PXlaRYuAwmMsA0laYt1C1ZX+ktBu4CI/+C9tH6BvmkvPEagayjoITzjqdx9YRjM7/c8cSa159thLqYzvfQlLXX48bua5DS16KETk19BBc/uaHZxYXzSE1wYXFArjKw=="
```

其中配置文件字段详细解释，请查看配置手册。

## 环境变量

除了配置文件外，Datalayers 支持通过环境变量设置配置。

比如 `DATALAYERS_SERVER__AUTH__USERNAME=admin` 环境变量将覆盖以下配置：

```toml
# datalayers.toml
[server.auth]
username = "admin"
```

配置项与环境变量之前可以通过以下规则转换：

* 由于配置文件中的 `.` 分隔符不能使用于环境变量，因此 Datalayers 选用双下划线 `__` 作为配置分割；
* 为了与其他的环境变量有所区分，Datalayers 还增加了一个前缀 `DATALAYERS_` 来用作环境变量命名空间;

## 配置项优先级与覆盖规则

* DATALAYERS 配置按以下顺序进行优先级排序：命令行参数 > 环境变量 > datalayers.toml > 操作系统设置(timezone)。
* 以“DATALAYERS_”开头的环境变量设置具有最高优先级，并将覆盖 etc/datalayers.toml 文件中的任何设置。
