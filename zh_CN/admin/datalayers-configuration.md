# 配置文件介绍
Datalayers 支持通过修改配置文件设置**计算层与存储层**，本章节将介绍 Datalayers 配置文件信息。

## 计算层
### 文件与目录
Datalayers 安装完成后会创建一些目录用来存放运行文件和配置文件，存储数据以及记录日志。

| 目录       | 描述                               |
| --------- | -------------------------         |
| bin       | 可执行文件                          |
| etc       | 静态配置文件                         |
| meta      | 当使用本地存储时，该目录存储元数据信息   |
| data      | 当使用本地存储时，该目录存储数据信息     |
| log       | 存储日志的目录                       |

### 配置文件介绍

Datalayers 配置文件为 `datalayers.toml`，根据安装方式其所在位置有所不同：

| 安装方式           | 配置文件所在位置                         |
| ----------------- | -------------------------             |
| DEB 或 RPM 包安装  | `/etc/datalayers/datalayers.toml`     |
| Docker 容器       | `/etc/datalayers/datalayers.toml`     |
| 解压缩包安装       | `./etc/datalayers.toml`                |

主配置文件包含了大部分常用的配置项，如果您没有在配置文件中明确指定某个配置项，Datalayers 将使用默认配置。

### 配置文件示例
```toml
[server]
timezone = "Asia/Shanghai"
# Confirm that have write permission for this location.
pid = "/var/run/datalayers/datalayers.pid"

addr = "0.0.0.0:8360"
timeout = "10s"

[server.auth]
username = "admin"
password = "public"
# This parameter cannot be empty. If it is empty, token authentication is not used
token = "c720790361da729344983bfc44238f24"
jwt_secret = "871b3c2d706d875e9c6389fb2457d957"

[server.http]
addr = "0.0.0.0:8361"

[logger]  
# Option for level: Trace | Debug | Info | Warn | Error , default: Info
level = "info"
# Option for log: Console | File (case sensitive)
# Note: If option is File, three options: path, max_log_files and rotation 
# should be set.
log = "Console"
# path = "/var/log/datalayers/"
#max_log_files = 7
# Option for rotation: Minutely | Hourly | Daily | Never , default : Daily
#rotation = "Daily"

[ts_engine]
# Request channel size of each worker (default 128).
worker_channel_size = 128

[ts_engine.wal]
# Only support local now
type = "local"
path = "/var/lib/datalayers/wal"
flush_interval = "0s"
max_file_size = "32MB"


[storage]
type = "fdb"

[storage.fdb]
cluster_file = "/etc/foundationdb/fdb.cluster"
path = "/datalayers"

[storage.local]
path = "/var/lib/datalayers/storage"

[node]
# The name is the unique identifier of the node, and the name cannot be repeated.
name = "localhost:8366"
# connect_timeout = "1s"
# timeout = "10s"
# Retry count, <= 1 means only once
# retry_count = 1
# rpc_max_conn = 20
# rpc_min_conn = 3

[license]
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6InRlc3QiLCJjZSI6bnVsbCwic2QiOiIyMDI0MDUxNyIsInZkIjozNjUsIm5sIjoxMDAsImNsIjoyNTYsImVsIjoxMDAwLCJmcyI6W119.dLBEUr9WDhuTBllPiZ3lNXOL2YtjuvFVUYQvmc85Ak0jgqHhtoCVz09GHAqdPs8yrzMxnQRiGeK49/Puzvqi6X5X0rYEOx5eiKuifWEkYnXDjtUfdvY79Z4p1SWi5h56hyyyvgrc6lPCWnccqM+JWNWA1a3QHo6V288KBQPFZvOcUY1Kl6F9lHHs5NVx/Wq+92cqg+VJ+ONivxwt3Y35VRelFczARLrpYdngpUQtvXud4nRGuDTj4YkhEZAgpjZXg7WMS8w54zboDOPKcLL5bhUTYa4WSinhSeWLEniISPu0/TihSlXsp/UqamUnb+NHa2sjMTKzAp0CeOZwZA++fQ=="

```

其中配置文件字段详细解释，请查看[配置文件字段](./datalayers-configuration-fields.md)

### 环境变量

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

### 配置覆盖规则
* DATALAYERS 配置按以下顺序进行优先级排序：环境变量 > datalayers.toml。
* 以“DATALAYERS_”开头的环境变量设置具有最高优先级，并将覆盖 etc/datalayers.toml 文件中的任何设置。


## 存储层


