---
title: "配置文件介绍"
description: "Datalayers 配置文件介绍：说明 datalayers.toml 的路径、默认行为与核心配置项，帮助你快速完成服务部署与调优。"
---
# 配置文件介绍

本文介绍 Datalayers 配置文件的结构、常见位置与使用方式。

`datalayers.toml` 是 Datalayers 的核心配置入口，涉及服务监听、认证方式、查询资源、存储后端和引擎行为等关键参数。

## 配置修改建议

- 修改配置前先备份当前文件
- 优先只修改与你当前场景直接相关的参数
- 修改后按部署方式重启 Datalayers，使新配置生效
- 在生产环境变更前先在测试环境验证配置效果

## 配置文件目录

Datalayers 配置文件为 `datalayers.toml`，根据安装方式其所在位置有所不同：

| 安装方式 | 配置文件所在位置 |
| --- | --- |
| DEB 或 RPM 包安装 | `/etc/datalayers/datalayers.toml` |
| Docker 容器 | `/etc/datalayers/datalayers.toml` |
| 解压缩包安装 | `./etc/datalayers.toml` |

主配置文件包含了大部分常用的配置项，如果您没有在配置文件中明确指定某个配置项，Datalayers 将使用默认配置。

## 环境变量

除了配置文件外，Datalayers 支持通过环境变量设置配置。

比如 `DATALAYERS_SERVER__AUTH__USERNAME=admin` 环境变量将覆盖以下配置：

```toml
# datalayers.toml
[server.auth]
username = "admin"
```

配置项与环境变量之前可以通过以下规则转换：

- 由于配置文件中的 `.` 分隔符不能使用于环境变量，因此 Datalayers 选用双下划线 `__` 作为配置分割；
- 为了与其他的环境变量有所区分，Datalayers 还增加了一个前缀 `DATALAYERS_` 来用作环境变量命名空间;

## 配置项优先级与覆盖规则

- DATALAYERS 配置按以下顺序进行优先级排序：命令行参数 > 环境变量 > datalayers.toml > 操作系统设置(timezone)。
- 以“DATALAYERS_”开头的环境变量设置具有最高优先级，并将覆盖 `/etc/datalayers/datalayers.toml` 文件中的任何设置。

## 配置文件示例

