---
title: "节点配置"
description: "Datalayers 节点配置说明：介绍 node 配置中的节点标识、超时、重试与 RPC 连接参数，帮助你稳定运行集群通信。"
---
# 节点配置

`node` 配置定义了 Datalayers 集群节点的关键行为与属性，包括节点标识、超时策略、重试机制和 RPC 连接管理。

## 配置示例

```toml
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

# The timeout of keep-alive in the cluster, in seconds, minimum 5
# Default: "30s"
keepalive_timeout = "30s"


 # The interval of keep-alive in the cluster, in seconds,
 # Default: "10s"
keepalive_interval = "10s"

# Whether or not to auto failover when node failure
# Default: false.
auto_failover = true

# The maximum duration allowed for node to be offline.
# If the node is offline longer than this duration and auto_failover is enabled,
# the node may be failovered automatically.
# Minimum value: "3m"
# Default: "10m"
max_offline_duration = "10m"
```

## 配置项说明

- `name`：节点唯一标识，集群内不能重复。
- `connect_timeout`：连接集群节点的超时时间。
- `timeout`：节点间单次请求的超时时间。
- `retry_count`：内部连接失败时的最大重试次数。
- `token`：集群模式下节点间内部通信使用的共享令牌。
- `rpc_max_conn` / `rpc_min_conn`：每个 RPC 目标维护的连接池上限和下限。
- `keepalive_timeout` / `keepalive_interval`：节点保活超时和发送间隔。
- `auto_failover`：是否在节点长时间离线后自动触发 failover。
- `max_offline_duration`：允许节点离线的最大时长，仅在 `auto_failover = true` 时生效。
