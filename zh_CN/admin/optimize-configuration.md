# 优化配置
本章节主要介绍如何根据资源情况，对系统进行调参优化，以提升系统的性能与稳定性。

## 前后台线程分离
在 Datalayers 的设计中，系统线程分为前台线程、后台线程。前台线程主要负责处理用户请求，如：insert、select 等，后台线程专注于处理后台任务，如：Compaction、GC、Flush等。为了降低前后台线程的相互影响，在对稳定性要求较高的场景，我们建议将前台线程与后台线程分离，分别绑定不同的 `CPU CORE`，减少 CPU 资源的争抢，以确保在高并发的情况下系统的稳定性与可用性。

配置示例：
```
# The configurations of runtime.
[runtime]

# The configurations of default runtime
#[runtime.default]
# Isolate number of CPU, float value
# >=1 means absolute number of CPU
# 0 means do not use isolate cpu for this runtime
# >0 and <1 means percentage of all CPU cores, 0.2  means 20% e.g.
# Default: 0.0
#cpu_cores = 0.0

# The configurations of background runtime
[runtime.background]
cpu_cores = 4
```
以上配置表示 CPU 的最后4个 Core 用于后台任务，其余的为前台线程。详见：[runtime](../admin/configuration-fields/runtime.md)


## 自动改表
在通过 InfluxDB 行协议写入时，Datalayers 支持根据行协议约定进行自动建表与改表，系统在高负载情况下，改表过程中可能会对写入性能产生一定影响，因此在生产环境中我们建议将自动改表功能关闭掉。
配置示例：
```
[ts_engine.schemaless]
# When using schemaless to write data, is automatic table modification allowed.
# Default: false.
auto_alter_table = false
```
