# Server

`server` 部分包含用于启动和管理 Datalayers 服务监听器的配置。

## 配置示例

```toml
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

# The configurations of the unix domain socket server.
[server.uds]
# The path of the unix domain socket, relative to `base_dir`.
# DONOT configure this options means do not support uds server by default.
# Recommend: "run/datalayers.sock"
path = "run/datalayers.sock"

# The configurations of the Redis service.
[server.redis]
# Users can start this service only when Datalayers server starts in cluster mode.
# Do not support redis service by default.
# Default: "".
# addr = "0.0.0.0:8362"

# The username.
# Default: "admin".
#username = "admin"

# The password.
# Default: "public".
#password = "public"

# The configurations of the Prometheus server.
[server.prometheus]
# The Prometheus endpoint.
# Default: "0.0.0.0:9090"
# addr = "0.0.0.0:9090"

# The default memtable size for auto-created metric tables.
memtable_size = "5MB"

# The default TTL for auto-created metric tables.
ttl = "365d"

# The configurations of the Postgres sql service.
[server.postgres]
# The endpoint of the server.
# Don't support postgres protocol by default.
# Recommend: "0.0.0.0:5432".
#addr = "0.0.0.0:5432"

# The configurations of the MCP (Model Context Protocol) server.
[server.mcp]
# Whether to enable MCP over Streamable HTTP.
# Default: false.
# enable = true

# Whether to enable auth middleware for MCP endpoints.
# Default: true.
# enable_auth = false

# Whether to enable stateful mode.
# Default: false.
# stateful_mode = true
```
