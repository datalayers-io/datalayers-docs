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

该配置处理磁盘上文件元数据的缓存，但在独立模式下不适用。

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

- **`file_meta_cache.disk.shards`**:  
  指定磁盘缓存的分片数量。类似于内存缓存，减少争用但可能引入额外开销。  
  - **默认值**：`16`。

- **`file_meta_cache.disk.reclaimers`**:  
  用于回收未使用或访问频率较低的缓存条目的线程数量。高值可能会增加 CPU 使用率。  
  - **默认值**：`8`。

- **`file_meta_cache.disk.recover_concurrency`**:  
  控制用于恢复过程的线程数量，影响恢复速度。  
  - **默认值**：`2`。

## 文件数据内存缓存

- **`file_cache.memory.capacity`**:  
  配置文件数据的内存缓存大小。  
  - `0`：禁用内存缓存。  
  - **默认值**：`"512MB"`。

- **`file_cache.memory.shards`**:  
  设置内存缓存的分片数量。  
  - **默认值**：`16`。

## 文件数据磁盘缓存

该部分管理磁盘上的文件数据缓存，在独立模式下也被禁用。

- **`file_cache.disk.capacity`**:  
  指定文件数据的磁盘缓存容量。  
  - **默认值**：`"10GB"`。

- **`file_cache.disk.path`**:  
  文件数据磁盘缓存将存储的目录。  
  - **默认值**：`"/var/lib/datalayers/file_cache"`。

- **`file_cache.disk.block_size`**:  
  设置磁盘缓存操作的块大小。  
  - **默认值**：`"64MB"`。

- **`file_cache.disk.buffer_threshold`**:  
  文件缓存操作期间使用的缓冲区大小阈值。  
  - **默认值**：`"128MB"`。

- **`file_cache.disk.compression`**:  
  磁盘缓存数据的压缩算法。选项包括 `"zstd"`、`"lz4"` 或 `"none"`。压缩可以减少磁盘使用，但增加计算开销。  
  - **默认值**：`"none"`。

- **`file_cache.disk.shards`**:  
  指定磁盘缓存的分片数量。  
  - **默认值**：`16`。

- **`file_cache.disk.reclaimers`**:  
  用于回收缓存空间的线程数量。  
  - **默认值**：`8`。

- **`file_cache.disk.recover_concurrency`**:  
  控制恢复文件缓存数据的并发级别。  
  - **默认值**：`4`。

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

## S3 对象存储

此部分配置 Datalayers 使用 Amazon S3 作为存储后端。

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

Datalayers 还可以将数据存储在 Microsoft Azure 的对象存储中。

- **`azure.container`**:  
  用于数据存储的 Azure 容器名称。  
- **`azure.account_name`**:  
  Azure 身份验证的帐户名称。  
- **`azure.account_key`**:  
  Azure 身份验证的帐户密钥。  
- **`azure.endpoint`**:  
  Azure 服务的端点。

## Google Cloud Storage (GCS)

Google Cloud Storage (GCS) 是另一个支持的对象存储后端。

- **`gcs.bucket`**:  
  GCS 桶名称，用于数据存储。  
- **`gcs.scope`**:  
  使用的 GCS 服务范围。  
- **`gcs.credential_path`**:  
  访问 GCS 的凭据文件路径。  
- **`gcs.endpoint`**:  
  GCS 访问的端点 URL。
