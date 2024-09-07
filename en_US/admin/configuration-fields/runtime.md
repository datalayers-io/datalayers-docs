# Runtime Configuration

The `runtime` section configures the CPU allocation and other runtime-specific settings for Datalayers. It allows the fine-tuning of CPU resources used by default operations and background tasks.

## Default Runtime Configuration

The `runtime.default` configuration controls the CPU usage for the primary operations of the system.

- **`cpu_cores`**:  
  Defines how many CPU cores are allocated to the default runtime. This setting allows for flexible CPU resource management. The value can be an absolute number, a percentage of total CPU cores, or `0` to disable CPU isolation for the runtime.  
  - `>= 1`: Specifies the absolute number of CPU cores to allocate.  
  - `0`: Disables CPU isolation for this runtime, meaning no specific cores are dedicated to it.  
  - `> 0 and < 1`: Specifies the percentage of total CPU cores to allocate. For example, `0.2` means 20% of all CPU cores.  
  - **Default**: `0.0` (no CPU isolation).

## Background Runtime Configuration

The `runtime.background` configuration manages the CPU resource allocation for background tasks that run alongside primary operations.

- **`cpu_cores`**:  
  Controls the number of CPU cores dedicated to background tasks. The value can follow the same rules as the `runtime.default` setting:  
  - `>= 1`: Absolute number of CPU cores for background tasks.  
  - `0`: No CPU isolation for background tasks.  
  - `> 0 and < 1`: Percentage of total CPU cores allocated for background tasks.  
  - **Default**: `0.0` (no CPU isolation).
