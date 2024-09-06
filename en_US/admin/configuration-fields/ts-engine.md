# Time Series Engine

The `ts_engine` section defines configuration settings for the Time-Series engine within Datalayers. These settings control how the engine handles data storage, writes, and flush operations, with a focus on managing the Write-Ahead Logging (WAL) component for reliability and performance.

## Configure Worker Channel

- **`worker_channel_size`**:  
  This setting specifies the size of the request channel for each worker in the Time-Series engine. A larger channel size allows more requests to be queued before being processed by the worker, which can help optimize performance under high load.  
  - **Default**: `128`.

## Configure Memtable Flush on Exit

- **`flush_on_exit`**:  
  This setting controls whether the Time-Series engine flushes the in-memory data structures (memtables) to persistent storage when the system or a worker exits.  
  - `true`: Flush memtable contents to persistent storage upon exit, ensuring no data loss.  
  - `false`: No flush upon exit, which may result in potential data loss.  
  - **Default**: `true`.

## Write-Ahead Logging (WAL)

The `ts_engine.wal` section handles the configurations of the WAL component, which ensures durability by recording changes before they are applied to the data store.

### Configure WAL Type

- **`type`**:  
  Specifies the type of WAL used by the Time-Series engine. Currently, only the "local" WAL is supported, which stores the log files locally on the server.  
  - **Default**: `"local"`.

### Control WAL Operations

- **`disable`**:  
  Controls whether WAL is enabled. Disabling the WAL will skip both writing changes to the WAL and replaying them during system restart.  
  - `true`: WAL is disabled, meaning no changes are logged or replayed. This may lead to potential data loss, and it's recommended only for non-critical environments.  
  - `false`: WAL is enabled, ensuring data consistency by logging changes and replaying them if necessary.  
  - **Default**: `false`.

- **`skip_replay`**:  
  Determines whether to skip the WAL replay process during system startup.  
  - `true`: WAL replay is skipped, which is recommended only for development environments.  
  - `false`: WAL replay is performed to restore the system to its last consistent state.  
  - **Default**: `false`.

### Configure WAL Storage

- **`path`**:  
  Defines the directory where WAL files are stored.  
  - **Default**: `"/var/lib/datalayers/wal"`.

### WAL Flush and File Management

- **`flush_interval`**:  
  Specifies the fixed time interval at which cached WAL entries are flushed to persistent storage.  
  - `0`: Immediate flush after every write operation.  
  - **Default**: `"0s"`. This setting is only applicable when using the "local" WAL type.

- **`max_file_size`**:  
  Limits the size of individual WAL files. When the file exceeds this size, a new WAL file is created.  
  - **Default**: `64MB`. This setting is only used when the WAL type is "local".