```toml
# Datalayers configuration file.
# Root directory for all local data paths.
base_dir = "/var/lib/datalayers"

# Temporary directory for files created during flush, compaction, and similar operations.
# Relative paths are resolved against `base_dir`.
# Set to an absolute path to place temp files in a different directory.
# Leave this unset to use env::temp_dir().
# Default: None.
# temp_dir = "temp"

# -----------------------------------------------------------------------------
# Server
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# Query
# -----------------------------------------------------------------------------

# Query-related configuration.
[query]
# The size of the memory pool which limits the total memory usage of query.
# For production environments, set the pool size to approximately 60% to 80% of available memory.
# Default: 60% of the host machine's available memory.
# memory_pool_size = "8GB"

# Optional slow-query logging.
# [query.slow_query]
# Record queries that take longer than this threshold.
# Default: "5s".
# threshold = "5s"

# Sample ratio for recording slow queries.
# Default: 1.0, which records all slow queries. Valid range (0.0, 1.0].
# sample_ratio = 1.0

# -----------------------------------------------------------------------------
# Time-series engine
# -----------------------------------------------------------------------------

# Time-series engine configuration.
[ts_engine]
# The size of the request channel for each worker.
# Default: 128.
# worker_channel_size = 128

# Maximum memory that memtables may use.
# Writes are rejected once memory usage exceeds this limit.
# Default: 80% of system memory.
# max_memory_used_size = "10GB"

# Cache size for SST file metadata. Setting it to 0 to disable the cache.
# Default: "2GB".
meta_cache_size = "2GB"

# Cache size for last value. Setting it to 0 to disable the cache.
# Default: "2GB".
last_cache_size = "2GB"

# Whether or not to preload parquet metadata on startup.
# This config only takes effect if the `ts_engine.meta_cache_size` is greater than 0.
# Default: true.
preload_parquet_metadata = true

# Optional max interval for flushing memtables to SST files.
# Default: "24h".
# flush_interval = "24h"

[ts_engine.schemaless]
# When using schemaless to write data, is automatic table modification allowed.
# Default: false.
auto_alter_table = false

# Write-Ahead Log (WAL) settings.
[ts_engine.wal]
# The type of the WAL.
# Currently, only the local WAL is supported.
# Default: "local".
type = "local"

# Whether or not to disable writing to WAL and replaying from WAL.
# Keep this false in production if strong consistency is required.
# Default: false.
disable = false

# Whether or not to skip WAL replay upon restart.
# It's meant to be used for development only.
# Default: false.
skip_replay = false

# Relative paths are resolved against `base_dir`.
# Set to an absolute path to place WAL files in a different directory.
# Default: "wal".
path = "wal"

# The maximum size of a WAL file.
# Default: "32MB".
# Only used when type = "local".
max_file_size = "64MB"


# -----------------------------------------------------------------------------
# Storage
# -----------------------------------------------------------------------------

# Storage configuration.
[storage]
# Namespace prefix used when storing data.
# Default: "DL".
# namespace = "DL"

# Global rate limit per second for object store uploading.
# Set to 0 to disable rate limiting.
# Default: "0MB".
# write_rate_limit = "5MB"

# Metadata storage in standalone mode.
[storage.meta.standalone]
# Relative paths are resolved against `base_dir`.
# Set to an absolute path to place metadata in a different directory.
# Default: "meta".
# path = "meta"

# Metadata storage in cluster mode.
[storage.meta.cluster]
# The cluster file of FoundationDB.
# Default: "/etc/foundationdb/fdb.cluster" on Linux.
# cluster_file = "/etc/foundationdb/fdb.cluster"


[storage.object_store]
# Supported (the case is not sensitive):
# - s3.
# - azure.
# - gcs.
# - local (standalone only).
# - fdb (cluster only).

# Global default storage type used for SST files when creating tables.
# If not specified, Datalayers uses local disk in standalone mode and fdb in cluster mode.
# You can override this with the `storage_type` table option at table creation time.
# Default: local|fdb.
# default_storage_type = ""

# Local object store settings (standalone only, enabled by default).
[storage.object_store.local]
# Relative paths are resolved against `base_dir`.
# Set to an absolute path to place data files in a different directory.
# Default: "data".
# path = "data"

# FoundationDB-backed object store settings (cluster only, enabled by default).
[storage.object_store.fdb]
# cluster_file = "/etc/foundationdb/fdb.cluster"

# Uploading rate limit per second.
# Default: "5MB".
write_rate_limit = "2MB"

# Optional S3 object store settings.
# Both virtual-hosted-style and path-style URLs are supported.
# Set `virtual_hosted_style = true` to use bucket-name as part of the host name.
# Set it to false to use path-style access such as:
#   https://s3.region-code.amazonaws.com/bucket-name
#   http://<ip>:<port>
#   http://minio.example.net
# [storage.object_store.s3]
# bucket = "datalayers"
# access_key = "PLEASE_CHANGE_ME"
# secret_key = "PLEASE_CHANGE_ME"
# endpoint = "https://bucket-name.s3.region-code.amazonaws.com"
# region = "region-code"
# write_rate_limit = "0MB"
# virtual_hosted_style = true
# imds_provider = "aws" # or "aliyun", default is "aws"
# prefix = ""

# [storage.object_store.azure]
# container = "datalayers"
# account_name = "PLEASE CHANGE ME"
# account_key = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"
# write_rate_limit = "0MB"
# prefix = ""

# [storage.object_store.gcs]
# bucket = "datalayers"
# scope = "PLEASE CHANGE ME"
# credential_path = "PLEASE CHANGE ME"
# endpoint = "PLEASE CHANGE ME"
# write_rate_limit = "0MB"
# prefix = ""

# File cache is a hybrid cache. Disk cache requires memory cache to be enabled.
# However, you can enable memory cache without enabling disk cache.
[storage.object_store.file_cache]
# Setting to 0 will disable both memory cache and disk cache.
# Default: "0MB".
# memory = "1024MB"

# Set to 0 to disable disk cache.
# Default: "0GB".
# disk = "20GB"

# Relative paths are resolved against `base_dir`.
# Set to an absolute path to place cache files in a different directory.
# Default: "cache/file".
path = "cache/file"

# -----------------------------------------------------------------------------
# Index
# -----------------------------------------------------------------------------

[index]

[index.tantivy]
# Memory budget for index building.
# More memory could make the building process faster.
# Only used when building index, and will be released after building.
# Only one building process is allowed at a time, so this memory budget is global for the whole server.
# Default: "200MB".
build_memory = "200MB"

# Index cache settings.
[index.cache]
# Setting to 0 will disable memory cache.
# Default: "0MB".
# memory = "10GB"

# Setting to 0 will disable disk cache.
# Default: "0MB".
# disk = "20GB"

# Relative paths are resolved against `base_dir`.
# Set to an absolute path to place index cache files in a different directory.
# Default: "cache/index".
# path = "cache/index"

# -----------------------------------------------------------------------------
# Cluster configuration
# -----------------------------------------------------------------------------

[node]
# The name of the node. It's the unique identifier of the node in the cluster and cannot be repeated.
# Default: "localhost:8366".
name = "localhost:8366"

# The timeout of connecting to the cluster.
# Default: "1s".
connect_timeout = "1s"

# The timeout applied each request sent to the cluster.
# Default: "120s".
timeout = "120s"

# The maximum number of retries for internal connection.
# Default: 1.
retry_count = 1

# The provided token for internal communication in cluster mode.
# Default: "c720790361da729344983bfc44238f24".
token = "c720790361da729344983bfc44238f24"

# The maximum number of active connections at a time between each RPC endpoints.
# Default: 20.
rpc_max_conn = 20

# The minimum number of active connections at a time between each RPC endpoints.
# Default: 3.
rpc_min_conn = 3

# Keep-alive timeout in the cluster. Minimum: "5s".
# Default: "30s".
keepalive_timeout = "30s"

# Keep-alive interval in the cluster.
# Default: "10s".
keepalive_interval = "10s"

# Whether to failover automatically when a node goes offline.
# Default: false.
auto_failover = true

# Maximum time a node may stay offline before failover happens when auto_failover is true.
# Minimum value: "3m".
# Default: "10m".
max_offline_duration = "10m"

# -----------------------------------------------------------------------------
# Scheduler
# -----------------------------------------------------------------------------

# Scheduler configuration.
[scheduler]

# Flush jobs.
[scheduler.flush]
# The maximum number of running flush jobs at the same time.
concurrence_limit = 10
# The maximum number of pending flush jobs at the same time.
queue_limit = 10000

# Garbage collection jobs.
[scheduler.gc]
# The maximum number of running gc jobs at the same time.
concurrence_limit = 100
# The maximum number of pending gc jobs at the same time.
queue_limit = 10000

# Compaction jobs.
[scheduler.compact]
# The maximum number of running compact jobs at the same time.
concurrence_limit = 3

# Cluster compact inactive jobs.
[scheduler.cluster_compact_inactive]
# The maximum number of running `cluster compact inactive` jobs at the same time.
concurrence_limit = 10

# Cluster compact active jobs.
[scheduler.cluster_compact_active]
# The maximum number of running `cluster compact active` jobs at the same time.
concurrence_limit = 10

# -----------------------------------------------------------------------------
# Logging
# -----------------------------------------------------------------------------

# Logging configuration.
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
# Supported rotation values:
# - "MINUTELY" or "M".
# - "HOURLY" or "H".
# - "DAILY" or "D".
# Default: "DAILY".
# rotation = "DAILY"

# Optional. Maximum reserved count of log(all, error, slow query) rolling files.
# Note: "all" here covers only the info, error, and slow query logs;
# audit logs are NOT included and are not subject to this limit.
# Value rule:
#   Unset / set to 0 → Unlimited, keep forever
#   Positive integer N → Keep at most N rolling log files
# Default: Unlimited, keep forever.
# max_files = 30

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
verbose = false

# -----------------------------------------------------------------------------
# Audit Logging
# -----------------------------------------------------------------------------

# Optional audit log settings.
# [audit]

# The directory to store audit log files.
# Relative paths are resolved against `base_dir`.
# Default: "audit".
# path = "audit"

# The fixed time period for switching to a new log file.
# Supported rotation values:
# - "MINUTELY" or "M".
# - "HOURLY" or "H".
# - "DAILY" or "D".
# Default: "DAILY".
# rotation = "DAILY"

# Optional. Maximum reserved count of log rolling files.
# Value rule:
#   Unset / set to 0 → Unlimited, keep forever
#   Positive integer N → Keep at most N rolling log files
# Default: Unlimited, keep forever.
# max_files = 30

# Supported kinds of audit logs, separated by comma.
# Kind list: "dml", "ddl", "dql", "admin", "misc"
# "all" means all kinds could be logged.
# Default: "ddl,admin"
# kinds = "ddl,admin"

# Supported actions of audit logs, separated by comma.
# Action list: "select", "insert", "update", "delete", "create", "alter", "drop", "truncate", "trim",
#   "desc", "show", "create_user", "drop_user", "set_password", "grant", "revoke",
#   "flush", "cluster", "migrate", "compact", "export", "misc",
# "all" means all actions could be logged.
# Default: "all"
# actions = "all"

# Exclude actions of audit logs, separated by comma.
# Optional value is the same as `actions`.
# Default: "select,insert"
# excludes = ""

# -----------------------------------------------------------------------------
# Runtime
# -----------------------------------------------------------------------------

# Optional runtime settings.
# [runtime]

# Default runtime.
# [runtime.default]
# Isolated CPU allocation.
# - >= 1: absolute number of CPU cores.
# - = 0: disabled.
# - > 0 and < 1: percentage of all CPU cores, for example 0.2 means 20%.
# Default: 0.0.
# cpu_cores = 0.0

# Background runtime.
# [runtime.background]
# cpu_cores = 0.0

# -----------------------------------------------------------------------------
# License
# -----------------------------------------------------------------------------

# License configuration.
# Configuration `key` has higher priority than `file`,
# when no `key` is specified, the `file` configuration will be used.
[license]
# A trial license key which may be deprecated.
key = "eyJ2IjoxLCJ0IjoxLCJjbiI6Iua+nOWbvuacquadpe+8iOaIkOmDve+8ieaVsOaNruenkeaKgOaciemZkOWFrOWPuCIsImNlIjoieWluYm8ueWFuZ0BkYXRhbGF5ZXJzLmlvIiwic2QiOiIyMDI2MDQyMSIsInZkIjozNjUsIm5sIjozLCJjbCI6MTAwLCJlbCI6MTAwMDAwMDAsImZzIjpbXX0K.Vf1e1CATK9CAgVeFi41I/oEuE6sfULzAomYEcDmwTedZEQvMRTLupiYtLr06aM5mnXNz8hNjApYJ36zJugegml/6JbGATODHOrrWmqgM6EGThup8ANEeBOiLJ+HlMQ+BBCPeW6cHP3FoObQMiRQ5/fX+RsW8luBpPQ1UxwRbEALtN00+DKGHV5np20WQhdp6Eeo1FRIAWDV5mR6km55CVWPgDLT+SBae7C7qJhSL25AHAXdKn7VDPePNnS2RHa9M5N+wqBMYqb4MIqLUyaLzvrymaKtm2CIMEQ3flbMbzyGR+++2sc4t5rv+agVWU61kHaIKYz+jT/StEc8sEcyL/g=="
```

其中配置文件字段详细解释，请查看配置手册。
