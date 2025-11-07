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

# The unix socket file of peer server.
# Don't support peer server by default.
# Default: ""
# peer_addr = "run/datalayers.sock"

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
# Default: "87113c3d906df75e9c6389fbd457d957".
jwt_secret = "87212c3d906df71e9c6289fbd456d917"

# 密码强度，支持三种：
# weak: 弱密码，没有特殊要求；
# moderate: 一般密码，至少 8 位字符，至少包含大写、小写、数字和特殊字符中的三种；
# strong: 强密码，至少 14 位字符，包含大写、小写、数字和特殊字符。
# 默认：weak
#password_strength = "weak"

# 防暴力破解密码
# 形式为 "a/b/c"，a,b,c 都是整数，含义是连续失败 a 次后，b 分钟内禁止该用户重复尝试登录，之后每再失败一次，禁止时间延长 c 分钟。
# a最大值为 10，b,c 最大值为 120 分钟。
# 默认：0/0/0 表示不开启防暴力破解
#password_lockout = "3/5/5"

# The configurations of the Redis service.
[server.redis]
# 配置 Key-Value 服务的监听地址.
# Key-Value 服务仅在集群模式下才能工作.
# 默认情况下不启动 Key-Value 服务.
# Default: "".
# addr = "0.0.0.0:6379"

# The username.
# Default: "admin".
#username = "admin"

# The password.
# Default: "public".
#password = "public"
```
