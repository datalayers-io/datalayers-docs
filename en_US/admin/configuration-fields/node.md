# Node Configuration

The `node` section configures the behavior and attributes of a node within the Datalayers cluster. The node's configuration ensures proper identification, role assignment, timeouts, connection management, and data storage. Below are the specific configuration items:

## Node Name

- **`name`**:  
  Defines the unique identifier for the node in the cluster. This value **must** be unique across the cluster to avoid conflicts.  
  - **Default**: `"localhost:8366"`.
  - **Example**: `name = "localhost:8366"`.

## Role

- **`role`**:  
  Specifies the role of the node in the cluster. Possible roles could be `stateless`, `stateful`, or other roles as defined in the system.  
  - **Default**: `"stateless"`.
  - **Example**: `role = "stateless"`.

## Connection Timeout

- **`connect_timeout`**:  
  Sets the timeout duration for establishing connections to the cluster.  
  - **Default**: `"1s"`.
  - **Example**: `connect_timeout = "1s"`.

## Request Timeout

- **`timeout`**:  
  This value defines the timeout duration applied to each request sent to the cluster. This prevents requests from hanging indefinitely.  
  - **Default**: `"120s"`.
  - **Example**: `timeout = "120s"`.

## Retry Count

- **`retry_count`**:  
  Determines the maximum number of retries for establishing internal connections.  
  - **Default**: `1`.
  - **Example**: `retry_count = 1`.

## Data Path

- **`data_path`**:  
  Specifies the directory where the node stores its data.  
  - **Default**: `"/var/run/datalayers"`.
  - **Example**: `data_path = "/var/run/datalayers"`.

## RPC Connection Limits

- **`rpc_max_conn`**:  
  Sets the maximum number of active connections allowed between each RPC endpoint at a time. Limiting the number of connections can help manage resource usage.  
  - **Default**: `20`.
  - **Example**: `rpc_max_conn = 20`.

- **`rpc_min_conn`**:  
  Specifies the minimum number of active connections between each RPC endpoint. Maintaining a minimum number of connections ensures that the node is ready to handle requests efficiently.  
  - **Default**: `3`.
  - **Example**: `rpc_min_conn = 3`.

These configurations define how each node interacts with the cluster, manages timeouts, and handles RPC connections, ensuring smooth operation in a distributed environment.
