# Scheduler Configuration

The `scheduler` section manages job scheduling for the Datalayers system, including flush jobs, garbage collection (GC), and cluster compaction tasks. These settings help control how many jobs can run concurrently and how many can queue up when the system is under load.

## Flush Job Configuration

The `flush` job is responsible for writing data from memory to persistent storage. Proper tuning of flush jobs ensures efficient data management, avoiding memory overload or slow performance.

- **`concurrence_limit`**:  
  Defines the maximum number of flush jobs that can run concurrently. Limiting this ensures that the system doesn't become overloaded with multiple flush operations happening at once.  
  - **Default**: `3`.
  - **Example**: `concurrence_limit = 3`.

- **`queue_limit`**:  
  Specifies the maximum number of pending flush jobs waiting to be executed. This prevents the system from queuing too many jobs, which could lead to performance degradation.  
  - **Default**: `10000`.
  - **Example**: `queue_limit = 10000`.

## Garbage Collection (GC) Job Configuration

Garbage collection jobs remove unused or stale data, ensuring efficient use of resources.

- **`concurrence_limit`**:  
  Defines how many garbage collection jobs can run at the same time. This is typically kept low to avoid impacting system performance during critical operations.  
  - **Default**: `1`.
  - **Example**: `concurrence_limit = 1`.

- **`queue_limit`**:  
  Determines how many garbage collection jobs can be queued up at a given time.  
  - **Default**: `10000`.
  - **Example**: `queue_limit = 10000`.

## Cluster Compact Inactive Job Configuration

Cluster compaction reorganizes and optimizes the storage of data across the cluster. It helps improve the efficiency of storage and retrieval.

- **`concurrence_limit`**:  
  Specifies the maximum number of `cluster compact inactive` jobs that can run simultaneously. Compaction is a resource-heavy operation, so it's typically run sparingly to avoid impacting performance.  
  - **Default**: `1`.
  - **Example**: `concurrence_limit = 1`.

These configurations ensure that system jobs like flushing, garbage collection, and compaction are well-managed, providing optimal performance while preventing resource overload.
