# Server

`server` 部分包含用于启动和管理 Datalayers 服务监听器的配置。

## 配置示例

```toml
# Datalayers' configurations.
# The root directory of all local data storage paths
base_dir = "/var/lib/datalayers"

# The configurations of Datalayers server.
[server]
# 指定服务是以 单机/集群 模式启动.
# - true: 单机模式.
# - false: 集群模式.
# Default: false.
standalone = false

# 配置 Arrow FlightSQL 的监听地址.
# Default: "0.0.0.0:8360".
addr = "0.0.0.0:8360"

# 配置 HTTP 服务的舰艇地址.
# Default: "0.0.0.0:8361".
http = "0.0.0.0:8361"

# 配置 Key-Value 服务的监听地址.
# Key-Value 服务仅在集群模式下才能工作.
# 默认情况下不启动 Key-Value 服务.
# redis = "0.0.0.0:8362"

# 配置 session 超时时间.
# Default: "10s".
session_timeout = "10s"

# The timezone the server lives in.
# Default is Asia/Shanghai, if timezone not exist in configuration, we will use the machine local time.
timezone = "Asia/Shanghai"

# 配置 TLS 信息.
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

# The provided JSON Web Token.
# Default: "87113c3d906df75e9c6389fbd457d957".
jwt_secret = "87212c3d906df71e9c6289fbd456d917"
```
