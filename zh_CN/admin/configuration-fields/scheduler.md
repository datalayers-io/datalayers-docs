# 调度器配置

`scheduler` 管理 Datalayers 系统的作业调度，包括 memtable 数据落盘、垃圾回收（GC）和SST Compact等任务。这些设置帮助控制系统在负载下可以并发运行多少作业，以及可以排队多少作业。

这些配置确保了系统作业如刷新、垃圾回收和压缩的良好管理，提供最佳性能，同时防止资源过载。

## Flush Job 配置

`flush` Job 负责将数据从内存写入持久化存储。

- **`concurrence_limit`**:  
  定义当前节点可以同时运行的最大`flush`作业数。限制这一数值可以确保系统不会因多个刷新操作同时进行而过载。  
  - **默认值**：`3`。
  - **示例**：`concurrence_limit = 3`。

- **`queue_limit`**:  
  指定当前节点等待执行的最大待处理刷新作业数。这可以防止系统排队过多作业，从而导致性能下降。  
  - **默认值**：`10000`。
  - **示例**：`queue_limit = 10000`。

- **完整示例**:
  ```
  [scheduler.flush]
  concurrence_limit = 1
  queue_limit = 10000
  ```

## 垃圾回收（GC）作业配置

垃圾回收作业用于删除未使用或过时的数据，以确保资源的有效使用。

- **`concurrence_limit`**:  
  定义当前节点可以同时运行的垃圾回收作业数。这通常保持较低，以避免在关键操作期间影响系统性能。  
  - **默认值**：`1`。
  - **示例**：`concurrence_limit = 1`。

- **`queue_limit`**:  
  确定当前节点可以排队的垃圾回收作业数。  
  - **默认值**：`10000`。
  - **示例**：`queue_limit = 10000`。

- **完整示例**:
  ```
  [scheduler.gc]
  concurrence_limit = 1
  queue_limit = 10000
  ```

## Compact 作业配置

`compact` Job 负责对数据进行压缩、重组和优化，有助于提高存储和检索的效率。
- **`concurrence_limit`**:  
  定义当前节点可以同时运行的 Compact 作业数。这通常保持较低，以避免在关键操作期间影响系统性能。  
  - **默认值**：`1`。
  - **示例**：`concurrence_limit = 1`。

- **`queue_limit`**:  
  确定当前节点可以排队的 Compact 作业数。  
  - **默认值**：`10000`。
  - **示例**：`queue_limit = 10000`。

- **完整示例**:
  ```
  [scheduler.compact]
  concurrence_limit = 1
  queue_limit = 10000
  ```

## 集群 Compact 活跃窗口作业配置

集群模式下，控制所有节点同时运行的针对活跃窗口数据的 Compact 作业数量。活跃窗口是指当前正在写入数据的时间窗口，和表引擎中定义的 `COMPACT_WINDOW` 有关。

数据压缩是资源密集型操作，全局控制总作业数量有助于防止集群资源使用过载，影响关键操作。

- **`concurrence_limit`**:  
  指定所有节点可以同时运行的针对活跃窗口数据的 Compact 作业数。
  - **默认值**：`4`。
  - **示例**：`concurrence_limit = 4`。
- **完整示例**:
  ```
  [scheduler.cluster_compact_active]
  concurrence_limit = 2
  ```

## 集群 Compact 非活跃窗口作业配置

集群模式下，控制所有节点同时运行的针对非活跃窗口数据的 Compact 作业数量。非活跃窗口是指活跃窗口之前的时间窗口，和表引擎中定义的 `COMPACT_WINDOW` 有关。

- **`concurrence_limit`**:  
  指定所有节点可以同时运行的针对非活跃窗口数据的 Compact 作业数。
  - **默认值**：`2`。
  - **示例**：`concurrence_limit = 2`。
- **完整示例**:
  ```
  [scheduler.cluster_compact_inactive]
  concurrence_limit = 1
  ```
