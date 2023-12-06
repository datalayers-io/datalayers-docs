# 配置手册
DataLayers 支持通过修改配置文件设置**计算层与存储层**，本章节将介绍 DataLayers 配置文件信息。

## 计算层
### 文件与目录
DataLayers 安装完成后会创建一些目录用来存放运行文件和配置文件，存储数据以及记录日志。

| 目录       | 描述                               |
| --------- | -------------------------         |
| bin       | 可执行文件                          |
| etc       | 静态配置文件                         |
| meta      | 当使用本地存储时，该目录存储元数据信息   |
| data      | 当使用本地存储时，该目录存储数据信息     |
| log       | 存储日志的目录                       |

### 配置文件介绍

DataLayers 配置文件为 `datalayers.toml`，根据安装方式其所在位置有所不同：

| 安装方式          | 配置文件所在位置          |
| ----------------- | ------------------------- |
| DEB 或 RPM 包安装 | `/etc/datalayers/datalayers.toml`     |
| Docker 容器       | `/opt/datalayers/etc/datalayers.toml` |
| 解压缩包安装      | `./etc/datalayers.toml`         |

主配置文件包含了大部分常用的配置项，如果您没有在配置文件中明确指定某个配置项，DataLayers 将使用默认配置。
所有可用的配置项及其说明可参考主配置同路径下的 `datgalayers.toml.example` 文件。

### 配置文件示例
```toml
[server]
# work directory, default: "/var/run/datalayers"
workdir = "/var/run/datalayers"
# pid file, default "run/datalayers.pid" under workdir
pid = "run/datalayers.pid"

# system time zone 
# default: Asia/Shanghai (CST, +0800)
# timezone              Asia/Shanghai (CST, +0800)
# system locale
# locale                    en_US.UTF-8
# system charset
# charset                   UTF-8

[server.rpc]
addr = ":3308" # 支持 IPV4 IPV6
timeout = "10s" 
# backlog .......

[server.rpc.tls]
enable = false  # default false
# keyfile = "etc/certs/key.pem"
keyfile = "etc/certs/server.key"
# certfile = "etc/certs/cert.pem"
certfile = "etc/certs/server.crt"
# cacertfile = "etc/certs/cacert.pem"
cacertfile = "etc/certs/rootCA.crt"

[server.auth]
username = "admin"
password = "public"

[logger]
console_log = true
file_log = true
log_path = "/var/log/datalayers/datalayers.log"
level = "info" # debug | info | error | warning
# 单个日志大小，单位M, eg: 10  即 10M
rotation_size = 10
# 保存天数 , 7day
max_age = 7
# 保存日志数量
max_backups = 3

[storage]
# 数据存储方式 fdb | local
type = "fdb"

[storage.meta]
# 创建 checkpoint 的时间间隔，单位秒
checkpoint_internal = 3600
# 单个 meta log 文件最大记录行数
max_archive_record = 4096

# 当 type 为 local 时，使用该配置项，一个 disk 配置项中 log 和 data 必须成对出现。disk 可以有多个
[[storage.disk]]
log_path = "/mnt/1/datalayers/log"
data_path = "/mnt/1/datalayers/data"

[[storage.disk]]
log_path = "/mnt/2/datalayers/log"
data_path = "/mnt/2/datalayers/data"

# 当 type 为 fdb 时，使用该配置项
[storage.fdb]
cluster_file = "/etc/foundationdb/fdb.cluster"

[cluster]
server_addr_type = "hostname" # enum: [hostname | ip]

[license]
key = "MjIwMTExCjAKMTAKRXZhbHVhdGlvbgpjb250YWN0QGVtcXguaW8KZGVmYXVsdAoyMDIzMDEwOQoxODI1CjEwMAo=.MEUCIG62t8W15g05f1cKx3tA3YgJoR0dmyHOPCdbUxBGxgKKAiEAhHKh8dUwhU+OxNEaOn8mgRDtiT3R8RZooqy6dEsOmDI="
```

### 环境变量

除了配置文件外，DataLayers 支持通过环境变量设置配置。

比如 `DATALAYERS_SERVER__AUTH__USERNAME=admin` 环境变量将覆盖以下配置：

```toml
# datalayers.toml
[server.auth]
username = "admin"
```

配置项与环境变量之前可以通过以下规则转换：
* 由于配置文件中的 `.` 分隔符不能使用于环境变量，因此 DataLayers 选用双下划线 `__` 作为配置分割；
* 为了与其他的环境变量有所区分，DataLayers 还增加了一个前缀 `DATALAYERS_` 来用作环境变量命名空间;

### 配置覆盖规则
* DATALAYERS 配置按以下顺序进行优先级排序：环境变量 > datalayers.toml。
* 以“DATALAYERS_”开头的环境变量设置具有最高优先级，并将覆盖 etc/datalayers.toml 文件中的任何设置。


## 存储层


