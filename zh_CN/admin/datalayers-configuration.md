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

| 安装方式           | 配置文件所在位置                         |
| ----------------- | -------------------------             |
| DEB 或 RPM 包安装  | `/etc/datalayers/datalayers.toml`     |
| Docker 容器       | `/etc/datalayers/datalayers.toml`     |
| 解压缩包安装       | `./etc/datalayers.toml`                |

主配置文件包含了大部分常用的配置项，如果您没有在配置文件中明确指定某个配置项，DataLayers 将使用默认配置。
所有可用的配置项及其说明可参考主配置同路径下的 `datalayers.toml.example` 文件。

### 配置文件示例
```toml
[server]
workdir = "/usr/local/datalayers"

# 服务器时区，默认为系统时区
# timezone = "Asia/Shanghai"

port = ":3308"
timeout = "10s"

[server.auth]
username = "admin"
password = "public"

[cache]
# Read Cache 的容量
file_cache_size = "4G"

[logger]
console_log = true
file_log = false
# 相对于 `workdir` 路径，也可使用绝对路径
# log_path = "log/"
# debug | info | error | warning
level = "debug" 
# 单个日志大小，单位M, eg: 10  即 10M
rotation_size = 10
# 保存天数， 7 day
max_age_days = 7
# 保存日志数量
max_backups = 3

[wal]
# 相对于 `workdir`, 也可使用绝对路径
path = "wal/"

[meta]
# 单个 meta log 文件最大记录行数
max_archive_record = 4096
# 创建 checkpoint 的时间间隔，单位秒
checkpoint_internal_s = 3600

# standalone 模式仅支持 local 存储
[storage]

# [storage.fdb]
# cluster_file = "/etc/foundationdb/fdb.cluster"
# tls.....

[[storage.local]]
# 数据存储路径
path = "/datalayers/data"
# .....

#[[storage.local]]
#path = "/datalayers/data2"


[node]
# FQDN | ip , 推荐使用 FQDN。 节点在集群中的唯一标识，同时也是节点间通讯地址
name = "192.168.3.3"
# 节点间通信使用的认证key, 部署新集群时建议更新该值
cookie = "7e2c284b4d901b2661e67b1962fb11f6"

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


