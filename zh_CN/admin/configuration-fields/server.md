---
title: "Server 配置"
description: "Datalayers Server 配置说明：介绍服务启动模式、FlightSQL/HTTP/Posrgre/Redis/Prometheus 监听地址、会话超时、时区和 TLS 证书等关键参数。"
---
# Server 配置

`server` 部分包含用于启动和管理 Datalayers 服务监听器的配置。

## 配置示例

```toml
# Datalayers server configuration.
[server]
# Startup mode.
# - true: standalone mode.
# - false: cluster mode.
# Default: false.
standalone = false

# Server timezone.
# Default: "UTC".
# timezone = "Asia/Shanghai"

# Arrow Flight SQL endpoint.
[server.flightsql]
# Clients use this endpoint to connect through the Arrow Flight SQL protocol.
# Default: "0.0.0.0:8360".
addr = "0.0.0.0:8360"

# HTTP endpoint.
[server.http]
# Default: "0.0.0.0:8361".
addr = "0.0.0.0:8361"

# Optional MCP (Model Context Protocol) settings.
# [server.http.mcp]
# Whether to enable auth middleware for MCP endpoints.
# Default: false.
# enable_auth = false

# Whether to enable stateful mode.
# Default: false.
# stateful_mode = true

# Optional Postgres sql settings.
# [server.postgres]
# Default: "0.0.0.0:5432".
# addr = "0.0.0.0:5432"

# Unix domain socket endpoint.
[server.uds]
# Relative paths are resolved against `base_dir`.
# Default: "run/datalayers.sock".
# path = "run/datalayers.sock"

# Optional Redis service settings.
# [server.redis]
# Supported only in cluster mode.
# Default: "0.0.0.0:6379".
# addr = "0.0.0.0:6379"

# Username.
# Required when Redis service is enabled.
# username = "admin"

# Password.
# Required when Redis service is enabled.
# password = "public"

# Optional Prometheus server settings.
# [server.prometheus]
# Prometheus endpoint.
# Default: "0.0.0.0:9090".
# addr = "0.0.0.0:9090"

# The default memtable size for auto-created metric tables.
# memtable_size = "5MB"

# The default TTL for auto-created metric tables.
# ttl = "365d"

# Optional TLS certificate settings.
# [server.tls]
# Key file for TLS-enabled services, including HTTPS、PostgreSQL and Flight SQL.
# key = "/etc/datalayers/certs/server.key"
# Certificate file for TLS-enabled services, including HTTPS、PostgreSQL and Flight SQL.
# cert = "/etc/datalayers/certs/server.crt"

# Authentication and authorization.
[server.auth]
# Authentication mode.
# static: authenticate only with the configured built-in username and password.
# rbac: authenticate only with RBAC-managed users.
# chain: try static authentication first, then fall back to RBAC if static authentication fails.
# Valid values: "static", "rbac", "chain".
# Default: "static".
type = "static"

# The username used by static authentication.
# Used by: static, and the static branch of chain.
# Required when auth.type is "static" or "chain".
username = "admin"

# The password used by static authentication.
# Used by: static, and the static branch of chain.
# Required when auth.type is "static" or "chain".
password = "public"

# The JSON Web Token secret shared by all auth modes.
# Required for all auth modes.
jwt_secret = "871b3c2d706d875e9c6389fb2457d957"

# Password strength requirements.
# weak: no requirements, simple password.
# moderate: at least 8 characters, including at least three types of the following:
#   uppercase letters, lowercase letters, digits, and special characters.
# strong: at least 14 characters, including all types of the following:
#   uppercase letters, lowercase letters, digits, and special characters.
# Default: "weak"
# password_strength = "weak"

# Password protection against brute-force attacks.
# Format: "a/b/c", where:
# account is locked for "b" minutes after "a" failed password attempts,
# and then extended by another "c" minutes after each later failed attempt.
# The maximum values of a, b, and c are 10, 120, and 120 respectively.
# Values above those limits are clamped to 3/5/5.
# 0/-/- means no lockout.
# Default: "0/0/0".
# password_lockout = "0/0/0"
```
