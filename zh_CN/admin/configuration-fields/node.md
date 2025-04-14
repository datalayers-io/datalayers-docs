# 节点配置

`node` 部分配置 Datalayers 集群中节点的行为和属性。节点的配置确保正确的标识、角色分配、超时设置、连接管理和数据存储。以下是具体的配置项：

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

# The directory to store data of the node.
# Default: "/var/lib/datalayers/run".
data_path = "/var/lib/datalayers/run"

# The maximum number of active connections at a time between each RPC endpoints.
# Default: 20.
rpc_max_conn = 20

# The minimum number of active connections at a time between each RPC endpoints.
# Default: 3.
rpc_min_conn = 3

# The timeout of keep-alive in the cluster, in seconds, minimum 5
# Default: 30
keepalive_timeout = 30

# The interval of keep-alive in the cluster, in seconds,
#   minimum 1, maximum `keepalive_timeout / 2`
# Default: keepalive_timeout / 3
keepalive_interval = 10

# Whether or not to auto failover when node failure
# Default: false.
auto_failover = false
```
