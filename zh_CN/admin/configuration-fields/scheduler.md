---
title: "调度器配置 | Datalayers 文档"
description: "scheduler 管理 Datalayers 系统的作业调度，包括 memtable 数据落盘、垃圾回收（GC）和 SST Compact 等任务。这些设置用于控制系统在负载下可并发运行和排队的作业数量上限。"
---
# 调度器配置

`scheduler` 管理 Datalayers 系统的作业调度，包括 memtable 数据落盘、垃圾回收（GC）和 SST Compact 等任务。这些设置用于控制系统在负载下可并发运行和排队的作业数量上限。

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
concurrence_limit = 100
# The maximum number of pending gc jobs at the same time
queue_limit = 10000

[scheduler.compact]
# The maximum number of pending compact jobs at the same time
concurrence_limit = 3

[scheduler.cluster_compact_inactive]
# The maximum number of running `cluster compact inactive` jobs at the same time.
concurrence_limit = 10

[scheduler.cluster_compact_active]
# The maximum number of running `cluster compact active` jobs at the same time.
concurrence_limit = 10
```
