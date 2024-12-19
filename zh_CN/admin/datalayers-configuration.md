# 配置文件介绍

本章节将介绍 Datalayers 配置文件信息。

## 配置文件介绍

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

# The Redis Service endpoint of the server.
# Users can start this service only when Datalayers server starts in cluster mode.
# Default: "0.0.0.0:8362".
# redis = "0.0.0.0:8362" 

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
# The username.
# Default: "admin".
username = "admin"

# The password.
# Default: "public".
password = "public"

# The provided token.
# Default: "c720790361da729344983bfc44238f24".
token = "c720790361da729344983bfc44238f24"

# The provided JSON Web Token.
# Default: "871b3c2d706d875e9c6389fb2457d957".
jwt_secret = "871b3c2d706d875e9c6389fb2457d957"

# The configurations of the Time-Series engine.
[ts_engine]
# The size of the request channel for each worker.
# Default: 128.
worker_channel_size = 128

# The max size of memory that memtable will used.
# Server will reject to write after the memory used overflow this limitation
# Default: 80% of system memory.
#max_memory_used_size = "10GB"

# Cache size for SST file metadata. Setting it to 0 to disable the cache.
# Default: 128M
meta_cache_size = "512M"

# Whether or not to flush memtable before the system or worker exits
# Default: true.
flush_on_exit = true

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

# Disk cache block size
# Default: "64MB"
# block_size = "64MB"

# The configurations of the file data memory cache.
[storage.file_cache.memory]
# 0 means disable mem cache
# Default: "0MB"
capacity = "512MB"

# The shard number of mem cache
# More shards will help distribute the load and improve performance by reducing contention.
# But too many shards might lead to increased overhead due to managing more individual cache segments.
# Default: 16
# shards = 16

# The configurations of the file data disk cache.
# !!! Disk cache configuration not working on standalone mode
[storage.file_cache.disk]
# Disk cache capicity
# 0 means disable disk cache
# Default: "10GB"
capacity = "10GB"

# The directory where the disk cache will be stored
# Default: "/var/lib/datalayers/file_cache"
path = "/var/lib/datalayers/file_cache"

# Disk cache block size
# Default: "64MB"
# block_size = "64MB"

# The configurations of the local storage.
[storage.local]
# The path to store files in the local storage.
# Default: "/var/lib/datalayers/storage".
path = "/var/lib/datalayers/storage"

# The configurations of the FoundationDB-backed storage.
[storage.fdb]
# The cluster file of FoundationDB. Foundation clients and servers use the cluster file to connect to a cluster.
# Default: "/etc/foundationdb/fdb.cluster" on Linux system.
cluster_file = "/etc/foundationdb/fdb.cluster"

# The namespace with which to isolate key-values of Datalayers'.
# Default: "DL".
namespace = "DL"

# The speed limitation per second of the FoundationDB-backed storage.
# Default: "5MB".
max_flush_speed = "5MB"

# The global default storage type which one we use to store sst files when creating table.
# Datalayers will use local disk (standalone) and fdb (cluster) as the default storage type
# if the default_storage_type is none. User can specify the `storage_type` to override this
# through `table options` when creating table.
[storage.object_store]
# Supported (the case is not sensitive):
# - s3.
# - azure.
# - gcs.
# - local (only for standalone)
# - fdb (only for cluster)
# Default: None 
# default_storage_type = "s3"

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

[node]
# The name of the node. It's the unique identifier of the node in the cluster and cannot be repeated.
# Default: "localhost:8366".
name = "localhost:8366"

# Role of the node.
# Default: "stateless"
role = "stateless"

# The timeout of connecting to the cluster.
# Default: "1s".
connect_timeout = "1s"

# The timeout applied each request sent to the cluster.
# Default: "120s".
timeout = "120s"

# The maximum number of retries for internal connection.
# Default: 1.
retry_count = 1

# The directory to store data of the node.
# Default: "/var/run/datalayers".
data_path = "/var/run/datalayers"

# The maximum number of active connections at a time between each RPC endpoints.
# Default: 20.
rpc_max_conn = 20

# The minimum number of active connections at a time between each RPC endpoints.
# Default: 3.
rpc_min_conn = 3

# The configurations of the scheduler.
[scheduler]

# The configurations of the flush job.
[scheduler.flush]
# The maximum number of running flush jobs at the same time.
concurrence_limit = 3
# The maximum number of pending flush jobs at the same time
queue_limit = 10000

[scheduler.gc]
# The maximum number of running gc jobs at the same time.
concurrence_limit = 1
# The maximum number of pending gc jobs at the same time
queue_limit = 10000

[scheduler.cluster_compact_inactive]
# The maximum number of running `cluster compact inactive` jobs at the same time.
concurrence_limit = 1

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
[license]
# A trial license key which may be deprecated.
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6InRlc3QiLCJjZSI6bnVsbCwic2QiOiIyMDI0MDUxNyIsInZkIjozNjUsIm5sIjoxMDAsImNsIjoyNTYsImVsIjoxMDAwLCJmcyI6W119.dLBEUr9WDhuTBllPiZ3lNXOL2YtjuvFVUYQvmc85Ak0jgqHhtoCVz09GHAqdPs8yrzMxnQRiGeK49/Puzvqi6X5X0rYEOx5eiKuifWEkYnXDjtUfdvY79Z4p1SWi5h56hyyyvgrc6lPCWnccqM+JWNWA1a3QHo6V288KBQPFZvOcUY1Kl6F9lHHs5NVx/Wq+92cqg+VJ+ONivxwt3Y35VRelFczARLrpYdngpUQtvXud4nRGuDTj4YkhEZAgpjZXg7WMS8w54zboDOPKcLL5bhUTYa4WSinhSeWLEniISPu0/TihSlXsp/UqamUnb+NHa2sjMTKzAp0CeOZwZA++fQ=="
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
