# 配置手册
DataLayers 支持通过修改配置文件设置**计算层与存储层**，本章节将介绍 DataLayers 配置文件信息。

## 计算层
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
# system time zone 
# default: Asia/Shanghai (CST, +0800)
# timezone              Asia/Shanghai (CST, +0800)
# system locale
# locale                    en_US.UTF-8
# system charset
# charset                   UTF-8

[server.http]
addr = ":3309" # 支持 IPV4 IPV6
timeout = "10s" 
# backlog .......

[server.http.tls]
enable = false  # default false
# keyfile = "etc/certs/key.pem"
keyfile = "etc/certs/server.key"
# certfile = "etc/certs/cert.pem"
certfile = "etc/certs/server.crt"
# cacertfile = "etc/certs/cacert.pem"
cacertfile = "etc/certs/rootCA.crt"


[server.rpc]
addr = ":3308"
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
type = "FoundationDB"
cluster_file = "/etc/foundationdb/fdb.cluster"

[cluster]
server_addr_type = "hostname" # enum: [hostname | ip]

[license]
key = "MjIwMTExCjAKMTAKRXZhbHVhdGlvbgpjb250YWN0QGVtcXguaW8KZGVmYXVsdAoyMDIzMDEwOQoxODI1CjEwMAo=.MEUCIG62t8W15g05f1cKx3tA3YgJoR0dmyHOPCdbUxBGxgKKAiEAhHKh8dUwhU+OxNEaOn8mgRDtiT3R8RZooqy6dEsOmDI="


```

## 存储层


