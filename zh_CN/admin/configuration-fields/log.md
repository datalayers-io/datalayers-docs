# 日志配置

`log` 部分配置日志的生成、存储和管理方式。

- **`path`**:  
  指定日志文件存储的目录。确保该目录具有足够的权限，以便 Datalayers 系统可以写入日志。  
  - **默认值**：`"/var/log/datalayers/"`。
  - **示例**：`path = "/var/log/datalayers/"`。

- **`level`**:  
  设置日志输出的详细程度。可用的级别包括：
  - `"trace"`：详细的调试信息。
  - `"debug"`：调试信息。
  - `"info"`：一般操作信息。
  - `"warn"`：潜在问题的警告。
  - `"error"`：发生的错误。  
  - **默认值**：`"info"`。
  - **示例**：`level = "info"`。

- **`rotation`**:  
  确定新日志文件的创建频率。旋转选项包括：
  - `"MINUTELY"` 或 `"M"`：每分钟。
  - `"HOURLY"` 或 `"H"`：每小时。
  - `"DAILY"` 或 `"D"`：每天。
  - `"NEVER"` 或 `"N"`：不旋转。  
  - **默认值**：`"DAILY"`。
  - **示例**：`rotation = "DAILY"`。

- **`enable_stdout`**:  
  如果设置为 `true`，日志输出还会发送到标准输出（stdout）。这对于调试和实时监控非常有用。  
  - **默认值**：`true`。
  - **示例**：`enable_stdout = true`。

- **`enable_file`**:  
  如果设置为 `true`，日志将写入指定目录中的文件。通常启用此选项以实现持久的日志存储。  
  - **默认值**：`false`。
  - **示例**：`enable_file = true`。

- **`enable_err_file`**:  
  如果设置为 `true`，错误将记录到专用的错误文件中。这有助于将错误日志与普通日志分开，以便更容易进行故障排除。  
  - **默认值**：`false`。
  - **示例**：`enable_err_file = true`。

- **`verbose`**:  
  设置为 `true` 时，日志会包含额外的详细信息，如行号和文件名。这增强了日志的可读性，但可能会生成更大的日志文件。  
  - **默认值**：`true`。
  - **示例**：`verbose = true`。
