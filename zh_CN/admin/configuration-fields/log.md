---
title: "日志配置"
description: "Datalayers 日志配置说明：介绍 log 配置组中的日志轮转、标准输出、文件落盘与详细日志参数。"
---
# 日志配置

`log` 部分配置日志的生成、存储和管理方式。

## 配置示例

```toml
# Logging configuration.
[log]
# The directory to store log files.
# Default: "/var/log/datalayers".
path = "/var/log/datalayers/"

# The verbose level of logging.
# Supported levels (the case is not sensitive):
# - trace.
# - debug.
# - info.
# - warn.
# - error.
# Default: "info".
level = "info"

# The fixed time period for switching to a new log file.
# Supported rotation values:
# - "MINUTELY" or "M".
# - "HOURLY" or "H".
# - "DAILY" or "D".
# Default: "DAILY".
# rotation = "DAILY"

# Optional. Maximum reserved count of log(all, error, slow query) rolling files.
# Note: "all" here covers only the info, error, and slow query logs;
# audit logs are NOT included and are not subject to this limit.
# Value rule:
#   Unset / set to 0 → Unlimited, keep forever
#   Positive integer N → Keep at most N rolling log files
# Default: Unlimited, keep forever.
# max_files = 30

# Enables logging to stdout if set to true.
# Default: true.
enable_stdout = true

# Enables logging to files if set to true.
# Default: false.
enable_file = false

# Enables logging errors to dedicated files if set to true.
# Default: false.
enable_err_file = false

# Makes the logging more verbose by inserting line number and file name.
# Default: true.
verbose = false
```
