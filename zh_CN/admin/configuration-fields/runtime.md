---
title: "Runtime 配置"
description: "Datalayers Runtime 配置说明：介绍 CPU 核心隔离与前后台线程绑定策略，帮助你在高负载场景下减少资源争抢并提升稳定性。"
---
# Runtime 配置

该配置项用于将 `CPU Core` 与 `用户线程`、`后台线程`进行隔离与绑定，以保障系统在高负载场景下减少前后台线程的 CPU 资源争抢。

::: tip
后台线程包括不限于：compact、flush、gc、compact_active、compact_inactive

前台线程：除后台线程之外的其他线程
:::

## 配置示例

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
#[runtime.background]
#cpu_cores = 0.0
```
