# 存储

`storage` 部分配置了 Datalayers 系统中的各种存储组件和缓存机制。这些配置控制数据如何在内存、磁盘上缓存，以及如何存储在不同的后端存储中，如本地存储、FDB 和对象存储（S3、Azure、GCS）。

## 文件元数据内存缓存

- **`file_meta_cache.memory.capacity`**:  
  设置文件元数据的内存缓存大小。  
  - `0`：禁用内存缓存。  
  - **默认值**：`"512MB"`。

- **`file_meta_cache.memory.shards`**:  
  指定内存缓存的分片数量。更多的分片可以通过减少争用来提高性能，但过多的分片可能会引入额外的开销。  
  - **默认值**：`16`。

## 文件元数据磁盘缓存

配置磁盘上的元数据缓存， 在单机模式下无效。

- **`file_meta_cache.disk.capacity`**:  
  设置文件元数据的磁盘缓存容量。  
  - `0`：禁用磁盘缓存。  
  - **默认值**：`"1GB"`。

- **`file_meta_cache.disk.path`**:  
  磁盘缓存将存储的目录。  
  - **默认值**：`"/var/lib/datalayers/meta_cache"`。

- **`file_meta_cache.disk.block_size`**:  
  定义磁盘缓存的块大小。  
  - **默认值**：`"64MB"`。

## 文件数据内存缓存

- **`file_cache.memory.capacity`**:  
  设置文件元数据的内存缓存大小。  
  - `0`：禁用内存缓存。  
  - **默认值**：`"512MB"`。

- **`file_cache.memory.shards`**:  
  指定内存缓存的分片数量。更多的分片可以通过减少争用来提高性能，但过多的分片可能会引入额外的开销。  
  - **默认值**：`16`。

## 文件数据磁盘缓存

配置磁盘上的文件数据缓存， 在单机模式下将会被禁用。

- **`file_cache.disk.capacity`**:  
  指定文件数据的磁盘缓存容量。  
  - **默认值**：`"10GB"`。

- **`file_cache.disk.path`**:  
  文件数据磁盘缓存将存储的目录。  
  - **默认值**：`"/var/lib/datalayers/file_cache"`。

- **`file_cache.disk.block_size`**:  
  设置磁盘缓存操作的块大小。  
  - **默认值**：`"64MB"`。

## 本地存储

- **`local.path`**:  
  设置用于本地存储的文件存储目录。  
  - **默认值**：`"/var/lib/datalayers/storage"`。

## FDB 配置

Datalayers 与 FDB 集成以进行键值存储，以下设置配置了此连接。

- **`fdb.cluster_file`**:  
  FoundationDB 集群文件的路径，客户端和服务器用于连接集群。  
  - **默认值**：`"/etc/foundationdb/fdb.cluster"`。

- **`fdb.namespace`**:  
  指定用于隔离 Datalayers 中的键值的 FDB 命名空间。  
  - **默认值**：`"DL"`。

- **`fdb.max_flush_speed`**:  
  刷新数据到 FDB 的最大速度限制，以每秒为单位。  
  - **默认值**：`"5MB"`。

## 配置默认存储服务

- **`object_store.default_storage_type`**:  
当配置对象存储后，可通过该配置项指定数据默认的存储位置。在 create table 时，如未指定  table options 中的 storage_type，则会使用该配置项的值进行填充。

## S3 对象存储

Amazon S3 的配置，配置该项后可在建表时指定使用 S3 作为数据的持久化存储。

- **`object_store.s3.bucket`**:  
  存储数据的 S3 桶名称。  
- **`object_store.s3.access_key`**:  
  用于身份验证的 S3 访问密钥。  
- **`object_store.s3.secret_key`**:  
  用于 S3 身份验证的密钥。  
- **`object_store.s3.endpoint`**:  
  S3 兼容服务的端点 URL。  
- **`object_store.s3.region`**:  
  指定 S3 桶的区域。

## Azure 对象存储

Microsoft Azure 的对象存储的配置，配置该项后可在建表时指定使用 Azure 作为数据的持久化存储。

- **`azure.container`**:  
  用于数据存储的 Azure 容器名称。  
- **`azure.account_name`**:  
  Azure 身份验证的帐户名称。  
- **`azure.account_key`**:  
  Azure 身份验证的帐户密钥。  
- **`azure.endpoint`**:  
  Azure 服务的端点。

## Google Cloud Storage (GCS)

Google Cloud Storage (GCS) 的存储配置，配置该项后可在建表时指定使用 GCS 作为数据的持久化存储。

- **`gcs.bucket`**:  
  GCS 桶名称，用于数据存储。  
- **`gcs.scope`**:  
  使用的 GCS 服务范围。  
- **`gcs.credential_path`**:  
  访问 GCS 的凭据文件路径。  
- **`gcs.endpoint`**:  
  GCS 访问的端点 URL。
