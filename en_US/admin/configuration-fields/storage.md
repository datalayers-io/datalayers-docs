# Storage

The `storage` section configures various storage components and caching mechanisms within Datalayers. These configurations control how data is cached in memory, on disk, and stored across different backends like local storage, FoundationDB, and object stores (S3, Azure, GCS).

## File Meta Memory Cache

- **`file_meta_cache.memory.capacity`**:  
  Sets the memory cache size for file metadata.  
  - `0`: Disables the memory cache.  
  - **Default**: `"512MB"`.

- **`file_meta_cache.memory.shards`**:  
  Specifies the number of shards for the memory cache. More shards can improve performance by reducing contention. However, too many shards may introduce overhead.  
  - **Default**: `16`.

## File Meta Disk Cache

This configuration handles caching of file metadata on disk, but it is not applicable in standalone mode.

- **`file_meta_cache.disk.capacity`**:  
  Sets the disk cache capacity for file metadata.  
  - `0`: Disables disk cache.  
  - **Default**: `"1GB"`.

- **`file_meta_cache.disk.path`**:  
  The directory where the disk cache will be stored.  
  - **Default**: `"/var/lib/datalayers/meta_cache"`.

- **`file_meta_cache.disk.block_size`**:  
  Defines the block size of the disk cache.  
  - **Default**: `"64MB"`.

- **`file_meta_cache.disk.shards`**:  
  Specifies the number of shards for the disk cache. Similar to memory cache, this reduces contention but may introduce overhead with many shards.  
  - **Default**: `16`.

- **`file_meta_cache.disk.reclaimers`**:  
  Number of threads that reclaim unused or less frequently accessed cache entries. High values can increase CPU usage.  
  - **Default**: `8`.

- **`file_meta_cache.disk.recover_concurrency`**:  
  Controls the number of threads used for recovery processes, affecting recovery speed.  
  - **Default**: `2`.

## File Data Memory Cache

- **`file_cache.memory.capacity`**:  
  Configures the memory cache size for file data.  
  - `0`: Disables the memory cache.  
  - **Default**: `"512MB"`.

- **`file_cache.memory.shards`**:  
  Sets the number of shards for the memory cache.  
  - **Default**: `16`.

## File Data Disk Cache

This section manages caching of file data on disk, which is also disabled in standalone mode.

- **`file_cache.disk.capacity`**:  
  Specifies the disk cache capacity for file data.  
  - **Default**: `"10GB"`.

- **`file_cache.disk.path`**:  
  The directory where the file data disk cache will be stored.  
  - **Default**: `"/var/lib/datalayers/file_cache"`.

- **`file_cache.disk.block_size`**:  
  Sets the block size for disk cache operations.  
  - **Default**: `"64MB"`.

- **`file_cache.disk.buffer_threshold`**:  
  The buffer size threshold to be used during file cache operations.  
  - **Default**: `"128MB"`.

- **`file_cache.disk.compression`**:  
  The compression algorithm for disk cache data. Options include `"zstd"`, `"lz4"`, or `"none"`. Compression can reduce disk usage but increases computational overhead.  
  - **Default**: `"none"`.

- **`file_cache.disk.shards`**:  
  Specifies the number of shards for the disk cache.  
  - **Default**: `16`.

- **`file_cache.disk.reclaimers`**:  
  Number of threads used for reclaiming cache space.  
  - **Default**: `8`.

- **`file_cache.disk.recover_concurrency`**:  
  Controls the concurrency level for recovering file cache data.  
  - **Default**: `4`.

## Local Storage

- **`local.path`**:  
  Sets the directory where files are stored for local storage.  
  - **Default**: `"/var/lib/datalayers/storage"`.

## FoundationDB-Backed Storage

Datalayers integrates with FoundationDB for key-value storage, and the following settings configure this connection.

- **`fdb.cluster_file`**:  
  The path to the FoundationDB cluster file, which clients and servers use to connect to a cluster.  
  - **Default**: `"/etc/foundationdb/fdb.cluster"`.

- **`fdb.namespace`**:  
  Specifies the namespace used to isolate key-values within FoundationDB for Datalayers.  
  - **Default**: `"DL"`.

- **`fdb.max_flush_speed`**:  
  The maximum speed limit for flushing data to FoundationDB, specified per second.  
  - **Default**: `"5MB"`.

## S3 Object Store

This section configures Datalayers to use Amazon S3 as a storage backend.

- **`object_store.s3.bucket`**:  
  The S3 bucket name where data is stored.  
- **`object_store.s3.access_key`**:  
  The S3 access key used for authentication.  
- **`object_store.s3.secret_key`**:  
  The secret key for S3 authentication.  
- **`object_store.s3.endpoint`**:  
  The endpoint URL of the S3-compatible service.  
- **`object_store.s3.region`**:  
  Specifies the region for the S3 bucket.

## Azure Object Store

Datalayers can also store data in Microsoft Azure's object storage.

- **`azure.container`**:  
  The Azure container name for data storage.  
- **`azure.account_name`**:  
  The account name for Azure authentication.  
- **`azure.account_key`**:  
  The account key for Azure authentication.  
- **`azure.endpoint`**:  
  The Azure service endpoint.

## Google Cloud Storage (GCS)

Google Cloud Storage (GCS) is another supported object storage backend.

- **`gcs.bucket`**:  
  The GCS bucket name for data storage.  
- **`gcs.scope`**:  
  The scope of GCS services used.  
- **`gcs.credential_path`**:  
  The path to the credentials file for accessing GCS.  
- **`gcs.endpoint`**:  
  The GCS endpoint URL for access.
