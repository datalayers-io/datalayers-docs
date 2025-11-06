# 系统监控指标

Datalayers 提供丰富的监控指标，帮助用户全面掌握服务运行状态，快速识别和定位系统异常。

## 与监控系统集成 ​

Datalayers 原生支持与 Prometheus 集成，实现高效的监控数据采集。将 Datalayers 接入第三方监控系统可带来以下优势：

* **统一监控视图**：将 Datalayers 的监控数据与其他系统指标（如服务器主机信息）整合，构建完整的监控体系
* **可视化展示**：通过 Grafana 等工具创建丰富的监控仪表盘，直观呈现系统运行状态（详见 [Grafana监控](./system-monitor-grafana.md)）
* **智能告警**：利用 Prometheus Alertmanager 实现多通道告警通知，及时发现问题并快速响应

## Datalayers Metrics

| Key                                                   | Type      | 说明                                                      |
| ----------------------------------------------------- | --------- | --------------------------------------------------------- |
| **datalayers_system_memory_usage**                    | gauge     | <span style="color:red">*</span> Datalayers 节点系统内存使用量，建议峰值负载不高于 60%       |
| **datalayers_memory_usage**                           | gauge     | <span style="color:red">*</span> Datalayers 进程内存占用，建议峰值时不高于系统总内存的 60%   |
| **datalayers_cpu_usage**                              | gauge     | <span style="color:red">*</span> Datalayers 进程 CPU 使用率，建议峰值时不高于 60%                |
| **datalayers_system_cpu_usage**                       | gauge     | <span style="color:red">*</span> Datalayers 节点系统整体 CPU 使用率，建议峰值时不高于 60%       |
| datalayers_system_memory_total                        | gauge     | Datalayers 节点系统总内存                                  |
| datalayers_cpu_total                                  | gauge     | Datalayers 节点 CPU core 数量                              |
| datalayers_ingest_rows_total                          | counter   | Datalayers 写入的行数                                     |
| datalayers_select_total                               | counter   | Datalayers select 请求次数                                |
| parquet_meta_op_total                                 | counter   | parquet meta 缓存相关指标                                 |
| datalayers_parquet_meta_cache_usage                   | gauge     | Parquet meta 和 statistics 的缓存使用量                   |
| datalayers_parquet_meta_cache_config_size             | gauge     | 缓存 Parquet meta 和 statistics 的最大内存使用量           |
| datalayers_flush_queue_limit                          | gauge     | Flush 任务队列长度限制                                    |
| datalayers_flush_concurrence_limit                    | gauge     | Flush 并行任务限制                                        |
| **datalayers_flush_pending_length**                   | gauge     | <span style="color:red">*</span> Flush 队列中等待的数量，该值不应该等于 datalayers_flush_queue_limit 的数量     |
| datalayers_flush_running_length                       | gauge     | 正在 Flush 任务的数量                                    |
| datalayers_compact_queue_limit                        | gauge     | Compact 任务队列长度限制                                  |
| datalayers_compact_concurrence_limit                  | gauge     | Compact 并行任务限制                                      |
| datalayers_compact_pending_length                     | gauge     | Compact pending 中的数量                                  |
| datalayers_compact_running_length                     | gauge     | Compact running 中的数量                                  |
| datalayers_global_rejected_write                      | counter   | Datalayers 节点 memtable 的数据量达到阈值后拒绝写入的次数   |
| datalayers_rejected_write                             | counter   | Table 分区 memtable 的数据量达到阈值后拒绝写入的次数        |
| latency_flush_per_10m_milliseconds                    | histogram | Flush 平均生成 10M 数据的延迟                             |
| latency_compact_per_10m_milliseconds                  | histogram | Compact 平均生成 10M 数据的延迟                           |
| datalayers_panic_total                                | counter   | Datalayers panic 的次数                                   |
| datalayers_hybrid_cached_file_memory_config_size      | gauge     | 缓存对象存储文件内容的最大内存使用量                        |
| datalayers_hybrid_cached_file_disk_config_size        | gauge     | 缓存对象存储文件内容的最大磁盘使用量                        |
| datalayers_hybrid_cached_file_meta_memory_config_size | gauge     | 缓存对象存储文件 meta 信息的最大内存使用量                  |

## FDB Metrics

| Key                                                   | Type      | 说明                                                      |
| ----------------------------------------------------- | --------- | --------------------------------------------------------- |
| **fdb_database_available**                            | gauge     | <span style="color:red">*</span> 元数据服务状态状态，0 不健康，1 状态       |
| **fdb_process_disk_free_bytes**                       | gauge     | <span style="color:red">*</span> 元数据存储磁盘已使用空间大小，单位：bytes, 使用空间不超过：80%    |
| **fdb_exporter_latency_seconds**                      | gauge     | <span style="color:red">*</span> 访问元数据服务的时延，单位：秒。不应该大于1                      |
| fdb_process_disk_total_bytes                          | gauge     | 元数据存储磁盘的总空间大小，单位：bytes   |
