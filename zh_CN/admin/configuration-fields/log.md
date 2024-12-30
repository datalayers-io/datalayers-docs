# 日志配置

`log` 部分配置日志的生成、存储和管理方式。

## 配置示例

```toml
# The fixed time period for switching to a new log file.
# Supported rotation kinds:
# - "MINUTELY" or "M".
# - "HOURLY" or "H".
# - "DAILY" or "D".
# - "NEVER" or "N".
# Default: "HOURLY".
rotation = "DAILY"

# 日志是否输出到标准输出中，在容器中，将默认输出到标准输出 
# Default: true.
enable_stdout = true

# Enables logging to files if set to true.
# Default: false.
enable_file = false

# 设置错误日志是否启用单独的文件文件存储.
# Default: false.
enable_err_file = false

# Makes the logging more verbose by inserting line number and file name.
# Default: true.
verbose = true
```
