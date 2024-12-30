# 调度器配置

`scheduler` 管理 Datalayers 系统的作业调度，包括 memtable 数据落盘、垃圾回收（GC）和SST Compact等任务。这些设置帮助控制系统在负载下可以并发运行多少作业，以及可以排队多少作业。

这些配置确保了系统作业如刷新、垃圾回收和压缩的良好管理，提供最佳性能，同时防止资源过载。

## 配置示例

```toml
# The configurations of the scheduler.
[scheduler]

# The configurations of the flush job.
[scheduler.flush]
# The maximum number of running flush jobs at the same time.
concurrence_limit = 3
# The maximum number of pending flush jobs at the same time
queue_limit = 10000

[scheduler.gc]
# The maximum number of running gc jobs at the same time.
concurrence_limit = 1
# The maximum number of pending gc jobs at the same time
queue_limit = 10000

[scheduler.cluster_compact_inactive]
# The maximum number of running `cluster compact inactive` jobs at the same time.
concurrence_limit = 1
```
