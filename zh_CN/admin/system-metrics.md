# 系统监控指标

Datalayers 提供了丰富的指标来帮助用户了解当前服务状态，监测和定位系统的异常。

## 与监控系统集成 ​

Datalayers 指标支持与 Prometheus 集成。使用第三方监控系统对 Datalayers 进行监控有如下好处：

* Datalayers 的监控数据与其他系统的监控数据进行整合，形成一个完整的监控系统，如监控服务器主机的相关信息。
* 使用更加丰富的监控图表，更直观地展示监控数据，如使用 Grafana 的仪表盘，参考[Grafana监控](./system-monitor-grafana.md)。
* 使用更加丰富的告警方式，更及时地发现问题，如使用 Prometheus 的 Alertmanager。

## Datalayers Metrics

| Key                                        | Type             |  说明                             |
| -------------------------------------------| ---------------- | -------------------------------- |
| datalayers_memory_total                    | gauge            | Datalayers 节点总内存              |
| datalayers_memory_usage                    | gauge            | Datalayers 进程内存占用            |
| datalayers_cpu_total                       | gauge            | Datalayers 节点CPU core 数量       |
| datalayers_cpu_usage                       | gauge            | Datalayers 节点CPU 使用率          |
| datalayers_ingest_rows_total               | counter          | Datalayers 写入的行数              |
| datalayers_select_total                    | counter          | Datalayers select 请求次数         |
| parquet_meta_op_total                      | counter          | parquet meta 缓存相关指标          |
| datalayers_flush_queue_limit               | gauge            | Flush 任务队列长度限制               |
| datalayers_flush_concurrence_limit         | gauge            | Flush 并行任务限制                  |
| datalayers_flush_pending_length            | gauge            | Flush pending 中的数量              |
| datalayers_flush_running_length            | gauge            | Flush running 中的数量              |
| datalayers_compact_queue_limit             | gauge            | Compact 任务队列长度限制              |
| datalayers_compact_concurrence_limit       | gauge            | Compact 并行任务限制                 |
| datalayers_compact_pending_length          | gauge            | Compact pending 中的数量            |
| datalayers_compact_running_length          | gauge            | Compact running 中的数量            |
| datalayers_node_rejected_write           | counter          | Datalayers 节点 memtable 的数据量达到阈值后拒绝写入的次数 |
| datalayers_rejected_write                  | counter          | Table 分区 memtable 的数据量达到阈值后拒绝写入的次数 |
| latency_flush_per_10m_milliseconds         | histogram        | Flush 平均生成 10M 数据的延迟         |
| latency_compact_per_10m_milliseconds       | histogram        | Compact 平均生成 10M 数据的延迟       |
| datalayers_panic_total                     | counter          | Datalayers panic 的次数            |
