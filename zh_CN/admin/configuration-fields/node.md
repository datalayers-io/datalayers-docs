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
token = "c720790361da719344973bfc44138f24"

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
```
