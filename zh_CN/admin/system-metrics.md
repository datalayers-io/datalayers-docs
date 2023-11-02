# 系监控指标
DataLayers 提供了丰富的指标来帮助用户了解当前服务状态，监测和定位系统的异常。


## 与监控系统集成 ​

DataLayers 指标支持与 Prometheus 集成。使用第三方监控系统对 DataLayers 进行监控有如下好处：

* DataLayers 的监控数据与其他系统的监控数据进行整合，形成一个完整的监控系统，如监控服务器主机的相关信息。
* 使用更加丰富的监控图表，更直观地展示监控数据，如使用 Grafana 的仪表盘，参考[Grafana监控](./system-monitor-grafana.md)。
* 使用更加丰富的告警方式，更及时地发现问题，如使用 Prometheus 的 Alertmanager。

## DataLayers Metrics

## FoundationDB Metrics
| 指标名称                                                        | 备注                         |
| ---------------------------------------------------------------| --------------------------- |
| fdb_exporter_latency_seconds                                   | todo                        |
| fdb_database_available                                         |                             |
| fdb_database_locked                                            |                             |
| fdb_clients_total                                              |                             |
| fdb_datacenter_lag_seconds                                     |                             |
| fdb_latency_probe_read_seconds                                 |                             |
| fdb_latency_probe_commit_seconds                               |                             |
| fdb_latency_probe_transaction_start_seconds                    |                             |
| fdb_latency_probe_immediate_priority_transaction_start_seconds |                             |
| fdb_latency_probe_batch_priority_transaction_start_seconds     |                             |
| fdb_workload_operations_read_requests_total                    |                             |
| fdb_workload_operations_reads_total                            |                             |
| fdb_workload_operations_writes_total                           |                             |
| fdb_workload_transactions_started_total                        |                             |
| fdb_workload_transactions_committed_total                      |                             |
| fdb_workload_transactions_conflicted_total                     |                             |
| fdb_workload_keys_read_total                                   |                             |
| fdb_workload_bytes_read_total                                  |                             |
| fdb_workload_bytes_written_total                               |                             |
| fdb_data_state                                                 |                             |
| fdb_data_least_operating_space_log_server_bytes                |                             |
| fdb_data_least_operating_space_storage_server_bytes            |                             |
| fdb_data_average_partition_size_bytes                          |                             |
| fdb_data_partitions_total                                      |                             |
| fdb_data_total_disk_used_bytes                                 |                             |
| fdb_data_total_kv_size_bytes                                   |                             |
| fdb_data_system_kv_size_bytes                                  |                             |
| fdb_data_moving_in_flight_bytes                                |                             |
| fdb_data_moving_in_queue_bytes                                 |                             |
| fdb_data_moving_total_written_bytes                            |                             |
| fdb_qos_limiting_storage_server_data_lag_seconds               |                             |
| fdb_qos_limiting_storage_server_durability_lag_seconds         |                             |
| fdb_qos_limiting_storage_server_queue_bytes                    |                             |
| fdb_qos_worst_storage_server_data_lag_seconds                  |                             |
| fdb_qos_worst_storage_server_durability_lag_seconds            |                             |
| fdb_qos_worst_storage_server_queue_bytes                       |                             |
| fdb_qos_worst_log_server_queue_bytes                           |                             |
| fdb_qos_released_transactions_per_second                       |                             |
| fdb_qos_transactions_per_second_limit                          |                             |
| fdb_qos_performance_limited_by                                 |                             |
| fdb_qos_batch_released_transactions_per_second                 |                             |
| fdb_qos_batch_transactions_per_second_limit                    |                             |
| fdb_qos_batch_performance_limited_by                           |                             |
| fdb_recovery_state                                             |                             |
| fdb_recovery_state_active_generations                          |                             |
| fdb_process_uptime_seconds                                     |                             |
| fdb_process_class                                              |                             |
| fdb_process_degraded                                           |                             |
| fdb_process_run_loop_busy_ratio                                |                             |
| fdb_process_cpu_usage_cores                                    |                             |
| fdb_process_memory_available_bytes                             |                             |
| fdb_process_memory_used_bytes                                  |                             |
| fdb_process_memory_limit_bytes                                 |                             |
| fdb_process_memory_unused_allocated_memory                     |                             |
| fdb_process_disk_usage_ratio                                   |                             |
| fdb_process_disk_free_bytes                                    |                             |
| fdb_process_disk_total_bytes                                   |                             |
| fdb_process_disk_reads_total                                   |                             |
| fdb_process_disk_writes_total                                  |                             |
| fdb_process_network_current_connections_total                  |                             |
| fdb_process_network_connection_errors_rate                     |                             |
| fdb_process_network_connections_closed_rate                    |                             |
| fdb_process_network_connections_established_rate               |                             |
| fdb_process_network_megabits_received_rate                     |                             |
| fdb_process_network_megabits_sent_rate                         |                             |
| fdb_process_role                                               |                             |
| fdb_process_storage_data_lag_seconds                           |                             |
| fdb_process_storage_durability_lag_seconds                     |                             |
| fdb_process_storage_input_bytes_total                          |                             |
| fdb_process_storage_durable_bytes_total                        |                             |
| fdb_process_storage_stored_bytes                               |                             |
| fdb_process_storage_kvstore_available_bytes                    |                             |
| fdb_process_storage_kvstore_free_bytes                         |                             |
| fdb_process_storage_kvstore_total_bytes                        |                             |
| fdb_process_storage_kvstore_used_bytes                         |                             |
| fdb_process_log_queue_disk_available_bytes                     |                             |
| fdb_process_log_queue_disk_free_bytes                          |                             |
| fdb_process_log_queue_disk_total_bytes                         |                             |
| fdb_process_log_queue_disk_used_bytes                          |                             |
| fdb_process_log_input_bytes_total                              |                             |
| fdb_process_log_durable_bytes_total                            |                             |
