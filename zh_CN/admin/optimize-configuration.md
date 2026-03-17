---
title: "性能优化配置指南"
description: "Datalayers 性能优化配置指南：介绍基于系统资源的参数调优方法，帮助你在高负载场景下提升性能、稳定性与资源利用率。"
---
# 性能优化配置指南

## 概述

本文详细介绍如何根据系统资源情况对 Datalayers 进行参数调优，以提升系统性能与稳定性。合理配置能够充分发挥硬件潜力，确保系统在高负载下保持优异表现。

## 前后台线程资源隔离

### 设计原理  

在 Datalayers 的架构设计中，系统线程被明确划分为两类

- **前台线程**：负责处理用户实时请求，如数据插入（insert）、查询（select）等关键操作
- **后台线程**：专注于内部维护任务，如数据压缩（Compaction）、垃圾回收（GC）、数据刷盘（Flush）等

### 资源隔离优势

- **降低资源争抢**：避免前后台任务竞争 CPU 资源
- **保障服务稳定性**：确保用户请求即使在高负载后台任务下也能及时响应
- **提升系统可用性**：防止后台任务影响前台服务的质量和延迟

### 配置示例

```toml
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

建议在 CPU 核数较多且后台任务占比较高的环境中启用该类隔离，以降低前台请求与后台维护任务之间的资源竞争。

## 自动改表

在通过 InfluxDB 行协议写入时，Datalayers 支持根据行协议约定进行自动建表与改表，系统在高负载情况下，改表过程中可能会对写入性能产生一定影响，因此在生产环境中我们建议将自动改表功能关闭掉。
配置示例：

```toml
[ts_engine.schemaless]
# When using schemaless to write data, is automatic table modification allowed.
# Default: false.
auto_alter_table = false
```

## 下一步

- 想做系统层优化，请参考 [Datalayers 系统调优指南](./system-tune.md)
- 想查看配置字段细节，请参考 [runtime 配置字段](./configuration-fields/runtime.md)
- 想做查询层调优，请参考 [查询性能调优概述](../development-guide/query-performance-tuning-overview.md)
