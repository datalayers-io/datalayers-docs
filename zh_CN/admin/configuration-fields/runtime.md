# Runtime 配置

该配置项用于 `CPU Core` 与 `用户线程`、`后台线程`进行分离与绑定，以保障系统在高负载时前台线程与后台线程不会争抢 CPU 资源。在系统负载较高的场景建议配置该项。

```tips
后台线程包括不限于：compact、flush、gc、compact_active、compact_inactive

前台线程：除后台线程之外的其他线程
```

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
