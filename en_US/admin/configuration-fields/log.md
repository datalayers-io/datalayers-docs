# Log and License Configuration

The `log` and `license` sections handle logging settings and license management for the Datalayers system. Proper configuration of these items ensures effective monitoring and compliance with licensing agreements.

## Logging Configuration

The `log` section configures how logs are generated, stored, and managed.

- **`path`**:  
  Specifies the directory where log files are stored. Ensure this directory has adequate permissions for the Datalayers system to write logs.  
  - **Default**: `"/var/log/datalayers/"`.
  - **Example**: `path = "/var/log/datalayers/"`.

- **`level`**:  
  Sets the verbosity of the logging output. Available levels include:
  - `"trace"`: Detailed debugging information.
  - `"debug"`: Debugging information.
  - `"info"`: General operational information.
  - `"warn"`: Warnings about potential issues.
  - `"error"`: Errors that occur.  
  - **Default**: `"info"`.
  - **Example**: `level = "info"`.

- **`rotation`**:  
  Determines how often a new log file is created. Rotation options include:
  - `"MINUTELY"` or `"M"`: Every minute.
  - `"HOURLY"` or `"H"`: Every hour.
  - `"DAILY"` or `"D"`: Every day.
  - `"NEVER"` or `"N"`: No rotation.  
  - **Default**: `"DAILY"`.
  - **Example**: `rotation = "DAILY"`.

- **`enable_stdout`**:  
  If set to `true`, logging output is also sent to the standard output (stdout). This is useful for debugging and real-time monitoring.  
  - **Default**: `true`.
  - **Example**: `enable_stdout = true`.

- **`enable_file`**:  
  If set to `true`, logs will be written to files in the specified directory. This is generally enabled for persistent log storage.  
  - **Default**: `false`.
  - **Example**: `enable_file = true`.

- **`enable_err_file`**:  
  If set to `true`, errors are logged to a dedicated error file. This helps in separating error logs from general logs for easier troubleshooting.  
  - **Default**: `false`.
  - **Example**: `enable_err_file = true`.

- **`verbose`**:  
  When set to `true`, logging includes additional details such as line numbers and file names. This enhances log readability but can generate larger log files.  
  - **Default**: `true`.
  - **Example**: `verbose = true`.
