# 系统监控

本系统采用 Datalayers Exporter 采集相关指标，并通过 Prometheus 获取并存储系统监控指标，采用 Grafana 可视化展示监控的指标数据，可监控 FoundationDB 和 Datalayers 的指标。


## 获取 Datalayers Exporter

```
docker run  ghcr.io/datalayers-io/datalayers-exporter:latest
```

Exporter 容器暴露端口为 `9555`

## 配置 Prometheus

获取 prometheus 官方镜像，并启动。

```
docker run -p 9090:9090 prom/prometheus
```

容器运行后，进入容器，在 `/etc/prometheus/prometheus.yml` 配置文件中增加一个任务，定时拉取 FoundationDB 指标数据：

``` yml
global:
  scrape_interval: 5s
  scrape_timeout: 5s
  evaluation_interval: 1m

- job_name: foundationdb
  honor_timestamps: true
  scrape_interval: 5s
  scrape_timeout: 5s
  metrics_path: /metrics-fdb
  scheme: http
  follow_redirects: true
  enable_http2: true
  static_configs:
  - targets:
    - datalayers-exporter:9555
```

再增加一个任务，定时拉取 Datalayers 指标数据：

``` yml
global:
  scrape_interval: 5s
  scrape_timeout: 5s
  evaluation_interval: 1m

- job_name: foundationdb
  honor_timestamps: true
  scrape_interval: 5s
  scrape_timeout: 5s
  metrics_path: /metrics-fdb
  scheme: http
  follow_redirects: true
  enable_http2: true
  static_configs:
  - targets:
    - datalayers-exporter:9555

- job_name: datalayers
  honor_timestamps: true
  scrape_interval: 5s
  scrape_timeout: 5s
  metrics_path: /metrics-dtls
  scheme: http
  follow_redirects: true
  enable_http2: true
  static_configs:
  - targets:
    - datalayers-exporter:9555
```


修改配置文件后，重新启动 Prometheus。


## Grafana 配置

### 添加 Prometheus 数据源

找到 Grafana 菜单 `Configuration - Data sources` ，或访问 `/datasources/new` 页面，选择 Prometheus 分类，进入页面后，填入 Prometheus Server 地址，根据需求填写其他配置，保存并通过测试后生效。

### 添加指标面板

添加 Prometheus 数据源后，可在 `Grafana - Dashboards` 手动添加指标面板，或通过以下 json 文件快速导入模版：

``` json
{

}
```

## FoundationDB 指标

| 指标名称 | 备注 |
| ------------- | ----------- |
| fdb_exporter_latency_seconds | todo |
| fdb_database_available |  |
| fdb_database_locked |  |
| fdb_clients_total |  |
| fdb_datacenter_lag_seconds |  |
| fdb_latency_probe_read_seconds |  |
| fdb_latency_probe_commit_seconds |  |
| fdb_latency_probe_transaction_start_seconds |  |
| fdb_latency_probe_immediate_priority_transaction_start_seconds |  |
| fdb_latency_probe_batch_priority_transaction_start_seconds |  |
| fdb_workload_operations_read_requests_total |  |
| fdb_workload_operations_reads_total |  |
| fdb_workload_operations_writes_total |  |
| fdb_workload_transactions_started_total |  |
| fdb_workload_transactions_committed_total |  |
| fdb_workload_transactions_conflicted_total |  |
| fdb_workload_keys_read_total |  |
| fdb_workload_bytes_read_total |  |
| fdb_workload_bytes_written_total |  |
| fdb_data_state |  |
| fdb_data_least_operating_space_log_server_bytes |  |
| fdb_data_least_operating_space_storage_server_bytes |  |
| fdb_data_average_partition_size_bytes |  |
| fdb_data_partitions_total |  |
| fdb_data_total_disk_used_bytes |  |
| fdb_data_total_kv_size_bytes |  |
| fdb_data_system_kv_size_bytes |  |
| fdb_data_moving_in_flight_bytes |  |
| fdb_data_moving_in_queue_bytes |  |
| fdb_data_moving_total_written_bytes |  |
| fdb_qos_limiting_storage_server_data_lag_seconds |  |
| fdb_qos_limiting_storage_server_durability_lag_seconds |  |
| fdb_qos_limiting_storage_server_queue_bytes |  |
| fdb_qos_worst_storage_server_data_lag_seconds |  |
| fdb_qos_worst_storage_server_durability_lag_seconds |  |
| fdb_qos_worst_storage_server_queue_bytes |  |
| fdb_qos_worst_log_server_queue_bytes |  |
| fdb_qos_released_transactions_per_second |  |
| fdb_qos_transactions_per_second_limit |  |
| fdb_qos_performance_limited_by |  |
| fdb_qos_batch_released_transactions_per_second |  |
| fdb_qos_batch_transactions_per_second_limit |  |
| fdb_qos_batch_performance_limited_by |  |
| fdb_recovery_state |  |
| fdb_recovery_state_active_generations |  |
| fdb_process_uptime_seconds |  |
| fdb_process_class |  |
| fdb_process_degraded |  |
| fdb_process_run_loop_busy_ratio |  |
| fdb_process_cpu_usage_cores |  |
| fdb_process_memory_available_bytes |  |
| fdb_process_memory_used_bytes |  |
| fdb_process_memory_limit_bytes |  |
| fdb_process_memory_unused_allocated_memory |  |
| fdb_process_disk_usage_ratio |  |
| fdb_process_disk_free_bytes |  |
| fdb_process_disk_total_bytes |  |
| fdb_process_disk_reads_total |  |
| fdb_process_disk_writes_total |  |
| fdb_process_network_current_connections_total |  |
| fdb_process_network_connection_errors_rate |  |
| fdb_process_network_connections_closed_rate |  |
| fdb_process_network_connections_established_rate |  |
| fdb_process_network_megabits_received_rate |  |
| fdb_process_network_megabits_sent_rate |  |
| fdb_process_role |  |
| fdb_process_storage_data_lag_seconds |  |
| fdb_process_storage_durability_lag_seconds |  |
| fdb_process_storage_input_bytes_total |  |
| fdb_process_storage_durable_bytes_total |  |
| fdb_process_storage_stored_bytes |  |
| fdb_process_storage_kvstore_available_bytes |  |
| fdb_process_storage_kvstore_free_bytes |  |
| fdb_process_storage_kvstore_total_bytes |  |
| fdb_process_storage_kvstore_used_bytes |  |
| fdb_process_log_queue_disk_available_bytes |  |
| fdb_process_log_queue_disk_free_bytes |  |
| fdb_process_log_queue_disk_total_bytes |  |
| fdb_process_log_queue_disk_used_bytes |  |
| fdb_process_log_input_bytes_total |  |
| fdb_process_log_durable_bytes_total |  |


## Datalayers 指标

todo

