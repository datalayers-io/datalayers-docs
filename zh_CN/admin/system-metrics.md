# 系监控指标
Datalayers 提供了丰富的指标来帮助用户了解当前服务状态，监测和定位系统的异常。


## 与监控系统集成 ​

Datalayers 指标支持与 Prometheus 集成。使用第三方监控系统对 Datalayers 进行监控有如下好处：

* Datalayers 的监控数据与其他系统的监控数据进行整合，形成一个完整的监控系统，如监控服务器主机的相关信息。
* 使用更加丰富的监控图表，更直观地展示监控数据，如使用 Grafana 的仪表盘，参考[Grafana监控](./system-monitor-grafana.md)。
* 使用更加丰富的告警方式，更及时地发现问题，如使用 Prometheus 的 Alertmanager。

## Datalayers Metrics
| 指标名称                                                        | 备注                         |
| ---------------------------------------------------------------| --------------------------- |
| insert_request_total       |  insert 语句被调用的次数 |
| insert_rows_total       |  数据 insert 的行数(包括所有写入方式，按行统计) |
| schemaless_request_total       |  schemaless 写入请求的次数 |
| schemaless_insert_rows_total       |  schemaless 写入的行数 |
| select_request_total       |  select 语句被调用的次数 |
| memtable_size_bytes       |  当前 memtable 的数据大小 |
| memtable_rows_total       |  当前 memtable 的行数 |
| latency_memtable_sort_milliseconds       |  sort 被调用的时间分布 |
| immutable_size_bytes       |  当前 inmutable 的数据大小 |
| immutable_rows_total       |  当前 inmutable的行数 |
| flush_queue_total       |  flush 队列任务的数量 |
| latency_flush_write_file_milliseconds       |  flush 写文件的耗时 |
| latency_immutable_seconds       |  从 immutable 到 flush 完成的时间 |
| memtable_pk_total       | 内存中的主键数量 |
| memory_usage       |  进程内存使用量 |
| flush_repack_delay       |  flush 过程中，repack 耗时 |
| flush_delay       |  flush 过程中，io 耗时 |
| parquet_meta_cache_hit_total       |  parquet meta cache 命中次数 |
| parquet_meta_cache_miss_total       |  parquet meta cache 未命中次数 |
| object_store_meta_cache_hit_total       |  object_store cache 命中次数 |
| object_store_meta_cache_miss_total       |  object_store cache 未命中次数 |
