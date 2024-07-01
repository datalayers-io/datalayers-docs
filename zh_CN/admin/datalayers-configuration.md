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
# DataLayers' configurations.

# The configurations of DataLayers server.
[server]
# In which mode to start the DataLayers server.
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

# A session is regarded timeout if it's not active in the past `session_timeout` duration.
# Default: "10s".
session_timeout = "10s"

# The timezone the server lives in.
# Default is Asia/Shanghai, if timezone not exist in configuration, we will use the machine local time.
timezone = "Asia/Shanghai"

# Whether or not to enable InfluxDB's schemaless feature.
# Default: true.
enable_influxdb_schemaless = true

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

# Whether or not to flush memtable before the system or worker exits
# Default: true.
flush_on_exit = true

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

# The directory to store WAL files.
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

# The configurations of the local storage.
[storage.local]
# The directory to store files in the local storage.
# Default: "/var/lib/datalayers/storage".
path = "/var/lib/datalayers/storage"

# The configurations of the FoundationDB-backed storage.
[storage.fdb]
# The cluster file of FoundationDB. Foundation clients and servers use the cluster file to connect to a cluster.
# Default: "/etc/foundationdb/fdb.cluster" on Linux system.
cluster_file = "/etc/foundationdb/fdb.cluster"

# The namespace with which to isolate key-values of DataLayers'.
# Default: "DL".
namespace = "DL"

# The speed limitation per second of the FoundationDB-backed storage.
# Default: "15MB".
max_flush_speed = "5MB"

# The configurations of the S3 object store.
# TODO(niebayes): add comments for object store configs.
[storage.object_store.s3]
bucket = "datalayers"
root = "datalayers"
access_key = "ZHKs9zvS101fHP5cOSJq"
secret_key = "e9BlzvVHItNu8kHZZ16WRyFNEPF78y6Ne5wnshaT"
endpoint = "http://127.0.0.1:9000"
region = "datalayers"

# [storage.azure]
# container = "datalayers" # your can change it as you want
# root = "PLEASE CHANGE ME"
# account_name = "PLEASE CHANGE ME"
# account_key = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"

# [storage.gcs]
# bucket = "datalayers" # your can change it as you want
# root= = "PLEASE CHANGE ME"
# scope = "PLEASE CHANGE ME"
# credential_path = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"

[node]
# The name of the node. It's the unique identifier of the node in the cluster and cannot be repeated.
# Default: "localhost:8366".
name = "localhost:8366"

# The timeout of connecting to the cluster.
# Default: "1s".
connect_timeout = "1s"

# The timeout applied each request sent to the FoundationDB cluster.
# Default: "10s".
timeout = "10s"

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
dir = "/var/log/datalayers/"

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
rotation = "HOURLY"

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
more_verbose = true

# The configurations of license.
[license]
# A trial license key which may be deprecated.
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6InRlc3QiLCJjZSI6bnVsbCwic2QiOiIyMDI0MDUxNyIsInZkIjozNjUsIm5sIjoxMDAsImNsIjoyNTYsImVsIjoxMDAwLCJmcyI6W119.dLBEUr9WDhuTBllPiZ3lNXOL2YtjuvFVUYQvmc85Ak0jgqHhtoCVz09GHAqdPs8yrzMxnQRiGeK49/Puzvqi6X5X0rYEOx5eiKuifWEkYnXDjtUfdvY79Z4p1SWi5h56hyyyvgrc6lPCWnccqM+JWNWA1a3QHo6V288KBQPFZvOcUY1Kl6F9lHHs5NVx/Wq+92cqg+VJ+ONivxwt3Y35VRelFczARLrpYdngpUQtvXud4nRGuDTj4YkhEZAgpjZXg7WMS8w54zboDOPKcLL5bhUTYa4WSinhSeWLEniISPu0/TihSlXsp/UqamUnb+NHa2sjMTKzAp0CeOZwZA++fQ=="

```

其中配置文件字段详细解释，请查看[配置文件字段](./datalayers-configuration-fields.md)

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




